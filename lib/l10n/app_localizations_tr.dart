// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Finder';

  @override
  String get sectionFavorites => 'Favoriler';

  @override
  String get sectionLocations => 'Konumlar';

  @override
  String get placeComputer => 'Bilgisayar';

  @override
  String get placeTrash => 'Çöp Sepeti';

  @override
  String get tooltipBack => 'Geri';

  @override
  String get tooltipForward => 'İleri';

  @override
  String get tooltipViewIcons => 'Simgeler Olarak Görüntüle';

  @override
  String get tooltipViewList => 'Liste Olarak Görüntüle';

  @override
  String get tooltipViewColumns => 'Sütunlar Olarak Görüntüle';

  @override
  String get tooltipEject => 'Çıkar';

  @override
  String get searchHint => 'Ara';

  @override
  String get columnName => 'Ad';

  @override
  String get columnModified => 'Değiştirilme Tarihi';

  @override
  String get columnSize => 'Boyut';

  @override
  String get columnKind => 'Tür';

  @override
  String get kindFolder => 'Klasör';

  @override
  String get kindImage => 'Resim';

  @override
  String get kindVideo => 'Film';

  @override
  String get kindAudio => 'Ses';

  @override
  String get kindText => 'Düz Metin';

  @override
  String get kindCode => 'Kaynak Kodu';

  @override
  String get kindPdf => 'PDF Belgesi';

  @override
  String get kindArchive => 'Arşiv';

  @override
  String get kindDocument => 'Belge';

  @override
  String get kindSpreadsheet => 'Hesap Tablosu';

  @override
  String get kindPresentation => 'Sunu';

  @override
  String get kindApplication => 'Uygulama';

  @override
  String get kindOther => 'Belge';

  @override
  String kindOtherExt(String ext) {
    return '$ext Dosyası';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count öğe',
      one: '1 öğe',
    );
    return '$_temp0';
  }

  @override
  String selectedOfCount(int selected, int count) {
    return '$count öğeden $selected öğe seçildi';
  }

  @override
  String spaceAvailable(String size) {
    return '$size kullanılabilir';
  }

  @override
  String get emptyFolder => 'Boş klasör';

  @override
  String noResults(String query) {
    return '“$query” için sonuç yok';
  }

  @override
  String todayAt(String time) {
    return 'Bugün $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Dün $time';
  }

  @override
  String get menuOpen => 'Aç';

  @override
  String get menuQuickLook => 'Hızlı Bakış';

  @override
  String get menuRename => 'Yeniden Adlandır';

  @override
  String get menuDuplicate => 'Çoğalt';

  @override
  String get menuCopy => 'Kopyala';

  @override
  String get menuCut => 'Kes';

  @override
  String get menuPaste => 'Yapıştır';

  @override
  String get menuMoveToTrash => 'Çöp Sepeti’ne Taşı';

  @override
  String get menuDeleteImmediately => 'Hemen Sil…';

  @override
  String get menuPutBack => 'Geri Koy';

  @override
  String get menuEmptyTrash => 'Çöp Sepeti’ni Boşalt';

  @override
  String get menuNewFolder => 'Yeni Klasör';

  @override
  String get menuGetInfo => 'Bilgi Al';

  @override
  String get menuCopyPath => 'Yolu Kopyala';

  @override
  String get menuOpenInTerminal => 'Terminal’de Aç';

  @override
  String menuOpenInApp(String app) {
    return '$app ile Aç';
  }

  @override
  String get menuAddToSidebar => 'Kenar Çubuğuna Ekle';

  @override
  String get menuRemoveFromSidebar => 'Kenar Çubuğundan Kaldır';

  @override
  String get menuShowHidden => 'Gizli Dosyaları Göster';

  @override
  String get menuHideHidden => 'Gizli Dosyaları Gizle';

  @override
  String get menuNewWindow => 'Yeni Pencere';

  @override
  String get goToFolderTitle => 'Klasöre Git';

  @override
  String get goToFolderHint => 'ör. ~/Documents veya /etc';

  @override
  String get buttonGo => 'Git';

  @override
  String get buttonCancel => 'İptal';

  @override
  String get buttonDelete => 'Sil';

  @override
  String get buttonOk => 'Tamam';

  @override
  String deleteConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count öğe hemen silinsin mi?',
      one: 'Bu öğe hemen silinsin mi?',
    );
    return '$_temp0';
  }

  @override
  String get deleteConfirmBody => 'Bu işlem geri alınamaz.';

  @override
  String get emptyTrashConfirmTitle =>
      'Çöp Sepeti’ndeki öğeler kalıcı olarak silinsin mi?';

  @override
  String get infoKind => 'Tür';

  @override
  String get infoSize => 'Boyut';

  @override
  String get infoWhere => 'Konum';

  @override
  String get infoModified => 'Değiştirilme';

  @override
  String get infoPermissions => 'İzinler';

  @override
  String get infoCalculating => 'Hesaplanıyor…';

  @override
  String get untitledFolder => 'adsız klasör';

  @override
  String get copySuffix => 'kopya';

  @override
  String get pathCopied => 'Yol kopyalandı';

  @override
  String movedToTrash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count öğe Çöp Sepeti’ne taşındı',
      one: '1 öğe Çöp Sepeti’ne taşındı',
    );
    return '$_temp0';
  }

  @override
  String errorFolderNotFound(String path) {
    return '“$path” klasörü bulunamadı.';
  }

  @override
  String errorOperation(String message) {
    return 'İşlem tamamlanamıyor: $message';
  }

  @override
  String errorNameTaken(String name) {
    return '“$name” adı zaten kullanılıyor.';
  }

  @override
  String get errorInvalidName => 'Bu ad kullanılamaz.';

  @override
  String get quickLookNoPreview => 'Önizleme yok';

  @override
  String get tooltipGroupSort => 'Grupla ve Sırala';

  @override
  String get menuGroupBy => 'Gruplama Ölçütü';

  @override
  String get menuSortBy => 'Sıralama Ölçütü';

  @override
  String get groupNone => 'Yok';

  @override
  String get groupToday => 'Bugün';

  @override
  String get groupYesterday => 'Dün';

  @override
  String get groupPrevious7Days => 'Önceki 7 Gün';

  @override
  String get groupPrevious30Days => 'Önceki 30 Gün';

  @override
  String get groupFolders => 'Klasörler';

  @override
  String get groupOther => 'Diğer';

  @override
  String get sizeZero => 'Sıfır bayt';

  @override
  String sizeLessThan(String size) {
    return '$size altı';
  }

  @override
  String sizeBetween(String from, String to) {
    return '$from ile $to arası';
  }

  @override
  String sizeAtLeast(String size) {
    return '$size veya daha fazla';
  }

  @override
  String get menuSettings => 'Ayarlar…';

  @override
  String get settingsTitle => 'Finder Ayarları';

  @override
  String get settingsGeneral => 'Genel';

  @override
  String get settingsSidebar => 'Kenar Çubuğu';

  @override
  String get settingsAdvanced => 'Gelişmiş';

  @override
  String get settingsNewWindowsShow => 'Yeni pencerelerde gösterilen:';

  @override
  String get settingsDefaultView => 'Varsayılan görünüm:';

  @override
  String get settingsAppearance => 'Görünüm:';

  @override
  String get settingsLanguage => 'Dil:';

  @override
  String get settingsShowInSidebar => 'Kenar çubuğunda şu öğeleri göster:';

  @override
  String get settingsBookmarks => 'Yer imli klasörler';

  @override
  String get settingsExternalDrives => 'Harici sürücüler';

  @override
  String get settingsShowHidden => 'Gizli dosyaları göster';

  @override
  String get settingsFoldersOnTop => 'Sıralarken klasörleri üstte tut';

  @override
  String get settingsThumbnails => 'Simgelerde resim önizlemelerini göster';

  @override
  String get settingsWarnEmptyTrash => 'Çöp Sepeti’ni boşaltmadan önce uyar';

  @override
  String get settingsNewWindowsNote =>
      'Gruplama, sıralama ve görünüm seçimleri açık ve yeni pencerelere uygulanır.';

  @override
  String get appearanceSystem => 'Sistem';

  @override
  String get appearanceLight => 'Açık';

  @override
  String get appearanceDark => 'Koyu';

  @override
  String get languageSystem => 'Sistem';

  @override
  String get viewIcons => 'Simgeler';

  @override
  String get viewList => 'Liste';

  @override
  String get viewColumns => 'Sütunlar';

  @override
  String get placeHome => 'Ev';

  @override
  String get placeDesktop => 'Masaüstü';

  @override
  String get placeDocuments => 'Belgeler';

  @override
  String get placeDownloads => 'İndirilenler';

  @override
  String get placePictures => 'Resimler';

  @override
  String get placeMusic => 'Müzik';

  @override
  String get placeVideos => 'Videolar';

  @override
  String get tooltipNewTab => 'Yeni Sekme';

  @override
  String get tooltipCloseTab => 'Sekmeyi Kapat';

  @override
  String get menuOpenInNewTab => 'Yeni Sekmede Aç';

  @override
  String get menuCloseOtherTabs => 'Diğer Sekmeleri Kapat';

  @override
  String get menuMoveTabToNewWindow => 'Sekmeyi Yeni Pencereye Taşı';

  @override
  String get menuMergeAllWindows => 'Tüm Pencereleri Birleştir';

  @override
  String mergedWindows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pencere birleştirildi',
      one: '1 pencere birleştirildi',
      zero: 'Birleştirilecek başka Finder penceresi yok',
    );
    return '$_temp0';
  }

  @override
  String get settingsDisplay => 'Ekran';

  @override
  String get settingsOpenFoldersInTabs =>
      'Klasörleri yeni pencereler yerine sekmelerde aç';

  @override
  String get settingsAccentColor => 'Vurgu rengi:';

  @override
  String get settingsTextSize => 'Metin boyutu:';

  @override
  String get settingsIconSize => 'Simge boyutu:';

  @override
  String get settingsShowPathBar => 'Yol çubuğunu göster';

  @override
  String get settingsShowStatusBar => 'Durum çubuğunu göster';

  @override
  String get settingsShowExtensions => 'Tüm dosya adı uzantılarını göster';

  @override
  String get settingsEnterRenames =>
      'Yeniden adlandırmak için Enter’a bas (macOS tarzı)';

  @override
  String get accentBlue => 'Mavi';

  @override
  String get accentPurple => 'Mor';

  @override
  String get accentPink => 'Pembe';

  @override
  String get accentRed => 'Kırmızı';

  @override
  String get accentOrange => 'Turuncu';

  @override
  String get accentYellow => 'Sarı';

  @override
  String get accentGreen => 'Yeşil';

  @override
  String get accentGraphite => 'Grafit';

  @override
  String get splitDropHint => 'Yan yana göstermek için bırakın';

  @override
  String get menuSplitView => 'Yan Yana Göster';

  @override
  String get menuExitSplitView => 'Bölünmüş Görünümden Çık';

  @override
  String get settingsRestoreTabs => 'Son seferki sekmeleri yeniden aç';

  @override
  String get menuUndo => 'Geri Al';

  @override
  String get menuRedo => 'Yinele';

  @override
  String conflictTitle(String name, String folder) {
    return '“$folder” içinde “$name” zaten var';
  }

  @override
  String get conflictBody =>
      'Değiştirmek istiyor musunuz? Değiştirdiğiniz öğe Çöp Sepeti’ne gider.';

  @override
  String get conflictReplace => 'Değiştir';

  @override
  String get conflictKeepBoth => 'Her İkisini de Tut';

  @override
  String get conflictSkip => 'Atla';

  @override
  String conflictApplyToAll(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sonraki $count çakışma için de aynısını yap',
      one: 'Sonraki çakışma için de aynısını yap',
    );
    return '$_temp0';
  }

  @override
  String transferCopying(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count öğe “$dest” içine kopyalanıyor',
      one: '1 öğe “$dest” içine kopyalanıyor',
    );
    return '$_temp0';
  }

  @override
  String transferMoving(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count öğe “$dest” içine taşınıyor',
      one: '1 öğe “$dest” içine taşınıyor',
    );
    return '$_temp0';
  }

  @override
  String transferBytes(String done, String total) {
    return '$done / $total';
  }

  @override
  String transferRemaining(String time) {
    return 'yaklaşık $time kaldı';
  }

  @override
  String get searchIn => 'Ara:';

  @override
  String searchScopeSubfolders(String folder) {
    return '“$folder” ve alt klasörleri';
  }

  @override
  String get searchScopeThisFolder => 'Yalnızca bu klasör';

  @override
  String get searchByName => 'Ad';

  @override
  String get searchByContents => 'Ad ve İçerik';

  @override
  String get searching => 'Aranıyor…';

  @override
  String get columnLocation => 'Konum';

  @override
  String get tagRed => 'Kırmızı';

  @override
  String get tagOrange => 'Turuncu';

  @override
  String get tagYellow => 'Sarı';

  @override
  String get tagGreen => 'Yeşil';

  @override
  String get tagBlue => 'Mavi';

  @override
  String get tagPurple => 'Mor';

  @override
  String get tagGray => 'Gri';

  @override
  String get sidebarTags => 'Etiketler';

  @override
  String get sidebarDevices => 'Aygıtlar';

  @override
  String menuSendTo(String device) {
    return '$device aygıtına gönder';
  }

  @override
  String sentToDevice(int count, String device) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count öge $device aygıtına gönderildi',
    );
    return '$_temp0';
  }

  @override
  String taggedIn(String tag, String folder) {
    return '“$folder” içinde $tag etiketli';
  }

  @override
  String get tooltipRecentFolders => 'Son Klasörler';

  @override
  String get recentNone => 'Son klasör yok';

  @override
  String get menuClearRecents => 'Menüyü Temizle';

  @override
  String get settingsTheme => 'Tema';

  @override
  String themeEditingFor(String mode) {
    return '$mode görünüm için renkler. Açık ve koyu kendi renklerini korur.';
  }

  @override
  String get themeAccent => 'Vurgu rengi';

  @override
  String get themeSelection => 'Seçim';

  @override
  String get themeFolder => 'Klasörler';

  @override
  String get themeWindow => 'Pencere arka planı';

  @override
  String get themeSidebar => 'Kenar çubuğu';

  @override
  String get themeToolbar => 'Araç çubuğu';

  @override
  String get themeReset => 'Varsayılanı kullan';

  @override
  String get themeResetAll => 'Tüm Renkleri Sıfırla';

  @override
  String get colorPickerTitle => 'Renk Seçin';

  @override
  String get colorHue => 'Ton';

  @override
  String get colorSaturation => 'Doygunluk';

  @override
  String get colorBrightness => 'Parlaklık';

  @override
  String get settingsUpdates => 'Güncellemeler';

  @override
  String get updateAutoCheck => 'Güncellemeleri otomatik olarak denetle';

  @override
  String get updateCheckNow => 'Şimdi Denetle';

  @override
  String get updateChecking => 'Güncellemeler denetleniyor…';

  @override
  String get updateUpToDate => 'Finder güncel.';

  @override
  String get updateAvailable => 'Finder’ın yeni bir sürümü var.';

  @override
  String get updateInstall => 'Şimdi Güncelle';

  @override
  String get updateInstalling =>
      'Güncelleme indiriliyor ve derleniyor. Bu birkaç dakika sürebilir…';

  @override
  String get updateInstalled => 'Güncelleme yüklendi.';

  @override
  String get updateRestart => 'Finder’ı Yeniden Başlat';

  @override
  String updateFailed(String reason) {
    return 'Güncellenemedi: $reason';
  }

  @override
  String get updateUnsupported =>
      'Bu derleme kendini güncelleyemez. Güncelleme almak için install.sh ile yükleyin.';

  @override
  String get themeEffects => 'Efektler';

  @override
  String get themeSidebarOpacity => 'Kenar çubuğu opaklığı';

  @override
  String get themeWindowOpacity => 'Pencere opaklığı';

  @override
  String get themeGlass =>
      'Menüler, iletişim kutuları ve paneller için cam stili';

  @override
  String themeBlurHint(String appId) {
    return 'Finder’ın arkasındaki masaüstünü bulanıklaştırmak için “Blur my Shell” GNOME uzantısını yükleyin ve $appId için açın.';
  }
}
