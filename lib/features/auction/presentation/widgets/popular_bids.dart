// In popular_bids.dart, replace with:
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubel/core/theme/app_colors.dart';
import 'package:ubel/features/auction/presentation/providers/auction_provider.dart';
import 'package:ubel/features/auction/presentation/widgets/auction_card.dart';

Widget popularBids(WidgetRef ref) {
  final popularAuctions = ref.watch(popularAuctionsProvider);

  return popularAuctions.when(
    data: (auctions) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Bids',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 254,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: auctions.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: AuctionCard(auction: auctions[index]),
              ),
            ),
          ),
        ),
      ],
    ),
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (_, __) => const SizedBox(),
  );
}
