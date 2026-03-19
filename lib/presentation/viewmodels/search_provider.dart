import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/search_result.dart';
import '../../data/repositories/stock_repository.dart';
import 'providers.dart';

// ---------------------------------------------------------------------------
// Search query
// ---------------------------------------------------------------------------

final searchQueryProvider = StateProvider<String>((ref) => '');

// ---------------------------------------------------------------------------
// Debounced search results
// ---------------------------------------------------------------------------

class SearchNotifier extends AsyncNotifier<List<SearchResult>> {
  Timer? _debounce;

  @override
  Future<List<SearchResult>> build() async => [];

  void search(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      state = const AsyncData([]);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    state = const AsyncLoading();
    final repo = ref.read(stockRepositoryProvider);
    state = await AsyncValue.guard(() => repo.searchSymbol(query));
  }

  void clear() {
    _debounce?.cancel();
    state = const AsyncData([]);
  }
}

final searchNotifierProvider =
    AsyncNotifierProvider<SearchNotifier, List<SearchResult>>(
  SearchNotifier.new,
);
