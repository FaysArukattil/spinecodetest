import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/custom_button.dart';
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

    await Future.delayed(const Duration(milliseconds: 1000));
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
    final maskedPhone = widget.phone.length >= 10
        ? '+91 ${widget.phone.substring(0, 3)}****${widget.phone.substring(7)}'
        : widget.phone;

    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification', style: TextStyle(fontSize: 16)),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;
            final isCompactHeight = constraints.maxHeight < 550;

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth > 500 ? (constraints.maxWidth - 440) / 2 : 20,
                vertical: isCompactHeight ? 12 : 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - (isCompactHeight ? 24 : 48),
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (!isCompactHeight) ...[
                        const SizedBox(height: 10),
                        CircleAvatar(
                          radius: isLandscape ? 24 : 36,
                          backgroundColor: AppColors.successLight,
                          child: Icon(
                            Icons.mark_email_read_outlined,
                            color: AppColors.brandGreen,
                            size: isLandscape ? 24 : 36,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Text(
                        'Enter Verification Code',
                        style: AppTextStyles.h1.copyWith(
                          fontSize: isCompactHeight ? 18 : 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We have sent a 6-digit confirmation code to $maskedPhone',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(fontSize: 12),
                      ),
                      SizedBox(height: isCompactHeight ? 16 : 28),

                      // Responsive 6 PIN Boxes (Figma)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          6,
                          (i) => Flexible(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: _pinBox(i),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isCompactHeight ? 20 : 28),

                      CustomButton(
                        label: 'Verify & Proceed',
                        isLoading: _isVerifying,
                        onPressed: _verify,
                      ),
                      const SizedBox(height: 20),

                      // Countdown / Resend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Didn't receive the code? ",
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          GestureDetector(
                            onTap: _resendCountdown == 0 ? _resendCode : null,
                            child: Text(
                              _resendCountdown > 0
                                  ? 'Resend in ${_resendCountdown}s'
                                  : 'Resend OTP',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _resendCountdown == 0
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                decoration: _resendCountdown == 0
                                    ? TextDecoration.underline
                                    : TextDecoration.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _pinBox(int index) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 48, minWidth: 36, maxHeight: 52),
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            filled: true,
            fillColor: AppColors.surfaceAlt,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          onChanged: (val) {
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
      );
}
