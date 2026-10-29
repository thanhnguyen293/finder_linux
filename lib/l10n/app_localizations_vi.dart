// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Finder';

  @override
  String get sectionFavorites => 'Mục ưa thích';

  @override
  String get sectionLocations => 'Vị trí';

  @override
  String get placeComputer => 'Máy tính';

  @override
  String get placeTrash => 'Thùng rác';

  @override
  String get tooltipBack => 'Quay lại';

  @override
  String get tooltipForward => 'Tiến tới';

  @override
  String get tooltipViewIcons => 'Xem dạng biểu tượng';

  @override
  String get tooltipViewList => 'Xem dạng danh sách';

  @override
  String get tooltipViewColumns => 'Xem dạng cột';

  @override
  String get tooltipEject => 'Đẩy ra';

  @override
  String get searchHint => 'Tìm kiếm';

  @override
  String get columnName => 'Tên';

  @override
  String get columnModified => 'Ngày sửa đổi';

  @override
  String get columnSize => 'Kích thước';

  @override
  String get columnKind => 'Loại';

  @override
  String get kindFolder => 'Thư mục';

  @override
  String get kindImage => 'Hình ảnh';

  @override
  String get kindVideo => 'Phim';

  @override
  String get kindAudio => 'Âm thanh';

  @override
  String get kindText => 'Văn bản thuần';

  @override
  String get kindCode => 'Mã nguồn';

  @override
  String get kindPdf => 'Tài liệu PDF';

  @override
  String get kindArchive => 'Tệp nén';

  @override
  String get kindDocument => 'Tài liệu';

  @override
  String get kindSpreadsheet => 'Bảng tính';

  @override
  String get kindPresentation => 'Bản trình bày';

  @override
  String get kindApplication => 'Ứng dụng';

  @override
  String get kindOther => 'Tài liệu';

  @override
  String kindOtherExt(String ext) {
    return 'Tệp $ext';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mục',
    );
    return '$_temp0';
  }

  @override
  String selectedOfCount(int selected, int count) {
    return 'Đã chọn $selected/$count';
  }

  @override
  String spaceAvailable(String size) {
    return 'Còn trống $size';
  }

  @override
  String get emptyFolder => 'Thư mục trống';

  @override
  String noResults(String query) {
    return 'Không có kết quả cho “$query”';
  }

  @override
  String todayAt(String time) {
    return 'Hôm nay lúc $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Hôm qua lúc $time';
  }

  @override
  String get menuOpen => 'Mở';

  @override
  String get menuQuickLook => 'Xem nhanh';

  @override
  String get menuRename => 'Đổi tên';

  @override
  String get menuDuplicate => 'Nhân bản';

  @override
  String get menuCopy => 'Sao chép';

  @override
  String get menuCut => 'Cắt';

  @override
  String get menuPaste => 'Dán';

  @override
  String get menuMoveToTrash => 'Chuyển vào Thùng rác';

  @override
  String get menuDeleteImmediately => 'Xóa ngay…';

  @override
  String get menuPutBack => 'Khôi phục';

  @override
  String get menuEmptyTrash => 'Dọn sạch Thùng rác';

  @override
  String get menuNewFolder => 'Thư mục mới';

  @override
  String get menuGetInfo => 'Lấy thông tin';

  @override
  String get menuCopyPath => 'Sao chép đường dẫn';

  @override
  String get menuOpenInTerminal => 'Mở trong Terminal';

  @override
  String get menuAddToSidebar => 'Thêm vào thanh bên';

  @override
  String get menuRemoveFromSidebar => 'Xóa khỏi thanh bên';

  @override
  String get menuShowHidden => 'Hiện tệp ẩn';

  @override
  String get menuHideHidden => 'Ẩn tệp ẩn';

  @override
  String get menuNewWindow => 'Cửa sổ mới';

  @override
  String get goToFolderTitle => 'Đi tới thư mục';

  @override
  String get goToFolderHint => 'vd: ~/Documents hoặc /etc';

  @override
  String get buttonGo => 'Đi';

  @override
  String get buttonCancel => 'Hủy';

  @override
  String get buttonDelete => 'Xóa';

  @override
  String get buttonOk => 'OK';

  @override
  String deleteConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Xóa ngay $count mục?',
    );
    return '$_temp0';
  }

  @override
  String get deleteConfirmBody => 'Bạn không thể hoàn tác thao tác này.';

  @override
  String get emptyTrashConfirmTitle => 'Xóa vĩnh viễn các mục trong Thùng rác?';

  @override
  String get infoKind => 'Loại';

  @override
  String get infoSize => 'Kích thước';

  @override
  String get infoWhere => 'Vị trí';

  @override
  String get infoModified => 'Sửa đổi';

  @override
  String get infoPermissions => 'Quyền';

  @override
  String get infoCalculating => 'Đang tính…';

  @override
  String get untitledFolder => 'thư mục không tên';

  @override
  String get copySuffix => 'bản sao';

  @override
  String get pathCopied => 'Đã sao chép đường dẫn';

  @override
  String movedToTrash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Đã chuyển $count mục vào Thùng rác',
    );
    return '$_temp0';
  }

  @override
  String errorFolderNotFound(String path) {
    return 'Không tìm thấy thư mục “$path”.';
  }

  @override
  String errorOperation(String message) {
    return 'Không thể hoàn tất thao tác: $message';
  }

  @override
  String errorNameTaken(String name) {
    return 'Tên “$name” đã được dùng.';
  }

  @override
  String get errorInvalidName => 'Không thể dùng tên này.';

  @override
  String get quickLookNoPreview => 'Không có bản xem trước';

  @override
  String get tooltipGroupSort => 'Nhóm và sắp xếp';

  @override
  String get menuGroupBy => 'Nhóm theo';

  @override
  String get menuSortBy => 'Sắp xếp theo';

  @override
  String get groupNone => 'Không nhóm';

  @override
  String get groupToday => 'Hôm nay';

  @override
  String get groupYesterday => 'Hôm qua';

  @override
  String get groupPrevious7Days => '7 ngày trước';

  @override
  String get groupPrevious30Days => '30 ngày trước';

  @override
  String get groupFolders => 'Thư mục';

  @override
  String get groupOther => 'Khác';

  @override
  String get sizeZero => '0 byte';

  @override
  String sizeLessThan(String size) {
    return 'Dưới $size';
  }

  @override
  String sizeBetween(String from, String to) {
    return 'Từ $from đến $to';
  }

  @override
  String sizeAtLeast(String size) {
    return 'Từ $size trở lên';
  }

  @override
  String get menuSettings => 'Cài đặt…';

  @override
  String get settingsTitle => 'Cài đặt Finder';

  @override
  String get settingsGeneral => 'Chung';

  @override
  String get settingsSidebar => 'Thanh bên';

  @override
  String get settingsAdvanced => 'Nâng cao';

  @override
  String get settingsNewWindowsShow => 'Cửa sổ mới mở:';

  @override
  String get settingsDefaultView => 'Kiểu xem:';

  @override
  String get settingsAppearance => 'Giao diện:';

  @override
  String get settingsLanguage => 'Ngôn ngữ:';

  @override
  String get settingsShowInSidebar => 'Hiện các mục này trong thanh bên:';

  @override
  String get settingsBookmarks => 'Thư mục đã đánh dấu';

  @override
  String get settingsExternalDrives => 'Ổ đĩa ngoài';

  @override
  String get settingsShowHidden => 'Hiện tệp ẩn';

  @override
  String get settingsFoldersOnTop => 'Giữ thư mục ở trên cùng khi sắp xếp';

  @override
  String get settingsThumbnails => 'Hiện ảnh xem trước trong biểu tượng';

  @override
  String get settingsWarnEmptyTrash => 'Cảnh báo trước khi dọn sạch Thùng rác';

  @override
  String get settingsNewWindowsNote =>
      'Lựa chọn nhóm, sắp xếp và kiểu xem áp dụng cho cửa sổ đang mở và cửa sổ mới.';

  @override
  String get appearanceSystem => 'Theo hệ thống';

  @override
  String get appearanceLight => 'Sáng';

  @override
  String get appearanceDark => 'Tối';

  @override
  String get languageSystem => 'Theo hệ thống';

  @override
  String get viewIcons => 'Biểu tượng';

  @override
  String get viewList => 'Danh sách';

  @override
  String get viewColumns => 'Cột';

  @override
  String get placeHome => 'Thư mục nhà';

  @override
  String get placeDesktop => 'Màn hình nền';

  @override
  String get placeDocuments => 'Tài liệu';

  @override
  String get placeDownloads => 'Tải về';

  @override
  String get placePictures => 'Hình ảnh';

  @override
  String get placeMusic => 'Nhạc';

  @override
  String get placeVideos => 'Video';

  @override
  String get tooltipNewTab => 'Tab mới';

  @override
  String get tooltipCloseTab => 'Đóng tab';

  @override
  String get menuOpenInNewTab => 'Mở trong tab mới';

  @override
  String get menuCloseOtherTabs => 'Đóng các tab khác';

  @override
  String get menuMoveTabToNewWindow => 'Chuyển tab sang cửa sổ mới';

  @override
  String get menuMergeAllWindows => 'Gộp tất cả cửa sổ';

  @override
  String mergedWindows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Đã gộp $count cửa sổ',
      zero: 'Không có cửa sổ Finder nào khác để gộp',
    );
    return '$_temp0';
  }

  @override
  String get settingsDisplay => 'Hiển thị';

  @override
  String get settingsOpenFoldersInTabs =>
      'Mở thư mục trong tab thay vì cửa sổ mới';

  @override
  String get settingsAccentColor => 'Màu nhấn:';

  @override
  String get settingsTextSize => 'Cỡ chữ:';

  @override
  String get settingsIconSize => 'Cỡ biểu tượng:';

  @override
  String get settingsShowPathBar => 'Hiện thanh đường dẫn';

  @override
  String get settingsShowStatusBar => 'Hiện thanh trạng thái';

  @override
  String get settingsShowExtensions => 'Hiện tất cả phần mở rộng tên tệp';

  @override
  String get settingsEnterRenames => 'Nhấn Enter để đổi tên (kiểu macOS)';

  @override
  String get accentBlue => 'Xanh dương';

  @override
  String get accentPurple => 'Tím';

  @override
  String get accentPink => 'Hồng';

  @override
  String get accentRed => 'Đỏ';

  @override
  String get accentOrange => 'Cam';

  @override
  String get accentYellow => 'Vàng';

  @override
  String get accentGreen => 'Xanh lá';

  @override
  String get accentGraphite => 'Than chì';
}
