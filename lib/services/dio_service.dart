import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final supabaseUrl = dotenv.env['SUPABASE_URL']!;

  final dio = Dio(
    BaseOptions(
      baseUrl: '$supabaseUrl/rest/v1', // Use env variable
      headers: {
        'apikey': dotenv.env['SUPABASE_ANON_KEY']!,
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  dio.interceptors.addAll([
    LogInterceptor(responseBody: true),
    InterceptorsWrapper(
      onError: (error, handler) {
        return handler.next(error);
      },
    ),
  ]);

  return dio;
});
