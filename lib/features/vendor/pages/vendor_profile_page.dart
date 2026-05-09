import 'package:flutter/material.dart';
import 'package:sukisave/core/services/auth_service.dart';
import 'package:sukisave/core/widgets/profile_overview.dart';
import 'package:sukisave/features/vendor/pages/vendor_profile_view.dart';
import 'package:sukisave/features/vendor/widgets/vendor_bottom_navbar.dart';

class VendorProfilePage extends StatefulWidget {
  const VendorProfilePage({super.key});

  @override
  State<VendorProfilePage> createState() => _VendorProfilePageState();
}

class _VendorProfilePageState extends State<VendorProfilePage> {
  String _displayName = '';
  String _businessType = '';

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
      _displayName = user?.name ?? '';
      _businessType = user?.businessType ?? 'Business account';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProfileOverviewPage(
      displayName: _displayName,
      headerTitle: 'Vendor Account',
      promoTitle: 'Grow with SukiSave',
      promoSubtitle: _businessType,
      promoActionText: 'Manage listings, orders, and customer reach',
      promoImagePath: 'assets/images/profile/profile_images.png',
      balanceLabel: 'Vendor wallet',
      balanceValue: 'PHP 0.00',
      quickActions: const [
        ProfileOverviewAction(icon: Icons.inventory_2_outlined, label: 'Items'),
        ProfileOverviewAction(
          icon: Icons.shopping_bag_outlined,
          label: 'Orders',
        ),
        ProfileOverviewAction(icon: Icons.insights_outlined, label: 'Reports'),
      ],
      sections: [
        ProfileOverviewSection(
          title: 'Vendor tools',
          children: [
            ProfileOverviewPage.listItem(
              Icons.storefront_outlined,
              'Business profile',
            ),
            ProfileOverviewPage.divider(),
            ProfileOverviewPage.listItem(
              Icons.local_offer_outlined,
              'Product promotions',
            ),
            ProfileOverviewPage.divider(),
            ProfileOverviewPage.listItem(
              Icons.account_balance_wallet_outlined,
              'Payout settings',
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
              Icons.description_outlined,
              'Terms & policies',
            ),
          ],
        ),
      ],
      onViewProfile: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VendorProfileViewPage(),
          ),
        );
      },
      onLogout: () async {
        await AuthService.instance.logout();
        if (!context.mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
      },
      bottomNavigationBar: const VendorBottomNavBar(currentIndex: 4),
    );
  }
}
