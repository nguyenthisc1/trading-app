import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/stock_quote.dart';
import '../../data/models/watchlist_item.dart';
import '../../data/repositories/stock_repository.dart';
import '../../data/repositories/watchlist_repository.dart';
import 'auth_provider.dart';
import 'providers.dart';

// ---------------------------------------------------------------------------
// Watchlist items (Firestore stream)
// ---------------------------------------------------------------------------

final watchlistItemsProvider = StreamProvider<List<WatchlistItem>>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.valueOrNull;
  if (user == null) return const Stream.empty();

  final repo = ref.watch(watchlistRepositoryProvider);
  return repo.watchlistStream(user.uid);
});

// ---------------------------------------------------------------------------
// Watchlist quotes (fetched for all items)
// ---------------------------------------------------------------------------

final watchlistQuotesProvider =
    FutureProvider<Map<String, StockQuote>>((ref) async {
  final items = ref.watch(watchlistItemsProvider).valueOrNull ?? [];
  if (items.isEmpty) return {};

  final repo = ref.watch(stockRepositoryProvider);
  final symbols = items.map((e) => e.symbol).toList();
  final quotes = await repo.getQuotes(symbols);

  return {for (final q in quotes) q.symbol: q};
});

// ---------------------------------------------------------------------------
// Watchlist notifier (add/remove)
// ---------------------------------------------------------------------------

class WatchlistNotifier extends Notifier<void> {
  @override
  void build() {}

  WatchlistRepository get _repo => ref.read(watchlistRepositoryProvider);

  String? get _uid => ref.read(authStateProvider).valueOrNull?.uid;

  Future<void> addSymbol(String symbol, {String? name}) async {
    final uid = _uid;
    if (uid == null) return;
    await _repo.addSymbol(uid, symbol, name: name);
  }

  Future<void> removeSymbol(String symbol) async {
    final uid = _uid;
    if (uid == null) return;
    await _repo.removeSymbol(uid, symbol);
  }

  Future<bool> contains(String symbol) async {
    final uid = _uid;
    if (uid == null) return false;
    return _repo.containsSymbol(uid, symbol);
  }
}

final watchlistNotifierProvider = NotifierProvider<WatchlistNotifier, void>(
  WatchlistNotifier.new,
);

// Convenience: check if a specific symbol is in watchlist
final isInWatchlistProvider = FutureProvider.family<bool, String>((ref, symbol) async {
  final items = ref.watch(watchlistItemsProvider).valueOrNull ?? [];
  return items.any((item) => item.symbol == symbol);
});
