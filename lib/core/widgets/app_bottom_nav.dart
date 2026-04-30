import 'package:flutter/material.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  Color get _brandGreen => const Color(0xFF0F5513);

  Widget _navItem({
    required BuildContext context,
    required int index,
    required IconData selected,
    required IconData unselected,
    required String semanticsLabel,
  }) {
    final bool isSelected = currentIndex == index;
    return InkWell(
      onTap: () => _handleNavTap(context, index),
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        width: 56,
        height: 52,
        child: Icon(
          isSelected ? selected : unselected,
          color: _brandGreen.withValues(alpha: isSelected ? 1 : 0.8),
          size: 24,
          semanticLabel: semanticsLabel,
        ),
      ),
    );
  }

  void _handleNavTap(BuildContext context, int index) {
    onTap(index);
    if (currentIndex == index) {
      return;
    }
    final String routeName = _routeForIndex(index);
    if (routeName.isEmpty) {
      return;
    }

    Navigator.of(context).pushReplacementNamed(routeName);
  }

  String _routeForIndex(int index) {
    switch (index) {
      case 0:
        return '/landing';
      case 1:
        return '/messages';
      case 2:
        return '/receipts';
      case 3:
        return '/profile';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _navItem(
                    context: context,
                    index: 0,
                    selected: Icons.home,
                    unselected: Icons.home_outlined,
                    semanticsLabel: 'Home',
                  ),
                  _navItem(
                    context: context,
                    index: 1,
                    selected: Icons.chat_bubble,
                    unselected: Icons.chat_bubble_outline,
                    semanticsLabel: 'Messages',
                  ),
                  _navItem(
                    context: context,
                    index: 2,
                    selected: Icons.receipt_long,
                    unselected: Icons.receipt_long_outlined,
                    semanticsLabel: 'Receipts',
                  ),
                  _navItem(
                    context: context,
                    index: 3,
                    selected: Icons.person,
                    unselected: Icons.person_outline,
                    semanticsLabel: 'Profile',
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/map');
              },
              customBorder: const CircleBorder(),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _brandGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _brandGreen.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.map, color: Colors.white, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
