import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubel/core/theme/app_colors.dart';
import 'package:ubel/features/auction/presentation/widgets/auction_card.dart';
import '../../../../services/supabase_service.dart';
import '../../domain/entities/auction_entity.dart';
import '../providers/auction_provider.dart';

class CategoryTabsSection extends ConsumerWidget {
  final List<String> categories;

  const CategoryTabsSection({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: categories.length,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tab Bar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              indicatorPadding: const EdgeInsets.symmetric(vertical: 8),
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(width: 0.6, color: AppColors.darkGray),
              ),
              labelColor: AppColors.textPrimary,
              unselectedLabelColor: AppColors.mediumGray.withAlpha(100),
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              dividerColor: Colors.transparent,
              labelPadding: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              tabs: categories.map((name) => Tab(text: name)).toList(),
            ),
          ),

          // Tab Content
          SizedBox(
            height: 500,
            child: TabBarView(
              children: categories.map((category) {
                final categoryId = _mapToCategoryId(category);
                return _CategoryContent(
                    categoryId: categoryId, categoryName: category);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _mapToCategoryId(String displayName) {
    switch (displayName.toLowerCase()) {
      case 'artworks':
        return 'artworks';
      case 'memes':
        return 'memes';
      case 'collectibles':
        return 'collectibles';
      case 'timepieces':
        return 'timepieces';
      case 'fashion':
        return 'fashion';
      default:
        return 'recents';
    }
  }
}

class _CategoryContent extends ConsumerWidget {
  final String categoryId;
  final String categoryName;

  const _CategoryContent(
      {required this.categoryId, required this.categoryName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (categoryId == 'recents') {
      // For Recents tab, use the existing recentAuctions widget
      return _RecentAuctionsContent();
    }

    // For other categories, fetch category-specific auctions
    final categoryAuctions = ref.watch(categoryAuctionsProvider(categoryId));

    return categoryAuctions.when(
      data: (auctions) {
        if (auctions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 48,
                  color: AppColors.mediumGray.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No items in $categoryName',
                  style: const TextStyle(color: AppColors.mediumGray),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: auctions.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AuctionCard(auction: auctions[index]),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(
        child: Text('Error loading items',
            style: TextStyle(color: AppColors.error)),
      ),
    );
  }
}

class _RecentAuctionsContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auctionsAsync = ref.watch(auctionsProvider);

    return auctionsAsync.when(
      data: (auctions) {
        if (auctions.isEmpty) {
          return const Center(
            child: Text('No active auctions'),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16).copyWith(bottom: 120),
          itemCount: auctions.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AuctionCard(auction: auctions[index]),
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (error, _) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
}

// Provider for category-based auctions
final categoryAuctionsProvider =
    FutureProvider.family<List<AuctionEntity>, String>((ref, categoryId) async {
  final client = ref.watch(supabaseClientProvider);

  final response = await client
      .from('auctions')
      .select('''
        *,
        profiles:seller_id (
          username,
          avatar_url
        )
      ''')
      .eq('status', 'active')
      .eq('category', categoryId)
      .order('created_at', ascending: false);

  return (response as List).map((json) {
    if (json['profiles'] != null) {
      json['seller_name'] = json['profiles']['username'];
      json['seller_avatar'] = json['profiles']['avatar_url'];
    }
    return _mapToAuction(json);
  }).toList();
});

// Helper function to map JSON to AuctionEntity
AuctionEntity _mapToAuction(Map<String, dynamic> json) {
  return AuctionEntity(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    startingPrice: (json['starting_price'] as num).toDouble(),
    currentPrice: (json['current_price'] as num).toDouble(),
    imageUrl: json['image_url'],
    category: json['category'] ?? 'recents',
    startTime: DateTime.parse(json['start_time']),
    endTime: DateTime.parse(json['end_time']),
    sellerId: json['seller_id'],
    sellerName: json['seller_name'] ?? json['profiles']?['username'],
    sellerAvatar: json['seller_avatar'] ?? json['profiles']?['avatar_url'],
    status: AuctionStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => AuctionStatus.active,
    ),
    winnerId: json['winner_id'],
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: DateTime.parse(json['updated_at']),
    bidCount: json['bid_count'] ?? 0,
  );
}
