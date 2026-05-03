import 'package:flutter/material.dart';
import 'package:smart_campus_companion/core/constants/color_constants.dart';

class CampusIllustration extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Sky background (transparent, let gradient show)

    // Sun
    paint.color = AppColors.secondary.withOpacity(0.8);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), size.width * 0.08, paint);

    // Building 1 (left)
    paint.color = AppColors.mutedBlue.withOpacity(0.9);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.45, size.width * 0.25, size.height * 0.4),
      paint,
    );
    // Building windows
    paint.color = AppColors.white.withOpacity(0.8);
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 2; j++) {
        canvas.drawRect(
          Rect.fromLTWH(
            size.width * (0.12 + i * 0.07),
            size.height * (0.5 + j * 0.12),
            size.width * 0.04,
            size.height * 0.06,
          ),
          paint,
        );
      }
    }

    // Building 2 (center, taller)
    paint.color = AppColors.navy.withOpacity(0.9);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.4, size.height * 0.35, size.width * 0.3, size.height * 0.5),
      paint,
    );
    // Clock tower
    paint.color = AppColors.primary;
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.53, size.height * 0.2, size.width * 0.04, size.height * 0.15),
      paint,
    );
    paint.color = AppColors.secondary;
    canvas.drawCircle(
      Offset(size.width * 0.55, size.height * 0.22),
      size.width * 0.02,
      paint,
    );

    // Building 3 (right)
    paint.color = AppColors.primary.withOpacity(0.8);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.75, size.height * 0.5, size.width * 0.2, size.height * 0.35),
      paint,
    );

    // Path/walkway
    paint.color = AppColors.white.withOpacity(0.3);
    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.85);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.8,
      size.width * 0.8,
      size.height * 0.85,
    );
    path.lineTo(size.width * 0.85, size.height);
    path.lineTo(size.width * 0.15, size.height);
    path.close();
    canvas.drawPath(path, paint);

    // Trees
    paint.color = const Color(0xFF6C9E6B);
    canvas.drawCircle(Offset(size.width * 0.05, size.height * 0.7), size.width * 0.06, paint);
    canvas.drawCircle(Offset(size.width * 0.95, size.height * 0.65), size.width * 0.07, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}