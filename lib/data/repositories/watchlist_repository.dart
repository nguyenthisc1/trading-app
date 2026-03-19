import '../datasources/firebase_datasource.dart';
import '../models/watchlist_item.dart';

class WatchlistRepository {
  final FirebaseDatasource _datasource;

  WatchlistRepository({required FirebaseDatasource datasource})
      : _datasource = datasource;

  Stream<List<WatchlistItem>> watchlistStream(String uid) =>
      _datasource.watchlistStream(uid);

  Future<List<WatchlistItem>> getWatchlist(String uid) =>
      _datasource.getWatchlist(uid);

  Future<void> addSymbol(String uid, String symbol, {String? name}) =>
      _datasource.addToWatchlist(uid, symbol, name: name);

  Future<void> removeSymbol(String uid, String symbol) =>
      _datasource.removeFromWatchlist(uid, symbol);

  Future<bool> containsSymbol(String uid, String symbol) =>
      _datasource.isInWatchlist(uid, symbol);
}
