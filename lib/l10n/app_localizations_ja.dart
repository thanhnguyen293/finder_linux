// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Finder';

  @override
  String get sectionFavorites => 'お気に入り';

  @override
  String get sectionLocations => '場所';

  @override
  String get placeComputer => 'コンピュータ';

  @override
  String get placeTrash => 'ゴミ箱';

  @override
  String get tooltipBack => '戻る';

  @override
  String get tooltipForward => '進む';

  @override
  String get tooltipViewIcons => 'アイコンとして表示';

  @override
  String get tooltipViewList => 'リストとして表示';

  @override
  String get tooltipViewColumns => 'カラムとして表示';

  @override
  String get tooltipEject => '取り出す';

  @override
  String get searchHint => '検索';

  @override
  String get columnName => '名前';

  @override
  String get columnModified => '変更日';

  @override
  String get columnSize => 'サイズ';

  @override
  String get columnKind => '種類';

  @override
  String get kindFolder => 'フォルダ';

  @override
  String get kindImage => 'イメージ';

  @override
  String get kindVideo => 'ムービー';

  @override
  String get kindAudio => 'オーディオ';

  @override
  String get kindText => 'プレーンテキスト';

  @override
  String get kindCode => 'ソースコード';

  @override
  String get kindPdf => 'PDF書類';

  @override
  String get kindArchive => 'アーカイブ';

  @override
  String get kindDocument => '書類';

  @override
  String get kindSpreadsheet => 'スプレッドシート';

  @override
  String get kindPresentation => 'プレゼンテーション';

  @override
  String get kindApplication => 'アプリケーション';

  @override
  String get kindOther => '書類';

  @override
  String kindOtherExt(String ext) {
    return '$extファイル';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count個の項目',
      one: '1個の項目',
    );
    return '$_temp0';
  }

  @override
  String selectedOfCount(int selected, int count) {
    return '$count個中$selected個を選択';
  }

  @override
  String spaceAvailable(String size) {
    return '$size使用可能';
  }

  @override
  String get emptyFolder => '空のフォルダ';

  @override
  String noResults(String query) {
    return '“$query”の検索結果はありません';
  }

  @override
  String todayAt(String time) {
    return '今日 $time';
  }

  @override
  String yesterdayAt(String time) {
    return '昨日 $time';
  }

  @override
  String get menuOpen => '開く';

  @override
  String get menuQuickLook => 'クイックルック';

  @override
  String get menuRename => '名称変更';

  @override
  String get menuDuplicate => '複製';

  @override
  String get menuCopy => 'コピー';

  @override
  String get menuCut => 'カット';

  @override
  String get menuPaste => 'ペースト';

  @override
  String get menuMoveToTrash => 'ゴミ箱に入れる';

  @override
  String get menuDeleteImmediately => 'すぐに削除…';

  @override
  String get menuPutBack => '戻す';

  @override
  String get menuEmptyTrash => 'ゴミ箱を空にする';

  @override
  String get menuNewFolder => '新規フォルダ';

  @override
  String get menuGetInfo => '情報を見る';

  @override
  String get menuCopyPath => 'パスをコピー';

  @override
  String get menuOpenInTerminal => 'ターミナルで開く';

  @override
  String get menuAddToSidebar => 'サイドバーに追加';

  @override
  String get menuRemoveFromSidebar => 'サイドバーから削除';

  @override
  String get menuShowHidden => '不可視ファイルを表示';

  @override
  String get menuHideHidden => '不可視ファイルを非表示';

  @override
  String get menuNewWindow => '新規ウインドウ';

  @override
  String get goToFolderTitle => 'フォルダへ移動';

  @override
  String get goToFolderHint => '例：~/Documents または /etc';

  @override
  String get buttonGo => '移動';

  @override
  String get buttonCancel => 'キャンセル';

  @override
  String get buttonDelete => '削除';

  @override
  String get buttonOk => 'OK';

  @override
  String deleteConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count個の項目をすぐに削除しますか？',
      one: 'この項目をすぐに削除しますか？',
    );
    return '$_temp0';
  }

  @override
  String get deleteConfirmBody => 'この操作は取り消せません。';

  @override
  String get emptyTrashConfirmTitle => 'ゴミ箱の項目を完全に消去しますか？';

  @override
  String get infoKind => '種類';

  @override
  String get infoSize => 'サイズ';

  @override
  String get infoWhere => '場所';

  @override
  String get infoModified => '変更日';

  @override
  String get infoPermissions => 'アクセス権';

  @override
  String get infoCalculating => '計算中…';

  @override
  String get untitledFolder => '名称未設定フォルダ';

  @override
  String get copySuffix => 'コピー';

  @override
  String get pathCopied => 'パスをコピーしました';

  @override
  String movedToTrash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count個の項目をゴミ箱に入れました',
      one: '1個の項目をゴミ箱に入れました',
    );
    return '$_temp0';
  }

  @override
  String errorFolderNotFound(String path) {
    return 'フォルダ“$path”が見つかりません。';
  }

  @override
  String errorOperation(String message) {
    return '操作を完了できません：$message';
  }

  @override
  String errorNameTaken(String name) {
    return '名前“$name”は既に使用されています。';
  }

  @override
  String get errorInvalidName => 'その名前は使用できません。';

  @override
  String get quickLookNoPreview => 'プレビューは利用できません';

  @override
  String get tooltipGroupSort => 'グループと並べ替え';

  @override
  String get menuGroupBy => 'グループ化';

  @override
  String get menuSortBy => '並べ替え';

  @override
  String get groupNone => 'なし';

  @override
  String get groupToday => '今日';

  @override
  String get groupYesterday => '昨日';

  @override
  String get groupPrevious7Days => '過去7日間';

  @override
  String get groupPrevious30Days => '過去30日間';

  @override
  String get groupFolders => 'フォルダ';

  @override
  String get groupOther => 'その他';

  @override
  String get sizeZero => '0バイト';

  @override
  String sizeLessThan(String size) {
    return '$size未満';
  }

  @override
  String sizeBetween(String from, String to) {
    return '$from～$to';
  }

  @override
  String sizeAtLeast(String size) {
    return '$size以上';
  }

  @override
  String get menuSettings => '設定…';

  @override
  String get settingsTitle => 'Finder設定';

  @override
  String get settingsGeneral => '一般';

  @override
  String get settingsSidebar => 'サイドバー';

  @override
  String get settingsAdvanced => '詳細';

  @override
  String get settingsNewWindowsShow => '新規ウインドウで表示する項目:';

  @override
  String get settingsDefaultView => 'デフォルトの表示:';

  @override
  String get settingsAppearance => '外観:';

  @override
  String get settingsLanguage => '言語:';

  @override
  String get settingsShowInSidebar => 'サイドバーに表示する項目:';

  @override
  String get settingsBookmarks => 'ブックマークしたフォルダ';

  @override
  String get settingsExternalDrives => '外部ディスク';

  @override
  String get settingsShowHidden => '不可視ファイルを表示';

  @override
  String get settingsFoldersOnTop => '並べ替え時にフォルダを先頭にする';

  @override
  String get settingsThumbnails => 'アイコンにイメージのプレビューを表示';

  @override
  String get settingsWarnEmptyTrash => 'ゴミ箱を空にする前に警告を表示';

  @override
  String get settingsNewWindowsNote =>
      'グループ、並べ替え、表示の選択は、開いているウインドウと新規ウインドウに適用されます。';

  @override
  String get appearanceSystem => 'システム';

  @override
  String get appearanceLight => 'ライト';

  @override
  String get appearanceDark => 'ダーク';

  @override
  String get languageSystem => 'システム';

  @override
  String get viewIcons => 'アイコン';

  @override
  String get viewList => 'リスト';

  @override
  String get viewColumns => 'カラム';

  @override
  String get placeHome => 'ホーム';

  @override
  String get placeDesktop => 'デスクトップ';

  @override
  String get placeDocuments => '書類';

  @override
  String get placeDownloads => 'ダウンロード';

  @override
  String get placePictures => 'ピクチャ';

  @override
  String get placeMusic => 'ミュージック';

  @override
  String get placeVideos => 'ムービー';

  @override
  String get tooltipNewTab => '新規タブ';

  @override
  String get tooltipCloseTab => 'タブを閉じる';

  @override
  String get menuOpenInNewTab => '新規タブで開く';

  @override
  String get menuCloseOtherTabs => '他のタブを閉じる';

  @override
  String get menuMoveTabToNewWindow => 'タブを新規ウインドウに移動';

  @override
  String get menuMergeAllWindows => 'すべてのウインドウを統合';

  @override
  String mergedWindows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count個のウインドウを統合しました',
      one: '1個のウインドウを統合しました',
      zero: '統合する他のFinderウインドウはありません',
    );
    return '$_temp0';
  }

  @override
  String get settingsDisplay => '表示';

  @override
  String get settingsOpenFoldersInTabs => '新規ウインドウではなくタブでフォルダを開く';

  @override
  String get settingsAccentColor => 'アクセントカラー:';

  @override
  String get settingsTextSize => 'テキストサイズ:';

  @override
  String get settingsIconSize => 'アイコンサイズ:';

  @override
  String get settingsShowPathBar => 'パスバーを表示';

  @override
  String get settingsShowStatusBar => 'ステータスバーを表示';

  @override
  String get settingsShowExtensions => 'すべてのファイル名拡張子を表示';

  @override
  String get settingsEnterRenames => 'Enterキーで名称変更（macOSスタイル）';

  @override
  String get accentBlue => 'ブルー';

  @override
  String get accentPurple => 'パープル';

  @override
  String get accentPink => 'ピンク';

  @override
  String get accentRed => 'レッド';

  @override
  String get accentOrange => 'オレンジ';

  @override
  String get accentYellow => 'イエロー';

  @override
  String get accentGreen => 'グリーン';

  @override
  String get accentGraphite => 'グラファイト';

  @override
  String get splitDropHint => 'ドロップして並べて表示';

  @override
  String get menuSplitView => '並べて表示';

  @override
  String get menuExitSplitView => '分割表示を終了';

  @override
  String get settingsRestoreTabs => '前回のタブを再び開く';

  @override
  String get menuUndo => '取り消す';

  @override
  String get menuRedo => 'やり直す';

  @override
  String conflictTitle(String name, String folder) {
    return '“$folder”には“$name”という項目が既に存在します';
  }

  @override
  String get conflictBody => '置き換えますか？置き換えた項目はゴミ箱に入ります。';

  @override
  String get conflictReplace => '置き換える';

  @override
  String get conflictKeepBoth => '両方を残す';

  @override
  String get conflictSkip => 'スキップ';

  @override
  String conflictApplyToAll(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '次の$count件の競合にも同じ操作を適用',
      one: '次の競合にも同じ操作を適用',
    );
    return '$_temp0';
  }

  @override
  String transferCopying(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count個の項目を“$dest”にコピー中',
      one: '1個の項目を“$dest”にコピー中',
    );
    return '$_temp0';
  }

  @override
  String transferMoving(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count個の項目を“$dest”に移動中',
      one: '1個の項目を“$dest”に移動中',
    );
    return '$_temp0';
  }

  @override
  String transferBytes(String done, String total) {
    return '$total中$done';
  }

  @override
  String transferRemaining(String time) {
    return '残り約$time';
  }

  @override
  String get searchIn => '検索:';

  @override
  String searchScopeSubfolders(String folder) {
    return '“$folder”とサブフォルダ';
  }

  @override
  String get searchScopeThisFolder => 'このフォルダのみ';

  @override
  String get searchByName => '名前';

  @override
  String get searchByContents => '名前と内容';

  @override
  String get searching => '検索中…';

  @override
  String get columnLocation => '場所';

  @override
  String get tagRed => 'レッド';

  @override
  String get tagOrange => 'オレンジ';

  @override
  String get tagYellow => 'イエロー';

  @override
  String get tagGreen => 'グリーン';

  @override
  String get tagBlue => 'ブルー';

  @override
  String get tagPurple => 'パープル';

  @override
  String get tagGray => 'グレイ';

  @override
  String get sidebarTags => 'タグ';

  @override
  String taggedIn(String tag, String folder) {
    return '“$folder”内の$tagタグ付き項目';
  }

  @override
  String get tooltipRecentFolders => '最近使ったフォルダ';

  @override
  String get recentNone => '最近使ったフォルダはありません';

  @override
  String get menuClearRecents => 'メニューを消去';

  @override
  String get settingsTheme => 'テーマ';

  @override
  String themeEditingFor(String mode) {
    return '$mode外観の色。ライトとダークはそれぞれ別の色を保持します。';
  }

  @override
  String get themeAccent => 'アクセントカラー';

  @override
  String get themeSelection => '選択部分';

  @override
  String get themeFolder => 'フォルダ';

  @override
  String get themeWindow => 'ウインドウの背景';

  @override
  String get themeSidebar => 'サイドバー';

  @override
  String get themeToolbar => 'ツールバー';

  @override
  String get themeReset => 'デフォルトに戻す';

  @override
  String get themeResetAll => 'すべての色をリセット';

  @override
  String get colorPickerTitle => '色を選択';

  @override
  String get colorHue => '色相';

  @override
  String get colorSaturation => '彩度';

  @override
  String get colorBrightness => '明るさ';

  @override
  String get settingsUpdates => 'アップデート';

  @override
  String get updateAutoCheck => 'アップデートを自動的に確認';

  @override
  String get updateCheckNow => '今すぐ確認';

  @override
  String get updateChecking => 'アップデートを確認中…';

  @override
  String get updateUpToDate => 'Finderは最新です。';

  @override
  String get updateAvailable => '新しいバージョンのFinderがあります。';

  @override
  String get updateInstall => '今すぐアップデート';

  @override
  String get updateInstalling => 'アップデートをダウンロードしてビルドしています。数分かかる場合があります…';

  @override
  String get updateInstalled => 'アップデートをインストールしました。';

  @override
  String get updateRestart => 'Finderを再起動';

  @override
  String updateFailed(String reason) {
    return 'アップデートできませんでした: $reason';
  }

  @override
  String get updateUnsupported =>
      'このビルドは自動アップデートできません。install.sh でインストールしてください。';

  @override
  String get themeEffects => 'エフェクト';

  @override
  String get themeSidebarOpacity => 'サイドバーの不透明度';

  @override
  String get themeWindowOpacity => 'ウインドウの不透明度';

  @override
  String get themeGlass => 'メニュー、ダイアログ、パネルをガラス風にする';

  @override
  String themeBlurHint(String appId) {
    return 'Finderの背後のデスクトップをぼかすには、GNOME拡張機能「Blur my Shell」をインストールして $appId に対して有効にしてください。';
  }
}
