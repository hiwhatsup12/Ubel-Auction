import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubel/features/auction/presentation/providers/auction_provider.dart';
import 'package:ubel/features/auction/presentation/widgets/auction_card.dart';

// Widget recentAuctions(WidgetRef ref) {
//   final auctionsAsync = ref.watch(auctionsProvider);

//   return auctionsAsync.when(
//     data: (auctions) => ListView.builder(
//       // This is important: it prevents the list from fighting with
//       // the Home Screen's scroll behavior if needed
//       padding: const EdgeInsets.all(16).copyWith(bottom: 120),
//       itemCount: auctions.length,
//       itemBuilder: (context, index) => Padding(
//         padding: const EdgeInsets.only(bottom: 16),
//         child: AuctionCard(auction: auctions[index]),
//       ),
//     ),
//     loading: () => const Center(
//       child: CircularProgressIndicator(strokeWidth: 2),
//     ),
//     error: (error, _) => Center(
//       child: Text('Error: $error'),
//     ),
//   );
// }

Widget recentAuctions(WidgetRef ref, String categoryId) {
  // Pass the categoryId (e.g., 'recents', 'fashion', 'artworks')
  final auctionsAsync = ref.watch(filteredAuctionsProvider(categoryId));

  return auctionsAsync.when(
    data: (auctions) => auctions.isEmpty
        ? const Center(child: Text('No items in this category yet'))
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: auctions.length,
            itemBuilder: (context, index) =>
                AuctionCard(auction: auctions[index]),
          ),
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (err, stack) => Center(child: Text('Error: $err')),
  );
}
