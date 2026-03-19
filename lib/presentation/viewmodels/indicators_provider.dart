import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/indicator_data.dart';
import '../../data/repositories/stock_repository.dart';
import 'chart_provider.dart';
import 'providers.dart';

// ---------------------------------------------------------------------------
// Active indicators configuration
// ---------------------------------------------------------------------------

final activeIndicatorsProvider =
    NotifierProvider<ActiveIndicatorsNotifier, ActiveIndicators>(
  ActiveIndicatorsNotifier.new,
);

class ActiveIndicatorsNotifier extends Notifier<ActiveIndicators> {
  @override
  ActiveIndicators build() => const ActiveIndicators(showVolume: true);

  void toggle(String indicator) {
    switch (indicator) {
      case 'SMA':
        state = state.copyWith(showSma: !state.showSma);
      case 'EMA':
        state = state.copyWith(showEma: !state.showEma);
      case 'BBANDS':
        state = state.copyWith(showBbands: !state.showBbands);
      case 'RSI':
        state = state.copyWith(showRsi: !state.showRsi);
      case 'MACD':
        state = state.copyWith(showMacd: !state.showMacd);
      case 'Volume':
        state = state.copyWith(showVolume: !state.showVolume);
    }
  }

  void updateSmaPeriod(int period) =>
      state = state.copyWith(smaPeriod: period);
  void updateEmaPeriod(int period) =>
      state = state.copyWith(emaPeriod: period);
  void updateRsiPeriod(int period) =>
      state = state.copyWith(rsiPeriod: period);
}

// ---------------------------------------------------------------------------
// SMA data
// ---------------------------------------------------------------------------

final smaDataProvider =
    FutureProvider.family<IndicatorData, ({String symbol, String timeframe, int period})>(
  (ref, args) {
    final repo = ref.watch(stockRepositoryProvider);
    return repo.getSma(args.symbol, period: args.period, timeframe: args.timeframe);
  },
);

// ---------------------------------------------------------------------------
// EMA data
// ---------------------------------------------------------------------------

final emaDataProvider =
    FutureProvider.family<IndicatorData, ({String symbol, String timeframe, int period})>(
  (ref, args) {
    final repo = ref.watch(stockRepositoryProvider);
    return repo.getEma(args.symbol, period: args.period, timeframe: args.timeframe);
  },
);

// ---------------------------------------------------------------------------
// RSI data
// ---------------------------------------------------------------------------

final rsiDataProvider =
    FutureProvider.family<IndicatorData, ({String symbol, String timeframe, int period})>(
  (ref, args) {
    final repo = ref.watch(stockRepositoryProvider);
    return repo.getRsi(args.symbol, period: args.period, timeframe: args.timeframe);
  },
);

// ---------------------------------------------------------------------------
// MACD data
// ---------------------------------------------------------------------------

final macdDataProvider =
    FutureProvider.family<List<MacdPoint>, ({String symbol, String timeframe})>(
  (ref, args) {
    final repo = ref.watch(stockRepositoryProvider);
    return repo.getMacd(args.symbol, timeframe: args.timeframe);
  },
);

// ---------------------------------------------------------------------------
// Bollinger Bands data
// ---------------------------------------------------------------------------

final bbandsDataProvider =
    FutureProvider.family<List<BbandsPoint>, ({String symbol, String timeframe, int period})>(
  (ref, args) {
    final repo = ref.watch(stockRepositoryProvider);
    return repo.getBbands(args.symbol, period: args.period, timeframe: args.timeframe);
  },
);

// ---------------------------------------------------------------------------
// Convenience: current chart's indicator args
// ---------------------------------------------------------------------------

final currentSmaProvider = FutureProvider<IndicatorData?>((ref) async {
  final active = ref.watch(activeIndicatorsProvider);
  if (!active.showSma) return null;
  final symbol = ref.watch(selectedSymbolProvider);
  final timeframe = ref.watch(selectedTimeframeProvider);
  return ref.watch(
    smaDataProvider((symbol: symbol, timeframe: timeframe, period: active.smaPeriod)).future,
  );
});

final currentEmaProvider = FutureProvider<IndicatorData?>((ref) async {
  final active = ref.watch(activeIndicatorsProvider);
  if (!active.showEma) return null;
  final symbol = ref.watch(selectedSymbolProvider);
  final timeframe = ref.watch(selectedTimeframeProvider);
  return ref.watch(
    emaDataProvider((symbol: symbol, timeframe: timeframe, period: active.emaPeriod)).future,
  );
});

final currentRsiProvider = FutureProvider<IndicatorData?>((ref) async {
  final active = ref.watch(activeIndicatorsProvider);
  if (!active.showRsi) return null;
  final symbol = ref.watch(selectedSymbolProvider);
  final timeframe = ref.watch(selectedTimeframeProvider);
  return ref.watch(
    rsiDataProvider((symbol: symbol, timeframe: timeframe, period: active.rsiPeriod)).future,
  );
});

final currentMacdProvider = FutureProvider<List<MacdPoint>?>((ref) async {
  final active = ref.watch(activeIndicatorsProvider);
  if (!active.showMacd) return null;
  final symbol = ref.watch(selectedSymbolProvider);
  final timeframe = ref.watch(selectedTimeframeProvider);
  return ref.watch(
    macdDataProvider((symbol: symbol, timeframe: timeframe)).future,
  );
});
