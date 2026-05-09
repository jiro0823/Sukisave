import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sukisave/core/services/auth_service.dart';
import 'package:sukisave/core/widgets/app_image.dart';
import 'package:sukisave/features/vendor/pages/vendor-dashboard.dart';

import 'login_page.dart';

class SignupVendorPage extends StatefulWidget {
  const SignupVendorPage({super.key});

  @override
  State<SignupVendorPage> createState() => _SignupVendorPageState();
}

class _SignupVendorPageState extends State<SignupVendorPage> {
  static const Color _brandGreen = Color(0xFF0F5513);
  static const Color _lineGrey = Color(0xFFBDBDBD);

  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  String? _logoPath;
  final ImagePicker _picker = ImagePicker();

  final List<String> _businessTypes = <String>[
    'Food & Beverage',
    'Grocery',
    'Bakery',
    'Catering',
    'Retail',
  ];

  final Map<String, List<String>> _regionCities = <String, List<String>>{
    'NCR': <String>['Quezon City', 'Manila', 'Makati', 'Taguig'],
    'CALABARZON': <String>['Antipolo', 'Calamba', 'Batangas City'],
    'Central Luzon': <String>['Angeles', 'San Fernando', 'Cabanatuan'],
    'Central Visayas': <String>['Cebu City', 'Mandaue', 'Lapu-Lapu'],
    'Davao Region': <String>['Davao City', 'Tagum', 'Panabo'],
  };

  String? _selectedType;
  String? _selectedRegion;
  String? _selectedCity;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  double _strength = 0.0;
  String _strengthLabel = 'Weak';

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updateStrength);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_updateStrength);
    _businessNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _updateStrength() {
    final String value = _passwordController.text;
    int score = 0;
    if (value.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(value)) score++;
    if (RegExp(r'[a-z]').hasMatch(value)) score++;
    if (RegExp(r'[0-9]').hasMatch(value)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(value)) score++;

    final double nextStrength = (score / 5).clamp(0.0, 1.0);
    String nextLabel = 'Weak';
    if (nextStrength >= 0.8) {
      nextLabel = 'Strong';
    } else if (nextStrength >= 0.5) {
      nextLabel = 'Medium';
    }

    setState(() {
      _strength = nextStrength;
      _strengthLabel = nextLabel;
    });
  }

  Future<void> _pickLogoPath() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() {
      _logoPath = picked.path;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Color _strengthColor() {
    if (_strength >= 0.8) return const Color(0xFF2E7D32);
    if (_strength >= 0.5) return const Color(0xFFF9A825);
    return const Color(0xFFC62828);
  }

  InputDecoration _underlineDecoration({
    required String hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: 'Geist',
        fontSize: 13,
        color: Color(0xFF9E9E9E),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: _lineGrey),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: _lineGrey, width: 1.2),
      ),
      suffixIcon: suffixIcon,
    );
  }

  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Geist',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  'Create Business Account',
                  style: const TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _brandGreen,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: InkWell(
                  onTap: _pickLogoPath,
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: _logoPath == null || _logoPath!.isEmpty
                        ? const Icon(
                            Icons.file_upload_outlined,
                            color: _brandGreen,
                            size: 28,
                          )
                        : AppImage(
                            path: _logoPath!,
                            borderRadius: BorderRadius.circular(28),
                            fit: BoxFit.cover,
                            errorWidget: const Icon(
                              Icons.file_upload_outlined,
                              color: _brandGreen,
                              size: 28,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Upload logo (optional)',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 12,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _label('Business Name'),
              TextField(
                controller: _businessNameController,
                style: const TextStyle(fontFamily: 'Geist', fontSize: 13),
                decoration: _underlineDecoration(
                  hint: 'Enter your Business Name',
                ),
              ),
              const SizedBox(height: 14),
              _label('Type'),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                items: _businessTypes
                    .map(
                      (type) => DropdownMenuItem<String>(
                        value: type,
                        child: Text(
                          type,
                          style: const TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
                decoration: _underlineDecoration(
                  hint: 'Business Type',
                  suffixIcon: const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF9E9E9E),
                    size: 20,
                  ),
                ),
                icon: const SizedBox.shrink(),
              ),
              const SizedBox(height: 14),
              _label('Region'),
              DropdownButtonFormField<String>(
                initialValue: _selectedRegion,
                items: _regionCities.keys
                    .map(
                      (region) => DropdownMenuItem<String>(
                        value: region,
                        child: Text(
                          region,
                          style: const TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRegion = value;
                    _selectedCity = null;
                  });
                },
                decoration: _underlineDecoration(
                  hint: 'Select your region',
                  suffixIcon: const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF9E9E9E),
                    size: 20,
                  ),
                ),
                icon: const SizedBox.shrink(),
              ),
              const SizedBox(height: 14),
              _label('City'),
              DropdownButtonFormField<String>(
                initialValue: _selectedCity,
                items: (_regionCities[_selectedRegion] ?? <String>[])
                    .map(
                      (city) => DropdownMenuItem<String>(
                        value: city,
                        child: Text(
                          city,
                          style: const TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: _selectedRegion == null
                    ? null
                    : (value) {
                        setState(() {
                          _selectedCity = value;
                        });
                      },
                decoration: _underlineDecoration(
                  hint: 'Select your City',
                  suffixIcon: const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF9E9E9E),
                    size: 20,
                  ),
                ),
                icon: const SizedBox.shrink(),
              ),
              const SizedBox(height: 14),
              _label('Email'),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontFamily: 'Geist', fontSize: 13),
                decoration: _underlineDecoration(hint: 'info@gmail.com'),
              ),
              const SizedBox(height: 14),
              _label('Phone number'),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontFamily: 'Geist', fontSize: 13),
                decoration: _underlineDecoration(hint: '(+63)'),
              ),
              const SizedBox(height: 14),
              _label('Password'),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(fontFamily: 'Geist', fontSize: 13),
                decoration: _underlineDecoration(
                  hint: 'Enter your password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF9E9E9E),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: _strength,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFE0E0E0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _strengthColor(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _strengthLabel,
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 12,
                      color: _strengthColor(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _label('Confirm Password'),
              TextField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                style: const TextStyle(fontFamily: 'Geist', fontSize: 13),
                decoration: _underlineDecoration(
                  hint: 'Enter your password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF9E9E9E),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirm = !_obscureConfirm;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: _saveSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already an account? ',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 13,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _brandGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveSignup() async {
    if (_businessNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmController.text.isEmpty ||
        _selectedType == null ||
        _selectedRegion == null ||
        _selectedCity == null) {
      _showMessage('Please complete all fields.');
      return;
    }

    if (_passwordController.text != _confirmController.text) {
      _showMessage('Passwords do not match.');
      return;
    }

    if (_passwordController.text.length < 8) {
      _showMessage('Password must be at least 8 characters.');
      return;
    }

    try {
      await AuthService.instance.registerUser(
        role: 'vendor',
        name: _businessNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        businessType: _selectedType,
        region: _selectedRegion,
        city: _selectedCity,
        logoPath: (_logoPath == null || _logoPath!.isEmpty) ? null : _logoPath,
      );
      if (!mounted) return;
      _showMessage('Vendor account created.');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const VendorDashboard()),
      );
    } on AuthException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('Unable to create account right now.');
    }
  }
}
