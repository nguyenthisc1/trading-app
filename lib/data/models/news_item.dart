class NewsTickerSentiment {
  final String ticker;
  final String relevanceScore;
  final String tickerSentimentScore;
  final String tickerSentimentLabel;

  const NewsTickerSentiment({
    required this.ticker,
    required this.relevanceScore,
    required this.tickerSentimentScore,
    required this.tickerSentimentLabel,
  });

  factory NewsTickerSentiment.fromJson(Map<String, dynamic> json) {
    return NewsTickerSentiment(
      ticker: json['ticker'] as String? ?? '',
      relevanceScore: json['relevance_score'] as String? ?? '0',
      tickerSentimentScore: json['ticker_sentiment_score'] as String? ?? '0',
      tickerSentimentLabel: json['ticker_sentiment_label'] as String? ?? 'Neutral',
    );
  }
}

enum SentimentLabel { bullish, somewhatBullish, neutral, somewhatBearish, bearish }

class NewsItem {
  final String title;
  final String url;
  final String timePublished;
  final List<String> authors;
  final String summary;
  final String bannerImage;
  final String source;
  final String sourceDomain;
  final List<String> topics;
  final double overallSentimentScore;
  final String overallSentimentLabel;
  final List<NewsTickerSentiment> tickerSentiment;

  const NewsItem({
    required this.title,
    required this.url,
    required this.timePublished,
    required this.authors,
    required this.summary,
    required this.bannerImage,
    required this.source,
    required this.sourceDomain,
    required this.topics,
    required this.overallSentimentScore,
    required this.overallSentimentLabel,
    required this.tickerSentiment,
  });

  SentimentLabel get sentiment {
    switch (overallSentimentLabel.toLowerCase()) {
      case 'bullish':
        return SentimentLabel.bullish;
      case 'somewhat-bullish':
        return SentimentLabel.somewhatBullish;
      case 'somewhat-bearish':
        return SentimentLabel.somewhatBearish;
      case 'bearish':
        return SentimentLabel.bearish;
      default:
        return SentimentLabel.neutral;
    }
  }

  DateTime? get publishedAt {
    // Format: 20240115T130000
    try {
      final s = timePublished;
      return DateTime(
        int.parse(s.substring(0, 4)),
        int.parse(s.substring(4, 6)),
        int.parse(s.substring(6, 8)),
        int.parse(s.substring(9, 11)),
        int.parse(s.substring(11, 13)),
      );
    } catch (_) {
      return null;
    }
  }

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    final authorsRaw = json['authors'];
    final List<String> authors = authorsRaw is List
        ? authorsRaw.map((e) => e.toString()).toList()
        : [];

    final topicsRaw = json['topics'];
    final List<String> topics = topicsRaw is List
        ? (topicsRaw as List)
            .map((e) => (e as Map<String, dynamic>)['topic']?.toString() ?? '')
            .toList()
        : [];

    final tickerRaw = json['ticker_sentiment'];
    final List<NewsTickerSentiment> tickerSentiment = tickerRaw is List
        ? (tickerRaw as List)
            .map((e) => NewsTickerSentiment.fromJson(e as Map<String, dynamic>))
            .toList()
        : [];

    return NewsItem(
      title: json['title'] as String? ?? '',
      url: json['url'] as String? ?? '',
      timePublished: json['time_published'] as String? ?? '',
      authors: authors,
      summary: json['summary'] as String? ?? '',
      bannerImage: json['banner_image'] as String? ?? '',
      source: json['source'] as String? ?? '',
      sourceDomain: json['source_domain'] as String? ?? '',
      topics: topics,
      overallSentimentScore:
          double.tryParse(json['overall_sentiment_score']?.toString() ?? '0') ?? 0,
      overallSentimentLabel: json['overall_sentiment_label'] as String? ?? 'Neutral',
      tickerSentiment: tickerSentiment,
    );
  }

  static List<NewsItem> parseList(Map<String, dynamic> json) {
    final feed = json['feed'] as List<dynamic>? ?? [];
    return feed
        .map((e) => NewsItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
