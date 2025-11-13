import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/globals.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isEmailSelected = true;
  bool rememberMe = false;
  bool _isLoading = false;
  bool _showPassword = false; // Added for password visibility

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

  /// ---------------------------- LOGIN FUNCTION ----------------------------
  Future<void> _loginUser() async {
    String? inputIdentifier =
    isEmailSelected ? emailController.text.trim() : phoneController.text.trim();
    String password = passwordController.text.trim();

    if (inputIdentifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 🔗 Use your backend API URL
      const String apiUrl = "https://darziapplication.onrender.com/api/auth/login";
      // 👆 10.0.2.2 works for Android Emulator (replace with your local IP for real devices)

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          isEmailSelected ? "email" : "phone": inputIdentifier,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // ✅ Successful login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "Login successful!"),
            backgroundColor: Colors.green,
          ),
        );

        // Optional: Save token for future sessions
        // final prefs = await SharedPreferences.getInstance();
        // await prefs.setString('token', data["token"]);

        // Navigate to home screen
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // ❌ Invalid credentials or server response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "Login failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // 🔥 Handle network errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: \$e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// ------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE0B2), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "Login",
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Please provide the details below to log in",
                  style: TextStyle(color: Colors.black54, fontSize: 15),
                ),
                const SizedBox(height: 30),

                // Email / Phone toggle
                Container(
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      _buildToggleButton("Email", isEmailSelected, () {
                        setState(() => isEmailSelected = true);
                      }),
                      _buildToggleButton("Phone", !isEmailSelected, () {
                        setState(() => isEmailSelected = false);
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                if (isEmailSelected)
                  _buildInputField(
                      "Enter Your Email", Icons.email_outlined, emailController)
                else
                  _buildInputField(
                      "Enter Your Phone", Icons.phone, phoneController),
                const SizedBox(height: 15),
                _buildInputField(
                    "Enter Your Password", Icons.lock_outline, passwordController,
                    isPassword: true),

                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: rememberMe,
                          activeColor: Colors.orange,
                          onChanged: (v) {
                            setState(() => rememberMe = v ?? false);
                          },
                        ),
                        const Text("Remember me"),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgot-password');
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: _isLoading ? null : _loginUser,
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
                      "Log In",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 25),
                Row(
                  children: const [
                    Expanded(child: Divider(thickness: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text("Or Continue With",
                          style: TextStyle(color: Colors.black54)),
                    ),
                    Expanded(child: Divider(thickness: 1)),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _socialButton("Google", Icons.g_mobiledata),
                    _socialButton("Apple", Icons.apple),
                  ],
                ),
                const SizedBox(height: 25),

                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/signup'),
                  child: const Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(color: Colors.black54),
                      children: [
                        TextSpan(
                          text: "Sign Up",
                          style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold),
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
    );
  }

  Widget _buildToggleButton(String text, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: active ? Colors.orange : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
                color: active ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, IconData icon,
      TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? !_showPassword : false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.orange),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            _showPassword ? Icons.visibility : Icons.visibility_off,
            color: Colors.orange,
          ),
          onPressed: () {
            setState(() => _showPassword = !_showPassword);
          },
        )
            : null,
      ),
    );
  }

  static Widget _socialButton(String label, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text("\$label login not yet implemented."),
            backgroundColor: Colors.blueAccent,
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.black12),
        ),
      ),
      icon: Icon(icon, size: 26, color: Colors.black),
      label: Text(label, style: const TextStyle(fontSize: 16)),
    );
  }
}
