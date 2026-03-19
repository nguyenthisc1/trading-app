class StockQuote {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final double changePercent;
  final double open;
  final double high;
  final double low;
  final double previousClose;
  final double volume;
  final DateTime? latestTradingDay;

  const StockQuote({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.open,
    required this.high,
    required this.low,
    required this.previousClose,
    required this.volume,
    this.latestTradingDay,
  });

  bool get isPositive => change >= 0;

  factory StockQuote.fromAlphaVantage(Map<String, dynamic> json) {
    final q = json['Global Quote'] as Map<String, dynamic>? ?? {};
    final changeStr = (q['09. change'] as String? ?? '0').replaceAll('%', '');
    final changePercentStr =
        (q['10. change percent'] as String? ?? '0%').replaceAll('%', '');
    return StockQuote(
      symbol: q['01. symbol'] as String? ?? '',
      name: q['01. symbol'] as String? ?? '',
      price: double.tryParse(q['05. price'] as String? ?? '0') ?? 0,
      change: double.tryParse(changeStr) ?? 0,
      changePercent: double.tryParse(changePercentStr) ?? 0,
      open: double.tryParse(q['02. open'] as String? ?? '0') ?? 0,
      high: double.tryParse(q['03. high'] as String? ?? '0') ?? 0,
      low: double.tryParse(q['04. low'] as String? ?? '0') ?? 0,
      previousClose: double.tryParse(q['08. previous close'] as String? ?? '0') ?? 0,
      volume: double.tryParse(q['06. volume'] as String? ?? '0') ?? 0,
      latestTradingDay: DateTime.tryParse(q['07. latest trading day'] as String? ?? ''),
    );
  }

  StockQuote copyWith({
    String? symbol,
    String? name,
    double? price,
    double? change,
    double? changePercent,
    double? open,
    double? high,
    double? low,
    double? previousClose,
    double? volume,
    DateTime? latestTradingDay,
  }) {
    return StockQuote(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      price: price ?? this.price,
      change: change ?? this.change,
      changePercent: changePercent ?? this.changePercent,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      previousClose: previousClose ?? this.previousClose,
      volume: volume ?? this.volume,
      latestTradingDay: latestTradingDay ?? this.latestTradingDay,
    );
  }
}
