class IndicatorPoint {
  final DateTime date;
  final double value;

  const IndicatorPoint({required this.date, required this.value});
}

class MacdPoint {
  final DateTime date;
  final double macd;
  final double signal;
  final double histogram;

  const MacdPoint({
    required this.date,
    required this.macd,
    required this.signal,
    required this.histogram,
  });
}

class BbandsPoint {
  final DateTime date;
  final double upperBand;
  final double middleBand;
  final double lowerBand;

  const BbandsPoint({
    required this.date,
    required this.upperBand,
    required this.middleBand,
    required this.lowerBand,
  });
}

class IndicatorData {
  final String type;
  final String symbol;
  final List<IndicatorPoint> points;

  const IndicatorData({
    required this.type,
    required this.symbol,
    required this.points,
  });

  factory IndicatorData.fromAlphaVantage(
    Map<String, dynamic> json,
    String type,
    String symbol,
  ) {
    final seriesKey = 'Technical Analysis: $type';
    final series = json[seriesKey] as Map<String, dynamic>? ?? {};
    final valueKey = _getValueKey(type);

    final points = series.entries.map((entry) {
      final values = entry.value as Map<String, dynamic>;
      return IndicatorPoint(
        date: DateTime.parse(entry.key),
        value: double.tryParse(values[valueKey] as String? ?? '0') ?? 0,
      );
    }).toList();

    points.sort((a, b) => b.date.compareTo(a.date));
    return IndicatorData(type: type, symbol: symbol, points: points);
  }

  static String _getValueKey(String type) {
    switch (type) {
      case 'SMA':
        return 'SMA';
      case 'EMA':
        return 'EMA';
      case 'RSI':
        return 'RSI';
      default:
        return type;
    }
  }

  static List<MacdPoint> parseMacd(
    Map<String, dynamic> json,
    String symbol,
  ) {
    const seriesKey = 'Technical Analysis: MACD';
    final series = json[seriesKey] as Map<String, dynamic>? ?? {};

    final points = series.entries.map((entry) {
      final values = entry.value as Map<String, dynamic>;
      return MacdPoint(
        date: DateTime.parse(entry.key),
        macd: double.tryParse(values['MACD'] as String? ?? '0') ?? 0,
        signal: double.tryParse(values['MACD_Signal'] as String? ?? '0') ?? 0,
        histogram:
            double.tryParse(values['MACD_Hist'] as String? ?? '0') ?? 0,
      );
    }).toList();

    points.sort((a, b) => b.date.compareTo(a.date));
    return points;
  }

  static List<BbandsPoint> parseBbands(
    Map<String, dynamic> json,
    String symbol,
  ) {
    const seriesKey = 'Technical Analysis: BBANDS';
    final series = json[seriesKey] as Map<String, dynamic>? ?? {};

    final points = series.entries.map((entry) {
      final values = entry.value as Map<String, dynamic>;
      return BbandsPoint(
        date: DateTime.parse(entry.key),
        upperBand:
            double.tryParse(values['Real Upper Band'] as String? ?? '0') ?? 0,
        middleBand:
            double.tryParse(values['Real Middle Band'] as String? ?? '0') ?? 0,
        lowerBand:
            double.tryParse(values['Real Lower Band'] as String? ?? '0') ?? 0,
      );
    }).toList();

    points.sort((a, b) => b.date.compareTo(a.date));
    return points;
  }
}

class ActiveIndicators {
  final bool showSma;
  final bool showEma;
  final bool showBbands;
  final bool showRsi;
  final bool showMacd;
  final bool showVolume;
  final int smaPeriod;
  final int emaPeriod;
  final int rsiPeriod;

  const ActiveIndicators({
    this.showSma = false,
    this.showEma = false,
    this.showBbands = false,
    this.showRsi = false,
    this.showMacd = false,
    this.showVolume = true,
    this.smaPeriod = 20,
    this.emaPeriod = 20,
    this.rsiPeriod = 14,
  });

  ActiveIndicators copyWith({
    bool? showSma,
    bool? showEma,
    bool? showBbands,
    bool? showRsi,
    bool? showMacd,
    bool? showVolume,
    int? smaPeriod,
    int? emaPeriod,
    int? rsiPeriod,
  }) {
    return ActiveIndicators(
      showSma: showSma ?? this.showSma,
      showEma: showEma ?? this.showEma,
      showBbands: showBbands ?? this.showBbands,
      showRsi: showRsi ?? this.showRsi,
      showMacd: showMacd ?? this.showMacd,
      showVolume: showVolume ?? this.showVolume,
      smaPeriod: smaPeriod ?? this.smaPeriod,
      emaPeriod: emaPeriod ?? this.emaPeriod,
      rsiPeriod: rsiPeriod ?? this.rsiPeriod,
    );
  }
}
