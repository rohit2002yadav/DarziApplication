import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

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
  String? _tailorType;
  File? _profileImage;
  File? _shopImage;
  
  String? _selectedCustomerCity;
  String? _selectedCustomerState;
  String? _selectedTailorCity;
  String? _selectedTailorState;

  // Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final customerAddressController = TextEditingController();
  final customerLandmarkController = TextEditingController();
  final customerPinController = TextEditingController();
  final shopNameController = TextEditingController();
  final tailorAddressController = TextEditingController();
  final tailorLandmarkController = TextEditingController();
  final tailorZipController = TextEditingController();

  final List<String> indianStates = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
    'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana',
    'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal'
  ];
  final List<String> indianCities = [
    'Mumbai', 'Delhi', 'Bangalore', 'Hyderabad', 'Ahmedabad', 'Chennai', 'Kolkata',
    'Surat', 'Pune', 'Jaipur', 'Lucknow', 'Kanpur', 'Nagpur', 'Indore', 'Thane'
  ];

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    customerAddressController.dispose();
    customerLandmarkController.dispose();
    customerPinController.dispose();
    shopNameController.dispose();
    tailorAddressController.dispose();
    tailorLandmarkController.dispose();
    tailorZipController.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  Future<File?> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    return image != null ? File(image.path) : null;
  }

  Future<void> _handleSendOtp() async {
    setState(() => _isLoading = true);

    final url = Uri.parse('https://darziapplication.onrender.com/api/auth/send-otp');

    final Map<String, dynamic> userData = {
      'role': role,
      'name': nameController.text,
      'email': emailController.text,
      'phone': phoneController.text,
      'password': passwordController.text,
      if (role == 'customer') ...{
        'customerDetails': {
          'address': customerAddressController.text,
          'city': _selectedCustomerCity,
          'state': _selectedCustomerState,
          'landmark': customerLandmarkController.text,
          'pin': customerPinController.text,
        }
      } else ...{
        'tailorDetails': {
          'shopName': shopNameController.text,
          'tailorType': _tailorType,
          'address': tailorAddressController.text,
          'city': _selectedTailorCity,
          'state': _selectedTailorState,
          'landmark': tailorLandmarkController.text,
          'zipCode': tailorZipController.text,
          'profilePictureUrl': '', 
          'shopPictureUrl': '', 
        }
      },
    };

    try {
      final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode(userData));
      final resBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resBody['message'] as String? ?? "OTP has been sent!"), backgroundColor: Colors.green));
        Navigator.of(context).pushNamed('/verify-otp', arguments: emailController.text.trim());
      } else {
        _showError(resBody['error'] as String? ?? "Failed to send OTP.");
      }
    } catch (e) {
      _showError("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: step == 3 && role == 'customer' ? Theme.of(context).primaryColor.withOpacity(0.05) : Colors.white,
      appBar: step > 0 ? AppBar(elevation: 0, backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.black)) : null,
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (step > 0 && step != 3) const SizedBox(height: 20),
              if (step == 0) _buildRoleSelection(),
              if (step == 1) _buildInitialDetails(),
              if (step == 2) _buildAuthDetails(),
              if (step == 3 && role == 'customer') _buildCustomerAddress(),
              if (step == 3 && role == 'tailor') _buildTailorDetails(),
              if (step == 4 && role == 'tailor') _buildTailorAddress(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildRoleSelection() {
    return Column(
      children: [
        Image.asset(
          'assets/images/signup.jpg', 
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const SizedBox(height: 200),
        ),
        const SizedBox(height: 20),
        const Text("Sign Up", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        const Text("Please provide the details below to create your account", style: TextStyle(color: Colors.black54, fontSize: 15), textAlign: TextAlign.center),
        const SizedBox(height: 40),
        const Text("What are you?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [_roleButton("Customer", "customer"), _roleButton("Tailor", "tailor")],
        ),
      ],
    );
  }

  // --- RESTORED WIDGETS ---
  Widget _buildInitialDetails() {
    return Column(
      children: [
        const Text("Enter your details", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        _buildField("Enter Your Full Name", Icons.person, nameController),
        const SizedBox(height: 20),
        _nextButton("Continue", () {
          if (nameController.text.trim().isEmpty) {
            _showError("Please enter your full name");
          } else {
            setState(() => step++);
          }
        }),
      ],
    );
  }

  Widget _buildAuthDetails() {
    return Column(
      children: [
        const Text("Enter your details", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        _buildField("Email", Icons.email, emailController),
        const SizedBox(height: 12),
        _buildField("Phone", Icons.phone, phoneController, keyboardType: TextInputType.phone),
        const SizedBox(height: 12),
        _buildPasswordField("Password", passwordController),
        const SizedBox(height: 20),
        _nextButton("Continue", () {
          if (emailController.text.isEmpty || !emailController.text.contains('@')) {
            _showError("Please enter a valid email address");
          } else if (phoneController.text.length < 10) {
            _showError("Please enter a valid 10-digit phone number");
          } else if (passwordController.text.length < 6) {
            _showError("Password must be at least 6 characters");
          } else {
            setState(() => step++);
          }
        }),
      ],
    );
  }

  Widget _buildTailorDetails() {
    final Color primaryColor = Theme.of(context).primaryColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Enter your details", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        const Text("Upload Profile Picture", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFFE0E0E0),
                backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null ? const Icon(Icons.camera_alt, color: Colors.grey, size: 40) : null,
              ),
              Positioned(bottom: 0, right: 0, child: CircleAvatar(radius: 18, backgroundColor: primaryColor, child: IconButton(icon: const Icon(Icons.edit, color: Colors.white, size: 18), onPressed: () async {
                final image = await _pickImage();
                if (image != null) setState(() => _profileImage = image);
              }))),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildField("Enter Your Shop Name", null, shopNameController, hint: "Enter Your Shop Name"),
        const SizedBox(height: 20),
        const Text("Upload Shop Picture (Optional)", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () async {
            final image = await _pickImage();
            if (image != null) setState(() => _shopImage = image);
          },
          child: Container(
            height: 100, 
            width: 100, 
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              image: _shopImage != null ? DecorationImage(image: FileImage(_shopImage!), fit: BoxFit.cover) : null,
            ),
            child: _shopImage == null ? const Center(child: Icon(Icons.image, color: Colors.grey, size: 40)) : null,
          ),
        ),
        const SizedBox(height: 20),
        const Text("Type of tailor", style: TextStyle(fontWeight: FontWeight.w600)),
        _buildTailorTypeOption("Mens Tailor", "mens"),
        _buildTailorTypeOption("Ladies Tailor", "ladies"),
        _buildTailorTypeOption("Both", "both"),
        const SizedBox(height: 30),
        _nextButton("Continue", () {
          if (shopNameController.text.isEmpty || _tailorType == null) {
             _showError("Please fill all required details.");
          } else {
            setState(() => step++);
          }
        }),
      ],
    );
  }

  Widget _buildTailorAddress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Enter Your Shop Address", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildField("Address", Icons.home, tailorAddressController),
        const SizedBox(height: 12),
        _buildDropdown('Select City', _selectedTailorCity, indianCities, (val) => setState(() => _selectedTailorCity = val), icon: Icons.location_city),
        const SizedBox(height: 12),
        _buildDropdown('Select State', _selectedTailorState, indianStates, (val) => setState(() => _selectedTailorState = val), icon: Icons.map),
        const SizedBox(height: 12),
        _buildField("Landmark", Icons.place, tailorLandmarkController),
        const SizedBox(height: 12),
        _buildField("Zip Code", Icons.pin_drop, tailorZipController, keyboardType: TextInputType.number, maxLength: 6),
        const SizedBox(height: 30),
        _nextButton("Send OTP", _handleSendOtp, isLoading: _isLoading),
      ],
    );
  }

  // --- THIS WIDGET IS NOW REDESIGNED ---
  Widget _buildCustomerAddress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Enter Your Address", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        _buildField("Address", Icons.home_work_outlined, customerAddressController),
        const SizedBox(height: 16),
        _buildDropdown('City', _selectedCustomerCity, indianCities, (val) => setState(() => _selectedCustomerCity = val), icon: Icons.location_city_outlined),
        const SizedBox(height: 16),
        _buildDropdown('State', _selectedCustomerState, indianStates, (val) => setState(() => _selectedCustomerState = val), icon: Icons.map_outlined),
        const SizedBox(height: 16),
        _buildField("Landmark", Icons.place_outlined, customerLandmarkController),
        const SizedBox(height: 16),
        _buildField("Pin Code", Icons.pin_drop_outlined, customerPinController, keyboardType: TextInputType.number, maxLength: 6),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSendOtp,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Theme.of(context).primaryColor),
            child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                : const Text("Send OTP", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String hint, String? value, List<String> items, ValueChanged<String?> onChanged, {required IconData icon}) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2)),
      ),
      isExpanded: true,
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTailorTypeOption(String title, String value) {
    return RadioListTile<String>(
      title: Text(title),
      value: value,
      groupValue: _tailorType,
      onChanged: (val) => setState(() => _tailorType = val),
      activeColor: Theme.of(context).primaryColor,
    );
  }

  Widget _roleButton(String label, String value) {
    final Color primaryColor = Theme.of(context).primaryColor;
    bool selected = role == value;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? primaryColor : primaryColor.withOpacity(0.1),
        foregroundColor: selected ? Colors.white : primaryColor,
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

  Widget _buildField(String label, IconData? icon, TextEditingController ctrl, {TextInputType? keyboardType, int? maxLength, String? hint}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, color: Theme.of(context).primaryColor) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        filled: true,
        fillColor: Colors.white,
        counterText: "",
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController ctrl) {
    return TextFormField(
      controller: ctrl,
      obscureText: !_showPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _showPassword = !_showPassword),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _nextButton(String text, VoidCallback onTap, {bool isLoading = false}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            backgroundColor: Theme.of(context).primaryColor
        ),
        onPressed: isLoading ? null : onTap,
        child: isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
            : Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
