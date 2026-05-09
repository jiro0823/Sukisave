import 'package:flutter/material.dart';

class BarChartWidget extends StatelessWidget {
  final List<double> data;
  final List<String> labels;

  const BarChartWidget({super.key, required this.data, required this.labels});

  @override
  Widget build(BuildContext context) {
    final max = data.isEmpty ? 0.0 : data.reduce((a, b) => a > b ? a : b);
    final safeMax = max <= 0 ? 1.0 : max;

    return Container(
      padding: const EdgeInsets.all(16),
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${max.toInt()}k",
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              Text(
                "${(max / 2).toInt()}k",
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              const Text(
                "0",
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(data.length, (i) {
                      final value = data[i];
                      final isPeak = value == max && max > 0;

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 2,
                            height: 10,
                            color: Colors.grey.shade400,
                          ),
                          Container(
                            width: 10,
                            height: (value / safeMax) * 140,
                            decoration: BoxDecoration(
                              color: isPeak
                                  ? const Color(0xFF0F5513)
                                  : Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
                Container(height: 1, color: Colors.grey),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: labels
                      .map(
                        (e) => Text(
                          e,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
