import 'package:flutter/material.dart';
import 'package:sukisave/core/widgets/app_image.dart';

class ProfileOverviewAction {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const ProfileOverviewAction({
    required this.icon,
    required this.label,
    this.onTap,
  });
}

class ProfileOverviewSection {
  final String title;
  final List<Widget> children;

  const ProfileOverviewSection({required this.title, required this.children});
}

class ProfileOverviewPage extends StatelessWidget {
  final String displayName;
  final String headerTitle;
  final String promoTitle;
  final String promoSubtitle;
  final String promoActionText;
  final String promoImagePath;
  final String balanceLabel;
  final String balanceValue;
  final List<ProfileOverviewAction> quickActions;
  final List<ProfileOverviewSection> sections;
  final VoidCallback onViewProfile;
  final VoidCallback onLogout;
  final Widget bottomNavigationBar;

  const ProfileOverviewPage({
    super.key,
    required this.displayName,
    required this.headerTitle,
    required this.promoTitle,
    required this.promoSubtitle,
    required this.promoActionText,
    required this.promoImagePath,
    required this.balanceLabel,
    required this.balanceValue,
    required this.quickActions,
    required this.sections,
    required this.onViewProfile,
    required this.onLogout,
    required this.bottomNavigationBar,
  });

  static const Color brandGreen = Color(0xFF0F5513);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: const BoxDecoration(color: Colors.white),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    headerTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: brandGreen,
                      ),
                    ),
                    InkWell(
                      onTap: onViewProfile,
                      child: const Text(
                        'View Profile',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _PromoCard(
                      title: promoTitle,
                      subtitle: promoSubtitle,
                      actionText: promoActionText,
                      imagePath: promoImagePath,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: quickActions
                          .map(
                            (action) => _QuickCard(
                              icon: action.icon,
                              label: action.label,
                              onTap: action.onTap,
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Balance',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    _BalancePanel(label: balanceLabel, value: balanceValue),
                    const SizedBox(height: 20),
                    ...sections.expand(
                      (section) => [
                        _SectionCard(
                          title: section.title,
                          children: section.children,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: brandGreen),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      onPressed: onLogout,
                      child: const Text(
                        'Log out',
                        style: TextStyle(
                          color: brandGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  static Widget listItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [Icon(icon, size: 20), const SizedBox(width: 10), Text(text)],
      ),
    );
  }

  static Widget divider() {
    return Divider(color: Colors.grey.shade300, height: 1);
  }
}

class _PromoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionText;
  final String imagePath;

  const _PromoCard({
    required this.title,
    required this.subtitle,
    required this.actionText,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ProfileOverviewPage.brandGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  actionText,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          AppImage(path: imagePath, width: 70, height: 70, fit: BoxFit.contain),
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _QuickCard({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [Icon(icon), const SizedBox(height: 6), Text(label)],
          ),
        ),
      ),
    );
  }
}

class _BalancePanel extends StatelessWidget {
  final String label;
  final String value;

  const _BalancePanel({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}
