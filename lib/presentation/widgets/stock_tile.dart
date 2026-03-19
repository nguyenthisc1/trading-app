import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/number_formatter.dart';
import '../../data/models/stock_quote.dart';
import 'price_badge.dart';

class StockTile extends StatelessWidget {
  final StockQuote? quote;
  final String symbol;
  final String? name;
  final bool isLoading;
  final VoidCallback? onTap;
  final Widget? trailing;

  const StockTile({
    super.key,
    required this.symbol,
    this.name,
    this.quote,
    this.isLoading = false,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _SymbolAvatar(symbol: symbol, isDark: isDark),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    symbol,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (name != null || quote?.name != null)
                    Text(
                      name ?? quote!.name,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isLoading)
              const SizedBox(
                width: 60,
                child: _PriceLoadingShimmer(),
              )
            else if (quote != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${NumberFormatter.formatPrice(quote!.price)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: quote!.isPositive
                          ? AppColors.bullish
                          : AppColors.bearish,
                    ),
                  ),
                  const SizedBox(height: 2),
                  PriceBadge(
                    changePercent: quote!.changePercent,
                    compact: true,
                  ),
                ],
              ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

class _SymbolAvatar extends StatelessWidget {
  final String symbol;
  final bool isDark;

  const _SymbolAvatar({required this.symbol, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = _colorFromSymbol(symbol);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          symbol.length > 2 ? symbol.substring(0, 2) : symbol,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Color _colorFromSymbol(String symbol) {
    const colors = [
      AppColors.primary,
      AppColors.accent,
      AppColors.indicatorSma,
      AppColors.indicatorEma,
      Color(0xFF9C27B0),
      Color(0xFFFF9800),
      Color(0xFFE91E63),
      Color(0xFF00BCD4),
    ];
    final index = symbol.codeUnitAt(0) % colors.length;
    return colors[index];
  }
}

class _PriceLoadingShimmer extends StatelessWidget {
  const _PriceLoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          height: 14,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 10,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}
