import 'package:equatable/equatable.dart';

import 'package:crypto_tracker_app/core/config/api_config.dart';
import 'package:crypto_tracker_app/core/error/failure.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/coin.dart';

/// UI state for the dedicated Search tab (server-side CoinGecko search).
class SearchState extends Equatable {
  const SearchState({
    this.query = '',
    this.results = const [],
    this.history = const [],
    this.isLoading = false,
    this.hasCompletedSearch = false,
    this.failure,
  });

  final String query;
  final List<Coin> results;
  final List<String> history;
  final bool isLoading;

  /// `true` once the current [query] has finished a network/cache lookup.
  final bool hasCompletedSearch;
  final Failure? failure;

  bool get hasQuery => query.trim().isNotEmpty;

  bool get canSearch => query.trim().length >= ApiConfig.searchMinLength;

  SearchState copyWith({
    String? query,
    List<Coin>? results,
    List<String>? history,
    bool? isLoading,
    bool? hasCompletedSearch,
    Failure? failure,
    bool clearFailure = false,
    bool clearResults = false,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: clearResults ? const [] : (results ?? this.results),
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      hasCompletedSearch: hasCompletedSearch ?? this.hasCompletedSearch,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [
    query,
    results,
    history,
    isLoading,
    hasCompletedSearch,
    failure,
  ];
}
