class AppConstants {
  AppConstants._();

  static const String appName = 'TradeFlow';
  static const String appVersion = '1.0.0';

  // SharedPreferences keys
  static const String prefThemeMode = 'theme_mode';
  static const String prefApiKey = 'alpha_vantage_api_key';
  static const String prefLastSymbol = 'last_viewed_symbol';

  // Default API key (demo — limited to specific symbols)
  static const String defaultApiKey = 'demo';

  // Chart timeframes
  static const List<String> chartTimeframes = ['1D', '1W', '1M', '3M', '1Y'];

  // Default symbols for demo
  static const List<String> defaultWatchlistSymbols = [
    'AAPL',
    'GOOGL',
    'MSFT',
    'AMZN',
    'TSLA',
    'META',
    'NVDA',
  ];

  // Indicators
  static const List<String> availableIndicators = [
    'SMA',
    'EMA',
    'RSI',
    'MACD',
    'BBANDS',
    'Volume',
  ];

  // Default indicator periods
  static const int defaultSmaPeriod = 20;
  static const int defaultEmaPeriod = 20;
  static const int defaultRsiPeriod = 14;

  // Price refresh interval in seconds
  static const int refreshIntervalSeconds = 60;

  // Pagination
  static const int newsPageSize = 20;
}
