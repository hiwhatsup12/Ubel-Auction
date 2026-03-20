import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ubel/core/theme/app_colors.dart';
import 'sell_dialog_painter.dart';

void showSellPopup(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "",
    barrierColor: Colors.transparent, // Very light dim
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, anim1, anim2) {
      return const SizedBox.expand(); // Required but not used for the UI
    },
    transitionBuilder: (context, anim1, anim2, child) {
      // Bouncy luxury curve
      final curve = Curves.easeOutBack.transform(anim1.value);

      return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          // 110px lifts it to sit perfectly on your floating Nav Bar
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
          child: Material(
            color: Colors.transparent,
            child: Transform.scale(
              scale: 0.6 + (0.4 * curve),
              alignment: Alignment.bottomCenter,
              child: Opacity(
                opacity: anim1.value,
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: SellDialogPainter(
                      color: AppColors.surface,
                      cornerRadius: 40,
                      notchWidth: 112,
                      notchHeight: 48,
                    ),
                    child: _buildMenuContent(context),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildMenuContent(BuildContext context) {
  return Column(
    children: [
      const SizedBox(height: 10),
      _buildOption(context, "Auction", "Standard bidding process",
          'assets/icons/add-square-stroke-rounded.svg'),
      const SizedBox(height: 12),
      _buildOption(context, "Go Live", "Showcase your items to a live audience",
          'assets/icons/live-streaming-02-stroke-rounded.svg'),
    ],
  );
}

Widget _buildOption(
    BuildContext context, String title, String sub, String svgIcon) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: InkWell(
      onTap: () {
        if (title == 'Auction') {
          HapticFeedback.mediumImpact();
          context.pushNamed('create-auction');
        }
        // Navigator.pop(context);
        // Add your navigation logic here (e.g., context.push('/create-auction'))
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.darkGray.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 16)),
                Text(sub,
                    style: const TextStyle(
                        color: AppColors.mediumGray,
                        fontWeight: FontWeight.w300,
                        fontSize: 12)),
              ],
            ),
            const Spacer(),
            SvgPicture.asset(svgIcon)
          ],
        ),
      ),
    ),
  );
}
