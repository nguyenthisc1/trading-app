import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/news_item.dart';
import '../../data/repositories/stock_repository.dart';
import 'providers.dart';

// ---------------------------------------------------------------------------
// Market news (general)
// ---------------------------------------------------------------------------

final marketNewsProvider = FutureProvider<List<NewsItem>>((ref) {
  final repo = ref.watch(stockRepositoryProvider);
  return repo.getNews(limit: 20);
});

// ---------------------------------------------------------------------------
// News for a specific symbol
// ---------------------------------------------------------------------------

final symbolNewsProvider =
    FutureProvider.family<List<NewsItem>, String>((ref, symbol) {
  final repo = ref.watch(stockRepositoryProvider);
  return repo.getNews(tickers: symbol, limit: 20);
});

// ---------------------------------------------------------------------------
// Selected news topic filter
// ---------------------------------------------------------------------------

final newsTopicFilterProvider = StateProvider<String?>((ref) => null);

final filteredNewsProvider = Provider<AsyncValue<List<NewsItem>>>((ref) {
  final news = ref.watch(marketNewsProvider);
  final topic = ref.watch(newsTopicFilterProvider);
  if (topic == null) return news;
  return news.whenData(
    (items) => items.where((n) => n.topics.contains(topic)).toList(),
  );
});
