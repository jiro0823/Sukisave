import 'package:flutter/material.dart';

class FilterTabs extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onChanged;

  const FilterTabs({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = ["Today", "Weekly", "Monthly"];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEAEAEA),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final selected = i == selectedIndex;

          return GestureDetector(
            onTap: () => onChanged(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF0F5513) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tabs[i],
                style: TextStyle(color: selected ? Colors.white : Colors.black),
              ),
            ),
          );
        }),
      ),
    );
  }
}
