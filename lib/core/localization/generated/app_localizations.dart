import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_th.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('th'),
  ];

  /// Application title shown on the home app bar.
  ///
  /// In en, this message translates to:
  /// **'Crypto Tracker'**
  String get appTitle;

  /// No description provided for @navMarket.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get navMarket;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or symbol'**
  String get searchHint;

  /// No description provided for @searchServerMode.
  ///
  /// In en, this message translates to:
  /// **'Searching all coins on CoinGecko'**
  String get searchServerMode;

  /// No description provided for @searchMinCharsHint.
  ///
  /// In en, this message translates to:
  /// **'Type at least {minChars} characters to search'**
  String searchMinCharsHint(int minChars);

  /// No description provided for @searchEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Search all coins'**
  String get searchEmptyTitle;

  /// No description provided for @searchEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter at least {minChars} characters to search CoinGecko.'**
  String searchEmptyMessage(int minChars);

  /// No description provided for @searchLocalMode.
  ///
  /// In en, this message translates to:
  /// **'Filtering loaded coins — type {minChars}+ chars to search all'**
  String searchLocalMode(int minChars);

  /// No description provided for @searchHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get searchHistoryTitle;

  /// No description provided for @searchHistoryClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get searchHistoryClear;

  /// No description provided for @overviewGlobalTitle.
  ///
  /// In en, this message translates to:
  /// **'Global overview'**
  String get overviewGlobalTitle;

  /// No description provided for @offlineBannerMessage.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Showing cached data.'**
  String get offlineBannerMessage;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @emptyMarketTitle.
  ///
  /// In en, this message translates to:
  /// **'No coins available'**
  String get emptyMarketTitle;

  /// No description provided for @emptyMarketMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find any coins to display right now.'**
  String get emptyMarketMessage;

  /// No description provided for @emptySearchTitle.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get emptySearchTitle;

  /// No description provided for @emptySearchMessage.
  ///
  /// In en, this message translates to:
  /// **'No coins match \"{query}\".'**
  String emptySearchMessage(String query);

  /// No description provided for @emptyFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get emptyFavoritesTitle;

  /// No description provided for @emptyFavoritesMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap the star on any coin to add it here.'**
  String get emptyFavoritesMessage;

  /// No description provided for @endOfListReached.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the end of the list.'**
  String get endOfListReached;

  /// No description provided for @errorNoInternetTitle.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get errorNoInternetTitle;

  /// No description provided for @errorNoInternetMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again.'**
  String get errorNoInternetMessage;

  /// No description provided for @errorTimeoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Request timed out'**
  String get errorTimeoutTitle;

  /// No description provided for @errorTimeoutMessage.
  ///
  /// In en, this message translates to:
  /// **'The server took too long to respond. Please try again.'**
  String get errorTimeoutMessage;

  /// No description provided for @errorServerTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorServerTitle;

  /// No description provided for @errorServerMessage.
  ///
  /// In en, this message translates to:
  /// **'Our servers returned an error. Please try again later.'**
  String get errorServerMessage;

  /// No description provided for @errorUnknownTitle.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error'**
  String get errorUnknownTitle;

  /// No description provided for @errorUnknownMessage.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get errorUnknownMessage;

  /// No description provided for @errorCacheTitle.
  ///
  /// In en, this message translates to:
  /// **'No cached data'**
  String get errorCacheTitle;

  /// No description provided for @errorCacheMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline and we have no saved data to show.'**
  String get errorCacheMessage;

  /// No description provided for @coinDetailMarketCap.
  ///
  /// In en, this message translates to:
  /// **'Market Cap'**
  String get coinDetailMarketCap;

  /// No description provided for @coinDetailVolume.
  ///
  /// In en, this message translates to:
  /// **'24h Volume'**
  String get coinDetailVolume;

  /// No description provided for @coinDetailAth.
  ///
  /// In en, this message translates to:
  /// **'All-Time High'**
  String get coinDetailAth;

  /// No description provided for @coinDetailAtl.
  ///
  /// In en, this message translates to:
  /// **'All-Time Low'**
  String get coinDetailAtl;

  /// No description provided for @coinDetailRank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get coinDetailRank;

  /// No description provided for @coinDetailRankShort.
  ///
  /// In en, this message translates to:
  /// **'RANK #{rank}'**
  String coinDetailRankShort(int rank);

  /// No description provided for @coinDetailSupply.
  ///
  /// In en, this message translates to:
  /// **'Circulating Supply'**
  String get coinDetailSupply;

  /// No description provided for @coinDetailMaxSupply.
  ///
  /// In en, this message translates to:
  /// **'Max Supply'**
  String get coinDetailMaxSupply;

  /// No description provided for @maxSupplyUncapped.
  ///
  /// In en, this message translates to:
  /// **'∞ uncapped'**
  String get maxSupplyUncapped;

  /// No description provided for @overviewTrending.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get overviewTrending;

  /// No description provided for @overviewMarketCapLabel.
  ///
  /// In en, this message translates to:
  /// **'Market Cap · 24h'**
  String get overviewMarketCapLabel;

  /// No description provided for @overviewVolumeLabel.
  ///
  /// In en, this message translates to:
  /// **'Volume · 24h'**
  String get overviewVolumeLabel;

  /// No description provided for @coinDetailAbout.
  ///
  /// In en, this message translates to:
  /// **'About {name}'**
  String coinDetailAbout(String name);

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @settingsLiveUpdates.
  ///
  /// In en, this message translates to:
  /// **'Live updates'**
  String get settingsLiveUpdates;

  /// No description provided for @settingsLiveUpdatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-refresh market prices'**
  String get settingsLiveUpdatesTitle;

  /// No description provided for @settingsLiveUpdatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Refresh every 120s on the Market tab while online. Pull-to-refresh still works when off.'**
  String get settingsLiveUpdatesSubtitle;

  /// No description provided for @refreshUpdating.
  ///
  /// In en, this message translates to:
  /// **'Syncing live data'**
  String get refreshUpdating;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'th'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'th':
      return AppLocalizationsTh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
