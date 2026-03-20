import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auction_entity.freezed.dart';
part 'auction_entity.g.dart'; // <-- 1. ADD THIS

enum AuctionStatus { active, ended, cancelled, completed }

@freezed
class AuctionEntity with _$AuctionEntity {
  const factory AuctionEntity({
    required String id,
    required String title,
    required String description,
    // required double startingPrice,
    required String category,
    // required double currentPrice,
    String? imageUrl,
    required DateTime startTime,
    @Default(0.0) double startingPrice,
    @Default(0.0) double currentPrice,
    @Default(0) int bidCount,
    required DateTime endTime,
    required String sellerId,
    String? sellerName,
    String? sellerAvatar,
    required AuctionStatus status,
    String? winnerId,
    // required int bidCount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AuctionEntity;

  // <-- 2. ADD THIS LINE EXACTLY
  factory AuctionEntity.fromJson(Map<String, dynamic> json) =>
      _$AuctionEntityFromJson(json);

  const AuctionEntity._();

  String? get fullImageUrl {
    if (imageUrl == null) return null;
    if (imageUrl!.startsWith('http')) return imageUrl;
    return Supabase.instance.client.storage
        .from('auction-images')
        .getPublicUrl(imageUrl!);
  }
}
