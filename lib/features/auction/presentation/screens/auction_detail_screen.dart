import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ubel/core/theme/app_colors.dart';
import 'package:ubel/features/auction/domain/entities/auction_entity.dart';
import 'package:ubel/features/auction/presentation/providers/auction_provider.dart';
import 'package:ubel/features/auction/presentation/providers/favorite_provider.dart';
import 'package:ubel/features/bidding/presentation/widgets/place_bid_button.dart';
import '../../../bidding/presentation/providers/bidding_provider.dart';
import '../../../bidding/presentation/widgets/bid_history.dart';
import '../../../../core/utils/extensions.dart';

class AuctionDetailScreen extends ConsumerStatefulWidget {
  final String auctionId;

  const AuctionDetailScreen({super.key, required this.auctionId});

  @override
  ConsumerState<AuctionDetailScreen> createState() =>
      _AuctionDetailScreenState();
}

class _AuctionDetailScreenState extends ConsumerState<AuctionDetailScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(biddingRealtimeProvider(widget.auctionId));
  }

  /// Helper to format duration beautifully
  /// Helper to format duration with maximum FOMO (Always keeps seconds ticking)
  String _formatTimeLeft(Duration duration) {
    if (duration.isNegative) return 'Ended';

    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    // If more than a day, show: 2d 05h 30m 12s
    if (days > 0) {
      return '${days}d ${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s';
    }
    // If under a day, show: 05h 30m 12s
    else if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s';
    }
    // Final countdown: 30m 12s
    else {
      return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auctionAsync = ref.watch(auctionDetailProvider(widget.auctionId));

    return auctionAsync.when(
      data: (auction) {
        if (auction == null) {
          return const Scaffold(body: Center(child: Text('Auction not found')));
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true, backgroundColor: AppColors.background, surfaceTintColor: AppColors.background,
                    elevation: 0,
                    centerTitle: true,
                    leading:
                        // //
                        IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textPrimary, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    // // 1. CENTERED CATEGORY TITLE
                    title: Text(
                      auction.category.toUpperCase(), // e.g., "FASHION"
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    // 2. SVG ICON AT THE END
                    actions: [
                      Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: GestureDetector(
                          onTap: () {
                            // Add share or more options logic here
                            HapticFeedback.lightImpact();
                          },
                          child: SvgPicture.asset(
                            'assets/icons/dots-three-vertical-light.svg', // Or 'dots-three-vertical-light.svg'
                            width: 24,
                            colorFilter: const ColorFilter.mode(
                                AppColors.textPrimary, BlendMode.srcIn),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //* AUCTION IMAGE
                          Container(
                            height: 400,
                            width: double.maxFinite,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: AppColors.darkGray.withOpacity(0.1),
                                  width: 0.5),
                            ),
                            child: (auction.imageUrl == null ||
                                    auction.imageUrl!.isEmpty)
                                ? const Center(
                                    child: Icon(
                                        Icons.image_not_supported_outlined,
                                        size: 50,
                                        color: AppColors.mediumGray))
                                : CachedNetworkImage(
                                    imageUrl: auction.fullImageUrl ?? '',
                                    fit: BoxFit.cover,
                                    alignment: Alignment.topCenter,
                                    placeholder: (context, url) => const Center(
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2)),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.broken_image,
                                            size: 50,
                                            color: AppColors.mediumGray),
                                  ),
                          ),
                          const SizedBox(height: 12),
                          Text(auction.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 28,
                                  color: AppColors.textPrimary)),
                          Text(auction.description,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 16,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 16),

                          //* SELLER DETAILS
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: AppColors.darkGray.withOpacity(0.2),
                                    width: 0.5),
                                borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: 46,
                                      width: 46,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: AppColors.darkGray
                                                .withOpacity(0.1),
                                            width: 0.5),
                                      ),
                                      child: CachedNetworkImage(
                                        imageUrl: auction.sellerAvatar ?? '',
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.person,
                                                color: AppColors.textPrimary),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(auction.sellerName ?? 'Unknown',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textPrimary)),
                                        const Text('Seller',
                                            style: TextStyle(
                                                color: AppColors.textPrimary,
                                                fontWeight: FontWeight.w300)),
                                      ],
                                    ),
                                  ],
                                ),
                                SvgPicture.asset(
                                  'assets/icons/chat-teardrop-dots-light.svg',
                                  width: 26,
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          //* BID STATUS & REAL-TIME TIMER
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Current Bid (${auction.bidCount} bids)',
                                      style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w300)),
                                  Text(auction.currentPrice.currency,
                                      style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w300,
                                          color: AppColors.textPrimary)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.end, // Aligned to end
                                children: [
                                  const Text('Time Left',
                                      style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w300)),
                                  StreamBuilder(
                                    stream: Stream.periodic(
                                        const Duration(seconds: 1)),
                                    builder: (context, _) {
                                      final remaining = auction.endTime
                                          .difference(DateTime.now());

                                      // Logic for "Urgency" color
                                      final isUrgent = remaining.inHours < 1 &&
                                          !remaining.isNegative;

                                      return Text(_formatTimeLeft(remaining),
                                          style: TextStyle(
                                              color: isUrgent
                                                  ? Colors.red
                                                  : AppColors.textPrimary,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500));
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          BidHistory(auctionId: auction.id),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              //* BOTTOM ACTION BAR (OPTIMISTIC HEART)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 28),
                child: Row(
                  children: [
                    if (auction.status == AuctionStatus.active)
                      Expanded(
                        child: PlaceBidButton(
                          auctionId: auction.id,
                          currentPrice: auction.currentPrice,
                        ),
                      ),
                    const SizedBox(width: 16),
                    Consumer(
                      builder: (context, ref, child) {
                        final isFavorite =
                            ref.watch(favoriteNotifierProvider(auction.id));

                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            ref
                                .read(favoriteNotifierProvider(auction.id)
                                    .notifier)
                                .toggle();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isFavorite
                                  ? AppColors.darkGray
                                  : AppColors.background,
                              border: Border.all(
                                  width: 0.4, color: AppColors.darkGray),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: SvgPicture.asset(
                                isFavorite
                                    ? 'assets/icons/heart-fill.svg'
                                    : 'assets/icons/heart-light.svg',
                                key: ValueKey<bool>(isFavorite),
                                width: 24,
                                colorFilter: ColorFilter.mode(
                                  isFavorite
                                      ? AppColors.pureWhite
                                      : AppColors.darkGray,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }
}
