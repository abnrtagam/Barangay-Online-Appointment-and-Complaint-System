import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants/app_colors.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();

  void _handleVerify() async {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter the code')));
      return;
    }

    final result = await context.read<AuthProvider>().verifyOtp(
      email: widget.email,
      otpCode: _otpController.text,
    );

    if (mounted) {
      if (result['success']) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Email Verified'),
            content: Text(result['message'] ?? 'Your email has been verified successfully. Your account is now pending admin approval.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to login
                },
                child: const Text('BACK TO LOGIN'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Verification failed'), backgroundColor: AppColors.danger));
      }
    }
  }

  void _handleResend() async {
    final result = await context.read<AuthProvider>().resendOtp(email: widget.email);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? AppColors.success : AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(title: const Text('VERIFY EMAIL')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.mark_email_read_outlined, size: 64, color: AppColors.primary600),
            const SizedBox(height: 24),
            const Text(
              'Enter Verification Code',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary900, fontFamily: 'Plus Jakarta Sans'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'We sent a 6-digit code to ${widget.email}. Please enter it below to verify your account.',
              style: const TextStyle(fontSize: 14, color: AppColors.gray500, fontFamily: 'DM Sans', height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            _inputLabel('6-DIGIT OTP CODE'),
            TextField(
              controller: _otpController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: 8),
              decoration: const InputDecoration(hintText: '000000', hintStyle: TextStyle(letterSpacing: 8, color: AppColors.gray200)),
              maxLength: 6,
            ),
            const SizedBox(height: 32),

            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return ElevatedButton(
                  onPressed: auth.isLoading ? null : _handleVerify,
                  child: auth.isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('VERIFY ACCOUNT'),
                );
              },
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Didn't receive the code?", style: TextStyle(color: AppColors.gray600)),
                TextButton(
                  onPressed: _handleResend,
                  child: const Text('Resend Code', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.gray700, letterSpacing: 1)),
    );
  }
}
