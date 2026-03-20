import 'package:freezed_annotation/freezed_annotation.dart';

// Ensure this matches your actual filename: category_entity.dart
part 'category_entity.freezed.dart'; 

@freezed
class CategoryEntity with _$CategoryEntity {
  const factory CategoryEntity({
    required String id,
    required String name,
    String? icon,
    @JsonKey(name: 'display_order') required int displayOrder,
  }) = _CategoryEntity;
}