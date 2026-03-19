import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/number_formatter.dart';

class PriceBadge extends StatelessWidget {
  final double changePercent;
  final bool compact;

  const PriceBadge({
    super.key,
    required this.changePercent,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = changePercent >= 0;
    final color = isPositive ? AppColors.bullish : AppColors.bearish;
    final icon = isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down;
    final text = NumberFormatter.formatPercent(changePercent);

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class SentimentBadge extends StatelessWidget {
  final String label;

  const SentimentBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (label.toLowerCase()) {
      case 'bullish':
        color = AppColors.bullish;
      case 'somewhat-bullish':
        color = AppColors.bullish.withValues(alpha: 0.8);
      case 'bearish':
        color = AppColors.bearish;
      case 'somewhat-bearish':
        color = AppColors.bearish.withValues(alpha: 0.8);
      default:
        color = AppColors.sentimentNeutral;
    }

    String displayLabel;
    switch (label.toLowerCase()) {
      case 'bullish':
        displayLabel = 'Bullish';
      case 'somewhat-bullish':
        displayLabel = 'Somewhat Bullish';
      case 'bearish':
        displayLabel = 'Bearish';
      case 'somewhat-bearish':
        displayLabel = 'Somewhat Bearish';
      default:
        displayLabel = 'Neutral';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        displayLabel,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
