// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Finder';

  @override
  String get sectionFavorites => 'Favorit';

  @override
  String get sectionLocations => 'Lokasi';

  @override
  String get placeComputer => 'Komputer';

  @override
  String get placeTrash => 'Tong Sampah';

  @override
  String get tooltipBack => 'Kembali';

  @override
  String get tooltipForward => 'Maju';

  @override
  String get tooltipViewIcons => 'Tampilkan sebagai Ikon';

  @override
  String get tooltipViewList => 'Tampilkan sebagai Daftar';

  @override
  String get tooltipViewColumns => 'Tampilkan sebagai Kolom';

  @override
  String get tooltipEject => 'Keluarkan';

  @override
  String get searchHint => 'Cari';

  @override
  String get columnName => 'Nama';

  @override
  String get columnModified => 'Tanggal Diubah';

  @override
  String get columnSize => 'Ukuran';

  @override
  String get columnKind => 'Jenis';

  @override
  String get kindFolder => 'Folder';

  @override
  String get kindImage => 'Gambar';

  @override
  String get kindVideo => 'Film';

  @override
  String get kindAudio => 'Audio';

  @override
  String get kindText => 'Teks Biasa';

  @override
  String get kindCode => 'Kode Sumber';

  @override
  String get kindPdf => 'Dokumen PDF';

  @override
  String get kindArchive => 'Arsip';

  @override
  String get kindDocument => 'Dokumen';

  @override
  String get kindSpreadsheet => 'Spreadsheet';

  @override
  String get kindPresentation => 'Presentasi';

  @override
  String get kindApplication => 'Aplikasi';

  @override
  String get kindOther => 'Dokumen';

  @override
  String kindOtherExt(String ext) {
    return 'File $ext';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count item',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String selectedOfCount(int selected, int count) {
    return '$selected dari $count dipilih';
  }

  @override
  String spaceAvailable(String size) {
    return '$size tersedia';
  }

  @override
  String get emptyFolder => 'Folder kosong';

  @override
  String noResults(String query) {
    return 'Tidak ada hasil untuk “$query”';
  }

  @override
  String todayAt(String time) {
    return 'Hari ini pukul $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Kemarin pukul $time';
  }

  @override
  String get menuOpen => 'Buka';

  @override
  String get menuQuickLook => 'Quick Look';

  @override
  String get menuRename => 'Ganti Nama';

  @override
  String get menuDuplicate => 'Duplikat';

  @override
  String get menuCopy => 'Salin';

  @override
  String get menuCut => 'Potong';

  @override
  String get menuPaste => 'Tempel';

  @override
  String get menuMoveToTrash => 'Pindahkan ke Tong Sampah';

  @override
  String get menuDeleteImmediately => 'Hapus Langsung…';

  @override
  String get menuPutBack => 'Kembalikan';

  @override
  String get menuEmptyTrash => 'Kosongkan Tong Sampah';

  @override
  String get menuNewFolder => 'Folder Baru';

  @override
  String get menuGetInfo => 'Dapatkan Info';

  @override
  String get menuCopyPath => 'Salin Path';

  @override
  String get menuOpenInTerminal => 'Buka di Terminal';

  @override
  String menuOpenInApp(String app) {
    return 'Buka di $app';
  }

  @override
  String get menuAddToSidebar => 'Tambahkan ke Bar Samping';

  @override
  String get menuRemoveFromSidebar => 'Hapus dari Bar Samping';

  @override
  String get menuShowHidden => 'Tampilkan File Tersembunyi';

  @override
  String get menuHideHidden => 'Sembunyikan File Tersembunyi';

  @override
  String get menuNewWindow => 'Jendela Baru';

  @override
  String get goToFolderTitle => 'Pergi ke Folder';

  @override
  String get goToFolderHint => 'mis. ~/Documents atau /etc';

  @override
  String get buttonGo => 'Pergi';

  @override
  String get buttonCancel => 'Batal';

  @override
  String get buttonDelete => 'Hapus';

  @override
  String get buttonOk => 'OK';

  @override
  String deleteConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hapus $count item langsung?',
      one: 'Hapus item ini langsung?',
    );
    return '$_temp0';
  }

  @override
  String get deleteConfirmBody => 'Tindakan ini tidak dapat dibatalkan.';

  @override
  String get emptyTrashConfirmTitle => 'Hapus permanen item di Tong Sampah?';

  @override
  String get infoKind => 'Jenis';

  @override
  String get infoSize => 'Ukuran';

  @override
  String get infoWhere => 'Lokasi';

  @override
  String get infoModified => 'Diubah';

  @override
  String get infoPermissions => 'Izin';

  @override
  String get infoCalculating => 'Menghitung…';

  @override
  String get untitledFolder => 'folder tanpa judul';

  @override
  String get copySuffix => 'salinan';

  @override
  String get pathCopied => 'Path disalin';

  @override
  String movedToTrash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count item dipindahkan ke Tong Sampah',
      one: '1 item dipindahkan ke Tong Sampah',
    );
    return '$_temp0';
  }

  @override
  String errorFolderNotFound(String path) {
    return 'Folder “$path” tidak dapat ditemukan.';
  }

  @override
  String errorOperation(String message) {
    return 'Operasi tidak dapat diselesaikan: $message';
  }

  @override
  String errorNameTaken(String name) {
    return 'Nama “$name” sudah digunakan.';
  }

  @override
  String get errorInvalidName => 'Nama tersebut tidak dapat digunakan.';

  @override
  String get quickLookNoPreview => 'Pratinjau tidak tersedia';

  @override
  String get tooltipGroupSort => 'Grup dan Urutkan';

  @override
  String get menuGroupBy => 'Kelompokkan Menurut';

  @override
  String get menuSortBy => 'Urutkan Menurut';

  @override
  String get groupNone => 'Tidak Ada';

  @override
  String get groupToday => 'Hari Ini';

  @override
  String get groupYesterday => 'Kemarin';

  @override
  String get groupPrevious7Days => '7 Hari Sebelumnya';

  @override
  String get groupPrevious30Days => '30 Hari Sebelumnya';

  @override
  String get groupFolders => 'Folder';

  @override
  String get groupOther => 'Lainnya';

  @override
  String get sizeZero => 'Nol byte';

  @override
  String sizeLessThan(String size) {
    return 'Kurang dari $size';
  }

  @override
  String sizeBetween(String from, String to) {
    return '$from hingga $to';
  }

  @override
  String sizeAtLeast(String size) {
    return '$size atau lebih';
  }

  @override
  String get menuSettings => 'Pengaturan…';

  @override
  String get settingsTitle => 'Pengaturan Finder';

  @override
  String get settingsGeneral => 'Umum';

  @override
  String get settingsSidebar => 'Bar Samping';

  @override
  String get settingsAdvanced => 'Lanjutan';

  @override
  String get settingsNewWindowsShow => 'Jendela baru menampilkan:';

  @override
  String get settingsDefaultView => 'Tampilan default:';

  @override
  String get settingsAppearance => 'Tema:';

  @override
  String get settingsLanguage => 'Bahasa:';

  @override
  String get settingsShowInSidebar => 'Tampilkan item ini di bar samping:';

  @override
  String get settingsBookmarks => 'Folder yang di-bookmark';

  @override
  String get settingsExternalDrives => 'Drive eksternal';

  @override
  String get settingsShowHidden => 'Tampilkan file tersembunyi';

  @override
  String get settingsFoldersOnTop =>
      'Tetap tampilkan folder di atas saat mengurutkan';

  @override
  String get settingsThumbnails => 'Tampilkan pratinjau gambar di ikon';

  @override
  String get settingsWarnEmptyTrash =>
      'Tampilkan peringatan sebelum mengosongkan Tong Sampah';

  @override
  String get settingsNewWindowsNote =>
      'Pilihan grup, urutan, dan tampilan berlaku untuk jendela yang terbuka dan jendela baru.';

  @override
  String get appearanceSystem => 'Sistem';

  @override
  String get appearanceLight => 'Terang';

  @override
  String get appearanceDark => 'Gelap';

  @override
  String get languageSystem => 'Sistem';

  @override
  String get viewIcons => 'Ikon';

  @override
  String get viewList => 'Daftar';

  @override
  String get viewColumns => 'Kolom';

  @override
  String get placeHome => 'Beranda';

  @override
  String get placeDesktop => 'Desktop';

  @override
  String get placeDocuments => 'Dokumen';

  @override
  String get placeDownloads => 'Unduhan';

  @override
  String get placePictures => 'Gambar';

  @override
  String get placeMusic => 'Musik';

  @override
  String get placeVideos => 'Video';

  @override
  String get tooltipNewTab => 'Tab Baru';

  @override
  String get tooltipCloseTab => 'Tutup Tab';

  @override
  String get menuOpenInNewTab => 'Buka di Tab Baru';

  @override
  String get menuCloseOtherTabs => 'Tutup Tab Lainnya';

  @override
  String get menuMoveTabToNewWindow => 'Pindahkan Tab ke Jendela Baru';

  @override
  String get menuMergeAllWindows => 'Gabungkan Semua Jendela';

  @override
  String mergedWindows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jendela digabungkan',
      one: '1 jendela digabungkan',
      zero: 'Tidak ada jendela Finder lain untuk digabungkan',
    );
    return '$_temp0';
  }

  @override
  String get settingsDisplay => 'Tampilan';

  @override
  String get settingsOpenFoldersInTabs =>
      'Buka folder di tab, bukan di jendela baru';

  @override
  String get settingsAccentColor => 'Warna aksen:';

  @override
  String get settingsTextSize => 'Ukuran teks:';

  @override
  String get settingsIconSize => 'Ukuran ikon:';

  @override
  String get settingsShowPathBar => 'Tampilkan bar path';

  @override
  String get settingsShowStatusBar => 'Tampilkan bar status';

  @override
  String get settingsShowExtensions => 'Tampilkan semua ekstensi nama file';

  @override
  String get settingsEnterRenames =>
      'Tekan Enter untuk mengganti nama (gaya macOS)';

  @override
  String get accentBlue => 'Biru';

  @override
  String get accentPurple => 'Ungu';

  @override
  String get accentPink => 'Merah Muda';

  @override
  String get accentRed => 'Merah';

  @override
  String get accentOrange => 'Oranye';

  @override
  String get accentYellow => 'Kuning';

  @override
  String get accentGreen => 'Hijau';

  @override
  String get accentGraphite => 'Grafit';

  @override
  String get splitDropHint => 'Lepas untuk menampilkan berdampingan';

  @override
  String get menuSplitView => 'Tampilkan Berdampingan';

  @override
  String get menuExitSplitView => 'Keluar dari Tampilan Terpisah';

  @override
  String get settingsRestoreTabs => 'Buka kembali tab dari sesi terakhir';

  @override
  String get menuUndo => 'Urungkan';

  @override
  String get menuRedo => 'Ulangi';

  @override
  String conflictTitle(String name, String folder) {
    return '“$name” sudah ada di “$folder”';
  }

  @override
  String get conflictBody =>
      'Apakah Anda ingin menggantinya? Item yang diganti akan masuk ke Tong Sampah.';

  @override
  String get conflictReplace => 'Ganti';

  @override
  String get conflictKeepBoth => 'Simpan Keduanya';

  @override
  String get conflictSkip => 'Lewati';

  @override
  String conflictApplyToAll(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lakukan hal yang sama untuk $count konflik berikutnya',
      one: 'Lakukan hal yang sama untuk konflik berikutnya',
    );
    return '$_temp0';
  }

  @override
  String transferCopying(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Menyalin $count item ke “$dest”',
      one: 'Menyalin 1 item ke “$dest”',
    );
    return '$_temp0';
  }

  @override
  String transferMoving(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Memindahkan $count item ke “$dest”',
      one: 'Memindahkan 1 item ke “$dest”',
    );
    return '$_temp0';
  }

  @override
  String transferBytes(String done, String total) {
    return '$done dari $total';
  }

  @override
  String transferRemaining(String time) {
    return 'sekitar $time lagi';
  }

  @override
  String get searchIn => 'Cari:';

  @override
  String searchScopeSubfolders(String folder) {
    return '“$folder” dan subfolder';
  }

  @override
  String get searchScopeThisFolder => 'Hanya folder ini';

  @override
  String get searchByName => 'Nama';

  @override
  String get searchByContents => 'Nama & Isi';

  @override
  String get searching => 'Mencari…';

  @override
  String get columnLocation => 'Lokasi';

  @override
  String get tagRed => 'Merah';

  @override
  String get tagOrange => 'Oranye';

  @override
  String get tagYellow => 'Kuning';

  @override
  String get tagGreen => 'Hijau';

  @override
  String get tagBlue => 'Biru';

  @override
  String get tagPurple => 'Ungu';

  @override
  String get tagGray => 'Abu-abu';

  @override
  String get sidebarTags => 'Tag';

  @override
  String get sidebarDevices => 'Perangkat';

  @override
  String menuSendTo(String device) {
    return 'Kirim ke $device';
  }

  @override
  String sentToDevice(int count, String device) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count item dikirim ke $device',
    );
    return '$_temp0';
  }

  @override
  String taggedIn(String tag, String folder) {
    return 'Ditandai $tag di “$folder”';
  }

  @override
  String get tooltipRecentFolders => 'Folder Terbaru';

  @override
  String get recentNone => 'Tidak ada folder terbaru';

  @override
  String get menuClearRecents => 'Bersihkan Menu';

  @override
  String get settingsTheme => 'Tema';

  @override
  String themeEditingFor(String mode) {
    return 'Warna untuk tampilan $mode. Terang dan gelap menyimpan warnanya sendiri.';
  }

  @override
  String get themeAccent => 'Warna aksen';

  @override
  String get themeSelection => 'Pilihan';

  @override
  String get themeFolder => 'Folder';

  @override
  String get themeWindow => 'Latar belakang jendela';

  @override
  String get themeSidebar => 'Bar samping';

  @override
  String get themeToolbar => 'Bar alat';

  @override
  String get themeReset => 'Gunakan default';

  @override
  String get themeResetAll => 'Atur Ulang Semua Warna';

  @override
  String get colorPickerTitle => 'Pilih Warna';

  @override
  String get colorHue => 'Rona';

  @override
  String get colorSaturation => 'Saturasi';

  @override
  String get colorBrightness => 'Kecerahan';

  @override
  String get settingsUpdates => 'Pembaruan';

  @override
  String get updateAutoCheck => 'Periksa pembaruan secara otomatis';

  @override
  String get updateCheckNow => 'Periksa Sekarang';

  @override
  String get updateChecking => 'Memeriksa pembaruan…';

  @override
  String get updateUpToDate => 'Finder sudah terbaru.';

  @override
  String get updateAvailable => 'Versi baru Finder tersedia.';

  @override
  String get updateInstall => 'Perbarui Sekarang';

  @override
  String get updateInstalling =>
      'Mengunduh dan membangun pembaruan. Ini dapat memakan waktu beberapa menit…';

  @override
  String get updateInstalled => 'Pembaruan sudah diinstal.';

  @override
  String get updateRestart => 'Mulai Ulang Finder';

  @override
  String updateFailed(String reason) {
    return 'Tidak dapat memperbarui: $reason';
  }

  @override
  String get updateUnsupported =>
      'Build ini tidak dapat memperbarui dirinya sendiri. Instal dengan install.sh untuk mendapatkan pembaruan.';

  @override
  String get themeEffects => 'Efek';

  @override
  String get themeSidebarOpacity => 'Opasitas bar samping';

  @override
  String get themeWindowOpacity => 'Opasitas jendela';

  @override
  String get themeGlass => 'Gaya kaca untuk menu, dialog, dan panel';

  @override
  String themeBlurHint(String appId) {
    return 'Untuk mengaburkan desktop di belakang Finder, instal ekstensi GNOME “Blur my Shell” dan aktifkan untuk $appId.';
  }
}
