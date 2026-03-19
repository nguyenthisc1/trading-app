// Central provider definitions for dependency injection
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../data/datasources/alpha_vantage_api.dart';
import '../../data/datasources/firebase_datasource.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/stock_repository.dart';
import '../../data/repositories/watchlist_repository.dart';

// ---------------------------------------------------------------------------
// Shared Preferences
// ---------------------------------------------------------------------------

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

// ---------------------------------------------------------------------------
// API Key
// ---------------------------------------------------------------------------

final apiKeyProvider = Provider<String>((ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  return prefsAsync.when(
    data: (prefs) =>
        prefs.getString(AppConstants.prefApiKey) ?? AppConstants.defaultApiKey,
    loading: () => AppConstants.defaultApiKey,
    error: (_, __) => AppConstants.defaultApiKey,
  );
});

// -----------------------------------------------z----------------------------
// Data Sources
// ---------------------------------------------------------------------------

final alphaVantageApiProvider = Provider<AlphaVantageApi>((ref) {
  final apiKey = ref.watch(apiKeyProvider);
  return AlphaVantageApi(apiKey: apiKey);
});

final firebaseDatasourceProvider = Provider<FirebaseDatasource>((ref) {
  return FirebaseDatasource();
});

// ---------------------------------------------------------------------------
// Repositories
// ---------------------------------------------------------------------------

final stockRepositoryProvider = Provider<StockRepository>((ref) {
  final api = ref.watch(alphaVantageApiProvider);
  return StockRepository(api: api);
});

final watchlistRepositoryProvider = Provider<WatchlistRepository>((ref) {
  final datasource = ref.watch(firebaseDatasourceProvider);
  return WatchlistRepository(datasource: datasource);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final datasource = ref.watch(firebaseDatasourceProvider);
  return AuthRepository(datasource: datasource);
});
