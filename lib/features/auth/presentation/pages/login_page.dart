import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';
import 'otp_verification_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  bool _usePhoneOtp = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    if (_usePhoneOtp) {
      final auth = context.read<AuthProvider>();
      final phone = _phone.text.trim();

      // Only registered active shops can proceed to the OTP screen
      final checkError = await auth.checkShopPhone(phone);
      if (!mounted) return;
      if (checkError != null) {
        SnackbarHelper.error(context, checkError);
        return;
      }

      await auth.sendPhoneOtp(
        phone: phone,
        onCodeSent: (verificationId, resendToken) {
          if (!mounted) return;
          _openOtpScreen(context, auth, verificationId);
        },
        onError: (err) {
          if (!mounted) return;
          SnackbarHelper.error(context, err);
        },
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_email.text, _password.text);
    if (!mounted) return;
    if (ok) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.homeFor(auth.user!),
        (_) => false,
      );
    } else {
      SnackbarHelper.error(context, auth.error ?? 'Login failed');
    }
  }

  void _openOtpScreen(
    BuildContext context,
    AuthProvider auth,
    String? verificationId,
  ) {
    final nav = Navigator.of(context);
    nav
        .push<bool>(
          MaterialPageRoute(
            builder: (_) => OtpVerificationPage(
              phone: _phone.text.trim(),
              verificationId: verificationId,
            ),
          ),
        )
        .then((verified) {
          if (verified == true && mounted && auth.user != null) {
            nav.pushNamedAndRemoveUntil(
              AppRoutes.homeFor(auth.user!),
              (_) => false,
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.select<AuthProvider, bool>((a) => a.isLoading);
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _Background()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, c) {
                final keyboardOpen =
                    MediaQuery.viewInsetsOf(context).bottom > 0;
                final isLandscape = c.maxWidth > c.maxHeight;
                final topLogoPadding = keyboardOpen || isLandscape
                    ? 16.0
                    : (c.maxHeight < 700 ? 32.0 : 64.0);
                final formTopPadding = keyboardOpen || isLandscape
                    ? 12.0
                    : 28.0;
                final horizontalPadding = c.maxWidth > 550
                    ? (c.maxWidth - 440) / 2
                    : 24.0;

                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: c.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: topLogoPadding),
                            child: Center(
                              child: AppLogo(
                                height: (keyboardOpen || isLandscape) ? 36 : 48,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: 24,
                              top: formTopPadding,
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: 'Enter your registered\n',
                                        ),
                                        TextSpan(
                                          text: _usePhoneOtp
                                              ? 'mobile number'
                                              : 'email',
                                          style: const TextStyle(
                                            color: AppColors.accentGreen,
                                          ),
                                        ),
                                        const TextSpan(text: ' to continue'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  if (_usePhoneOtp) ...[
                                    CustomTextField(
                                      controller: _phone,
                                      label: 'Mobile Number',
                                      hint: 'Enter 10-digit mobile number',
                                      keyboardType: TextInputType.phone,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(10),
                                      ],
                                      validator: Validators.phone,
                                    ),
                                  ] else ...[
                                    CustomTextField(
                                      controller: _email,
                                      label: 'Email',
                                      hint: 'Email',
                                      keyboardType: TextInputType.emailAddress,
                                      validator: Validators.email,
                                    ),
                                    const SizedBox(height: 12),
                                    CustomTextField(
                                      controller: _password,
                                      label: 'Password',
                                      hint: 'Password',
                                      isPassword: true,
                                      validator: Validators.password,
                                    ),
                                  ],
                                  const SizedBox(height: 18),
                                  CustomButton(
                                    label: _usePhoneOtp ? 'Send OTP' : 'Login',
                                    isLoading: loading,
                                    onPressed: _submit,
                                  ),
                                  const SizedBox(height: 12),
                                  Center(
                                    child: TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _usePhoneOtp = !_usePhoneOtp;
                                        });
                                      },
                                      child: Text(
                                        _usePhoneOtp
                                            ? 'Or login with Email & Password'
                                            : 'Or login with Mobile OTP',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Background extends StatelessWidget {
  const _Background();
  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/login_bg.png',
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) => const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8EC5F0), Color(0xFF4C8B3F), Color(0xFF2D5A27)],
        ),
      ),
    ),
  );
}
