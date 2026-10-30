// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Finder';

  @override
  String get sectionFavorites => '个人收藏';

  @override
  String get sectionLocations => '位置';

  @override
  String get placeComputer => '电脑';

  @override
  String get placeTrash => '废纸篓';

  @override
  String get tooltipBack => '后退';

  @override
  String get tooltipForward => '前进';

  @override
  String get tooltipViewIcons => '以图标显示';

  @override
  String get tooltipViewList => '以列表显示';

  @override
  String get tooltipViewColumns => '以分栏显示';

  @override
  String get tooltipEject => '推出';

  @override
  String get searchHint => '搜索';

  @override
  String get columnName => '名称';

  @override
  String get columnModified => '修改日期';

  @override
  String get columnSize => '大小';

  @override
  String get columnKind => '种类';

  @override
  String get kindFolder => '文件夹';

  @override
  String get kindImage => '图像';

  @override
  String get kindVideo => '影片';

  @override
  String get kindAudio => '音频';

  @override
  String get kindText => '纯文本';

  @override
  String get kindCode => '源代码';

  @override
  String get kindPdf => 'PDF 文稿';

  @override
  String get kindArchive => '归档';

  @override
  String get kindDocument => '文稿';

  @override
  String get kindSpreadsheet => '电子表格';

  @override
  String get kindPresentation => '演示文稿';

  @override
  String get kindApplication => '应用程序';

  @override
  String get kindOther => '文稿';

  @override
  String kindOtherExt(String ext) {
    return '$ext 文件';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 项',
      one: '1 项',
    );
    return '$_temp0';
  }

  @override
  String selectedOfCount(int selected, int count) {
    return '已选择 $selected 项（共 $count 项）';
  }

  @override
  String spaceAvailable(String size) {
    return '可用 $size';
  }

  @override
  String get emptyFolder => '空文件夹';

  @override
  String noResults(String query) {
    return '未找到“$query”的结果';
  }

  @override
  String todayAt(String time) {
    return '今天 $time';
  }

  @override
  String yesterdayAt(String time) {
    return '昨天 $time';
  }

  @override
  String get menuOpen => '打开';

  @override
  String get menuQuickLook => '快速查看';

  @override
  String get menuRename => '重新命名';

  @override
  String get menuDuplicate => '制作副本';

  @override
  String get menuCopy => '拷贝';

  @override
  String get menuCut => '剪切';

  @override
  String get menuPaste => '粘贴';

  @override
  String get menuMoveToTrash => '移到废纸篓';

  @override
  String get menuDeleteImmediately => '立即删除…';

  @override
  String get menuPutBack => '放回原处';

  @override
  String get menuEmptyTrash => '清倒废纸篓';

  @override
  String get menuNewFolder => '新建文件夹';

  @override
  String get menuGetInfo => '显示简介';

  @override
  String get menuCopyPath => '拷贝路径';

  @override
  String get menuOpenInTerminal => '在终端中打开';

  @override
  String get menuAddToSidebar => '添加到边栏';

  @override
  String get menuRemoveFromSidebar => '从边栏移除';

  @override
  String get menuShowHidden => '显示隐藏文件';

  @override
  String get menuHideHidden => '不显示隐藏文件';

  @override
  String get menuNewWindow => '新建窗口';

  @override
  String get goToFolderTitle => '前往文件夹';

  @override
  String get goToFolderHint => '例如 ~/Documents 或 /etc';

  @override
  String get buttonGo => '前往';

  @override
  String get buttonCancel => '取消';

  @override
  String get buttonDelete => '删除';

  @override
  String get buttonOk => '好';

  @override
  String deleteConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '要立即删除 $count 个项目吗？',
      one: '要立即删除此项目吗？',
    );
    return '$_temp0';
  }

  @override
  String get deleteConfirmBody => '此操作无法撤销。';

  @override
  String get emptyTrashConfirmTitle => '要永久清除废纸篓中的项目吗？';

  @override
  String get infoKind => '种类';

  @override
  String get infoSize => '大小';

  @override
  String get infoWhere => '位置';

  @override
  String get infoModified => '修改时间';

  @override
  String get infoPermissions => '权限';

  @override
  String get infoCalculating => '正在计算…';

  @override
  String get untitledFolder => '未命名文件夹';

  @override
  String get copySuffix => '副本';

  @override
  String get pathCopied => '路径已拷贝';

  @override
  String movedToTrash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已将 $count 个项目移到废纸篓',
      one: '已将 1 个项目移到废纸篓',
    );
    return '$_temp0';
  }

  @override
  String errorFolderNotFound(String path) {
    return '找不到文件夹“$path”。';
  }

  @override
  String errorOperation(String message) {
    return '无法完成操作：$message';
  }

  @override
  String errorNameTaken(String name) {
    return '名称“$name”已被占用。';
  }

  @override
  String get errorInvalidName => '无法使用该名称。';

  @override
  String get quickLookNoPreview => '无可用预览';

  @override
  String get tooltipGroupSort => '分组与排序';

  @override
  String get menuGroupBy => '分组方式';

  @override
  String get menuSortBy => '排序方式';

  @override
  String get groupNone => '无';

  @override
  String get groupToday => '今天';

  @override
  String get groupYesterday => '昨天';

  @override
  String get groupPrevious7Days => '过去 7 天';

  @override
  String get groupPrevious30Days => '过去 30 天';

  @override
  String get groupFolders => '文件夹';

  @override
  String get groupOther => '其他';

  @override
  String get sizeZero => '零字节';

  @override
  String sizeLessThan(String size) {
    return '小于 $size';
  }

  @override
  String sizeBetween(String from, String to) {
    return '$from 至 $to';
  }

  @override
  String sizeAtLeast(String size) {
    return '$size 或更大';
  }

  @override
  String get menuSettings => '设置…';

  @override
  String get settingsTitle => 'Finder 设置';

  @override
  String get settingsGeneral => '通用';

  @override
  String get settingsSidebar => '边栏';

  @override
  String get settingsAdvanced => '高级';

  @override
  String get settingsNewWindowsShow => '新建窗口显示：';

  @override
  String get settingsDefaultView => '默认视图：';

  @override
  String get settingsAppearance => '外观：';

  @override
  String get settingsLanguage => '语言：';

  @override
  String get settingsShowInSidebar => '在边栏中显示这些项目：';

  @override
  String get settingsBookmarks => '书签文件夹';

  @override
  String get settingsExternalDrives => '外置硬盘';

  @override
  String get settingsShowHidden => '显示隐藏文件';

  @override
  String get settingsFoldersOnTop => '排序时将文件夹放在最前面';

  @override
  String get settingsThumbnails => '在图标中显示图像预览';

  @override
  String get settingsWarnEmptyTrash => '清倒废纸篓前显示警告';

  @override
  String get settingsNewWindowsNote => '分组、排序和视图选项适用于已打开的窗口和新窗口。';

  @override
  String get appearanceSystem => '系统';

  @override
  String get appearanceLight => '浅色';

  @override
  String get appearanceDark => '深色';

  @override
  String get languageSystem => '系统';

  @override
  String get viewIcons => '图标';

  @override
  String get viewList => '列表';

  @override
  String get viewColumns => '分栏';

  @override
  String get placeHome => '个人';

  @override
  String get placeDesktop => '桌面';

  @override
  String get placeDocuments => '文稿';

  @override
  String get placeDownloads => '下载';

  @override
  String get placePictures => '图片';

  @override
  String get placeMusic => '音乐';

  @override
  String get placeVideos => '视频';

  @override
  String get tooltipNewTab => '新建标签页';

  @override
  String get tooltipCloseTab => '关闭标签页';

  @override
  String get menuOpenInNewTab => '在新标签页中打开';

  @override
  String get menuCloseOtherTabs => '关闭其他标签页';

  @override
  String get menuMoveTabToNewWindow => '将标签页移到新窗口';

  @override
  String get menuMergeAllWindows => '合并所有窗口';

  @override
  String mergedWindows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已合并 $count 个窗口',
      one: '已合并 1 个窗口',
      zero: '没有可合并的其他 Finder 窗口',
    );
    return '$_temp0';
  }

  @override
  String get settingsDisplay => '显示';

  @override
  String get settingsOpenFoldersInTabs => '在标签页而非新窗口中打开文件夹';

  @override
  String get settingsAccentColor => '强调色：';

  @override
  String get settingsTextSize => '文字大小：';

  @override
  String get settingsIconSize => '图标大小：';

  @override
  String get settingsShowPathBar => '显示路径栏';

  @override
  String get settingsShowStatusBar => '显示状态栏';

  @override
  String get settingsShowExtensions => '显示所有文件扩展名';

  @override
  String get settingsEnterRenames => '按回车键重新命名（macOS 风格）';

  @override
  String get accentBlue => '蓝色';

  @override
  String get accentPurple => '紫色';

  @override
  String get accentPink => '粉色';

  @override
  String get accentRed => '红色';

  @override
  String get accentOrange => '橙色';

  @override
  String get accentYellow => '黄色';

  @override
  String get accentGreen => '绿色';

  @override
  String get accentGraphite => '石墨色';

  @override
  String get splitDropHint => '拖放以并排显示';

  @override
  String get menuSplitView => '并排显示';

  @override
  String get menuExitSplitView => '退出分屏视图';

  @override
  String get settingsRestoreTabs => '重新打开上次的标签页';

  @override
  String get menuUndo => '撤销';

  @override
  String get menuRedo => '重做';

  @override
  String conflictTitle(String name, String folder) {
    return '“$folder”中已存在“$name”';
  }

  @override
  String get conflictBody => '要替换它吗？被替换的项目将移到废纸篓。';

  @override
  String get conflictReplace => '替换';

  @override
  String get conflictKeepBoth => '保留两者';

  @override
  String get conflictSkip => '跳过';

  @override
  String conflictApplyToAll(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '对接下来的 $count 个冲突执行相同操作',
      one: '对下一个冲突执行相同操作',
    );
    return '$_temp0';
  }

  @override
  String transferCopying(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '正在拷贝 $count 个项目到“$dest”',
      one: '正在拷贝 1 个项目到“$dest”',
    );
    return '$_temp0';
  }

  @override
  String transferMoving(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '正在移动 $count 个项目到“$dest”',
      one: '正在移动 1 个项目到“$dest”',
    );
    return '$_temp0';
  }

  @override
  String transferBytes(String done, String total) {
    return '$done，共 $total';
  }

  @override
  String transferRemaining(String time) {
    return '还剩约 $time';
  }

  @override
  String get searchIn => '搜索：';

  @override
  String searchScopeSubfolders(String folder) {
    return '“$folder”及其子文件夹';
  }

  @override
  String get searchScopeThisFolder => '仅此文件夹';

  @override
  String get searchByName => '名称';

  @override
  String get searchByContents => '名称和内容';

  @override
  String get searching => '正在搜索…';

  @override
  String get columnLocation => '位置';

  @override
  String get tagRed => '红色';

  @override
  String get tagOrange => '橙色';

  @override
  String get tagYellow => '黄色';

  @override
  String get tagGreen => '绿色';

  @override
  String get tagBlue => '蓝色';

  @override
  String get tagPurple => '紫色';

  @override
  String get tagGray => '灰色';

  @override
  String get sidebarTags => '标签';

  @override
  String get sidebarDevices => '设备';

  @override
  String taggedIn(String tag, String folder) {
    return '“$folder”中标记为$tag的项目';
  }

  @override
  String get tooltipRecentFolders => '最近使用的文件夹';

  @override
  String get recentNone => '没有最近使用的文件夹';

  @override
  String get menuClearRecents => '清除菜单';

  @override
  String get settingsTheme => '主题';

  @override
  String themeEditingFor(String mode) {
    return '$mode外观的颜色。浅色和深色各自保留颜色。';
  }

  @override
  String get themeAccent => '强调色';

  @override
  String get themeSelection => '所选内容';

  @override
  String get themeFolder => '文件夹';

  @override
  String get themeWindow => '窗口背景';

  @override
  String get themeSidebar => '边栏';

  @override
  String get themeToolbar => '工具栏';

  @override
  String get themeReset => '使用默认值';

  @override
  String get themeResetAll => '还原所有颜色';

  @override
  String get colorPickerTitle => '选取颜色';

  @override
  String get colorHue => '色相';

  @override
  String get colorSaturation => '饱和度';

  @override
  String get colorBrightness => '亮度';

  @override
  String get settingsUpdates => '更新';

  @override
  String get updateAutoCheck => '自动检查更新';

  @override
  String get updateCheckNow => '立即检查';

  @override
  String get updateChecking => '正在检查更新…';

  @override
  String get updateUpToDate => '访达已是最新版本。';

  @override
  String get updateAvailable => '有新版本的访达可用。';

  @override
  String get updateInstall => '立即更新';

  @override
  String get updateInstalling => '正在下载并构建更新，可能需要几分钟…';

  @override
  String get updateInstalled => '更新已安装。';

  @override
  String get updateRestart => '重新启动访达';

  @override
  String updateFailed(String reason) {
    return '无法更新：$reason';
  }

  @override
  String get updateUnsupported => '此版本无法自行更新。请使用 install.sh 安装以获取更新。';

  @override
  String get themeEffects => '效果';

  @override
  String get themeSidebarOpacity => '边栏不透明度';

  @override
  String get themeWindowOpacity => '窗口不透明度';

  @override
  String get themeGlass => '菜单、对话框和面板使用玻璃样式';

  @override
  String themeBlurHint(String appId) {
    return '若要模糊访达后方的桌面，请安装 GNOME 扩展“Blur my Shell”并为 $appId 启用。';
  }
}
