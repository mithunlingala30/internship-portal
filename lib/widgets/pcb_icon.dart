import 'package:flutter/material.dart';

class PCBIcon extends StatelessWidget {
  final double size;
  const PCBIcon({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blueGrey.shade900,
            Colors.blueGrey.shade800,
          ],
        ),
      ),
      child: CustomPaint(
        painter: _PCBPainter(),
      ),
    );
  }
}

class _PCBPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // 1. Draw the Base Board (Dark Green)
    final boardPath = Path();
    final w = size.width;
    final h = size.height;
    
    // Isometric base
    boardPath.moveTo(w * 0.5, h * 0.2);
    boardPath.lineTo(w * 0.9, h * 0.45);
    boardPath.lineTo(w * 0.5, h * 0.8);
    boardPath.lineTo(w * 0.1, h * 0.45);
    boardPath.close();

    paint.color = const Color(0xFF1B5E20); // Dark Green
    canvas.drawPath(boardPath, paint);

    // 2. Add depth to the board
    final sidePath = Path();
    sidePath.moveTo(w * 0.1, h * 0.45);
    sidePath.lineTo(w * 0.5, h * 0.8);
    sidePath.lineTo(w * 0.5, h * 0.85);
    sidePath.lineTo(w * 0.1, h * 0.5);
    sidePath.close();
    paint.color = const Color(0xFF0D3310);
    canvas.drawPath(sidePath, paint);

    final otherSidePath = Path();
    otherSidePath.moveTo(w * 0.9, h * 0.45);
    otherSidePath.lineTo(w * 0.5, h * 0.8);
    otherSidePath.lineTo(w * 0.5, h * 0.85);
    otherSidePath.lineTo(w * 0.9, h * 0.5);
    otherSidePath.close();
    canvas.drawPath(otherSidePath, paint);

    // 3. Draw Gold Traces
    final tracePaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Simple geometric traces
    canvas.drawLine(Offset(w * 0.3, h * 0.4), Offset(w * 0.5, h * 0.5), tracePaint);
    canvas.drawLine(Offset(w * 0.5, h * 0.5), Offset(w * 0.7, h * 0.45), tracePaint);
    canvas.drawLine(Offset(w * 0.4, h * 0.6), Offset(w * 0.6, h * 0.5), tracePaint);
    
    // Nodes (dots)
    paint.color = const Color(0xFFFFD700);
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), 2, paint);
    canvas.drawCircle(Offset(w * 0.3, h * 0.4), 1.5, paint);
    canvas.drawCircle(Offset(w * 0.7, h * 0.45), 1.5, paint);

    // 4. Draw a Central Chip (3D Box)
    final chipPaint = Paint()..color = const Color(0xFF212121);
    final chipPath = Path();
    chipPath.moveTo(w * 0.45, h * 0.4);
    chipPath.lineTo(w * 0.6, h * 0.48);
    chipPath.lineTo(w * 0.45, h * 0.58);
    chipPath.lineTo(w * 0.3, h * 0.48);
    chipPath.close();
    canvas.drawPath(chipPath, chipPaint);

    // Chip Top Highlight
    paint.color = const Color(0xFF333333);
    canvas.drawPath(chipPath, paint);

    // Chip Pins (tiny gold lines)
    final pinPaint = Paint()
      ..color = const Color(0xFFC0C0C0)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(w * 0.35, h * 0.44), Offset(w * 0.32, h * 0.46), pinPaint);
    canvas.drawLine(Offset(w * 0.4, h * 0.47), Offset(w * 0.37, h * 0.49), pinPaint);
    canvas.drawLine(Offset(w * 0.55, h * 0.44), Offset(w * 0.58, h * 0.46), pinPaint);
    
    // Glow effect
    final glowPaint = Paint()
      ..color = const Color(0xFF00FF00).withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(w * 0.45, h * 0.48), 10, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
