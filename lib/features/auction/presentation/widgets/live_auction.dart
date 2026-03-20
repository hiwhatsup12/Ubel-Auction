import 'package:flutter/material.dart';
import 'package:ubel/core/theme/app_colors.dart';

Widget liveAuction() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    physics: const BouncingScrollPhysics(),
    child: Row(
      children: [
        _buildLiveUser("TOE Tech", "assets/images/user1.png", isLive: true),
        const SizedBox(width: 20),
        _buildLiveUser("Tom Emily", "assets/images/emily.jpeg", isLive: true),
        const SizedBox(width: 20),
        _buildLiveUser("Brown John", "assets/images/john.jpeg"),
        const SizedBox(width: 20),
        _buildLiveUser("Mike Stone", "assets/images/mike.jpeg"),
        const SizedBox(width: 20),
        _buildLiveUser("Lee Wang", "assets/images/lee.jpeg"),
        const SizedBox(width: 20),
        _buildLiveUser("Xia Xia", "assets/images/xia.jpeg"),
      ],
    ),
  );
}

Widget _buildLiveUser(String name, String assetPath, {bool isLive = false}) {
  return Column(
    children: [
      Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: 56,
            height: 56,
            padding: const EdgeInsets.all(2.5), // Space for the ring
            decoration: BoxDecoration(
              border: Border.all(
                color: isLive
                    ? AppColors.error
                    : AppColors.darkGray.withAlpha(51),
                width: 2,
              ),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                assetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if image asset is missing
                  return Container(color: AppColors.surface);
                },
                // Placeholder(strokeWidth: 0.4,), // Kept for later as requested
              ),
            ),
          ),
          if (isLive)
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                      color: Colors.white, width: 1.5), // Luxury "cutout" look
                ),
                child: const Text(
                  "LIVE",
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: AppColors.pureWhite,
                  ),
                ),
              ),
            )
        ],
      ),
      const SizedBox(height: 6),
      Text(
        name,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      )
    ],
  );
}
