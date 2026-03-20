import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ubel/features/auction/presentation/providers/auction_provider.dart';
import '../../../../services/supabase_service.dart';

final bidsProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, auctionId) {
  final client = ref.watch(supabaseClientProvider);
  
  return client
    .from('bids')
    .stream(primaryKey: ['id'])
    .eq('auction_id', auctionId)
    .order('created_at', ascending: false)
    .map((data) => data);
});

final biddingRealtimeProvider = Provider.family<RealtimeChannel, String>((ref, auctionId) {
  final client = ref.watch(supabaseClientProvider);
  
  final channel = client.channel('bids:$auctionId')
    .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'bids',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'auction_id',
        value: auctionId,
      ),
      callback: (payload) {
        // Handle real-time bid updates
        ref.invalidate(bidsProvider(auctionId));
        ref.invalidate(auctionDetailProvider(auctionId));
      },
    )
    .subscribe();
    
  ref.onDispose(() => channel.unsubscribe());
  return channel;
});

final biddingControllerProvider = StateNotifierProvider<BiddingController, AsyncValue<void>>((ref) {
  return BiddingController(ref);
});

class BiddingController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  
  BiddingController(this._ref) : super(const AsyncValue.data(null));
  
  SupabaseClient get _client => _ref.read(supabaseClientProvider);
  
  Future<void> placeBid({
    required String auctionId,
    required double amount,
  }) async {
    state = const AsyncValue.loading();
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('Not authenticated');
      
      // Call Supabase RPC function to handle bid placement atomically
      await _client.rpc('place_bid', params: {
        'p_auction_id': auctionId,
        'p_bidder_id': userId,
        'p_amount': amount,
      });
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}