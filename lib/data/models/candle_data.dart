import 'package:candlesticks/candlesticks.dart';

class CandleData {
  final String symbol;
  final String interval;
  final List<Candle> candles;

  const CandleData({
    required this.symbol,
    required this.interval,
    required this.candles,
  });

  static List<Candle> parseIntraday(
    Map<String, dynamic> json,
    String interval,
  ) {
    final key = 'Time Series ($interval)';
    final timeSeries = json[key] as Map<String, dynamic>? ?? {};
    return _parseSeries(timeSeries);
  }

  static List<Candle> parseDaily(Map<String, dynamic> json) {
    final timeSeries =
        json['Time Series (Daily)'] as Map<String, dynamic>? ?? {};
    return _parseSeries(timeSeries);
  }

  static List<Candle> _parseSeries(Map<String, dynamic> timeSeries) {
    final candles = timeSeries.entries.map((entry) {
      final values = entry.value as Map<String, dynamic>;
      return Candle(
        date: DateTime.parse(entry.key),
        open: double.tryParse(values['1. open'] as String? ?? '0') ?? 0,
        high: double.tryParse(values['2. high'] as String? ?? '0') ?? 0,
        low: double.tryParse(values['3. low'] as String? ?? '0') ?? 0,
        close: double.tryParse(values['4. close'] as String? ?? '0') ?? 0,
        volume: double.tryParse(values['5. volume'] as String? ?? '0') ?? 0,
      );
    }).toList();

    // Most recent first (candlesticks widget expects newest at index 0)
    candles.sort((a, b) => b.date.compareTo(a.date));
    return candles;
  }
}
