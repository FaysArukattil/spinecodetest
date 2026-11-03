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
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  int _resendCountdown = 60;
  Timer? _timer;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _focusNode.addListener(() {
      if (mounted) setState(() {});
    });
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
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _otpController.text.trim();
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

    final auth = context.read<AuthProvider>();
    final ok = await auth.loginWithDemoPhone(widget.phone);
    if (!mounted) return;
    setState(() => _isVerifying = false);
    if (ok) {
      SnackbarHelper.success(context, 'Mobile number verified successfully!');
      Navigator.pop(context, true);
    } else {
      SnackbarHelper.error(
        context,
        auth.error ?? 'This phone number is not registered with any shop.',
      );
    }
  }

  void _resendCode() {
    if (_resendCountdown > 0) return;
    _otpController.clear();
    _focusNode.requestFocus();
    _startTimer();
    setState(() {});
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

            // Compute exact circle size and gap so the 6 circles never overflow
            // Total width needed: 6 * circleSize + 5 * gap
            final double circleSize =
                ((availableWidth - 48 - 40) / 6).clamp(42.0, 48.0);
            final double gap =
                ((availableWidth - 48 - (circleSize * 6)) / 5).clamp(4.0, 10.0);

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: availableWidth > 500 ? (availableWidth - 380) / 2 : 20,
                vertical: isCompactHeight ? 8 : 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: isCompactHeight ? 8 : 20),

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
                  const SizedBox(height: 8),

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
                    const SizedBox(height: 10),
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

                  SizedBox(height: isCompactHeight ? 20 : 32),

                  // 6 Pristine Circles with invisible overlay input
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Row of 6 perfect vector circles (no rectangular children, no cutouts)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (int i = 0; i < 6; i++) ...[
                              if (i > 0) SizedBox(width: gap),
                              _buildPinCircle(i, circleSize),
                            ],
                          ],
                        ),

                        // Invisible text field overlay handling all touch, keyboard, and paste
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.0,
                            child: TextField(
                              controller: _otpController,
                              focusNode: _focusNode,
                              keyboardType: TextInputType.number,
                              autofocus: true,
                              showCursor: false,
                              enableInteractiveSelection: false,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (val) {
                                setState(() {});
                                if (val.length == 6) {
                                  _verify();
                                }
                              },
                            ),
                          ),
                        ),
                      ],
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

                  const SizedBox(height: 20),

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

                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPinCircle(int index, double size) {
    final text = _otpController.text;
    final hasValue = index < text.length;
    final digit = hasValue ? text[index] : '';

    // Active circle indicator: next empty box, or the 6th box if filled
    final isCurrent = _focusNode.hasFocus &&
        (index == text.length || (index == 5 && text.length == 6));

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: isCurrent
              ? const Color(0xFF2B2726)
              : (hasValue ? const Color(0xFF1E1E1E) : const Color(0xFF2E2E2E)),
          width: isCurrent ? 2.2 : 1.8,
        ),
        boxShadow: isCurrent
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
      child: Text(
        digit,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E1E1E),
          height: 1.0,
        ),
      ),
    );
  }
}
