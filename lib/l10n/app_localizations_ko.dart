// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Finder';

  @override
  String get sectionFavorites => '즐겨찾기';

  @override
  String get sectionLocations => '위치';

  @override
  String get placeComputer => '컴퓨터';

  @override
  String get placeTrash => '휴지통';

  @override
  String get tooltipBack => '뒤로';

  @override
  String get tooltipForward => '앞으로';

  @override
  String get tooltipViewIcons => '아이콘으로 보기';

  @override
  String get tooltipViewList => '목록으로 보기';

  @override
  String get tooltipViewColumns => '단으로 보기';

  @override
  String get tooltipEject => '추출';

  @override
  String get searchHint => '검색';

  @override
  String get columnName => '이름';

  @override
  String get columnModified => '수정일';

  @override
  String get columnSize => '크기';

  @override
  String get columnKind => '종류';

  @override
  String get kindFolder => '폴더';

  @override
  String get kindImage => '이미지';

  @override
  String get kindVideo => '동영상';

  @override
  String get kindAudio => '오디오';

  @override
  String get kindText => '일반 텍스트';

  @override
  String get kindCode => '소스 코드';

  @override
  String get kindPdf => 'PDF 문서';

  @override
  String get kindArchive => '보관함';

  @override
  String get kindDocument => '문서';

  @override
  String get kindSpreadsheet => '스프레드시트';

  @override
  String get kindPresentation => '프레젠테이션';

  @override
  String get kindApplication => '응용 프로그램';

  @override
  String get kindOther => '문서';

  @override
  String kindOtherExt(String ext) {
    return '$ext 파일';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 항목',
      one: '1개 항목',
    );
    return '$_temp0';
  }

  @override
  String selectedOfCount(int selected, int count) {
    return '$count개 중 $selected개 선택됨';
  }

  @override
  String spaceAvailable(String size) {
    return '$size 사용 가능';
  }

  @override
  String get emptyFolder => '빈 폴더';

  @override
  String noResults(String query) {
    return '“$query”에 대한 결과 없음';
  }

  @override
  String todayAt(String time) {
    return '오늘 $time';
  }

  @override
  String yesterdayAt(String time) {
    return '어제 $time';
  }

  @override
  String get menuOpen => '열기';

  @override
  String get menuQuickLook => '훑어보기';

  @override
  String get menuRename => '이름 변경';

  @override
  String get menuDuplicate => '복제';

  @override
  String get menuCopy => '복사';

  @override
  String get menuCut => '오려두기';

  @override
  String get menuPaste => '붙여넣기';

  @override
  String get menuMoveToTrash => '휴지통으로 이동';

  @override
  String get menuDeleteImmediately => '즉시 삭제…';

  @override
  String get menuPutBack => '되돌려 놓기';

  @override
  String get menuEmptyTrash => '휴지통 비우기';

  @override
  String get menuNewFolder => '새로운 폴더';

  @override
  String get menuGetInfo => '정보 가져오기';

  @override
  String get menuCopyPath => '경로 복사';

  @override
  String get menuOpenInTerminal => '터미널에서 열기';

  @override
  String get menuAddToSidebar => '사이드바에 추가';

  @override
  String get menuRemoveFromSidebar => '사이드바에서 제거';

  @override
  String get menuShowHidden => '숨김 파일 보기';

  @override
  String get menuHideHidden => '숨김 파일 가리기';

  @override
  String get menuNewWindow => '새로운 윈도우';

  @override
  String get goToFolderTitle => '폴더로 이동';

  @override
  String get goToFolderHint => '예: ~/Documents 또는 /etc';

  @override
  String get buttonGo => '이동';

  @override
  String get buttonCancel => '취소';

  @override
  String get buttonDelete => '삭제';

  @override
  String get buttonOk => '확인';

  @override
  String deleteConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 항목을 즉시 삭제하시겠습니까?',
      one: '이 항목을 즉시 삭제하시겠습니까?',
    );
    return '$_temp0';
  }

  @override
  String get deleteConfirmBody => '이 동작은 취소할 수 없습니다.';

  @override
  String get emptyTrashConfirmTitle => '휴지통의 항목을 영구적으로 지우시겠습니까?';

  @override
  String get infoKind => '종류';

  @override
  String get infoSize => '크기';

  @override
  String get infoWhere => '위치';

  @override
  String get infoModified => '수정일';

  @override
  String get infoPermissions => '권한';

  @override
  String get infoCalculating => '계산 중…';

  @override
  String get untitledFolder => '이름 없는 폴더';

  @override
  String get copySuffix => '복사본';

  @override
  String get pathCopied => '경로가 복사됨';

  @override
  String movedToTrash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 항목을 휴지통으로 이동함',
      one: '1개 항목을 휴지통으로 이동함',
    );
    return '$_temp0';
  }

  @override
  String errorFolderNotFound(String path) {
    return '“$path” 폴더를 찾을 수 없습니다.';
  }

  @override
  String errorOperation(String message) {
    return '작업을 완료할 수 없습니다: $message';
  }

  @override
  String errorNameTaken(String name) {
    return '“$name” 이름은 이미 사용 중입니다.';
  }

  @override
  String get errorInvalidName => '해당 이름은 사용할 수 없습니다.';

  @override
  String get quickLookNoPreview => '미리보기 없음';

  @override
  String get tooltipGroupSort => '그룹 및 정렬';

  @override
  String get menuGroupBy => '그룹 기준';

  @override
  String get menuSortBy => '정렬 기준';

  @override
  String get groupNone => '없음';

  @override
  String get groupToday => '오늘';

  @override
  String get groupYesterday => '어제';

  @override
  String get groupPrevious7Days => '지난 7일';

  @override
  String get groupPrevious30Days => '지난 30일';

  @override
  String get groupFolders => '폴더';

  @override
  String get groupOther => '기타';

  @override
  String get sizeZero => '0바이트';

  @override
  String sizeLessThan(String size) {
    return '$size 미만';
  }

  @override
  String sizeBetween(String from, String to) {
    return '$from ~ $to';
  }

  @override
  String sizeAtLeast(String size) {
    return '$size 이상';
  }

  @override
  String get menuSettings => '설정…';

  @override
  String get settingsTitle => 'Finder 설정';

  @override
  String get settingsGeneral => '일반';

  @override
  String get settingsSidebar => '사이드바';

  @override
  String get settingsAdvanced => '고급';

  @override
  String get settingsNewWindowsShow => '새로운 윈도우에 표시:';

  @override
  String get settingsDefaultView => '기본 보기:';

  @override
  String get settingsAppearance => '모양:';

  @override
  String get settingsLanguage => '언어:';

  @override
  String get settingsShowInSidebar => '사이드바에 표시할 항목:';

  @override
  String get settingsBookmarks => '북마크한 폴더';

  @override
  String get settingsExternalDrives => '외장 드라이브';

  @override
  String get settingsShowHidden => '숨김 파일 보기';

  @override
  String get settingsFoldersOnTop => '정렬 시 폴더를 맨 위에 유지';

  @override
  String get settingsThumbnails => '아이콘에 이미지 미리보기 표시';

  @override
  String get settingsWarnEmptyTrash => '휴지통을 비우기 전에 경고 표시';

  @override
  String get settingsNewWindowsNote =>
      '그룹, 정렬 및 보기 선택은 열려 있는 윈도우와 새로운 윈도우에 적용됩니다.';

  @override
  String get appearanceSystem => '시스템';

  @override
  String get appearanceLight => '라이트';

  @override
  String get appearanceDark => '다크';

  @override
  String get languageSystem => '시스템';

  @override
  String get viewIcons => '아이콘';

  @override
  String get viewList => '목록';

  @override
  String get viewColumns => '단';

  @override
  String get placeHome => '홈';

  @override
  String get placeDesktop => '데스크탑';

  @override
  String get placeDocuments => '문서';

  @override
  String get placeDownloads => '다운로드';

  @override
  String get placePictures => '사진';

  @override
  String get placeMusic => '음악';

  @override
  String get placeVideos => '비디오';

  @override
  String get tooltipNewTab => '새로운 탭';

  @override
  String get tooltipCloseTab => '탭 닫기';

  @override
  String get menuOpenInNewTab => '새로운 탭에서 열기';

  @override
  String get menuCloseOtherTabs => '다른 탭 닫기';

  @override
  String get menuMoveTabToNewWindow => '탭을 새로운 윈도우로 이동';

  @override
  String get menuMergeAllWindows => '모든 윈도우 병합';

  @override
  String mergedWindows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 윈도우를 병합함',
      one: '1개 윈도우를 병합함',
      zero: '병합할 다른 Finder 윈도우 없음',
    );
    return '$_temp0';
  }

  @override
  String get settingsDisplay => '보기';

  @override
  String get settingsOpenFoldersInTabs => '폴더를 새로운 윈도우 대신 탭으로 열기';

  @override
  String get settingsAccentColor => '강조 색상:';

  @override
  String get settingsTextSize => '텍스트 크기:';

  @override
  String get settingsIconSize => '아이콘 크기:';

  @override
  String get settingsShowPathBar => '경로 막대 보기';

  @override
  String get settingsShowStatusBar => '상태 막대 보기';

  @override
  String get settingsShowExtensions => '모든 파일 확장자 보기';

  @override
  String get settingsEnterRenames => 'Enter 키로 이름 변경(macOS 방식)';

  @override
  String get accentBlue => '파란색';

  @override
  String get accentPurple => '보라색';

  @override
  String get accentPink => '분홍색';

  @override
  String get accentRed => '빨간색';

  @override
  String get accentOrange => '주황색';

  @override
  String get accentYellow => '노란색';

  @override
  String get accentGreen => '초록색';

  @override
  String get accentGraphite => '그래파이트';

  @override
  String get splitDropHint => '여기에 놓아 나란히 보기';

  @override
  String get menuSplitView => '나란히 보기';

  @override
  String get menuExitSplitView => '분할 보기 종료';

  @override
  String get settingsRestoreTabs => '지난번 탭 다시 열기';

  @override
  String get menuUndo => '실행 취소';

  @override
  String get menuRedo => '실행 복귀';

  @override
  String conflictTitle(String name, String folder) {
    return '“$folder”에 “$name”이(가) 이미 있습니다';
  }

  @override
  String get conflictBody => '대체하시겠습니까? 대체되는 항목은 휴지통으로 이동합니다.';

  @override
  String get conflictReplace => '대체';

  @override
  String get conflictKeepBoth => '둘 다 유지';

  @override
  String get conflictSkip => '건너뛰기';

  @override
  String conflictApplyToAll(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '다음 충돌 $count건에도 동일하게 적용',
      one: '다음 충돌에도 동일하게 적용',
    );
    return '$_temp0';
  }

  @override
  String transferCopying(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 항목을 “$dest”(으)로 복사 중',
      one: '1개 항목을 “$dest”(으)로 복사 중',
    );
    return '$_temp0';
  }

  @override
  String transferMoving(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 항목을 “$dest”(으)로 이동 중',
      one: '1개 항목을 “$dest”(으)로 이동 중',
    );
    return '$_temp0';
  }

  @override
  String transferBytes(String done, String total) {
    return '$total 중 $done';
  }

  @override
  String transferRemaining(String time) {
    return '약 $time 남음';
  }

  @override
  String get searchIn => '검색:';

  @override
  String searchScopeSubfolders(String folder) {
    return '“$folder” 및 하위 폴더';
  }

  @override
  String get searchScopeThisFolder => '이 폴더만';

  @override
  String get searchByName => '이름';

  @override
  String get searchByContents => '이름 및 내용';

  @override
  String get searching => '검색 중…';

  @override
  String get columnLocation => '위치';

  @override
  String get tagRed => '빨강';

  @override
  String get tagOrange => '주황';

  @override
  String get tagYellow => '노랑';

  @override
  String get tagGreen => '초록';

  @override
  String get tagBlue => '파랑';

  @override
  String get tagPurple => '보라';

  @override
  String get tagGray => '회색';

  @override
  String get sidebarTags => '태그';

  @override
  String taggedIn(String tag, String folder) {
    return '“$folder”의 $tag 태그 항목';
  }

  @override
  String get tooltipRecentFolders => '최근 폴더';

  @override
  String get recentNone => '최근 폴더 없음';

  @override
  String get menuClearRecents => '메뉴 지우기';

  @override
  String get settingsTheme => '테마';

  @override
  String themeEditingFor(String mode) {
    return '$mode 화면 모드의 색상. 라이트와 다크는 각각 색상을 유지합니다.';
  }

  @override
  String get themeAccent => '강조 색상';

  @override
  String get themeSelection => '선택 항목';

  @override
  String get themeFolder => '폴더';

  @override
  String get themeWindow => '윈도우 배경';

  @override
  String get themeSidebar => '사이드바';

  @override
  String get themeToolbar => '도구 막대';

  @override
  String get themeReset => '기본값 사용';

  @override
  String get themeResetAll => '모든 색상 재설정';

  @override
  String get colorPickerTitle => '색상 선택';

  @override
  String get colorHue => '색조';

  @override
  String get colorSaturation => '채도';

  @override
  String get colorBrightness => '밝기';

  @override
  String get settingsUpdates => '업데이트';

  @override
  String get updateAutoCheck => '자동으로 업데이트 확인';

  @override
  String get updateCheckNow => '지금 확인';

  @override
  String get updateChecking => '업데이트 확인 중…';

  @override
  String get updateUpToDate => 'Finder가 최신 상태입니다.';

  @override
  String get updateAvailable => '새로운 버전의 Finder를 사용할 수 있습니다.';

  @override
  String get updateInstall => '지금 업데이트';

  @override
  String get updateInstalling => '업데이트를 다운로드하고 빌드하는 중입니다. 몇 분 정도 걸릴 수 있습니다…';

  @override
  String get updateInstalled => '업데이트가 설치되었습니다.';

  @override
  String get updateRestart => 'Finder 재시동';

  @override
  String updateFailed(String reason) {
    return '업데이트할 수 없음: $reason';
  }

  @override
  String get updateUnsupported =>
      '이 빌드는 스스로 업데이트할 수 없습니다. install.sh로 설치하면 업데이트를 받을 수 있습니다.';

  @override
  String get themeEffects => '효과';

  @override
  String get themeSidebarOpacity => '사이드바 불투명도';

  @override
  String get themeWindowOpacity => '윈도우 불투명도';

  @override
  String get themeGlass => '메뉴, 대화상자 및 패널에 유리 스타일 사용';

  @override
  String themeBlurHint(String appId) {
    return 'Finder 뒤의 데스크탑을 흐리게 하려면 GNOME 확장 프로그램 ‘Blur my Shell’을 설치하고 $appId에 대해 켜십시오.';
  }
}
