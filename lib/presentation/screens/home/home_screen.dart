import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../news/news_screen.dart';
import '../search/search_screen.dart';
import '../settings/settings_screen.dart';
import '../watchlist/watchlist_screen.dart';
import 'market_overview_screen.dart';

final _navIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  final Widget child;

  const HomeScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(_navIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const [
          MarketOverviewScreen(),
          WatchlistScreen(),
          SearchScreen(),
          NewsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) =>
            ref.read(_navIndexProvider.notifier).state = i,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.show_chart_outlined),
            selectedIcon: Icon(Icons.show_chart),
            label: 'Markets',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_outline),
            selectedIcon: Icon(Icons.star),
            label: 'Watchlist',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article),
            label: 'News',
          ),
        ],
      ),
    );
  }
}

// Placeholder for ShellRoute compatibility
class HomeShellContent extends StatelessWidget {
  const HomeShellContent({super.key});

  @override
  Widget build(BuildContext context) => const MarketOverviewScreen();
}
