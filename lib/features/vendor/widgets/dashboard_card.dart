import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String percent;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0F5513);

    return Container(
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(icon, color: primary),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey)),
              Text(percent, style: const TextStyle(color: primary)),
            ],
          ),
        ],
      ),
    );
  }
}
