import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubel/core/theme/app_colors.dart';
import 'package:ubel/features/auction/presentation/widgets/auction_card.dart';
import 'package:ubel/features/bidding/presentation/providers/activity_provider.dart';
// Import your activity provider here

class BidsScreen extends ConsumerStatefulWidget {
  const BidsScreen({super.key});

  @override
  ConsumerState<BidsScreen> createState() => _BidsScreenState();
}

class _BidsScreenState extends ConsumerState<BidsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          title: const Text(
            'Activity',
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary),
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: AppColors.darkGray,
                indicatorWeight: 1,
                dividerColor: Colors.transparent,
                labelColor: AppColors.textPrimary,
                unselectedLabelColor: AppColors.mediumGray,
                labelStyle:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                tabs: [
                  Tab(text: 'Active Bids'),
                  Tab(text: 'Won'),
                  Tab(text: 'Wishlist'),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            _BidsList(status: 'active'),
            _BidsList(status: 'won'),
            _WishlistTab(),
          ],
        ),
      ),
    );
  }
}

class _BidsList extends ConsumerWidget {
  final String status;
  const _BidsList({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Connect to real provider
    final bidsAsync = ref.watch(myBidsProvider(status));

    return bidsAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return _buildEmptyState(
            icon: status == 'won'
                ? Icons.emoji_events_outlined
                : Icons.gavel_rounded,
            message: status == 'won'
                ? 'You haven\'t won any auctions yet'
                : 'No active bids found',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) => AuctionCard(auction: items[index]),
        );
      },
      loading: () =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: AppColors.darkGray.withOpacity(0.1)),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
                color: AppColors.mediumGray,
                fontSize: 14,
                fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }
}

Widget _buildEmptyState({required IconData icon, required String message}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 40, color: AppColors.darkGray.withOpacity(0.1)),
        const SizedBox(height: 12),
        Text(
          message,
          style: const TextStyle(
              color: AppColors.mediumGray,
              fontSize: 14,
              fontWeight: FontWeight.w300),
        ),
      ],
    ),
  );
}

class _WishlistTab extends ConsumerWidget {
  const _WishlistTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistAsync = ref.watch(wishlistProvider);

    return wishlistAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border_rounded,
                    size: 40, color: AppColors.darkGray.withOpacity(0.1)),
                const SizedBox(height: 12),
                const Text('Your wishlist is empty',
                    style: TextStyle(
                        color: AppColors.mediumGray,
                        fontWeight: FontWeight.w300)),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.68, // Tightened for the grid look
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => AuctionCard(auction: items[index]),
        );
      },
      loading: () =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
