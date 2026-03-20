import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ubel/core/theme/app_colors.dart';
import 'package:ubel/features/auction/domain/entities/auction_entity.dart';
import 'package:ubel/features/auction/presentation/providers/favorite_provider.dart';
import '../../../../core/utils/extensions.dart';

class AuctionCard extends StatelessWidget {
  final AuctionEntity auction;

  const AuctionCard({super.key, required this.auction});

  @override
  Widget build(BuildContext context) {
    final timeRemaining = auction.endTime.difference(DateTime.now());
    final isEndingSoon =
        timeRemaining.inHours < 24 && timeRemaining.isNegative == false;

    // Get current user ID for the Winning/Outbid logic
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return InkWell(
      onTap: () => context.push('/auction/${auction.id}'),
      child: Container(
        width: double.maxFinite,
        height: 256, // Increased slightly to accommodate status badge
        decoration: BoxDecoration(
            border: Border.all(width: 0.6, color: AppColors.darkGray),
            borderRadius: BorderRadius.circular(18)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                  child: SizedBox(
                    height: 192.8,
                    width: double.maxFinite,
                    child: auction.fullImageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: auction.fullImageUrl!,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            placeholder: (_, __) => Container(
                              // height: 40,
                              color: AppColors.surface,
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              // height: 40,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported,
                                  color: AppColors.mediumGray, size: 32),
                            ),
                          )
                        : Container(
                            color: Colors.grey[50],
                            child: const Icon(Icons.image_not_supported,
                                color: AppColors.mediumGray, size: 32),
                          ),
                  ),
                ),

                // --- TOP ROW: HEART & TIMER ---
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //* OPTIMISTIC HEART BUTTON
                      Consumer(
                        builder: (context, ref, child) {
                          final isFavorite =
                              ref.watch(favoriteNotifierProvider(auction.id));

                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              ref
                                  .read(favoriteNotifierProvider(auction.id)
                                      .notifier)
                                  .toggle();
                            },
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, animation) =>
                                  ScaleTransition(
                                      scale: animation, child: child),
                              child: SvgPicture.asset(
                                isFavorite
                                    ? 'assets/icons/heart-fill.svg'
                                    : 'assets/icons/heart-light.svg',
                                key: ValueKey<bool>(isFavorite),
                                width: 24,
                                colorFilter: ColorFilter.mode(
                                    isFavorite
                                        ? Colors.redAccent
                                        : AppColors.pureWhite,
                                    BlendMode.srcIn),
                              ),
                            ),
                          );
                        },
                      ),

                      // TIMER BADGE
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            border: Border.all(
                                width: 0.6,
                                color: isEndingSoon
                                    ? AppColors.error
                                    : AppColors.pureWhite),
                            borderRadius: BorderRadius.circular(28)),
                        child: Text(
                          _formatDuration(timeRemaining),
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isEndingSoon
                                  ? AppColors.error
                                  : AppColors.pureWhite),
                        ),
                      )
                    ],
                  ),
                ),

                // --- STATUS BADGE (WINNING/OUTBID) ---
                // Only show if auction is active and user has actually interacted/bid
                if (auction.status == AuctionStatus.active &&
                    currentUserId != null &&
                    auction.bidCount > 0)
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: _buildStatusBadge(currentUserId),
                  ),
              ],
            ),

            // --- BOTTOM INFO SECTION ---
            Container(
              width: double.maxFinite,
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(width: 0.4, color: AppColors.darkGray)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          auction.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary),
                        ),
                        Text(
                          'Current Bid: ${auction.currentPrice.currency}',
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.mediumGray,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                        color: AppColors.primaryYellow,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Text(
                      'Bid',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String currentUserId) {
    // Determine if user is the leader
    final isWinning = auction.winnerId == currentUserId;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isWinning ? Colors.green : AppColors.error,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isWinning ? 'WINNING' : 'OUTBID',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return 'Ended';
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    }
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    return '${duration.inMinutes}m';
  }
}
