import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isEmailSelected = true;
  bool rememberMe = false;
  bool _isLoading = false;
  bool _showPassword = false;

  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true, String? actionLabel, VoidCallback? onActionPressed}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        action: actionLabel != null
            ? SnackBarAction(label: actionLabel, textColor: Colors.white, onPressed: onActionPressed!)
            : null,
      ),
    );
  }

  Future<void> _resendOtp() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      _showSnackBar("Please enter your email to resend OTP.");
      return;
    }
    setState(() => _isLoading = true);
    try {
      const String apiUrl = "https://darziapplication.onrender.com/api/auth/resend-otp";
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // Null-safe parsing
        _showSnackBar(data["message"] as String? ?? "New OTP sent!", isError: false);
        Navigator.pushNamed(context, '/verify-otp', arguments: email);
      } else {
        // Null-safe parsing
        _showSnackBar(data["error"] as String? ?? "Failed to resend OTP.");
      }
    } catch (e) {
      _showSnackBar("Network Error: $e");
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginUser() async {
    if (_isLoading) return;

    String identifier = isEmailSelected ? emailController.text.trim() : phoneController.text.trim();
    String password = passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      _showSnackBar("Please fill all fields.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      const String apiUrl = "https://darziapplication.onrender.com/api/auth/login";
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          isEmailSelected ? "email" : "phone": identifier,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _showSnackBar("Login successful!", isError: false);
        Navigator.pushReplacementNamed(context, '/home', arguments: data['user']);
      } else if (response.statusCode == 403 && data['needsVerification'] == true) {
        // Null-safe parsing
        _showSnackBar(
            data["error"] as String? ?? "Account not verified.",
            actionLabel: "RESEND OTP",
            onActionPressed: _resendOtp
        );
      } else {
        // Null-safe parsing
        _showSnackBar(data["error"] as String? ?? "Login failed");
      }
    } catch (e) {
      _showSnackBar("Network Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Welcome Back!", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor)),
              const SizedBox(height: 8),
              const Text("Please log in to your account", style: TextStyle(color: Colors.black54, fontSize: 15)),
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(25)),
                child: Row(
                  children: [
                    _buildToggleButton("Email", isEmailSelected, () => setState(() => isEmailSelected = true)),
                    _buildToggleButton("Phone", !isEmailSelected, () => setState(() => isEmailSelected = false)),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              if (isEmailSelected)
                _buildInputField("Enter Your Email", Icons.email_outlined, emailController)
              else
                _buildInputField("Enter Your Phone", Icons.phone, phoneController),
              const SizedBox(height: 15),
              _buildInputField("Enter Your Password", Icons.lock_outline, passwordController, isPassword: true, onSubmitted: (_) => _loginUser()),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(value: rememberMe, activeColor: primaryColor, onChanged: (v) => setState(() => rememberMe = v ?? false)),
                      const Text("Remember me"),
                    ],
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                    child: Text("Forgot Password?", style: TextStyle(color: primaryColor)),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: _isLoading ? null : _loginUser,
                  child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white)) : const Text("Log In", style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/signup'),
                child: Text.rich(
                  TextSpan(
                    text: "Don't have an account? ",
                    style: const TextStyle(color: Colors.black54),
                    children: [TextSpan(text: "Sign Up", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold))],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(String text, bool active, VoidCallback onTap) {
    final Color primaryColor = Theme.of(context).primaryColor;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(color: active ? primaryColor : Colors.transparent, borderRadius: BorderRadius.circular(25)),
          alignment: Alignment.center,
          child: Text(text, style: TextStyle(color: active ? Colors.white : Colors.black, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, IconData icon, TextEditingController controller, {bool isPassword = false, Function(String)? onSubmitted}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? !_showPassword : false,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _showPassword = !_showPassword),
        )
            : null,
      ),
    );
  }
}
