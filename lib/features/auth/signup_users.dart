import 'package:flutter/material.dart';
import 'package:sukisave/core/services/auth_service.dart';
import 'package:sukisave/features/home/pages/landing_page.dart';

import 'login_page.dart';

class SignupUsersPage extends StatefulWidget {
  const SignupUsersPage({super.key});

  @override
  State<SignupUsersPage> createState() => _SignupUsersPageState();
}

class _SignupUsersPageState extends State<SignupUsersPage> {
  static const Color _brandGreen = Color(0xFF0F5513);
  static const Color _lineGrey = Color(0xFFBDBDBD);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

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
    _nameController.dispose();
    _dobController.dispose();
    _addressController.dispose();
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

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 1),
    );

    if (picked == null) return;
    final String formatted =
        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    setState(() {
      _dobController.text = formatted;
    });
  }

  Future<void> _saveSignup() async {
    if (_nameController.text.trim().isEmpty ||
        _dobController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmController.text.isEmpty) {
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
        role: 'user',
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        dob: _dobController.text.trim(),
      );
      if (!mounted) return;
      _showMessage('Account created.');
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LandingPage()));
    } on AuthException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('Unable to create account right now.');
    }
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
                child: Image.asset(
                  'assets/images/auth/singup_banner.png',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _label('Name'),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(fontFamily: 'Geist', fontSize: 13),
                      decoration: _underlineDecoration(hint: 'Enter your name'),
                    ),
                    const SizedBox(height: 14),
                    _label('Date of birth'),
                    TextField(
                      controller: _dobController,
                      readOnly: true,
                      onTap: _pickDate,
                      style: const TextStyle(fontFamily: 'Geist', fontSize: 13),
                      decoration: _underlineDecoration(
                        hint: 'Enter your birthday',
                        suffixIcon: const Icon(
                          Icons.calendar_today_outlined,
                          color: Color(0xFF9E9E9E),
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _label('Address'),
                    TextField(
                      controller: _addressController,
                      style: const TextStyle(fontFamily: 'Geist', fontSize: 13),
                      decoration: _underlineDecoration(hint: 'Enter your City'),
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
                          'Already have an Account? ',
                          style: TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
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
            ],
          ),
        ),
      ),
    );
  }
}
