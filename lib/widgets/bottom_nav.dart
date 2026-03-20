import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ubel/core/theme/app_colors.dart';

class CustomSolidBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onCenterTap;

  const CustomSolidBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onCenterTap,
  });

  @override
  Widget build(BuildContext context) {
    // Standardizing these values to ensure no nulls are passed
    const double barHeight = 68.0;
    const double notchHeight = 32.0;
    const double totalHeight = barHeight + notchHeight;

    const double topCornerRadius = 32.0;
    const double bottomCornerRadius = 32.0;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. THE MAIN SOLID BODY
          Positioned.fill(
            child: CustomPaint(
              painter: SolidNavPainter(
                notchHeight: notchHeight,
                // GUARD: If AppColors.surface is null, use white
                color: AppColors.surface,
                borderColor: (AppColors.darkGray),
                borderWidth: 0.1,
                cornerRadius: topCornerRadius,
                bottomRadius: bottomCornerRadius,
              ),
            ),
          ),

          // 2. NAVIGATION ITEMS
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: barHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(
                    0, 'Home', 'house-simple-light', 'house-simple-light'),
                _buildNavItem(
                    1, 'Search', 'binoculars-light', 'binoculars-light'),
                const SizedBox(width: 84),
                _buildNavItem(2, 'Bids', 'gavel-light', 'gavel-light'),
                _buildNavItem(3, 'Profile', 'user-light', 'user-light'),
              ],
            ),
          ),

          // 3. THE CENTER BUTTON
          Positioned(
            left: 0,
            right: 0,
            top: 8,
            child: Center(
              child: GestureDetector(
                onTap: onCenterTap,
                child: Column(
                  children: [
                    Container(
                        width: 58,
                        height: 58,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.darkGray,
                          shape: BoxShape.circle,
                          // border: Border.all(
                          //   color: AppColors.surface ?? Colors.white,
                          //   width: 4,
                          // ),
                          boxShadow: [
                            BoxShadow(
                              color: (AppColors.textPrimary).withAlpha(60),
                              blurRadius: 35,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/coins-light.svg',
                          width: 22,
                          height: 22,
                          colorFilter: const ColorFilter.mode(
                              AppColors.surface, BlendMode.srcIn),
                        )),
                    const SizedBox(height: 7),
                    Text(
                      'Sell',
                      style: TextStyle(
                        color: AppColors.textSecondary.withAlpha(140),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      int index, String label, String inactive, String active) {
    final bool isActive = currentIndex == index;
    // GUARD: Ensure iconColor is never null
    final Color iconColor = isActive
        ? (AppColors.textPrimary)
        : (AppColors.textSecondary).withAlpha(140);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/${isActive ? active : inactive}.svg',
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: iconColor,
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SolidNavPainter extends CustomPainter {
  final double notchHeight;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final double cornerRadius;
  final double bottomRadius;
  final double humpRadius;

  SolidNavPainter({
    required this.notchHeight,
    required this.color,
    required this.borderColor,
    this.borderWidth = 4.0,
    this.cornerRadius = 25.0,
    this.bottomRadius = 25.0,
    this.humpRadius = 25.0, // This now controls the "Roundness" of the peak
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double nHeight = notchHeight;
    final double cRadius = cornerRadius;
    final double bRadius = bottomRadius;
    final double hRadius = humpRadius;

    final Paint fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Paint strokePaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final double centerX = size.width / 2;
    const double curveWidth = 85;

    // 1. Top Left Corner
    path.moveTo(0, nHeight + cRadius);
    path.quadraticBezierTo(0, nHeight, cRadius, nHeight);

    // 2. Line to start of hump
    path.lineTo(centerX - curveWidth, nHeight);

    // 3. SMOOTH BUBBLE HUMP (Liquid Style)
    // Left side curve going UP
    path.quadraticBezierTo(
      centerX - (curveWidth * 0.5), nHeight, // Control point
      centerX - hRadius, nHeight * 0.3, // End point (start of the peak)
    );

    // THE TOP CURVE (The "Peak" radius)
    // This replaces the lineTo with a smooth arc
    path.quadraticBezierTo(
      centerX,
      -10, // Control point (Pulls the peak slightly ABOVE 0 for extra roundness)
      centerX + hRadius, nHeight * 0.3, // End point
    );

    // Right side curve going DOWN
    path.quadraticBezierTo(
      centerX + (curveWidth * 0.5), nHeight, // Control point
      centerX + curveWidth, nHeight, // Back to the bar line
    );

    // 4. Top Right Corner
    path.lineTo(size.width - cRadius, nHeight);
    path.quadraticBezierTo(size.width, nHeight, size.width, nHeight + cRadius);

    // 5. Bottom Right Corner
    path.lineTo(size.width, size.height - bRadius);
    path.quadraticBezierTo(
        size.width, size.height, size.width - bRadius, size.height);

    // 6. Bottom Left Corner
    path.lineTo(bRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - bRadius);

    path.close();

    canvas.drawShadow(path, Colors.black.withOpacity(0.12), 10.0, false);
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant SolidNavPainter oldDelegate) => true;
}
