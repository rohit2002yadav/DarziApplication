import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ResetPasswordPage extends StatefulWidget {
  final String? email;
  const ResetPasswordPage({super.key, this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final otpController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  // Added state for password visibility and resend OTP loading
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isResending = false;

  Future<void> _handleResetPassword() async {
    if (widget.email == null || widget.email!.isEmpty) {
      _showError("Email not found. Please go back.");
      return;
    }
    if (otpController.text.length != 6) {
      _showError("Please enter the 6-digit OTP.");
      return;
    }
    if (passwordController.text.isEmpty || passwordController.text != confirmPasswordController.text) {
      _showError("Passwords do not match.");
      return;
    }

    setState(() => _isLoading = true);

    final url = Uri.parse('https://darziapplication.onrender.com/api/auth/reset-password');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'otp': otpController.text,
          'password': passwordController.text,
        }),
      );

      final resBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _showSuccess(resBody['message'] ?? "Password reset successfully! Please log in.");
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      } else {
        _showError(resBody['error'] ?? "Failed to reset password.");
      }
    } catch (e) {
      _showError("An error occurred: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- NEW FUNCTION TO RESEND OTP ---
  Future<void> _resendOtp() async {
    if (_isResending) return;
    if (widget.email == null || widget.email!.isEmpty) {
      _showError("Cannot resend OTP: Email not found.");
      return;
    }
    setState(() => _isResending = true);
    final url = Uri.parse('https://darziapplication.onrender.com/api/auth/forgot-password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email}),
      );
      final resBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _showSuccess(resBody['message'] ?? 'A new OTP has been sent.');
      } else {
        _showError(resBody['error'] ?? 'Failed to resend OTP.');
      }
    } catch (e) {
      _showError("An error occurred: $e");
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset Password"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              "An OTP has been sent to ${widget.email ?? 'your email'}.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            _buildTextField(otpController, "Enter 6-Digit OTP", Icons.pin, isOtp: true),
            const SizedBox(height: 16),
            // Updated to include visibility toggle
            _buildTextField(passwordController, "New Password", Icons.lock_outline, isPassword: true, obscureState: !_showPassword, toggleObscure: () => setState(() => _showPassword = !_showPassword)),
            const SizedBox(height: 16),
            _buildTextField(confirmPasswordController, "Confirm New Password", Icons.lock_outline, isPassword: true, obscureState: !_showConfirmPassword, toggleObscure: () => setState(() => _showConfirmPassword = !_showConfirmPassword)),
            const SizedBox(height: 20),
            // Added Resend OTP button
            Align(
              alignment: Alignment.centerRight,
              child: _isResending
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator())
                  : TextButton(
                      onPressed: _resendOtp,
                      child: const Text("Resend OTP"),
                    ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleResetPassword,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Reset Password", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Updated to support password visibility toggle
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false, bool isOtp = false, bool? obscureState, VoidCallback? toggleObscure}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureState ?? false,
      keyboardType: isOtp ? TextInputType.number : TextInputType.text,
      maxLength: isOtp ? 6 : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        counterText: "",
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(obscureState! ? Icons.visibility_off : Icons.visibility),
                onPressed: toggleObscure,
              )
            : null,
      ),
    );
  }
}
