import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../data/models/stock_quote.dart';
import '../../viewmodels/chart_provider.dart';
import '../../viewmodels/providers.dart';
import '../../widgets/stock_tile.dart';

class MarketOverviewScreen extends ConsumerWidget {
  const MarketOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(stockRepositoryProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  'Top Movers',
                  style: theme.textTheme.titleLarge,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            const SliverToBoxAdapter(child: _TopMoversList()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Text('All Markets', style: theme.textTheme.titleLarge),
              ),
            ),
            _MarketList(),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _TopMoversList extends ConsumerWidget {
  const _TopMoversList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbols = AppConstants.defaultWatchlistSymbols.take(5).toList();

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: symbols.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final symbol = symbols[index];
          final quoteAsync = ref.watch(liveQuoteProvider(symbol));
          return _MoverCard(
            symbol: symbol,
            quoteAsync: quoteAsync,
            onTap: () => context.push(AppRoutes.chartPath(symbol)),
          );
        },
      ),
    );
  }
}

class _MoverCard extends StatelessWidget {
  final String symbol;
  final AsyncValue<StockQuote> quoteAsync;
  final VoidCallback onTap;

  const _MoverCard({
    required this.symbol,
    required this.quoteAsync,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: quoteAsync.when(
          loading: () => _loadingContent(isDark),
          error: (_, __) => _errorContent(symbol, theme),
          data: (quote) => _quoteContent(quote, theme),
        ),
      ),
    );
  }

  Widget _quoteContent(StockQuote quote, ThemeData theme) {
    final isPositive = quote.isPositive;
    final color = isPositive ? AppColors.bullish : AppColors.bearish;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          symbol,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          '\$${NumberFormatter.formatPrice(quote.price)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            NumberFormatter.formatPercent(quote.changePercent),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _loadingContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: 12,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Container(
          height: 12,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Container(
          height: 18,
          width: 50,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _errorContent(String symbol, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(symbol, style: theme.textTheme.labelLarge),
        const Text(
          'N/A',
          style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 12),
        ),
        const Icon(Icons.error_outline, color: AppColors.bearish, size: 16),
      ],
    );
  }
}

class _MarketList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbols = AppConstants.defaultWatchlistSymbols;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= symbols.length) return null;
          final symbol = symbols[index];
          final quoteAsync = ref.watch(liveQuoteProvider(symbol));

          return Column(
            children: [
              StockTile(
                symbol: symbol,
                quote: quoteAsync.valueOrNull,
                isLoading: quoteAsync.isLoading,
                onTap: () => context.push(AppRoutes.chartPath(symbol)),
              ),
              const Divider(height: 1),
            ],
          );
        },
        childCount: symbols.length,
      ),
    );
  }
}
