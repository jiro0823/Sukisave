import 'package:flutter/material.dart';

class VendorDashboardPage extends StatelessWidget {
  const VendorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Vendor Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F5513),
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Vendor dashboard',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F5513),
          ),
        ),
      ),
    );
  }
}
