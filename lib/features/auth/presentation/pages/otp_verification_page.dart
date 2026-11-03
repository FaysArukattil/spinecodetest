import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../providers/auth_provider.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phone;
  final String? verificationId;
  const OtpVerificationPage({
    super.key,
    required this.phone,
    this.verificationId,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _resendCountdown = 60;
  Timer? _timer;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    for (int i = 0; i < 6; i++) {
      final index = i;
      _focusNodes[index].addListener(() {
        if (mounted) setState(() {});
      });
      _focusNodes[index].onKeyEvent = (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            _controllers[index].text.isEmpty &&
            index > 0) {
          _focusNodes[index - 1].requestFocus();
          _controllers[index - 1].clear();
          setState(() {});
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      };
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendCountdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown > 1) {
        setState(() => _resendCountdown--);
      } else {
        t.cancel();
        setState(() => _resendCountdown = 0);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    final code = _otp;
    if (code.length < 6) {
      SnackbarHelper.error(context, 'Please enter all 6 digits of the code.');
      return;
    }
    setState(() => _isVerifying = true);

    if (widget.verificationId != null && widget.verificationId!.isNotEmpty) {
      final auth = context.read<AuthProvider>();
      final ok = await auth.verifyOtpAndLogin(
        verificationId: widget.verificationId!,
        smsCode: code,
      );
      if (!mounted) return;
      setState(() => _isVerifying = false);
      if (ok) {
        SnackbarHelper.success(context, 'Signed in successfully via phone verification!');
        Navigator.pop(context, true);
      } else {
        SnackbarHelper.error(context, auth.error ?? 'Invalid verification code.');
      }
      return;
    }

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isVerifying = false);

    SnackbarHelper.success(context, 'Mobile number verified successfully!');
    Navigator.pop(context, true);
  }

  void _resendCode() {
    if (_resendCountdown > 0) return;
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
    _startTimer();
    SnackbarHelper.success(context, 'A new verification code has been sent.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2B2726)),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final isCompactHeight = constraints.maxHeight < 560;

            // Responsive circle sizing: prominent, high-contrast circular outline
            final double circleSize = ((availableWidth - 80) / 6).clamp(44.0, 50.0);
            final double circleSpacing =
                ((availableWidth - (circleSize * 6) - 48) / 5).clamp(4.0, 8.0);

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: availableWidth > 500 ? (availableWidth - 400) / 2 : 24,
                vertical: isCompactHeight ? 8 : 16,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - (isCompactHeight ? 16 : 32),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: isCompactHeight ? 12 : 24),

                    // Title matching Figma
                    const Text(
                      'OTP Verification',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E1E1E),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Subtitle matching Figma
                    const Text(
                      'Enter 6 digit verification\ncode sent to your mobile number',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF4A4A4A),
                        height: 1.4,
                      ),
                    ),

                    if (widget.verificationId == null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Text(
                          'Test Mode: Enter code 123456',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],

                    SizedBox(height: isCompactHeight ? 24 : 36),

                    // 6 Circular OTP input circles matching Figma with bold, crisp borders
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        6,
                        (i) => Padding(
                          padding: EdgeInsets.symmetric(horizontal: circleSpacing),
                          child: _circlePinBox(i, circleSize),
                        ),
                      ),
                    ),

                    SizedBox(height: isCompactHeight ? 24 : 36),

                    // Verify Button matching Figma: dark charcoal, rounded edges
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2B2726),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        onPressed: _isVerifying ? null : _verify,
                        child: _isVerifying
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.2,
                                ),
                              )
                            : const Text(
                                'Verify',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Resend text matching Figma: "Didn't receive resend in 60 sec"
                    GestureDetector(
                      onTap: _resendCountdown == 0 ? _resendCode : null,
                      child: Text(
                        _resendCountdown > 0
                            ? "Didn't receive resend in $_resendCountdown sec"
                            : "Didn't receive? Resend OTP",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: _resendCountdown == 0
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: _resendCountdown == 0
                              ? const Color(0xFF2B2726)
                              : const Color(0xFF333333),
                          decoration: _resendCountdown == 0
                              ? TextDecoration.underline
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _circlePinBox(int index, double size) {
    final hasFocus = _focusNodes[index].hasFocus;

    return GestureDetector(
      onTap: () => _focusNodes[index].requestFocus(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(
            color: hasFocus ? const Color(0xFF2B2726) : const Color(0xFF1E1E1E),
            width: hasFocus ? 2.4 : 1.8,
          ),
          boxShadow: hasFocus
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Center(
          child: SizedBox(
            width: size - 6,
            height: size - 6,
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              showCursor: false,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E1E1E),
                height: 1.0,
              ),
              maxLength: 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.zero,
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              onChanged: (val) {
                setState(() {});
                if (val.length > 1) {
                  final digits = val.replaceAll(RegExp(r'\D'), '');
                  for (int k = 0; k < digits.length && (index + k) < 6; k++) {
                    _controllers[index + k].text = digits[k];
                  }
                  final next = (index + digits.length).clamp(0, 5);
                  _focusNodes[next].requestFocus();
                  setState(() {});
                  if (_otp.length == 6) _verify();
                  return;
                }
                if (val.isNotEmpty && index < 5) {
                  _focusNodes[index + 1].requestFocus();
                } else if (val.isEmpty && index > 0) {
                  _focusNodes[index - 1].requestFocus();
                }
                if (_otp.length == 6) {
                  _verify();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
