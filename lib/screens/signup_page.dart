import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String? role;
  int step = 0;
  bool _showPassword = false;
  bool _isLoading = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  // Customer fields
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final landmarkController = TextEditingController();
  final pinController = TextEditingController();
  final otherController = TextEditingController();

  // Tailor fields
  final shopNameController = TextEditingController();
  final servicesController = TextEditingController();
  final experienceController = TextEditingController();
  final streetController = TextEditingController();
  final cityTailorController = TextEditingController();
  final stateTailorController = TextEditingController();
  final zipController = TextEditingController();


  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    cityController.dispose();
    stateController.dispose();
    landmarkController.dispose();
    pinController.dispose();
    otherController.dispose();
    shopNameController.dispose();
    servicesController.dispose();
    experienceController.dispose();
    streetController.dispose();
    cityTailorController.dispose();
    stateTailorController.dispose();
    zipController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^[0-9]{10}$').hasMatch(phone);
  }

  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  /// -------------------- Main Action: Send OTP --------------------
  Future<void> _handleRegistration() async {
    // First, run role-specific validation.
    final isCustomerValid = role == 'customer' && _validateCustomerFields();
    final isTailorValid = role == 'tailor' && _validateTailorFields();

    if (!isCustomerValid && !isTailorValid) {
      return; // Validation failed, error already shown.
    }

    setState(() => _isLoading = true);

    final url = Uri.parse('https://darziapplication.onrender.com/api/auth/send-otp');
    
    // Consolidate all user data into a single map
    final Map<String, dynamic> userData = {
      'role': role,
      'name': nameController.text,
      'email': emailController.text,
      'phone': phoneController.text,
      'password': passwordController.text,
      if (role == 'customer') ...{
        'city': cityController.text,
        'state': stateController.text,
        'landmark': landmarkController.text,
        'pin': pinController.text,
        'other': otherController.text,
      } else ...{
        'shopName': shopNameController.text,
        'services': servicesController.text,
        'experience': experienceController.text,
        'street': streetController.text,
        'city': cityTailorController.text,
        'state': stateTailorController.text,
        'zip': zipController.text,
      },
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      final resBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // On success, navigate to the OTP screen, passing the user's email.
        Navigator.pushNamed(context, '/verify-otp', arguments: emailController.text);
      } else {
        _showError(resBody['error'] ?? "Failed to send OTP. Please try again.");
      }
    } catch (e) {
      _showError("Error connecting to server: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// ----------------------------------------------------------------

  bool _validateCustomerFields() {
    if (cityController.text.isEmpty ||
        stateController.text.isEmpty ||
        landmarkController.text.isEmpty ||
        pinController.text.isEmpty) {
      _showError("Please fill all address fields.");
      return false;
    }
    if (pinController.text.length != 6) {
      _showError("Please enter a valid 6-digit PIN code.");
      return false;
    }
    return true;
  }

  bool _validateTailorFields() {
    if (shopNameController.text.isEmpty ||
        servicesController.text.isEmpty ||
        experienceController.text.isEmpty ||
        streetController.text.isEmpty ||
        cityTailorController.text.isEmpty ||
        stateTailorController.text.isEmpty ||
        zipController.text.isEmpty) {
      _showError("Please fill all shop and address details.");
      return false;
    }
    return true;
  }

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
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "Sign Up",
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Please provide the details below to create your account",
                  style: TextStyle(color: Colors.black54, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                if (step == 0) ...[
                  const Text("What are you?",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _roleButton("Customer", "customer"),
                      _roleButton("Tailor", "tailor"),
                    ],
                  ),
                ],
                if (step == 1)
                  Column(
                    children: [
                      _buildField("Full Name", Icons.person, nameController),
                      const SizedBox(height: 20),
                      _nextButton(() {
                        if (nameController.text.trim().isEmpty) {
                          _showError("Please enter your full name");
                        } else {
                          setState(() => step++);
                        }
                      }),
                    ],
                  ),
                if (step == 2)
                  Column(
                    children: [
                      _buildField("Email", Icons.email, emailController),
                      const SizedBox(height: 12),
                      _buildField("Phone", Icons.phone, phoneController,
                          keyboardType: TextInputType.phone),
                      const SizedBox(height: 12),
                      _buildPasswordField("Password", passwordController),
                      const SizedBox(height: 20),
                      _nextButton(() {
                        final email = emailController.text.trim();
                        final phone = phoneController.text.trim();
                        final pass = passwordController.text.trim();

                        if (!_isValidEmail(email)) {
                          _showError("Please enter a valid email address");
                        } else if (!_isValidPhone(phone)) {
                          _showError(
                              "Please enter a valid 10-digit phone number");
                        } else if (!_isValidPassword(pass)) {
                          _showError("Password must be at least 6 characters");
                        } else {
                          setState(() => step++);
                        }
                      }),
                    ],
                  ),
                if (step == 3)
                  role == "customer"
                      ? _buildCustomerAddress()
                      : _buildTailorDetails(),
                const SizedBox(height: 20),
                if (step > 0)
                  TextButton(
                    onPressed: () => setState(() => step--),
                    child: const Text("Back",
                        style: TextStyle(color: Colors.orange)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleButton(String label, String value) {
    bool selected = role == value;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? Colors.orange : Colors.orange.shade100,
        foregroundColor: selected ? Colors.white : Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      onPressed: () {
        setState(() {
          role = value;
          step = 1;
        });
      },
      child: Text(label, style: const TextStyle(fontSize: 18)),
    );
  }

  Widget _buildField(String label, IconData icon, TextEditingController ctrl,
      {TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.orange),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      obscureText: !_showPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock, color: Colors.orange),
        suffixIcon: IconButton(
          icon: Icon(
            _showPassword ? Icons.visibility : Icons.visibility_off,
            color: Colors.orange,
          ),
          onPressed: () {
            setState(() => _showPassword = !_showPassword);
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _nextButton(VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onTap,
        child: const Text("Next",
            style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }

  Widget _buildCustomerAddress() {
    return Column(
      children: [
        _buildField("City", Icons.location_city, cityController),
        const SizedBox(height: 10),
        _buildField("State", Icons.map, stateController),
        const SizedBox(height: 10),
        _buildField("Landmark", Icons.place, landmarkController),
        const SizedBox(height: 10),
        _buildField("PIN Code", Icons.pin, pinController,
            keyboardType: TextInputType.number),
        const SizedBox(height: 10),
        _buildField("Other Details", Icons.note, otherController),
        const SizedBox(height: 20),
        _registerButton(),
      ],
    );
  }

  Widget _buildTailorDetails() {
    return Column(
      children: [
        _buildField("Shop Name", Icons.store, shopNameController),
        const SizedBox(height: 10),
        _buildField(
            "Services Offered", Icons.design_services, servicesController),
        const SizedBox(height: 10),
        _buildField("Experience (years)", Icons.work, experienceController,
            keyboardType: TextInputType.number),
        const SizedBox(height: 10),
        _buildField("Street Address", Icons.home, streetController),
        const SizedBox(height: 10),
        _buildField("City", Icons.location_city, cityTailorController),
        const SizedBox(height: 10),
        _buildField("State", Icons.map, stateTailorController),
        const SizedBox(height: 10),
        _buildField("ZIP Code", Icons.pin_drop, zipController,
            keyboardType: TextInputType.number),
        const SizedBox(height: 20),
        _registerButton(),
      ],
    );
  }

  Widget _registerButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _isLoading ? null : _handleRegistration,
        child: _isLoading 
            ? const CircularProgressIndicator(color: Colors.white) 
            : const Text("Send OTP", style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }
}
