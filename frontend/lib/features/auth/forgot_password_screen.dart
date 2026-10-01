import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/inputs.dart';
import 'auth_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final auth = context.read<AuthController>();
      await auth.resetPassword(_emailController.text.trim());
      setState(() {
        _isSuccess = true;
        _message = 'Reset link sent! Please check your email.';
      });
    } on AuthException catch (e) {
      setState(() {
        _isSuccess = false;
        _message = e.message;
      });
    } catch (e) {
      setState(() {
        _isSuccess = false;
        _message = 'Unable to connect. Please check your internet connection.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.lock_reset, size: 48, color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Forgot Password',
                    style: AppTypography.textTheme.headlineLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your email address and we\'ll send you a password reset link.',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  if (_message != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isSuccess ? AppColors.successBackground : AppColors.errorBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isSuccess ? AppColors.success.withOpacity(0.3) : AppColors.error.withOpacity(0.3)
                        ),
                      ),
                      child: Text(
                        _message!,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: _isSuccess ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (!_isSuccess) ...[
                    AppTextField(
                      label: 'Email',
                      hint: 'owner@ahsantyre.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: (val) => val == null || val.isEmpty ? 'Email is required' : null,
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      text: 'Send Reset Link',
                      isLoading: _isLoading,
                      onPressed: _handleReset,
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Back to Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
