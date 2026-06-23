// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'ติดตามคริปโต';

  @override
  String get navMarket => 'ตลาด';

  @override
  String get navSearch => 'ค้นหา';

  @override
  String get navFavorites => 'รายการโปรด';

  @override
  String get searchHint => 'ค้นหาด้วยชื่อหรือสัญลักษณ์';

  @override
  String get searchServerMode => 'กำลังค้นหาทุกเหรียญบน CoinGecko';

  @override
  String searchMinCharsHint(int minChars) {
    return 'พิมพ์อย่างน้อย $minChars ตัวอักษรเพื่อค้นหา';
  }

  @override
  String get searchEmptyTitle => 'ค้นหาเหรียญทั้งหมด';

  @override
  String searchEmptyMessage(int minChars) {
    return 'พิมพ์อย่างน้อย $minChars ตัวอักษรเพื่อค้นหาบน CoinGecko';
  }

  @override
  String searchLocalMode(int minChars) {
    return 'กรองจากรายการที่โหลดแล้ว — พิมพ์ $minChars ตัวขึ้นไปเพื่อค้นหาทั้งหมด';
  }

  @override
  String get searchHistoryTitle => 'ค้นหาล่าสุด';

  @override
  String get searchHistoryClear => 'ล้าง';

  @override
  String get overviewGlobalTitle => 'ภาพรวมตลาด';

  @override
  String get offlineBannerMessage =>
      'คุณกำลังออฟไลน์ กำลังแสดงข้อมูลที่บันทึกไว้';

  @override
  String get retry => 'ลองใหม่';

  @override
  String get emptyMarketTitle => 'ไม่มีเหรียญให้แสดง';

  @override
  String get emptyMarketMessage => 'ขณะนี้ไม่พบเหรียญที่จะแสดง';

  @override
  String get emptySearchTitle => 'ไม่พบผลลัพธ์';

  @override
  String emptySearchMessage(String query) {
    return 'ไม่มีเหรียญที่ตรงกับ \"$query\"';
  }

  @override
  String get emptyFavoritesTitle => 'ยังไม่มีรายการโปรด';

  @override
  String get emptyFavoritesMessage =>
      'แตะรูปดาวบนเหรียญใดก็ได้เพื่อเพิ่มที่นี่';

  @override
  String get endOfListReached => 'คุณดูครบทั้งรายการแล้ว';

  @override
  String get errorNoInternetTitle => 'ไม่มีการเชื่อมต่ออินเทอร์เน็ต';

  @override
  String get errorNoInternetMessage => 'โปรดตรวจสอบการเชื่อมต่อแล้วลองอีกครั้ง';

  @override
  String get errorTimeoutTitle => 'หมดเวลาคำขอ';

  @override
  String get errorTimeoutMessage =>
      'เซิร์ฟเวอร์ใช้เวลานานเกินไป โปรดลองอีกครั้ง';

  @override
  String get errorServerTitle => 'เกิดข้อผิดพลาดบางอย่าง';

  @override
  String get errorServerMessage =>
      'เซิร์ฟเวอร์ตอบกลับข้อผิดพลาด โปรดลองใหม่ภายหลัง';

  @override
  String get errorUnknownTitle => 'ข้อผิดพลาดที่ไม่คาดคิด';

  @override
  String get errorUnknownMessage =>
      'เกิดข้อผิดพลาดที่ไม่คาดคิด โปรดลองอีกครั้ง';

  @override
  String get errorCacheTitle => 'ไม่มีข้อมูลที่บันทึกไว้';

  @override
  String get errorCacheMessage =>
      'คุณกำลังออฟไลน์และไม่มีข้อมูลที่บันทึกไว้ให้แสดง';

  @override
  String get coinDetailMarketCap => 'มูลค่าตลาด';

  @override
  String get coinDetailVolume => 'ปริมาณ 24 ชม.';

  @override
  String get coinDetailAth => 'สูงสุดตลอดกาล';

  @override
  String get coinDetailAtl => 'ต่ำสุดตลอดกาล';

  @override
  String get coinDetailRank => 'อันดับ';

  @override
  String coinDetailRankShort(int rank) {
    return 'อันดับ #$rank';
  }

  @override
  String get coinDetailSupply => 'อุปทานหมุนเวียน';

  @override
  String get coinDetailMaxSupply => 'อุปทานสูงสุด';

  @override
  String get maxSupplyUncapped => '∞ ไม่จำกัด';

  @override
  String get overviewTrending => 'กำลังมาแรง';

  @override
  String get overviewMarketCapLabel => 'มูลค่าตลาด · 24 ชม.';

  @override
  String get overviewVolumeLabel => 'ปริมาณ · 24 ชม.';

  @override
  String coinDetailAbout(String name) {
    return 'เกี่ยวกับ $name';
  }

  @override
  String get addToFavorites => 'เพิ่มในรายการโปรด';

  @override
  String get removeFromFavorites => 'ลบออกจากรายการโปรด';

  @override
  String get settingsTheme => 'ธีม';

  @override
  String get settingsLanguage => 'ภาษา';

  @override
  String get themeSystem => 'ระบบ';

  @override
  String get themeLight => 'สว่าง';

  @override
  String get themeDark => 'มืด';

  @override
  String get settingsLiveUpdates => 'อัปเดตอัตโนมัติ';

  @override
  String get settingsLiveUpdatesTitle => 'รีเฟรชราคาตลาดอัตโนมัติ';

  @override
  String get settingsLiveUpdatesSubtitle =>
      'อัปเดตทุก 120 วินาทีบนแท็บตลาดเมื่อออนไลน์ ปิดแล้วยังดึงข้อมูลด้วยการดึงลงได้';

  @override
  String get refreshUpdating => 'กำลังอัปเดตข้อมูล';
}
