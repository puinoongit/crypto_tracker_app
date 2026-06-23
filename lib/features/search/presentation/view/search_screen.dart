import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crypto_tracker_app/core/config/api_config.dart';
import 'package:crypto_tracker_app/core/config/performance_config.dart';
import 'package:crypto_tracker_app/core/localization/generated/app_localizations.dart';
import 'package:crypto_tracker_app/core/utils/debouncer.dart';
import 'package:crypto_tracker_app/core/widgets/empty_view.dart';
import 'package:crypto_tracker_app/core/widgets/error_view.dart';
import 'package:crypto_tracker_app/core/widgets/pull_to_refresh_sliver_scroll.dart';
import 'package:crypto_tracker_app/features/home/presentation/view/widgets/coin_list_item.dart';
import 'package:crypto_tracker_app/features/home/presentation/view/widgets/market_list_skeleton.dart';
import 'package:crypto_tracker_app/features/search/presentation/state/search_state.dart';
import 'package:crypto_tracker_app/features/search/presentation/view_model/search_view_model.dart';
import 'widgets/search_history_chips.dart';

/// Dedicated search tab — server-side CoinGecko search only.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final savedQuery = ref.read(searchViewModelProvider).query;
    if (savedQuery.isNotEmpty) {
      _searchController.text = savedQuery;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debouncer.run(() {
      ref.read(searchViewModelProvider.notifier).search(value);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(searchViewModelProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _buildSuffix(state),
                ),
              ),
              if (state.hasQuery) ...[
                const SizedBox(height: 6),
                Text(
                  state.canSearch
                      ? l10n.searchServerMode
                      : l10n.searchMinCharsHint(ApiConfig.searchMinLength),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (!state.hasQuery && state.history.isNotEmpty)
          SearchHistoryChips(
            queries: state.history,
            onSelected: (query) {
              _searchController.text = query;
              _searchController.selection = TextSelection.collapsed(
                offset: query.length,
              );
              ref
                  .read(searchViewModelProvider.notifier)
                  .searchFromHistory(query);
              setState(() {});
            },
            onClear: () {
              ref.read(searchViewModelProvider.notifier).clearHistory();
              setState(() {});
            },
          ),
        Expanded(child: _SearchBody(state: state)),
      ],
    );
  }

  Widget? _buildSuffix(SearchState state) {
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (!state.hasQuery) return null;
    return IconButton(
      icon: const Icon(Icons.clear_rounded),
      onPressed: () {
        _searchController.clear();
        ref.read(searchViewModelProvider.notifier).clear();
        setState(() {});
      },
    );
  }
}

class _SearchBody extends ConsumerWidget {
  const _SearchBody({required this.state});

  final SearchState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    if (!state.hasQuery) {
      if (state.history.isNotEmpty) {
        return const SizedBox.shrink();
      }
      return EmptyView(
        icon: Icons.search_rounded,
        title: l10n.searchEmptyTitle,
        message: l10n.searchEmptyMessage(ApiConfig.searchMinLength),
      );
    }

    if (!state.canSearch) {
      return const SizedBox.shrink();
    }

    if (state.failure != null) {
      return ErrorView(
        failure: state.failure!,
        onRetry: () => ref.read(searchViewModelProvider.notifier).refresh(),
      );
    }

    if (state.isLoading && state.results.isEmpty) {
      return const MarketListSkeleton();
    }

    if (state.hasCompletedSearch &&
        state.results.isEmpty &&
        state.failure == null) {
      return EmptyView(
        icon: Icons.search_off_rounded,
        title: l10n.emptySearchTitle,
        message: l10n.emptySearchMessage(state.query.trim()),
      );
    }

    return PullToRefreshSliverScroll(
      isRefreshing: state.isLoading,
      onRefresh: () => ref.read(searchViewModelProvider.notifier).refresh(),
      scrollKey: const PageStorageKey<String>('search_coin_list'),
      scrollCacheExtent: PerformanceConfig.listCacheExtent,
      slivers: [
        SliverList.separated(
          itemCount: state.results.length,
          separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
          itemBuilder: (context, index) {
            final coin = state.results[index];
            return CoinListItem(
              key: ValueKey(coin.id),
              coin: coin,
              enableHero: true,
            );
          },
        ),
      ],
    );
  }
}
