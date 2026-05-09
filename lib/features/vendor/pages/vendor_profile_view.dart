import 'package:flutter/material.dart';
import 'package:sukisave/core/services/auth_service.dart';
import 'package:sukisave/core/widgets/profile_details.dart';

class VendorProfileViewPage extends StatefulWidget {
  const VendorProfileViewPage({super.key});

  @override
  State<VendorProfileViewPage> createState() => _VendorProfileViewPageState();
}

class _VendorProfileViewPageState extends State<VendorProfileViewPage> {
  String _businessName = '';
  String _email = '';
  String _phone = '';
  String _businessType = '';
  String _region = '';
  String _city = '';

  @override
  void initState() {
    super.initState();
    _loadVendor();
  }

  Future<void> _loadVendor() async {
    final user =
        AuthService.instance.currentUser ??
        await AuthService.instance.restoreSession();
    if (!mounted) return;
    setState(() {
      _businessName = user?.name ?? '';
      _email = user?.email ?? '';
      _phone = user?.phone ?? '';
      _businessType = user?.businessType ?? '';
      _region = user?.region ?? '';
      _city = user?.city ?? '';
    });
  }

  Future<void> _confirmDelete() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete vendor account'),
          content: const Text(
            'Are you sure you want to delete this vendor account?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    await AuthService.instance.deleteCurrentUser();
    if (!mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(content: Text('Delete account successful.'));
      },
    );

    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.of(context).pop();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return ProfileDetailsPage(
      title: 'Vendor Profile',
      details: [
        ProfileDetailItem(label: 'Business name', value: _businessName),
        ProfileDetailItem(label: 'Business type', value: _businessType),
        ProfileDetailItem(label: 'Email', value: _email),
        ProfileDetailItem(label: 'Phone number', value: _phone),
        ProfileDetailItem(label: 'Region', value: _region),
        ProfileDetailItem(label: 'City', value: _city),
      ],
      connectedAccounts: const [
        ConnectedAccountItem(
          iconPath: 'assets/images/profile/fb.png',
          label: 'Facebook',
          status: 'Not connected',
        ),
        ConnectedAccountItem(
          iconPath: 'assets/images/profile/google.png',
          label: 'Google',
          status: 'Connected',
        ),
      ],
      onDeleteAccount: _confirmDelete,
    );
  }
}
