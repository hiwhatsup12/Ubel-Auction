import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ubel/core/theme/app_colors.dart';
import 'package:ubel/features/bidding/presentation/widgets/bid_board.dart';
import '../../../../core/utils/extensions.dart';
import '../providers/bidding_provider.dart';

class BidHistory extends ConsumerWidget {
  final String auctionId;

  const BidHistory({super.key, required this.auctionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bidsAsync = ref.watch(bidsProvider(auctionId));

    return bidsAsync.when(
      data: (bids) {
        if (bids.isEmpty) return _buildEmptyState();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: bids.asMap().entries.map((entry) {
            final index = entry.key;
            final bid = entry.value;
            final isHighest =
                index == 0; // The first bid in the list is the highest

            return LuxuryAccordionItem(
              isLast: index == bids.length - 1,
              isHighest: isHighest, // Pass this to the accordion
              titleWidget: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${(bid['amount'] as num).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      letterSpacing: -0.5,
                      color: isHighest
                          ? AppColors.textPrimary
                          : AppColors.mediumGray,
                    ),
                  ),
                  Text(
                    DateTime.parse(bid['created_at']).timeAgo,
                    style: TextStyle(
                        color: AppColors.mediumGray.withOpacity(0.6),
                        fontSize: 12),
                  ),
                ],
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 12, color: AppColors.mediumGray),
                      const SizedBox(width: 4),
                      Text(
                        'Bidder: ${bid['bidder_id'].toString().substring(0, 12)}...',
                        style: const TextStyle(
                            color: AppColors.mediumGray, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Time: ${DateTime.parse(bid['created_at']).timeAgo}',
                    style: TextStyle(
                        color: AppColors.mediumGray.withOpacity(0.6),
                        fontSize: 12),
                  ),
                  if (isHighest) _buildTopBidderBadge(),
                ],
              ),
            );
          }).toList(),
        );
      },
      loading: () => _buildShimmer(),
      error: (err, stack) => Center(child: Text('Error loading history: $err')),
    );
  }

  Widget _buildTopBidderBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withAlpha(20),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
            color: AppColors.primaryPurple.withAlpha(100), width: 0.5),
      ),
      child: const Text(
        'LEAD BIDDER',
        style: TextStyle(
          color: AppColors.primaryPurple,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.gavel_rounded,
                color: AppColors.mediumGray.withOpacity(0.3), size: 40),
            const SizedBox(height: 12),
            const Text('No bids yet. Start the auction!',
                style: TextStyle(color: AppColors.mediumGray)),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.white,
      child: Column(
        children: List.generate(
            4,
            (i) => const LuxuryAccordionItem(
                  title: '0000.00',
                  content: SizedBox(height: 20),
                )),
      ),
    );
  }
}
