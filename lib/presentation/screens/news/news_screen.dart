import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/news_item.dart';
import '../../viewmodels/news_provider.dart';
import '../../widgets/price_badge.dart';

class NewsScreen extends ConsumerWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final newsAsync = ref.watch(filteredNewsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Market News', style: theme.textTheme.headlineSmall),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => ref.invalidate(marketNewsProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          const _TopicFilterBar(),
          Expanded(
            child: newsAsync.when(
              loading: () => const _NewsLoadingList(),
              error: (error, _) => _NewsError(error: error.toString()),
              data: (news) {
                if (news.isEmpty) {
                  return const _EmptyNews();
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(marketNewsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: news.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _NewsCard(item: news[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicFilterBar extends ConsumerWidget {
  const _TopicFilterBar();

  static const topics = [
    ('All', null),
    ('Technology', 'technology'),
    ('Finance', 'finance'),
    ('Earnings', 'earnings'),
    ('IPO', 'ipo'),
    ('Economy', 'economy_macro'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(newsTopicFilterProvider);

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: topics.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (label, value) = topics[index];
          final isSelected = selected == value;
          return FilterChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (_) {
              ref.read(newsTopicFilterProvider.notifier).state = value;
            },
          );
        },
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsItem item;

  const _NewsCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _openUrl(item.url),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.bannerImage.isNotEmpty) _BannerImage(url: item.bannerImage),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source + time + sentiment
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.source,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (item.publishedAt != null)
                        Text(
                          DateFormatter.formatRelative(item.publishedAt!),
                          style: theme.textTheme.labelSmall,
                        ),
                      const SizedBox(width: 8),
                      SentimentBadge(label: item.overallSentimentLabel),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Title
                  Text(
                    item.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Summary
                  Text(
                    item.summary,
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Related tickers
                  if (item.tickerSentiment.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: item.tickerSentiment.take(3).map((t) {
                        final score = double.tryParse(
                              t.tickerSentimentScore,
                            ) ??
                            0;
                        final isPositive = score >= 0;
                        final color =
                            isPositive ? AppColors.bullish : AppColors.bearish;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: color.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            t.ticker,
                            style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _BannerImage extends StatelessWidget {
  final String url;

  const _BannerImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      height: 160,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        height: 160,
        color: AppColors.darkCard,
        child: const Center(
          child: Icon(Icons.image_outlined, color: AppColors.darkTextHint),
        ),
      ),
      errorWidget: (_, __, ___) => const SizedBox.shrink(),
    );
  }
}

class _NewsLoadingList extends StatelessWidget {
  const _NewsLoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const _NewsCardSkeleton(),
    );
  }
}

class _NewsCardSkeleton extends StatelessWidget {
  const _NewsCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerColor = isDark
        ? AppColors.darkCard
        : AppColors.lightCard;

    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: shimmerColor,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _EmptyNews extends StatelessWidget {
  const _EmptyNews();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 64, color: AppColors.darkTextHint),
          SizedBox(height: 16),
          Text(
            'No news available',
            style: TextStyle(color: AppColors.darkTextSecondary),
          ),
        ],
      ),
    );
  }
}

class _NewsError extends StatelessWidget {
  final String error;

  const _NewsError({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: AppColors.bearish),
            const SizedBox(height: 16),
            Text(
              'Failed to load news',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                color: AppColors.darkTextSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
