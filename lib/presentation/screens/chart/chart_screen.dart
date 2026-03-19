import 'package:candlesticks/candlesticks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../data/models/indicator_data.dart';
import '../../viewmodels/chart_provider.dart';
import '../../viewmodels/indicators_provider.dart';
import '../../viewmodels/watchlist_provider.dart';
import '../../widgets/chart/indicator_panel.dart';
import '../../widgets/chart/timeframe_picker.dart';
import '../../widgets/price_badge.dart';

class ChartScreen extends ConsumerStatefulWidget {
  final String symbol;

  const ChartScreen({super.key, required this.symbol});

  @override
  ConsumerState<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends ConsumerState<ChartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedSymbolProvider.notifier).state = widget.symbol;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chartState = ref.watch(chartStateProvider);
    final active = ref.watch(activeIndicatorsProvider);
    final isInWatchlist = ref.watch(isInWatchlistProvider(widget.symbol));

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => context.pop(),
        ),
        title: _ChartAppBarTitle(
          symbol: widget.symbol,
          quote: chartState.quote,
        ),
        actions: [
          isInWatchlist.when(
            data: (inList) => IconButton(
              icon: Icon(
                inList ? Icons.star : Icons.star_border,
                color: inList ? AppColors.accent : null,
              ),
              onPressed: () async {
                final notifier = ref.read(watchlistNotifierProvider.notifier);
                if (inList) {
                  await notifier.removeSymbol(widget.symbol);
                } else {
                  await notifier.addSymbol(widget.symbol);
                }
              },
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          IconButton(
            icon: const Icon(Icons.tune_outlined),
            onPressed: () => _showIndicatorSheet(context, ref),
          ),
        ],
      ),
      body: chartState.candles.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(error: error.toString()),
        data: (candles) => _ChartBody(
          candles: candles,
          timeframe: chartState.timeframe,
          active: active,
          isDark: isDark,
        ),
      ),
    );
  }

  void _showIndicatorSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkSurface
              : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _IndicatorSheet(ref: ref),
    );
  }
}

class _ChartAppBarTitle extends StatelessWidget {
  final String symbol;
  final AsyncValue<dynamic> quote;

  const _ChartAppBarTitle({required this.symbol, required this.quote});

  @override
  Widget build(BuildContext context) {
    return quote.when(
      loading: () => Text(symbol),
      error: (_, __) => Text(symbol),
      data: (q) => Row(
        children: [
          Text(
            symbol,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 12),
          Text(
            '\$${NumberFormatter.formatPrice(q.price)}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: q.isPositive ? AppColors.bullish : AppColors.bearish,
            ),
          ),
          const SizedBox(width: 8),
          PriceBadge(changePercent: q.changePercent, compact: true),
        ],
      ),
    );
  }
}

class _ChartBody extends ConsumerWidget {
  final List<Candle> candles;
  final String timeframe;
  final ActiveIndicators active;
  final bool isDark;

  const _ChartBody({
    required this.candles,
    required this.timeframe,
    required this.active,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbol = ref.watch(selectedSymbolProvider);

    // Pull RSI and MACD data if active
    final rsiAsync = active.showRsi ? ref.watch(currentRsiProvider) : null;
    final macdAsync = active.showMacd ? ref.watch(currentMacdProvider) : null;

    return Column(
      children: [
        // Timeframe picker
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TimeframePicker(
                  selected: timeframe,
                  onSelected: (tf) {
                    ref.read(selectedTimeframeProvider.notifier).state = tf;
                  },
                ),
              ),
            ],
          ),
        ),
        // Main candlestick chart
        Expanded(
          flex: 3,
          child: candles.isEmpty
              ? const Center(
                  child: Text(
                    'No data available',
                    style: TextStyle(color: AppColors.darkTextSecondary),
                  ),
                )
              : Candlesticks(
                  candles: candles,
                  onLoadMoreCandles: () async {},
                  actions: [
                    ToolBarAction(
                      child: const Icon(Icons.bar_chart, size: 18),
                      onPressed: () {},
                    ),
                  ],
                ),
        ),
        // Indicator sub-panels
        if (active.showVolume && candles.isNotEmpty) ...[
          const _PanelDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: VolumePanel(
              volumes: candles.map((c) => c.volume).toList(),
              isBullish: candles.map((c) => c.close >= c.open).toList(),
            ),
          ),
        ],
        if (active.showRsi && rsiAsync != null) ...[
          const _PanelDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: rsiAsync.when(
              loading: () => const _PanelLoading(label: 'RSI'),
              error: (_, __) => const _PanelError(label: 'RSI'),
              data: (data) => data != null
                  ? RsiPanel(points: data.points.take(100).toList())
                  : const SizedBox.shrink(),
            ),
          ),
        ],
        if (active.showMacd && macdAsync != null) ...[
          const _PanelDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: macdAsync.when(
              loading: () => const _PanelLoading(label: 'MACD'),
              error: (_, __) => const _PanelError(label: 'MACD'),
              data: (data) => data != null
                  ? MacdPanel(points: data.take(100).toList())
                  : const SizedBox.shrink(),
            ),
          ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }
}

class _PanelDivider extends StatelessWidget {
  const _PanelDivider();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 1,
      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      margin: const EdgeInsets.symmetric(vertical: 4),
    );
  }
}

class _PanelLoading extends StatelessWidget {
  final String label;

  const _PanelLoading({required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Center(
        child: Text(
          'Loading $label...',
          style: const TextStyle(
            color: AppColors.darkTextSecondary,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _PanelError extends StatelessWidget {
  final String label;

  const _PanelError({required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Center(
        child: Text(
          '$label unavailable',
          style: const TextStyle(
            color: AppColors.bearish,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.bearish, size: 48),
            const SizedBox(height: 16),
            Text(
              'Failed to load chart data',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                color: AppColors.darkTextSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _IndicatorSheet extends StatelessWidget {
  final WidgetRef ref;

  const _IndicatorSheet({required this.ref});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = ref.watch(activeIndicatorsProvider);
    final indicators = [
      ('SMA', 'Simple Moving Average', active.showSma),
      ('EMA', 'Exponential Moving Average', active.showEma),
      ('BBANDS', 'Bollinger Bands', active.showBbands),
      ('RSI', 'Relative Strength Index', active.showRsi),
      ('MACD', 'MACD', active.showMacd),
      ('Volume', 'Volume', active.showVolume),
    ];

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.darkBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Technical Indicators',
              style: theme.textTheme.titleLarge,
            ),
          ),
          ...indicators.map((item) {
            final (key, label, isActive) = item;
            return SwitchListTile(
              title: Text(key, style: theme.textTheme.titleMedium),
              subtitle: Text(label, style: theme.textTheme.bodySmall),
              value: isActive,
              onChanged: (_) =>
                  ref.read(activeIndicatorsProvider.notifier).toggle(key),
              activeColor: AppColors.primary,
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
