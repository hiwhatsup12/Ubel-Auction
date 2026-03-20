import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubel/features/auction/presentation/providers/auction_provider.dart';
import 'package:ubel/features/auction/presentation/widgets/category_tab_section.dart';
import 'package:ubel/features/auction/presentation/widgets/live_auction.dart';
import 'package:ubel/features/auction/presentation/widgets/popular_bids.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart'; // Import your colors

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Note: Ensure these providers are actually being used or remove them to avoid warnings

    final user = ref.watch(currentUserProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: RefreshIndicator(
          onRefresh: () async {
            // 1. Initial "Tick" feedback
            HapticFeedback.lightImpact();

            // 2. Trigger the reload
            // ref.refresh(filteredAuctionsProvider as Refreshable);

            // ref.refresh(categoryAuctionsProvider as Refreshable);
            // 4. "Success" feedback
            HapticFeedback.mediumImpact();
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: true,
                toolbarHeight: 50, // Increased slightly so it's not too cramped
                backgroundColor: AppColors.background,
                surfaceTintColor: AppColors.background,

                elevation: 0,
                // Use flexibleSpace or title instead of just actions for better layout
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'UBEL',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          letterSpacing: 4,
                          color: AppColors.textPrimary,
                          fontSize: 24),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          border: Border.all(
                              // Fixed: was BoxBorder.all
                              width: 0.8,
                              color: AppColors.primaryPurple),
                          borderRadius: BorderRadius.circular(60)),
                      child: const Text(
                        'Premium +',
                        style: TextStyle(
                            color: AppColors.primaryPurple,
                            fontWeight: FontWeight.w500,
                            fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              // Use SliverToBoxAdapter to turn regular widgets into slivers
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: liveAuction(),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16),
                  child: popularBids(ref),
                ),
              ),
              const SliverToBoxAdapter(
                child: CategoryTabsSection(
                  categories: [
                    'Recents',
                    'Artworks',
                    'Memes',
                    'Collectibles',
                    'Timepieces',
                    'Fashion',
                  ],
                ),
              ),
              // // Add more slivers here (SliverList, SliverGrid, etc.)
            ],
          ),
        ),
      ),
    );
  }
}
