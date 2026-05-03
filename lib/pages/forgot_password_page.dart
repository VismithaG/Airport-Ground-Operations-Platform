import 'package:flutter/material.dart';
import 'dart:math';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  int _step = 1;

  // Controllers
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State
  String _generatedOtp = '';
  bool _isLoading = false;
  String _errorMessage = '';

  // 1: Email Input
  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Reset Password",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7F1D1D),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Enter your work email address and we'll send you an OTP to verify your account.",
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: "Email Address",
            prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        if (_errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_emailController.text.isEmpty ||
                  !_emailController.text.contains('@')) {
                setState(
                  () => _errorMessage = "Please enter a valid work email.",
                );
                return;
              }
              setState(() {
                _errorMessage = '';
                _isLoading = true;
              });

              // Simulate network delay & OTP Generation
              Future.delayed(const Duration(seconds: 1), () {
                if (!mounted) return;

                final random = Random();
                const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
                _generatedOtp = List.generate(
                  6,
                  (index) => chars[random.nextInt(chars.length)],
                ).join();

                setState(() {
                  _isLoading = false;
                  _step = 2;
                });

                // Simulate Email Sending via SnackBar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '📧 SIMULATED EMAIL: Your OTP is $_generatedOtp',
                    ),
                    backgroundColor: Colors.blue.shade800,
                    duration: const Duration(seconds: 10),
                  ),
                );
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "Send OTP Code",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  // 2: OTP Input
  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Verify Account",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7F1D1D),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "We've sent a 6-character OTP to ${_emailController.text}.",
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _otpController,
          decoration: InputDecoration(
            labelText: "OTP Code",
            helperText: "Format: 6 Alphanumeric Characters",
            prefixIcon: const Icon(Icons.password, color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(8),
            ),
            counterText: "",
          ),
          maxLength: 6,
          textCapitalization: TextCapitalization.characters,
        ),
        if (_errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_otpController.text.toUpperCase() != _generatedOtp) {
                setState(
                  () => _errorMessage = "Invalid OTP code. Please try again.",
                );
                return;
              }
              setState(() {
                _errorMessage = '';
                _step = 3;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Verify OTP",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // 3: New Password Input
  Widget _buildNewPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Create New Password",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7F1D1D),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Your new password must be at least 8 characters long, and contain at least one letter, one number, and one uppercase letter.",
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _newPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: "New Password",
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: "Confirm Password",
            prefixIcon: const Icon(Icons.lock_reset, color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        if (_errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              final password = _newPasswordController.text;

              if (password.length < 8) {
                setState(
                  () =>
                      _errorMessage = "Password must be at least 8 characters.",
                );
                return;
              }
              if (!RegExp(r'\d').hasMatch(password)) {
                setState(
                  () => _errorMessage =
                      "Password must contain at least one number.",
                );
                return;
              }
              if (!RegExp(r'[a-zA-Z]').hasMatch(password)) {
                setState(
                  () => _errorMessage =
                      "Password must contain at least one letter.",
                );
                return;
              }
              if (!RegExp(r'[A-Z]').hasMatch(password)) {
                setState(
                  () => _errorMessage =
                      "Password must contain at least one uppercase letter.",
                );
                return;
              }
              if (password != _confirmPasswordController.text) {
                setState(() => _errorMessage = "Passwords do not match.");
                return;
              }

              setState(() {
                _errorMessage = '';
                _isLoading = true;
              });

              // Simulate connecting new password to account
              Future.delayed(const Duration(seconds: 2), () {
                if (!mounted) return;
                setState(() {
                  _isLoading = false;
                  _step = 4;
                });
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "Save New Password",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  // 4: Success Input
  Widget _buildSuccessStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 64),
        const SizedBox(height: 24),
        const Text(
          "Password Updated!",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Your password has been successfully saved. You can now sign in with your new credentials.",
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Back to Login",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF9FAFB), Color(0xFFFFE5E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: () {
                    switch (_step) {
                      case 1:
                        return _buildEmailStep();
                      case 2:
                        return _buildOtpStep();
                      case 3:
                        return _buildNewPasswordStep();
                      case 4:
                        return _buildSuccessStep();
                      default:
                        return const SizedBox.shrink();
                    }
                  }(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
