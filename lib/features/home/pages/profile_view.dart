import 'package:flutter/material.dart';
import 'package:sukisave/core/services/auth_service.dart';
import 'package:sukisave/core/widgets/profile_details.dart';

class ProfileViewPage extends StatefulWidget {
  const ProfileViewPage({super.key});

  @override
  State<ProfileViewPage> createState() => _ProfileViewPageState();
}

class _ProfileViewPageState extends State<ProfileViewPage> {
  String _name = '';
  String _email = '';
  String _phone = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user =
        AuthService.instance.currentUser ??
        await AuthService.instance.restoreSession();
    if (!mounted) return;
    setState(() {
      _name = user?.name ?? '';
      _email = user?.email ?? '';
      _phone = user?.phone ?? '';
    });
  }

  Future<void> _confirmDelete() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete account'),
          content: const Text('Are you sure you want to delete your account?'),
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
      title: 'Profile',
      details: [
        ProfileDetailItem(label: 'Name', value: _name),
        ProfileDetailItem(label: 'Email', value: _email),
        ProfileDetailItem(label: 'Mobile number', value: _phone),
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
