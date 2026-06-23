import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crypto_tracker_app/core/config/api_config.dart';
import 'package:crypto_tracker_app/features/search/data/datasource/search_local_datasource.dart';
import 'package:crypto_tracker_app/features/search/domain/usecase/search_coins.dart';
import 'package:crypto_tracker_app/features/search/presentation/search_providers.dart';
import 'package:crypto_tracker_app/features/search/presentation/state/search_state.dart';

/// Server-side coin search for the dedicated Search tab.
class SearchViewModel extends Notifier<SearchState> {
  late final SearchCoins _searchCoins;
  late final SearchLocalDataSource _local;
  bool _initialized = false;

  @override
  SearchState build() {
    _searchCoins = ref.watch(searchCoinsUseCaseProvider);
    _local = ref.watch(searchLocalDataSourceProvider);

    ref.onDispose(() => _initialized = false);

    if (!_initialized) {
      _initialized = true;
      final history = _local.readSearchHistory();
      final savedQuery = _local.readLastSearchQuery();
      if (savedQuery != null &&
          savedQuery.length >= ApiConfig.searchMinLength) {
        Future.microtask(() => _restoreSession(savedQuery));
        return SearchState(
          query: savedQuery,
          history: history,
          isLoading: true,
        );
      }
      return SearchState(history: history);
    }

    return state;
  }

  Future<void> _restoreSession(String query) async {
    if (!ref.exists(searchViewModelProvider)) return;
    state = state.copyWith(query: query, isLoading: true);
    await _runSearch(query);
  }

  Future<void> search(String query) async {
    if (query == state.query && state.isLoading) return;

    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      unawaited(_local.clearLastSearchQuery());
      state = state.copyWith(
        query: '',
        clearResults: true,
        isLoading: false,
        hasCompletedSearch: false,
        clearFailure: true,
      );
      return;
    }

    if (trimmed.length < ApiConfig.searchMinLength) {
      state = state.copyWith(
        query: query,
        clearResults: true,
        isLoading: false,
        hasCompletedSearch: false,
        clearFailure: true,
      );
      return;
    }

    final queryChanged = trimmed != state.query.trim();
    state = state.copyWith(
      query: query,
      clearResults: queryChanged,
      isLoading: true,
      hasCompletedSearch: false,
      clearFailure: true,
    );

    await _runSearch(trimmed);
  }

  Future<void> searchFromHistory(String query) => search(query);

  void clear() {
    unawaited(_local.clearLastSearchQuery());
    state = state.copyWith(
      query: '',
      clearResults: true,
      isLoading: false,
      hasCompletedSearch: false,
      clearFailure: true,
    );
  }

  Future<void> clearHistory() async {
    await _local.clearSearchHistory();
    state = state.copyWith(history: const []);
  }

  Future<void> refresh() async {
    final trimmed = state.query.trim();
    if (trimmed.length < ApiConfig.searchMinLength) return;
    state = state.copyWith(isLoading: true, clearFailure: true);
    await _runSearch(trimmed, forceRefresh: true);
  }

  Future<void> _runSearch(String query, {bool forceRefresh = false}) async {
    final result = await _searchCoins(
      SearchCoinsParams(query: query, forceRefresh: forceRefresh),
    );

    if (state.query.trim() != query) {
      state = state.copyWith(isLoading: false);
      return;
    }

    state = result.fold(
      (failure) => state.copyWith(
        results: const [],
        isLoading: false,
        hasCompletedSearch: true,
        failure: failure,
      ),
      (coins) {
        unawaited(_local.saveLastSearchQuery(query));
        unawaited(_persistHistoryEntry(query));
        return state.copyWith(
          results: coins,
          isLoading: false,
          hasCompletedSearch: true,
          clearFailure: true,
        );
      },
    );
  }

  Future<void> _persistHistoryEntry(String query) async {
    await _local.addSearchHistoryEntry(query);
    if (!ref.exists(searchViewModelProvider)) return;
    state = state.copyWith(history: _local.readSearchHistory());
  }
}

final searchViewModelProvider = NotifierProvider<SearchViewModel, SearchState>(
  SearchViewModel.new,
);
