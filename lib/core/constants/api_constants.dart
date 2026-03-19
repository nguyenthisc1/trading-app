class ApiConstants {
  ApiConstants._();

  static const String alphaVantageBaseUrl =
      'https://www.alphavantage.co/query';

  static const String defaultApiKey = 'GS8QL9XIM6JDXWZQ';

  // Alpha Vantage function names
  static const String timeSeriesIntraday = 'TIME_SERIES_INTRADAY';
  static const String timeSeriesDaily = 'TIME_SERIES_DAILY';
  static const String globalQuote = 'GLOBAL_QUOTE';
  static const String symbolSearch = 'SYMBOL_SEARCH';
  static const String sma = 'SMA';
  static const String ema = 'EMA';
  static const String rsi = 'RSI';
  static const String macd = 'MACD';
  static const String bbands = 'BBANDS';
  static const String newsSentiment = 'NEWS_SENTIMENT';
  static const String overview = 'OVERVIEW';

  // Intraday intervals
  static const String interval1min = '1min';
  static const String interval5min = '5min';
  static const String interval15min = '15min';
  static const String interval30min = '30min';
  static const String interval60min = '60min';

  // Output sizes
  static const String outputSizeCompact = 'compact';
  static const String outputSizeFull = 'full';

  // Connection timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
