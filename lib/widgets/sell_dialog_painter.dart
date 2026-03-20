import 'package:flutter/material.dart';
import 'package:ubel/core/theme/app_colors.dart';

class SellDialogPainter extends CustomPainter {
  final Color color;
  final double cornerRadius;
  final double bottomRadius;
  final double notchWidth;
  final double notchHeight;
  final double humpRadius;
  final double bottomInset;

  SellDialogPainter({
    required this.color,
    this.cornerRadius = 32.0,
    this.bottomRadius = 32.0,
    this.notchWidth = 110.0,
    this.notchHeight = 40.0,
    this.humpRadius = 25.0,
    this.bottomInset = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. FILL PAINT (The Solid Body)
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 2. BORDER PAINT (The Fine Outline)
    final borderPaint = Paint()
      ..color = AppColors.darkGray // Your requested color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.1 // Your requested width
      ..strokeCap = StrokeCap.round; // Ensures smooth joins at corners

    final path = Path();
    final centerX = size.width / 2;
    final w = size.width;
    final h = size.height - bottomInset;

    // --- PATH CONSTRUCTION ---
    path.moveTo(bottomRadius, h);

    // Bottom Left Corner
    path.quadraticBezierTo(0, h, 0, h - bottomRadius);

    // Left side & Top Left
    path.lineTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);

    // Top side & Top Right
    path.lineTo(w - cornerRadius, 0);
    path.quadraticBezierTo(w, 0, w, cornerRadius);

    // Right side & Bottom Right
    path.lineTo(w, h - bottomRadius);
    path.quadraticBezierTo(w, h, w - bottomRadius, h);

    // --- LIQUID INVERTED NOTCH (Right to Left) ---
    path.lineTo(centerX + (notchWidth / 2) + humpRadius, h);

    // Smooth Entry Curve
    path.quadraticBezierTo(
      centerX + (notchWidth / 2),
      h,
      centerX + (notchWidth / 2) - (humpRadius / 2),
      h - (notchHeight * 0.2),
    );

    // Main Arch (Peak)
    path.quadraticBezierTo(
      centerX,
      h - notchHeight - 8,
      centerX - (notchWidth / 2) + (humpRadius / 2),
      h - (notchHeight * 0.2),
    );

    // Smooth Exit Curve
    path.quadraticBezierTo(
      centerX - (notchWidth / 2),
      h,
      centerX - (notchWidth / 2) - humpRadius,
      h,
    );

    path.close();

    // --- DRAWING SEQUENCE ---
    // Draw shadow first (behind everything)
    canvas.drawShadow(path, Colors.black.withOpacity(0.12), 12, false);

    // Draw the solid background
    canvas.drawPath(path, fillPaint);

    // Draw the fine border on top for maximum crispness
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant SellDialogPainter oldDelegate) => true;
}
