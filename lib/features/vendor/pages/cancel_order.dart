import 'package:flutter/material.dart';
import 'package:sukisave/core/models/vendor_order_request.dart';
import 'package:sukisave/core/state/vendor_order_store.dart';

class CancelOrderPage extends StatefulWidget {
  final int requestId;

  const CancelOrderPage({super.key, required this.requestId});

  @override
  State<CancelOrderPage> createState() => _CancelOrderPageState();
}

class _CancelOrderPageState extends State<CancelOrderPage> {
  static const Color _brandGreen = Color(0xFF0F5513);
  static const Color _declineRed = Color(0xFFD64545);
  static const Color _fieldGray = Color(0xFFF2F2F2);

  final TextEditingController _reasonController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    VendorOrderStore.instance.updateStatus(
      widget.requestId,
      VendorOrderStatus.denied,
      declineReason: _reasonController.text.trim(),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/onboarding/white_logo.png',
                    width: 140,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Ordered Deny',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _declineRed,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Apologies, this order has been declined due to availability or timing.',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 12,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Enter an Reason Why it cancelled :',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _reasonController,
                    maxLines: 3,
                    style: const TextStyle(fontFamily: 'Geist', fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'Enter reason',
                      filled: true,
                      fillColor: _fieldGray,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Reason is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _brandGreen,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 14,
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
      ),
    );
  }
}
