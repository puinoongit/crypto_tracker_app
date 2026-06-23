// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Crypto Tracker';

  @override
  String get navMarket => 'Market';

  @override
  String get navSearch => 'Search';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get searchHint => 'Search by name or symbol';

  @override
  String get searchServerMode => 'Searching all coins on CoinGecko';

  @override
  String searchMinCharsHint(int minChars) {
    return 'Type at least $minChars characters to search';
  }

  @override
  String get searchEmptyTitle => 'Search all coins';

  @override
  String searchEmptyMessage(int minChars) {
    return 'Enter at least $minChars characters to search CoinGecko.';
  }

  @override
  String searchLocalMode(int minChars) {
    return 'Filtering loaded coins — type $minChars+ chars to search all';
  }

  @override
  String get searchHistoryTitle => 'Recent searches';

  @override
  String get searchHistoryClear => 'Clear';

  @override
  String get overviewGlobalTitle => 'Global overview';

  @override
  String get offlineBannerMessage => 'You are offline. Showing cached data.';

  @override
  String get retry => 'Retry';

  @override
  String get emptyMarketTitle => 'No coins available';

  @override
  String get emptyMarketMessage =>
      'We couldn\'t find any coins to display right now.';

  @override
  String get emptySearchTitle => 'No results';

  @override
  String emptySearchMessage(String query) {
    return 'No coins match \"$query\".';
  }

  @override
  String get emptyFavoritesTitle => 'No favorites yet';

  @override
  String get emptyFavoritesMessage =>
      'Tap the star on any coin to add it here.';

  @override
  String get endOfListReached => 'You\'ve reached the end of the list.';

  @override
  String get errorNoInternetTitle => 'No internet connection';

  @override
  String get errorNoInternetMessage =>
      'Please check your connection and try again.';

  @override
  String get errorTimeoutTitle => 'Request timed out';

  @override
  String get errorTimeoutMessage =>
      'The server took too long to respond. Please try again.';

  @override
  String get errorServerTitle => 'Something went wrong';

  @override
  String get errorServerMessage =>
      'Our servers returned an error. Please try again later.';

  @override
  String get errorUnknownTitle => 'Unexpected error';

  @override
  String get errorUnknownMessage =>
      'An unexpected error occurred. Please try again.';

  @override
  String get errorCacheTitle => 'No cached data';

  @override
  String get errorCacheMessage =>
      'You\'re offline and we have no saved data to show.';

  @override
  String get coinDetailMarketCap => 'Market Cap';

  @override
  String get coinDetailVolume => '24h Volume';

  @override
  String get coinDetailAth => 'All-Time High';

  @override
  String get coinDetailAtl => 'All-Time Low';

  @override
  String get coinDetailRank => 'Rank';

  @override
  String coinDetailRankShort(int rank) {
    return 'RANK #$rank';
  }

  @override
  String get coinDetailSupply => 'Circulating Supply';

  @override
  String get coinDetailMaxSupply => 'Max Supply';

  @override
  String get maxSupplyUncapped => '∞ uncapped';

  @override
  String get overviewTrending => 'Trending';

  @override
  String get overviewMarketCapLabel => 'Market Cap · 24h';

  @override
  String get overviewVolumeLabel => 'Volume · 24h';

  @override
  String coinDetailAbout(String name) {
    return 'About $name';
  }

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsLiveUpdates => 'Live updates';

  @override
  String get settingsLiveUpdatesTitle => 'Auto-refresh market prices';

  @override
  String get settingsLiveUpdatesSubtitle =>
      'Refresh every 120s on the Market tab while online. Pull-to-refresh still works when off.';

  @override
  String get refreshUpdating => 'Syncing live data';
}
