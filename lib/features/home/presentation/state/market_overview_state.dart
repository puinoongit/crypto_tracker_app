import 'package:equatable/equatable.dart';

import 'package:crypto_tracker_app/features/home/domain/entity/global_market.dart';
import 'package:crypto_tracker_app/features/home/domain/entity/trending_coin.dart';

/// Staged load order for the markets header: global → trending → coin list.
enum MarketOverviewPhase { idle, loadingGlobal, loadingTrending, complete }

/// Immutable state for the markets-overview header (global card + trending row).
///
/// The header is non-blocking: it never shows a full-screen error. If a section
/// fails to load it simply stays hidden, so the market list is always usable.
class MarketOverviewState extends Equatable {
  const MarketOverviewState({
    this.global,
    this.trending = const [],
    this.phase = MarketOverviewPhase.idle,
    this.isLoading = true,
  });

  final GlobalMarket? global;
  final List<TrendingCoin> trending;
  final MarketOverviewPhase phase;
  final bool isLoading;

  bool get hasGlobal => global != null;
  bool get hasTrending => trending.isNotEmpty;

  /// Header fetch finished — the coin list may start loading.
  bool get isHeaderComplete => phase == MarketOverviewPhase.complete;

  bool get showGlobalSkeleton =>
      !hasGlobal &&
      (phase == MarketOverviewPhase.idle ||
          phase == MarketOverviewPhase.loadingGlobal);

  bool get showTrendingSkeleton =>
      !hasTrending && phase == MarketOverviewPhase.loadingTrending;

  MarketOverviewState copyWith({
    GlobalMarket? global,
    List<TrendingCoin>? trending,
    MarketOverviewPhase? phase,
    bool? isLoading,
  }) {
    return MarketOverviewState(
      global: global ?? this.global,
      trending: trending ?? this.trending,
      phase: phase ?? this.phase,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [global, trending, phase, isLoading];
}
