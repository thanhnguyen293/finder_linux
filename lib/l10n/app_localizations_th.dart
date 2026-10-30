// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'Finder';

  @override
  String get sectionFavorites => 'รายการโปรด';

  @override
  String get sectionLocations => 'ตำแหน่งที่ตั้ง';

  @override
  String get placeComputer => 'คอมพิวเตอร์';

  @override
  String get placeTrash => 'ถังขยะ';

  @override
  String get tooltipBack => 'กลับ';

  @override
  String get tooltipForward => 'ไปข้างหน้า';

  @override
  String get tooltipViewIcons => 'ดูเป็นไอคอน';

  @override
  String get tooltipViewList => 'ดูเป็นรายการ';

  @override
  String get tooltipViewColumns => 'ดูเป็นคอลัมน์';

  @override
  String get tooltipEject => 'นำออก';

  @override
  String get searchHint => 'ค้นหา';

  @override
  String get columnName => 'ชื่อ';

  @override
  String get columnModified => 'วันที่แก้ไข';

  @override
  String get columnSize => 'ขนาด';

  @override
  String get columnKind => 'ชนิด';

  @override
  String get kindFolder => 'โฟลเดอร์';

  @override
  String get kindImage => 'รูปภาพ';

  @override
  String get kindVideo => 'ภาพยนตร์';

  @override
  String get kindAudio => 'เสียง';

  @override
  String get kindText => 'ข้อความธรรมดา';

  @override
  String get kindCode => 'ซอร์สโค้ด';

  @override
  String get kindPdf => 'เอกสาร PDF';

  @override
  String get kindArchive => 'ที่เก็บถาวร';

  @override
  String get kindDocument => 'เอกสาร';

  @override
  String get kindSpreadsheet => 'สเปรดชีต';

  @override
  String get kindPresentation => 'งานนำเสนอ';

  @override
  String get kindApplication => 'แอปพลิเคชัน';

  @override
  String get kindOther => 'เอกสาร';

  @override
  String kindOtherExt(String ext) {
    return 'ไฟล์ $ext';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count รายการ',
      one: '1 รายการ',
    );
    return '$_temp0';
  }

  @override
  String selectedOfCount(int selected, int count) {
    return 'เลือกแล้ว $selected จาก $count';
  }

  @override
  String spaceAvailable(String size) {
    return 'ว่าง $size';
  }

  @override
  String get emptyFolder => 'โฟลเดอร์ว่าง';

  @override
  String noResults(String query) {
    return 'ไม่พบผลลัพธ์สำหรับ “$query”';
  }

  @override
  String todayAt(String time) {
    return 'วันนี้เวลา $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'เมื่อวานเวลา $time';
  }

  @override
  String get menuOpen => 'เปิด';

  @override
  String get menuQuickLook => 'ดูด่วน';

  @override
  String get menuRename => 'เปลี่ยนชื่อ';

  @override
  String get menuDuplicate => 'ทำสำเนา';

  @override
  String get menuCopy => 'คัดลอก';

  @override
  String get menuCut => 'ตัด';

  @override
  String get menuPaste => 'วาง';

  @override
  String get menuMoveToTrash => 'ย้ายไปที่ถังขยะ';

  @override
  String get menuDeleteImmediately => 'ลบทันที…';

  @override
  String get menuPutBack => 'ใส่กลับ';

  @override
  String get menuEmptyTrash => 'ล้างถังขยะ';

  @override
  String get menuNewFolder => 'โฟลเดอร์ใหม่';

  @override
  String get menuGetInfo => 'แสดงข้อมูล';

  @override
  String get menuCopyPath => 'คัดลอกพาธ';

  @override
  String get menuOpenInTerminal => 'เปิดในเทอร์มินัล';

  @override
  String get menuAddToSidebar => 'เพิ่มไปยังแถบด้านข้าง';

  @override
  String get menuRemoveFromSidebar => 'นำออกจากแถบด้านข้าง';

  @override
  String get menuShowHidden => 'แสดงไฟล์ที่ซ่อน';

  @override
  String get menuHideHidden => 'ซ่อนไฟล์ที่ซ่อน';

  @override
  String get menuNewWindow => 'หน้าต่างใหม่';

  @override
  String get goToFolderTitle => 'ไปที่โฟลเดอร์';

  @override
  String get goToFolderHint => 'เช่น ~/Documents หรือ /etc';

  @override
  String get buttonGo => 'ไป';

  @override
  String get buttonCancel => 'ยกเลิก';

  @override
  String get buttonDelete => 'ลบ';

  @override
  String get buttonOk => 'ตกลง';

  @override
  String deleteConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ลบ $count รายการทันทีหรือไม่',
      one: 'ลบรายการนี้ทันทีหรือไม่',
    );
    return '$_temp0';
  }

  @override
  String get deleteConfirmBody => 'คุณไม่สามารถเลิกทำการดำเนินการนี้ได้';

  @override
  String get emptyTrashConfirmTitle => 'ลบรายการในถังขยะอย่างถาวรหรือไม่';

  @override
  String get infoKind => 'ชนิด';

  @override
  String get infoSize => 'ขนาด';

  @override
  String get infoWhere => 'ที่ตั้ง';

  @override
  String get infoModified => 'แก้ไขเมื่อ';

  @override
  String get infoPermissions => 'สิทธิ์';

  @override
  String get infoCalculating => 'กำลังคำนวณ…';

  @override
  String get untitledFolder => 'โฟลเดอร์ไม่มีชื่อ';

  @override
  String get copySuffix => 'สำเนา';

  @override
  String get pathCopied => 'คัดลอกพาธแล้ว';

  @override
  String movedToTrash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ย้าย $count รายการไปที่ถังขยะแล้ว',
      one: 'ย้าย 1 รายการไปที่ถังขยะแล้ว',
    );
    return '$_temp0';
  }

  @override
  String errorFolderNotFound(String path) {
    return 'ไม่พบโฟลเดอร์ “$path”';
  }

  @override
  String errorOperation(String message) {
    return 'ไม่สามารถดำเนินการให้เสร็จสมบูรณ์ได้: $message';
  }

  @override
  String errorNameTaken(String name) {
    return 'ชื่อ “$name” ถูกใช้แล้ว';
  }

  @override
  String get errorInvalidName => 'ไม่สามารถใช้ชื่อนี้ได้';

  @override
  String get quickLookNoPreview => 'ไม่มีตัวอย่าง';

  @override
  String get tooltipGroupSort => 'จัดกลุ่มและเรียงลำดับ';

  @override
  String get menuGroupBy => 'จัดกลุ่มตาม';

  @override
  String get menuSortBy => 'เรียงตาม';

  @override
  String get groupNone => 'ไม่มี';

  @override
  String get groupToday => 'วันนี้';

  @override
  String get groupYesterday => 'เมื่อวาน';

  @override
  String get groupPrevious7Days => '7 วันที่ผ่านมา';

  @override
  String get groupPrevious30Days => '30 วันที่ผ่านมา';

  @override
  String get groupFolders => 'โฟลเดอร์';

  @override
  String get groupOther => 'อื่นๆ';

  @override
  String get sizeZero => 'ศูนย์ไบต์';

  @override
  String sizeLessThan(String size) {
    return 'น้อยกว่า $size';
  }

  @override
  String sizeBetween(String from, String to) {
    return '$from ถึง $to';
  }

  @override
  String sizeAtLeast(String size) {
    return '$size ขึ้นไป';
  }

  @override
  String get menuSettings => 'การตั้งค่า…';

  @override
  String get settingsTitle => 'การตั้งค่า Finder';

  @override
  String get settingsGeneral => 'ทั่วไป';

  @override
  String get settingsSidebar => 'แถบด้านข้าง';

  @override
  String get settingsAdvanced => 'ขั้นสูง';

  @override
  String get settingsNewWindowsShow => 'หน้าต่างใหม่แสดง:';

  @override
  String get settingsDefaultView => 'มุมมองเริ่มต้น:';

  @override
  String get settingsAppearance => 'รูปลักษณ์:';

  @override
  String get settingsLanguage => 'ภาษา:';

  @override
  String get settingsShowInSidebar => 'แสดงรายการเหล่านี้ในแถบด้านข้าง:';

  @override
  String get settingsBookmarks => 'โฟลเดอร์ที่บุ๊กมาร์ก';

  @override
  String get settingsExternalDrives => 'ไดรฟ์ภายนอก';

  @override
  String get settingsShowHidden => 'แสดงไฟล์ที่ซ่อน';

  @override
  String get settingsFoldersOnTop => 'เก็บโฟลเดอร์ไว้ด้านบนเมื่อเรียงลำดับ';

  @override
  String get settingsThumbnails => 'แสดงตัวอย่างรูปภาพในไอคอน';

  @override
  String get settingsWarnEmptyTrash => 'แสดงคำเตือนก่อนล้างถังขยะ';

  @override
  String get settingsNewWindowsNote =>
      'ตัวเลือกการจัดกลุ่ม การเรียงลำดับ และมุมมองจะใช้กับหน้าต่างที่เปิดอยู่และหน้าต่างใหม่';

  @override
  String get appearanceSystem => 'ระบบ';

  @override
  String get appearanceLight => 'สว่าง';

  @override
  String get appearanceDark => 'มืด';

  @override
  String get languageSystem => 'ระบบ';

  @override
  String get viewIcons => 'ไอคอน';

  @override
  String get viewList => 'รายการ';

  @override
  String get viewColumns => 'คอลัมน์';

  @override
  String get placeHome => 'โฮม';

  @override
  String get placeDesktop => 'เดสก์ท็อป';

  @override
  String get placeDocuments => 'เอกสาร';

  @override
  String get placeDownloads => 'ดาวน์โหลด';

  @override
  String get placePictures => 'รูปภาพ';

  @override
  String get placeMusic => 'เพลง';

  @override
  String get placeVideos => 'วิดีโอ';

  @override
  String get tooltipNewTab => 'แท็บใหม่';

  @override
  String get tooltipCloseTab => 'ปิดแท็บ';

  @override
  String get menuOpenInNewTab => 'เปิดในแท็บใหม่';

  @override
  String get menuCloseOtherTabs => 'ปิดแท็บอื่น';

  @override
  String get menuMoveTabToNewWindow => 'ย้ายแท็บไปยังหน้าต่างใหม่';

  @override
  String get menuMergeAllWindows => 'รวมหน้าต่างทั้งหมด';

  @override
  String mergedWindows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'รวม $count หน้าต่างแล้ว',
      one: 'รวม 1 หน้าต่างแล้ว',
      zero: 'ไม่มีหน้าต่าง Finder อื่นให้รวม',
    );
    return '$_temp0';
  }

  @override
  String get settingsDisplay => 'การแสดงผล';

  @override
  String get settingsOpenFoldersInTabs => 'เปิดโฟลเดอร์ในแท็บแทนหน้าต่างใหม่';

  @override
  String get settingsAccentColor => 'สีเน้น:';

  @override
  String get settingsTextSize => 'ขนาดข้อความ:';

  @override
  String get settingsIconSize => 'ขนาดไอคอน:';

  @override
  String get settingsShowPathBar => 'แสดงแถบพาธ';

  @override
  String get settingsShowStatusBar => 'แสดงแถบสถานะ';

  @override
  String get settingsShowExtensions => 'แสดงนามสกุลไฟล์ทั้งหมด';

  @override
  String get settingsEnterRenames => 'กด Enter เพื่อเปลี่ยนชื่อ (แบบ macOS)';

  @override
  String get accentBlue => 'น้ำเงิน';

  @override
  String get accentPurple => 'ม่วง';

  @override
  String get accentPink => 'ชมพู';

  @override
  String get accentRed => 'แดง';

  @override
  String get accentOrange => 'ส้ม';

  @override
  String get accentYellow => 'เหลือง';

  @override
  String get accentGreen => 'เขียว';

  @override
  String get accentGraphite => 'เกรไฟต์';

  @override
  String get splitDropHint => 'วางเพื่อแสดงเคียงข้างกัน';

  @override
  String get menuSplitView => 'แสดงเคียงข้างกัน';

  @override
  String get menuExitSplitView => 'ออกจากมุมมองแยก';

  @override
  String get settingsRestoreTabs => 'เปิดแท็บจากครั้งล่าสุดอีกครั้ง';

  @override
  String get menuUndo => 'เลิกทำ';

  @override
  String get menuRedo => 'ทำซ้ำ';

  @override
  String conflictTitle(String name, String folder) {
    return '“$name” มีอยู่แล้วใน “$folder”';
  }

  @override
  String get conflictBody =>
      'คุณต้องการแทนที่หรือไม่ รายการที่แทนที่จะถูกย้ายไปที่ถังขยะ';

  @override
  String get conflictReplace => 'แทนที่';

  @override
  String get conflictKeepBoth => 'เก็บทั้งสอง';

  @override
  String get conflictSkip => 'ข้าม';

  @override
  String conflictApplyToAll(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ทำเช่นเดียวกันกับข้อขัดแย้งถัดไปอีก $count รายการ',
      one: 'ทำเช่นเดียวกันกับข้อขัดแย้งถัดไป',
    );
    return '$_temp0';
  }

  @override
  String transferCopying(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'กำลังคัดลอก $count รายการไปที่ “$dest”',
      one: 'กำลังคัดลอก 1 รายการไปที่ “$dest”',
    );
    return '$_temp0';
  }

  @override
  String transferMoving(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'กำลังย้าย $count รายการไปที่ “$dest”',
      one: 'กำลังย้าย 1 รายการไปที่ “$dest”',
    );
    return '$_temp0';
  }

  @override
  String transferBytes(String done, String total) {
    return '$done จาก $total';
  }

  @override
  String transferRemaining(String time) {
    return 'เหลืออีกประมาณ $time';
  }

  @override
  String get searchIn => 'ค้นหา:';

  @override
  String searchScopeSubfolders(String folder) {
    return '“$folder” และโฟลเดอร์ย่อย';
  }

  @override
  String get searchScopeThisFolder => 'เฉพาะโฟลเดอร์นี้';

  @override
  String get searchByName => 'ชื่อ';

  @override
  String get searchByContents => 'ชื่อและเนื้อหา';

  @override
  String get searching => 'กำลังค้นหา…';

  @override
  String get columnLocation => 'ตำแหน่งที่ตั้ง';

  @override
  String get tagRed => 'แดง';

  @override
  String get tagOrange => 'ส้ม';

  @override
  String get tagYellow => 'เหลือง';

  @override
  String get tagGreen => 'เขียว';

  @override
  String get tagBlue => 'น้ำเงิน';

  @override
  String get tagPurple => 'ม่วง';

  @override
  String get tagGray => 'เทา';

  @override
  String get sidebarTags => 'แท็ก';

  @override
  String taggedIn(String tag, String folder) {
    return 'แท็ก $tag ใน “$folder”';
  }

  @override
  String get tooltipRecentFolders => 'โฟลเดอร์ล่าสุด';

  @override
  String get recentNone => 'ไม่มีโฟลเดอร์ล่าสุด';

  @override
  String get menuClearRecents => 'ล้างเมนู';

  @override
  String get settingsTheme => 'ธีม';

  @override
  String themeEditingFor(String mode) {
    return 'สีสำหรับลักษณะที่ปรากฏแบบ$mode แบบสว่างและแบบมืดมีสีของตัวเอง';
  }

  @override
  String get themeAccent => 'สีเน้น';

  @override
  String get themeSelection => 'สิ่งที่เลือก';

  @override
  String get themeFolder => 'โฟลเดอร์';

  @override
  String get themeWindow => 'พื้นหลังหน้าต่าง';

  @override
  String get themeSidebar => 'แถบด้านข้าง';

  @override
  String get themeToolbar => 'แถบเครื่องมือ';

  @override
  String get themeReset => 'ใช้ค่าเริ่มต้น';

  @override
  String get themeResetAll => 'รีเซ็ตสีทั้งหมด';

  @override
  String get colorPickerTitle => 'เลือกสี';

  @override
  String get colorHue => 'สี';

  @override
  String get colorSaturation => 'ความอิ่มตัว';

  @override
  String get colorBrightness => 'ความสว่าง';

  @override
  String get settingsUpdates => 'อัปเดต';

  @override
  String get updateAutoCheck => 'ตรวจหาอัปเดตโดยอัตโนมัติ';

  @override
  String get updateCheckNow => 'ตรวจสอบเดี๋ยวนี้';

  @override
  String get updateChecking => 'กำลังตรวจหาอัปเดต…';

  @override
  String get updateUpToDate => 'Finder เป็นเวอร์ชันล่าสุดแล้ว';

  @override
  String get updateAvailable => 'มี Finder เวอร์ชันใหม่';

  @override
  String get updateInstall => 'อัปเดตเดี๋ยวนี้';

  @override
  String get updateInstalling =>
      'กำลังดาวน์โหลดและบิลด์อัปเดต อาจใช้เวลาสักครู่…';

  @override
  String get updateInstalled => 'ติดตั้งอัปเดตแล้ว';

  @override
  String get updateRestart => 'เริ่ม Finder ใหม่';

  @override
  String updateFailed(String reason) {
    return 'อัปเดตไม่ได้: $reason';
  }

  @override
  String get updateUnsupported =>
      'บิลด์นี้อัปเดตตัวเองไม่ได้ ติดตั้งด้วย install.sh เพื่อรับอัปเดต';

  @override
  String get themeEffects => 'เอฟเฟกต์';

  @override
  String get themeSidebarOpacity => 'ความทึบของแถบด้านข้าง';

  @override
  String get themeWindowOpacity => 'ความทึบของหน้าต่าง';

  @override
  String get themeGlass => 'ใช้สไตล์กระจกกับเมนู ไดอะล็อก และแผง';

  @override
  String themeBlurHint(String appId) {
    return 'หากต้องการเบลอเดสก์ท็อปด้านหลัง Finder ให้ติดตั้งส่วนขยาย GNOME “Blur my Shell” และเปิดใช้สำหรับ $appId';
  }
}
