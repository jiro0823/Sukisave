import 'package:flutter/material.dart';
import 'package:sukisave/core/services/auth_service.dart';
import 'package:sukisave/core/widgets/app_bottom_nav.dart';
import 'package:sukisave/core/widgets/profile_overview.dart';
import 'package:sukisave/features/home/pages/profile_view.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _displayName = '';

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
      _displayName = user?.name ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProfileOverviewPage(
      displayName: _displayName,
      headerTitle: 'Account',
      promoTitle: 'Save with Sukipro!',
      promoSubtitle: 'Free for 30 days',
      promoActionText: 'Start your free trial',
      promoImagePath: 'assets/images/profile/profile_images.png',
      balanceLabel: 'Sukipay',
      balanceValue: 'PHP 0.00',
      quickActions: const [
        ProfileOverviewAction(
          icon: Icons.receipt_long_outlined,
          label: 'Orders',
        ),
        ProfileOverviewAction(icon: Icons.favorite_border, label: 'Favorites'),
        ProfileOverviewAction(
          icon: Icons.location_on_outlined,
          label: 'Address',
        ),
      ],
      sections: [
        ProfileOverviewSection(
          title: 'Perks for you',
          children: [
            ProfileOverviewPage.listItem(
              Icons.emoji_events_outlined,
              'panda rewards',
            ),
            ProfileOverviewPage.divider(),
            ProfileOverviewPage.listItem(
              Icons.confirmation_number_outlined,
              'Vouchers',
            ),
            ProfileOverviewPage.divider(),
            ProfileOverviewPage.listItem(
              Icons.card_giftcard_outlined,
              'Invite friends',
            ),
            const SizedBox(height: 12),
            const Text(
              'General',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ProfileOverviewPage.listItem(Icons.help_outline, 'Help center'),
            ProfileOverviewPage.divider(),
            ProfileOverviewPage.listItem(
              Icons.storefront_outlined,
              'sukisave for business',
            ),
            ProfileOverviewPage.divider(),
            ProfileOverviewPage.listItem(
              Icons.description_outlined,
              'Terms & policies',
            ),
          ],
        ),
      ],
      onViewProfile: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileViewPage()),
        );
      },
      onLogout: () async {
        await AuthService.instance.logout();
        if (!context.mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
      },
      bottomNavigationBar: AppBottomNavBar(currentIndex: 3, onTap: (_) {}),
    );
  }
}
