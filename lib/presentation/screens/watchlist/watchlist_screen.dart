import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/watchlist_item.dart';
import '../../viewmodels/auth_provider.dart';
import '../../viewmodels/watchlist_provider.dart';
import '../../widgets/stock_tile.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Watchlist', style: theme.textTheme.headlineSmall),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(AppRoutes.home + '/search-add'),
            tooltip: 'Add symbol',
          ),
        ],
      ),
      body: authState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const _NotLoggedInView(),
        data: (user) {
          if (user == null) return const _NotLoggedInView();
          return const _WatchlistContent();
        },
      ),
    );
  }
}

class _WatchlistContent extends ConsumerWidget {
  const _WatchlistContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(watchlistItemsProvider);
    final quotesAsync = ref.watch(watchlistQuotesProvider);

    return itemsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorView(error: error.toString()),
      data: (items) {
        if (items.isEmpty) return const _EmptyWatchlist();

        final quotes = quotesAsync.valueOrNull ?? {};

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(watchlistQuotesProvider),
          child: ReorderableListView.builder(
            onReorder: (_, __) {}, // Optional: persist order to Firestore
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final quote = quotes[item.symbol];
              return _DismissibleTile(
                key: ValueKey(item.symbol),
                item: item,
                quote: quote,
                isLoading: quotesAsync.isLoading,
                onTap: () => context.push(AppRoutes.chartPath(item.symbol)),
                onDismiss: () => _removeItem(context, ref, item),
              );
            },
          ),
        );
      },
    );
  }

  void _removeItem(
    BuildContext context,
    WidgetRef ref,
    WatchlistItem item,
  ) async {
    await ref.read(watchlistNotifierProvider.notifier).removeSymbol(item.symbol);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.symbol} removed from watchlist'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              ref.read(watchlistNotifierProvider.notifier).addSymbol(
                item.symbol,
                name: item.name,
              );
            },
          ),
        ),
      );
    }
  }
}

class _DismissibleTile extends StatelessWidget {
  final WatchlistItem item;
  final dynamic quote;
  final bool isLoading;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _DismissibleTile({
    super.key,
    required this.item,
    this.quote,
    required this.isLoading,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: ValueKey(item.symbol),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.bearish,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        ),
        child: Column(
          children: [
            StockTile(
              symbol: item.symbol,
              name: item.name,
              quote: quote,
              isLoading: isLoading,
              onTap: onTap,
              trailing: const Icon(
                Icons.drag_handle,
                color: AppColors.darkTextHint,
                size: 20,
              ),
            ),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }
}

class _EmptyWatchlist extends StatelessWidget {
  const _EmptyWatchlist();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_outline,
              size: 64,
              color: AppColors.darkTextHint,
            ),
            const SizedBox(height: 16),
            Text('Your watchlist is empty', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Search for symbols and add them to track their prices.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.search, size: 18),
              label: const Text('Find Symbols'),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _NotLoggedInView extends StatelessWidget {
  const _NotLoggedInView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: AppColors.darkTextHint),
            const SizedBox(height: 16),
            Text(
              'Sign in to save your watchlist',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.push(AppRoutes.login),
              child: const Text('Sign In'),
            ),
          ],
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
      child: Text(
        'Error: $error',
        style: const TextStyle(color: AppColors.bearish),
      ),
    );
  }
}
