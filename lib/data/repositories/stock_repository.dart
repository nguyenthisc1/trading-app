import 'package:candlesticks/candlesticks.dart';
import '../datasources/alpha_vantage_api.dart';
import '../models/indicator_data.dart';
import '../models/news_item.dart';
import '../models/search_result.dart';
import '../models/stock_quote.dart';

class StockRepository {
  final AlphaVantageApi _api;

  StockRepository({required AlphaVantageApi api}) : _api = api;

  Future<StockQuote> getQuote(String symbol) => _api.getQuote(symbol);

  Future<List<StockQuote>> getQuotes(List<String> symbols) =>
      _api.getMultipleQuotes(symbols);

  Future<List<Candle>> getCandles(
    String symbol, {
    required String timeframe,
  }) async {
    switch (timeframe) {
      case '1D':
        final raw = await _api.getIntraday(
          symbol,
          interval: '5min',
          outputSize: 'compact',
        );
        return raw.cast<Candle>();
      case '1W':
        final raw = await _api.getIntraday(
          symbol,
          interval: '60min',
          outputSize: 'full',
        );
        return (raw.cast<Candle>()).take(7 * 7).toList(); // ~7 trading days
      case '1M':
        final raw = await _api.getDaily(symbol, outputSize: 'compact');
        return (raw.cast<Candle>()).take(30).toList();
      case '3M':
        final raw = await _api.getDaily(symbol, outputSize: 'full');
        return (raw.cast<Candle>()).take(90).toList();
      case '1Y':
        final raw = await _api.getDaily(symbol, outputSize: 'full');
        return (raw.cast<Candle>()).take(365).toList();
      default:
        final raw = await _api.getIntraday(symbol, interval: '5min');
        return raw.cast<Candle>();
    }
  }

  Future<IndicatorData> getSma(
    String symbol, {
    int period = 20,
    String timeframe = '1D',
  }) =>
      _api.getSma(
        symbol,
        timePeriod: period,
        interval: _mapTimeframeToInterval(timeframe),
      );

  Future<IndicatorData> getEma(
    String symbol, {
    int period = 20,
    String timeframe = '1D',
  }) =>
      _api.getEma(
        symbol,
        timePeriod: period,
        interval: _mapTimeframeToInterval(timeframe),
      );

  Future<IndicatorData> getRsi(
    String symbol, {
    int period = 14,
    String timeframe = '1D',
  }) =>
      _api.getRsi(
        symbol,
        timePeriod: period,
        interval: _mapTimeframeToInterval(timeframe),
      );

  Future<List<MacdPoint>> getMacd(String symbol, {String timeframe = '1D'}) =>
      _api.getMacd(
        symbol,
        interval: _mapTimeframeToInterval(timeframe),
      );

  Future<List<BbandsPoint>> getBbands(
    String symbol, {
    int period = 20,
    String timeframe = '1D',
  }) =>
      _api.getBbands(
        symbol,
        timePeriod: period,
        interval: _mapTimeframeToInterval(timeframe),
      );

  Future<List<SearchResult>> searchSymbol(String query) =>
      _api.searchSymbol(query);

  Future<List<NewsItem>> getNews({String? tickers, int limit = 20}) =>
      _api.getNewsSentiment(tickers: tickers, limit: limit);

  String _mapTimeframeToInterval(String timeframe) {
    switch (timeframe) {
      case '1D':
        return '5min';
      case '1W':
        return '60min';
      default:
        return 'daily';
    }
  }
}
