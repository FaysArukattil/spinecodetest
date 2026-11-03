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
      final verified = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationPage(phone: _phone.text.trim()),
        ),
      );
      if (verified == true && mounted) {
        // Auto sign in as store demo or prompt email
        SnackbarHelper.success(context, 'Signed in via mobile verification');
      }
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

  @override
  Widget build(BuildContext context) {
    final loading = context.select<AuthProvider, bool>((a) => a.isLoading);
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _Background()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, c) => SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: c.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 80),
                        child: Center(child: AppLogo()),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32, top: 40),
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
                                    const TextSpan(text: 'Enter your registered\n'),
                                    TextSpan(
                                      text: _usePhoneOtp ? 'mobile number' : 'email',
                                      style: const TextStyle(
                                        color: AppColors.accentGreen,
                                      ),
                                    ),
                                    const TextSpan(text: ' to continue'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
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
                                const SizedBox(height: 14),
                                CustomTextField(
                                  controller: _password,
                                  label: 'Password',
                                  hint: 'Password',
                                  isPassword: true,
                                  validator: Validators.password,
                                ),
                              ],
                              const SizedBox(height: 20),
                              CustomButton(
                                label: _usePhoneOtp ? 'Send OTP' : 'Login',
                                isLoading: loading,
                                onPressed: _submit,
                              ),
                              const SizedBox(height: 14),
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
                                        : 'Or login with Mobile OTP (Figma)',
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
