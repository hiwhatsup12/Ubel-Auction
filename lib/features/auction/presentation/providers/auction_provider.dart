import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../services/supabase_service.dart';
import '../../domain/entities/auction_entity.dart';

final auctionsProvider = StreamProvider<List<AuctionEntity>>((ref) {
  final client = ref.watch(supabaseClientProvider);

  return client
      .from('auctions')
      .stream(primaryKey: ['id'])
      .eq('status', 'active')
      .order('created_at', ascending: false)
      .map((data) => data.map((json) => _mapToAuction(json)).toList());
});

final auctionDetailProvider =
    StreamProvider.family<AuctionEntity?, String>((ref, id) {
  final client = ref.watch(supabaseClientProvider);

  return client
      .from('auctions')
      .stream(primaryKey: ['id'])
      .eq('id', id)
      .map((data) => data.isNotEmpty ? _mapToAuction(data.first) : null);
});

final myAuctionsProvider = StreamProvider<List<AuctionEntity>>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final userId = client.auth.currentUser?.id;

  if (userId == null) return Stream.value([]);

  return client
      .from('auctions')
      .stream(primaryKey: ['id'])
      .eq('seller_id', userId)
      .order('created_at', ascending: false)
      .map((data) => data.map((json) => _mapToAuction(json)).toList());
});

AuctionEntity _mapToAuction(Map<String, dynamic> json) {
  return AuctionEntity(
    id: json['id'] ?? '',
    title: json['title'] ?? 'No Title',
    description: json['description'] ?? '',
    startingPrice: (json['starting_price'] as num? ?? 0).toDouble(),
    currentPrice: (json['current_price'] as num? ?? 0).toDouble(),
    category: json['category'] ??
        'Recents', // Added this - was missing in your mapper
    imageUrl: json['image_url'],
    startTime:
        DateTime.parse(json['start_time'] ?? DateTime.now().toIso8601String()),
    endTime:
        DateTime.parse(json['end_time'] ?? DateTime.now().toIso8601String()),
    sellerId: json['seller_id'] ?? '',
    // Use a fallback for seller info since stream doesn't join profiles by default
    sellerName: json['seller_name'] ?? 'Seller',
    status: AuctionStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => AuctionStatus.active,
    ),
    winnerId: json['winner_id'],
    createdAt:
        DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    updatedAt:
        DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    bidCount: json['bid_count'] ?? 0,
  );
}

final auctionControllerProvider =
    StateNotifierProvider<AuctionController, AsyncValue<void>>((ref) {
  return AuctionController(ref);
});

class AuctionController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  AuctionController(this._ref) : super(const AsyncValue.data(null));

  SupabaseClient get _client => _ref.read(supabaseClientProvider);

  Future<void> createAuction({
    required String title,
    required String description,
    required double startingPrice,
    required DateTime endTime,
    String? imageUrl,
    required String category, // Add this
  }) async {
    state = const AsyncValue.loading();
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('Not authenticated');

      await _client.from('auctions').insert({
        'title': title,
        'description': description,
        'starting_price': startingPrice,
        'current_price': startingPrice,
        'image_url': imageUrl,
        'category': category,
        'end_time': endTime.toIso8601String(),
        'seller_id': userId,
        // Let Supabase handle status, bid_count, and timestamps automatically
      });
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteAuction(String auctionId) async {
    try {
      await _client.from('auctions').delete().eq('id', auctionId);
    } catch (e) {
      rethrow;
    }
  }
}

// Add this near your other providers
final popularAuctionsProvider = StreamProvider<List<AuctionEntity>>((ref) {
  final client = ref.watch(supabaseClientProvider);

  return client
      .from('auctions')
      .stream(primaryKey: ['id'])
      .eq('status', 'active')
      .order('bid_count', ascending: false) // Popular = most bids
      .limit(10)
      .map((data) => data.map((json) => _mapToAuction(json)).toList());
});

final filteredAuctionsProvider =
    StreamProvider.family<List<AuctionEntity>, String>((ref, categoryId) {
  final client = ref.watch(supabaseClientProvider);

  // 1. If it's 'recents', we want EVERYTHING (no filter)
  if (categoryId.toLowerCase() == 'recents') {
    return client
        .from('auctions')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => _mapToAuction(json)).toList());
  }

  // 2. If it's a specific category, chain the .eq() IMMEDIATELY
  return client
      .from('auctions')
      .stream(primaryKey: ['id'])
      .eq('category', categoryId) // This works because it's chained directly
      .order('created_at', ascending: false)
      .map((data) => data.map((json) => _mapToAuction(json)).toList());
});
