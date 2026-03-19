import 'package:dio/dio.dart';
import '../models/candle_data.dart';
import '../models/indicator_data.dart';
import '../models/news_item.dart';
import '../models/search_result.dart';
import '../models/stock_quote.dart';
import '../../core/constants/api_constants.dart';

class AlphaVantageException implements Exception {
  final String message;
  final int? statusCode;

  const AlphaVantageException(this.message, {this.statusCode});

  @override
  String toString() => 'AlphaVantageException: $message';
}

class AlphaVantageApi {
  final Dio _dio;
  String _apiKey;

  AlphaVantageApi({required String apiKey})
      : _apiKey = apiKey,
        _dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.alphaVantageBaseUrl,
            connectTimeout: ApiConstants.connectTimeout,
            receiveTimeout: ApiConstants.receiveTimeout,
            responseType: ResponseType.json,
          ),
        ) {
    _dio.interceptors.add(
      LogInterceptor(requestBody: false, responseBody: false),
    );
  }

  void updateApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  Map<String, String> get _baseParams => {'apikey': _apiKey};

  Future<Map<String, dynamic>> _get(Map<String, String> params) async {
    try {
      final response = await _dio.get(
        '',
        queryParameters: {..._baseParams, ...params},
      );
      final data = response.data as Map<String, dynamic>;
      if (data.containsKey('Note')) {
        throw const AlphaVantageException(
          'API rate limit reached. Please wait before making another request.',
        );
      }
      if (data.containsKey('Information')) {
        throw AlphaVantageException(data['Information'] as String);
      }
      return data;
    } on DioException catch (e) {
      throw AlphaVantageException(
        e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<StockQuote> getQuote(String symbol) async {
    final data = await _get({
      'function': ApiConstants.globalQuote,
      'symbol': symbol,
    });
    return StockQuote.fromAlphaVantage(data);
  }

  Future<List<StockQuote>> getMultipleQuotes(List<String> symbols) async {
    final futures = symbols.map((s) => getQuote(s));
    final results = await Future.wait(futures, eagerError: false);
    return results;
  }

  Future<List<dynamic>> getIntraday(
    String symbol, {
    String interval = ApiConstants.interval5min,
    String outputSize = ApiConstants.outputSizeCompact,
  }) async {
    final data = await _get({
      'function': ApiConstants.timeSeriesIntraday,
      'symbol': symbol,
      'interval': interval,
      'outputsize': outputSize,
    });
    return CandleData.parseIntraday(data, interval);
  }

  Future<List<dynamic>> getDaily(
    String symbol, {
    String outputSize = ApiConstants.outputSizeCompact,
  }) async {
    final data = await _get({
      'function': ApiConstants.timeSeriesDaily,
      'symbol': symbol,
      'outputsize': outputSize,
    });
    return CandleData.parseDaily(data);
  }

  Future<IndicatorData> getSma(
    String symbol, {
    int timePeriod = 20,
    String interval = 'daily',
    String seriesType = 'close',
  }) async {
    final data = await _get({
      'function': ApiConstants.sma,
      'symbol': symbol,
      'interval': interval,
      'time_period': timePeriod.toString(),
      'series_type': seriesType,
    });
    return IndicatorData.fromAlphaVantage(data, 'SMA', symbol);
  }

  Future<IndicatorData> getEma(
    String symbol, {
    int timePeriod = 20,
    String interval = 'daily',
    String seriesType = 'close',
  }) async {
    final data = await _get({
      'function': ApiConstants.ema,
      'symbol': symbol,
      'interval': interval,
      'time_period': timePeriod.toString(),
      'series_type': seriesType,
    });
    return IndicatorData.fromAlphaVantage(data, 'EMA', symbol);
  }

  Future<IndicatorData> getRsi(
    String symbol, {
    int timePeriod = 14,
    String interval = 'daily',
    String seriesType = 'close',
  }) async {
    final data = await _get({
      'function': ApiConstants.rsi,
      'symbol': symbol,
      'interval': interval,
      'time_period': timePeriod.toString(),
      'series_type': seriesType,
    });
    return IndicatorData.fromAlphaVantage(data, 'RSI', symbol);
  }

  Future<List<MacdPoint>> getMacd(
    String symbol, {
    String interval = 'daily',
    String seriesType = 'close',
    int fastPeriod = 12,
    int slowPeriod = 26,
    int signalPeriod = 9,
  }) async {
    final data = await _get({
      'function': ApiConstants.macd,
      'symbol': symbol,
      'interval': interval,
      'series_type': seriesType,
      'fastperiod': fastPeriod.toString(),
      'slowperiod': slowPeriod.toString(),
      'signalperiod': signalPeriod.toString(),
    });
    return IndicatorData.parseMacd(data, symbol);
  }

  Future<List<BbandsPoint>> getBbands(
    String symbol, {
    int timePeriod = 20,
    String interval = 'daily',
    String seriesType = 'close',
  }) async {
    final data = await _get({
      'function': ApiConstants.bbands,
      'symbol': symbol,
      'interval': interval,
      'time_period': timePeriod.toString(),
      'series_type': seriesType,
    });
    return IndicatorData.parseBbands(data, symbol);
  }

  Future<List<SearchResult>> searchSymbol(String keywords) async {
    final data = await _get({
      'function': ApiConstants.symbolSearch,
      'keywords': keywords,
    });
    return SearchResult.parseList(data);
  }

  Future<List<NewsItem>> getNewsSentiment({
    String? tickers,
    String? topics,
    int limit = 20,
    String? timeFrom,
    String? timeTo,
  }) async {
    final params = <String, String>{
      'function': ApiConstants.newsSentiment,
      'limit': limit.toString(),
    };
    if (tickers != null) params['tickers'] = tickers;
    if (topics != null) params['topics'] = topics;
    if (timeFrom != null) params['time_from'] = timeFrom;
    if (timeTo != null) params['time_to'] = timeTo;

    final data = await _get(params);
    return NewsItem.parseList(data);
  }
}
