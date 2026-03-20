import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

// 1. THE REAL-TIME STREAM
final isFavoriteStreamProvider = StreamProvider.family<bool, String>((ref, auctionId) {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return Stream.value(false);

  return Supabase.instance.client
      .from('favorites')
      .stream(primaryKey: ['user_id', 'auction_id'])
      .eq('user_id', user.id)
      .map((data) => data.any((item) => item['auction_id'] == auctionId));
});

// 2. THE OPTIMISTIC NOTIFIER (This keeps the heart filled during navigation)
final favoriteNotifierProvider = StateNotifierProvider.family<FavoriteNotifier, bool, String>((ref, auctionId) {
  // Sync local state with the stream whenever the stream updates
  final streamValue = ref.watch(isFavoriteStreamProvider(auctionId)).value ?? false;
  return FavoriteNotifier(streamValue, auctionId);
});

class FavoriteNotifier extends StateNotifier<bool> {
  final String auctionId;
  FavoriteNotifier(super.state, this.auctionId);

  Future<void> toggle() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    final originalState = state;
    state = !state; // INSTANT UI TOGGLE

    try {
      if (originalState) {
        await client.from('favorites').delete().match({
          'user_id': userId,
          'auction_id': auctionId,
        });
      } else {
        await client.from('favorites').insert({
          'user_id': userId,
          'auction_id': auctionId,
        });
      }
    } catch (e) {
      state = originalState; // REVERT ON ERROR
      debugPrint("Favorite Error: $e");
    }
  }
}