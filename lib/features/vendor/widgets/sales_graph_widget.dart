import 'package:flutter/material.dart';

class SalesGraphWidget extends StatelessWidget {
  final List<double> data;

  const SalesGraphWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Sales", style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Expanded(child: CustomPaint(painter: GradientLinePainter(data))),
        ],
      ),
    );
  }
}

class GradientLinePainter extends CustomPainter {
  final List<double> data;

  GradientLinePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (data.isEmpty) {
      final y = size.height * 0.6;
      path.moveTo(0, y);
      path.lineTo(size.width, y);
    } else {
      final maxValue = data.reduce((a, b) => a > b ? a : b);
      final safeMax = maxValue <= 0 ? 1.0 : maxValue;
      final topPadding = size.height * 0.1;
      final bottomPadding = size.height * 0.15;
      final usableHeight = size.height - topPadding - bottomPadding;
      final xStep = data.length == 1 ? 0.0 : size.width / (data.length - 1);

      for (int i = 0; i < data.length; i++) {
        final x = data.length == 1 ? size.width / 2 : xStep * i.toDouble();
        final value = data[i];
        final y =
            size.height - bottomPadding - (value / safeMax) * usableHeight;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
    }

    final paint = Paint()
      ..color = const Color(0xFF0F5513)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, paint);

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final gradient = LinearGradient(
      colors: [const Color(0xFF0F5513).withOpacity(0.4), Colors.white],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final fillPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant GradientLinePainter oldDelegate) {
    if (oldDelegate.data.length != data.length) return true;
    for (int i = 0; i < data.length; i++) {
      if (oldDelegate.data[i] != data[i]) return true;
    }
    return false;
  }
}
