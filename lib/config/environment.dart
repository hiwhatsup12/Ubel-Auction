import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get supabaseUrl => _getOrThrow('SUPABASE_URL');
  static String get supabaseAnonKey => _getOrThrow('SUPABASE_ANON_KEY');

  // Optional with default values
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? supabaseUrl;
  static bool get isDevelopment => dotenv.env['ENV'] == 'development';
  static bool get isProduction => dotenv.env['ENV'] == 'production';

  static String _getOrThrow(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw Exception('Missing required environment variable: $key');
    }
    return value;
  }
}
