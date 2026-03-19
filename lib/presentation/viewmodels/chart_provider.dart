import 'dart:async';
import 'package:candlesticks/candlesticks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/stock_quote.dart';
import '../../data/repositories/stock_repository.dart';
import 'providers.dart';

// ---------------------------------------------------------------------------
// Selected symbol
// ---------------------------------------------------------------------------

class SelectedSymbolNotifier extends Notifier<String> {
  @override
  String build() => 'AAPL';
}

final selectedSymbolProvider =
    NotifierProvider<SelectedSymbolNotifier, String>(SelectedSymbolNotifier.new);

// ---------------------------------------------------------------------------
// Selected timeframe
// ---------------------------------------------------------------------------

class SelectedTimeframeNotifier extends Notifier<String> {
  @override
  String build() => '1D';
}

final selectedTimeframeProvider = NotifierProvider<SelectedTimeframeNotifier, String>(
  SelectedTimeframeNotifier.new,
);

// ---------------------------------------------------------------------------
// Current quote
// ---------------------------------------------------------------------------

final stockQuoteProvider =
    FutureProvider.family<StockQuote, String>((ref, symbol) async {
  final repo = ref.watch(stockRepositoryProvider);
  return repo.getQuote(symbol);
});

// Auto-refreshing quote
final liveQuoteProvider =
    StreamProvider.family<StockQuote, String>((ref, symbol) {
  final repo = ref.watch(stockRepositoryProvider);
  final controller = StreamController<StockQuote>();

  Future<void> fetch() async {
    try {
      final quote = await repo.getQuote(symbol);
      if (!controller.isClosed) controller.add(quote);
    } catch (_) {}
  }

  fetch();
  final timer = Timer.periodic(
    const Duration(seconds: AppConstants.refreshIntervalSeconds),
    (_) => fetch(),
  );

  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });

  return controller.stream;
});

// ---------------------------------------------------------------------------
// Candles
// ---------------------------------------------------------------------------

final candlesProvider = FutureProvider.family<
    List<Candle>, ({String symbol, String timeframe})>((ref, args) {
  final repo = ref.watch(stockRepositoryProvider);
  return repo.getCandles(args.symbol, timeframe: args.timeframe);
});

// ---------------------------------------------------------------------------
// Chart state (combined symbol + candles + quote)
// ---------------------------------------------------------------------------

class ChartState {
  final String symbol;
  final String timeframe;
  final AsyncValue<List<Candle>> candles;
  final AsyncValue<StockQuote> quote;

  const ChartState({
    required this.symbol,
    required this.timeframe,
    required this.candles,
    required this.quote,
  });
}

final chartStateProvider = Provider<ChartState>((ref) {
  final symbol = ref.watch(selectedSymbolProvider);
  final timeframe = ref.watch(selectedTimeframeProvider);
  final candles = ref.watch(
    candlesProvider((symbol: symbol, timeframe: timeframe)),
  );
  final quote = ref.watch(liveQuoteProvider(symbol));

  return ChartState(
    symbol: symbol,
    timeframe: timeframe,
    candles: candles,
    quote: quote,
  );
});
