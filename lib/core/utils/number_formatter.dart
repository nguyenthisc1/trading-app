import 'package:intl/intl.dart';

class NumberFormatter {
  NumberFormatter._();

  static final _priceFormat = NumberFormat('#,##0.00', 'en_US');
  static final _compactFormat = NumberFormat.compact(locale: 'en_US');
  static final _percentFormat = NumberFormat('+0.00%;-0.00%', 'en_US');
  static final _volumeFormat = NumberFormat('#,##0', 'en_US');

  static String formatPrice(double price) => _priceFormat.format(price);

  static String formatChange(double change) {
    final sign = change >= 0 ? '+' : '';
    return '$sign${_priceFormat.format(change)}';
  }

  static String formatPercent(double percent) {
    final sign = percent >= 0 ? '+' : '';
    return '$sign${percent.toStringAsFixed(2)}%';
  }

  static String formatVolume(double volume) {
    if (volume >= 1e9) return '${(volume / 1e9).toStringAsFixed(2)}B';
    if (volume >= 1e6) return '${(volume / 1e6).toStringAsFixed(2)}M';
    if (volume >= 1e3) return '${(volume / 1e3).toStringAsFixed(1)}K';
    return _volumeFormat.format(volume);
  }

  static String formatMarketCap(double cap) => _compactFormat.format(cap);

  static String formatIndicatorValue(double value, {int decimals = 2}) {
    return value.toStringAsFixed(decimals);
  }
}
