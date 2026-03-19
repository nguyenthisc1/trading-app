import 'package:cloud_firestore/cloud_firestore.dart';

class WatchlistItem {
  final String symbol;
  final String? name;
  final DateTime addedAt;

  const WatchlistItem({
    required this.symbol,
    this.name,
    required this.addedAt,
  });

  factory WatchlistItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WatchlistItem(
      symbol: data['symbol'] as String? ?? doc.id,
      name: data['name'] as String?,
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'symbol': symbol,
      if (name != null) 'name': name,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  WatchlistItem copyWith({String? symbol, String? name, DateTime? addedAt}) {
    return WatchlistItem(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
