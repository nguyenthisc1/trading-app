class SearchResult {
  final String symbol;
  final String name;
  final String type;
  final String region;
  final String marketOpen;
  final String marketClose;
  final String timezone;
  final String currency;
  final String matchScore;

  const SearchResult({
    required this.symbol,
    required this.name,
    required this.type,
    required this.region,
    required this.marketOpen,
    required this.marketClose,
    required this.timezone,
    required this.currency,
    required this.matchScore,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      symbol: json['1. symbol'] as String? ?? '',
      name: json['2. name'] as String? ?? '',
      type: json['3. type'] as String? ?? '',
      region: json['4. region'] as String? ?? '',
      marketOpen: json['5. marketOpen'] as String? ?? '',
      marketClose: json['6. marketClose'] as String? ?? '',
      timezone: json['7. timezone'] as String? ?? '',
      currency: json['8. currency'] as String? ?? '',
      matchScore: json['9. matchScore'] as String? ?? '',
    );
  }

  static List<SearchResult> parseList(Map<String, dynamic> json) {
    final matches = json['bestMatches'] as List<dynamic>? ?? [];
    return matches
        .map((e) => SearchResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
