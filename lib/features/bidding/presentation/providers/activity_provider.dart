import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ubel/features/auction/domain/entities/auction_entity.dart';

final myBidsProvider =
    StreamProvider.family<List<AuctionEntity>, String>((ref, statusFilter) {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return Stream.value([]);

  return Supabase.instance.client
      .from('auctions')
      .stream(primaryKey: ['id']).map((data) {
    // Safe mapping: logic only runs if data is not null
    final auctions = data.map((json) => AuctionEntity.fromJson(json)).toList();

    if (statusFilter == 'active') {
      return auctions.where((a) => a.status == AuctionStatus.active).toList();
    } else {
      return auctions
          .where((a) => a.status == AuctionStatus.completed)
          .toList();
    }
  });
});

final wishlistProvider = StreamProvider<List<AuctionEntity>>((ref) {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return Stream.value([]);

  return Supabase.instance.client
      .from('favorites')
      .stream(primaryKey: ['user_id', 'auction_id'])
      .eq('user_id', userId)
      .asyncMap((favs) async {
        if (favs.isEmpty) return [];

        final ids = favs.map((f) => f['auction_id'] as String).toList();

        // Fetch auctions matching those IDs
        final response = await Supabase.instance.client
            .from('auctions')
            .select()
            .filter('id', 'in', ids);

        // The fix: Cast to List, filter out nulls, and map safely
        final List data = response as List;
        return data
            .map((json) {
              try {
                return AuctionEntity.fromJson(json as Map<String, dynamic>);
              } catch (e) {
                // This catches if one specific auction has a 'null' price in DB
                debugPrint("Mapping error for auction: $e");
                return null;
              }
            })
            .whereType<AuctionEntity>() // Removes any nulls from the list
            .toList();
      });
});
