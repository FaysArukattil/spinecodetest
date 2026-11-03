import os
import struct
import subprocess
import zlib

def main():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    logo_path = os.path.join(root, 'assets', 'images', 'logo.png')
    tmp_logo = '/tmp/scaled_logo_640.png'
    master_icon_path = os.path.join(root, 'assets', 'images', 'app_icon.png')

    # 1. Scale logo to 640 width with Lanczos filter using sips
    subprocess.run(['/usr/bin/sips', '--resampleWidth', '640', logo_path, '--out', tmp_logo], check=True)

    # 2. Decode scaled logo PNG scanlines
    with open(tmp_logo, 'rb') as f:
        data = f.read()

    w, h = struct.unpack('>II', data[16:24])
    pos = 8
    idat = b''
    while pos < len(data):
        length, chunk_type = struct.unpack('>I4s', data[pos:pos+8])
        if chunk_type == b'IDAT':
            idat += data[pos+8:pos+8+length]
        pos += 12 + length
    raw = zlib.decompress(idat)

    bpp = 4
    stride = 1 + w * bpp
    prev_row = bytearray(w * bpp)
    l_pixels = bytearray(w * h * bpp)
    for y in range(h):
        line = raw[y*stride:(y+1)*stride]
        filter_type = line[0]
        row = bytearray(line[1:])
        if filter_type == 1:
            for x in range(bpp, len(row)): row[x] = (row[x] + row[x-bpp]) & 0xFF
        elif filter_type == 2:
            for x in range(len(row)): row[x] = (row[x] + prev_row[x]) & 0xFF
        elif filter_type == 3:
            for x in range(len(row)):
                left = row[x-bpp] if x >= bpp else 0
                row[x] = (row[x] + (left + prev_row[x])//2) & 0xFF
        elif filter_type == 4:
            for x in range(len(row)):
                a = row[x-bpp] if x >= bpp else 0
                b = prev_row[x]
                c = prev_row[x-bpp] if x >= bpp else 0
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                pr = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                row[x] = (row[x] + pr) & 0xFF
        l_pixels[y*w*bpp:(y+1)*w*bpp] = row
        prev_row = row

    # 3. Create 1024x1024 canvas with pure white RGB background
    cw, ch = 1024, 1024
    canvas = bytearray([255] * (cw * ch * 3))

    ox = (cw - w) // 2
    oy = (ch - h) // 2

    for ly in range(h):
        cy = oy + ly
        for lx in range(w):
            cx = ox + lx
            l_idx = (ly * w + lx) * 4
            lr, lg, lb, la = l_pixels[l_idx:l_idx+4]
            if la > 0:
                c_idx = (cy * cw + cx) * 3
                # Alpha blend over 255 (white)
                canvas[c_idx] = (lr * la + 255 * (255 - la)) // 255
                canvas[c_idx+1] = (lg * la + 255 * (255 - la)) // 255
                canvas[c_idx+2] = (lb * la + 255 * (255 - la)) // 255

    # 4. Save master 1024x1024 RGB PNG
    def chunk(tag, chunk_data):
        return struct.pack('>I', len(chunk_data)) + tag + chunk_data + struct.pack('>I', zlib.crc32(tag + chunk_data) & 0xffffffff)

    header = b'\x89PNG\r\n\x1a\n'
    ihdr = chunk(b'IHDR', struct.pack('>IIBBBBB', cw, ch, 8, 2, 0, 0, 0))
    raw_scanlines = bytearray()
    for y in range(ch):
        raw_scanlines.append(0)
        raw_scanlines.extend(canvas[y * cw * 3 : (y + 1) * cw * 3])
    idat = chunk(b'IDAT', zlib.compress(bytes(raw_scanlines), 6))
    iend = chunk(b'IEND', b'')

    with open(master_icon_path, 'wb') as f:
        f.write(header + ihdr + idat + iend)
    print(f'Saved master icon to: {master_icon_path}')

    # 5. Export all icon targets using sips
    targets = [
        # Android launcher icons
        ('android/app/src/main/res/mipmap-mdpi/ic_launcher.png', 48, 48),
        ('android/app/src/main/res/mipmap-hdpi/ic_launcher.png', 72, 72),
        ('android/app/src/main/res/mipmap-xhdpi/ic_launcher.png', 96, 96),
        ('android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png', 144, 144),
        ('android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png', 192, 192),

        # Android round launcher icons
        ('android/app/src/main/res/mipmap-mdpi/ic_launcher_round.png', 48, 48),
        ('android/app/src/main/res/mipmap-hdpi/ic_launcher_round.png', 72, 72),
        ('android/app/src/main/res/mipmap-xhdpi/ic_launcher_round.png', 96, 96),
        ('android/app/src/main/res/mipmap-xxhdpi/ic_launcher_round.png', 144, 144),
        ('android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_round.png', 192, 192),

        # iOS icons
        ('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png', 1024, 1024),
        ('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png', 20, 20),
        ('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png', 40, 40),
        ('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png', 60, 60),
        ('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png', 29, 29),
        ('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png', 58, 58),
        ('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png', 87, 87),
        ('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png', 40, 40),
        ('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png', 80, 80),
        ('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png', 120, 120),
        ('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png', 120, 120),
        ('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png', 180, 180),
        ('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png', 76, 76),
        ('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png', 152, 152),
        ('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png', 167, 167),

        # Web & PWA icons
        ('web/favicon.png', 32, 32),
        ('web/icons/Icon-192.png', 192, 192),
        ('web/icons/Icon-512.png', 512, 512),
        ('web/icons/Icon-maskable-192.png', 192, 192),
        ('web/icons/Icon-maskable-512.png', 512, 512),
    ]

    for rel_path, th, tw in targets:
        full_path = os.path.join(root, rel_path)
        os.makedirs(os.path.dirname(full_path), exist_ok=True)
        subprocess.run(['/usr/bin/sips', '-z', str(th), str(tw), master_icon_path, '--out', full_path], check=True)
        print(f'Generated: {rel_path} ({tw}x{th})')

    if os.path.exists(tmp_logo):
        os.remove(tmp_logo)

    print('All app icons generated successfully!')

if __name__ == '__main__':
    main()
