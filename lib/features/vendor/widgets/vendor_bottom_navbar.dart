import 'package:flutter/material.dart';
import '../pages/vendor-dashboard.dart';
import '../pages/product_page.dart';
import '../pages/vendor-order.dart';
import '../pages/vendor_message.dart';
import '../pages/vendor_profile_page.dart';

class VendorBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const VendorBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0F5513);

    final items = [
      {"icon": Icons.home, "label": "Overview"},
      {"icon": Icons.inventory, "label": "Product"},
      {"icon": Icons.shopping_bag, "label": "Orders"},
      {"icon": Icons.message, "label": "Messages"},
      {"icon": Icons.person, "label": "Account"},
    ];

    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final selected = i == currentIndex;

          return Expanded(
            child: InkWell(
              onTap: () => _handleNavigation(context, i),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    items[i]["icon"] as IconData,
                    color: selected ? primary : Colors.grey,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    items[i]["label"] as String,
                    style: TextStyle(
                      color: selected ? primary : Colors.grey,
                      fontSize: 12,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget page;

    switch (index) {
      case 0:
        page = const VendorDashboard();
        break;
      case 1:
        page = const ProductPage();
        break;
      case 2:
        page = const VendorOrderPage();
        break;
      case 3:
        page = const VendorMessagePage();
        break;
      case 4:
        page = const VendorProfilePage();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }
}
