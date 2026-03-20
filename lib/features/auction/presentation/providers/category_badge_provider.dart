import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubel/features/auction/domain/entities/category_entity.dart';
import 'package:ubel/services/supabase_service.dart';

final categoriesProvider = FutureProvider<List<CategoryEntity>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final data = await client
      .from('categories')
      .select()
      .order('display_order', ascending: true);

  return (data as List)
      .map((json) => CategoryEntity(
            id: json['id'],
            name: json['name'],
            icon: json['icon'],
            displayOrder: json['display_order'] ?? 0,
          ))
      .toList();
});
