import 'package:flutter/material.dart';

class ConfirmOrderPage extends StatelessWidget {
  const ConfirmOrderPage({super.key});

  static const Color _brandGreen = Color(0xFF0F5513);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/onboarding/white_logo.png',
                  width: 140,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Order Confirmed!',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _brandGreen,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'You\'ve confirmed the order. Prepare it on time to ensure customer satisfaction.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 180,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brandGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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
}
