// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'Finder';

  @override
  String get sectionFavorites => 'Вибране';

  @override
  String get sectionLocations => 'Розташування';

  @override
  String get placeComputer => 'Комп’ютер';

  @override
  String get placeTrash => 'Смітник';

  @override
  String get tooltipBack => 'Назад';

  @override
  String get tooltipForward => 'Вперед';

  @override
  String get tooltipViewIcons => 'Показати як піктограми';

  @override
  String get tooltipViewList => 'Показати як список';

  @override
  String get tooltipViewColumns => 'Показати як стовпці';

  @override
  String get tooltipEject => 'Витягти';

  @override
  String get searchHint => 'Пошук';

  @override
  String get columnName => 'Ім’я';

  @override
  String get columnModified => 'Дата зміни';

  @override
  String get columnSize => 'Розмір';

  @override
  String get columnKind => 'Тип';

  @override
  String get kindFolder => 'Папка';

  @override
  String get kindImage => 'Зображення';

  @override
  String get kindVideo => 'Фільм';

  @override
  String get kindAudio => 'Звук';

  @override
  String get kindText => 'Простий текст';

  @override
  String get kindCode => 'Вихідний код';

  @override
  String get kindPdf => 'Документ PDF';

  @override
  String get kindArchive => 'Архів';

  @override
  String get kindDocument => 'Документ';

  @override
  String get kindSpreadsheet => 'Електронна таблиця';

  @override
  String get kindPresentation => 'Презентація';

  @override
  String get kindApplication => 'Програма';

  @override
  String get kindOther => 'Документ';

  @override
  String kindOtherExt(String ext) {
    return 'Файл $ext';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count елемента',
      many: '$count елементів',
      few: '$count елементи',
      one: '$count елемент',
    );
    return '$_temp0';
  }

  @override
  String selectedOfCount(int selected, int count) {
    return 'Вибрано $selected з $count';
  }

  @override
  String spaceAvailable(String size) {
    return 'Доступно: $size';
  }

  @override
  String get emptyFolder => 'Порожня папка';

  @override
  String noResults(String query) {
    return 'Немає результатів для «$query»';
  }

  @override
  String todayAt(String time) {
    return 'Сьогодні о $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Вчора о $time';
  }

  @override
  String get menuOpen => 'Відкрити';

  @override
  String get menuQuickLook => 'Швидкий перегляд';

  @override
  String get menuRename => 'Перейменувати';

  @override
  String get menuDuplicate => 'Дублювати';

  @override
  String get menuCopy => 'Скопіювати';

  @override
  String get menuCut => 'Вирізати';

  @override
  String get menuPaste => 'Вставити';

  @override
  String get menuMoveToTrash => 'Перемістити до смітника';

  @override
  String get menuDeleteImmediately => 'Видалити негайно…';

  @override
  String get menuPutBack => 'Повернути';

  @override
  String get menuEmptyTrash => 'Очистити смітник';

  @override
  String get menuNewFolder => 'Нова папка';

  @override
  String get menuGetInfo => 'Отримати інформацію';

  @override
  String get menuCopyPath => 'Скопіювати шлях';

  @override
  String get menuOpenInTerminal => 'Відкрити в Терміналі';

  @override
  String get menuAddToSidebar => 'Додати до бічної панелі';

  @override
  String get menuRemoveFromSidebar => 'Вилучити з бічної панелі';

  @override
  String get menuShowHidden => 'Показати приховані файли';

  @override
  String get menuHideHidden => 'Сховати приховані файли';

  @override
  String get menuNewWindow => 'Нове вікно';

  @override
  String get goToFolderTitle => 'Перейти до папки';

  @override
  String get goToFolderHint => 'напр. ~/Documents або /etc';

  @override
  String get buttonGo => 'Перейти';

  @override
  String get buttonCancel => 'Скасувати';

  @override
  String get buttonDelete => 'Видалити';

  @override
  String get buttonOk => 'OK';

  @override
  String deleteConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Видалити $count елемента негайно?',
      many: 'Видалити $count елементів негайно?',
      few: 'Видалити $count елементи негайно?',
      one: 'Видалити $count елемент негайно?',
    );
    return '$_temp0';
  }

  @override
  String get deleteConfirmBody => 'Цю дію не можна скасувати.';

  @override
  String get emptyTrashConfirmTitle => 'Остаточно стерти елементи у смітнику?';

  @override
  String get infoKind => 'Тип';

  @override
  String get infoSize => 'Розмір';

  @override
  String get infoWhere => 'Де';

  @override
  String get infoModified => 'Змінено';

  @override
  String get infoPermissions => 'Права доступу';

  @override
  String get infoCalculating => 'Обчислення…';

  @override
  String get untitledFolder => 'папка без назви';

  @override
  String get copySuffix => 'копія';

  @override
  String get pathCopied => 'Шлях скопійовано';

  @override
  String movedToTrash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Переміщено $count елемента до смітника',
      many: 'Переміщено $count елементів до смітника',
      few: 'Переміщено $count елементи до смітника',
      one: 'Переміщено $count елемент до смітника',
    );
    return '$_temp0';
  }

  @override
  String errorFolderNotFound(String path) {
    return 'Папку «$path» не знайдено.';
  }

  @override
  String errorOperation(String message) {
    return 'Не вдалося виконати операцію: $message';
  }

  @override
  String errorNameTaken(String name) {
    return 'Ім’я «$name» уже зайняте.';
  }

  @override
  String get errorInvalidName => 'Це ім’я не можна використовувати.';

  @override
  String get quickLookNoPreview => 'Попередній перегляд недоступний';

  @override
  String get tooltipGroupSort => 'Групування і сортування';

  @override
  String get menuGroupBy => 'Групувати за';

  @override
  String get menuSortBy => 'Сортувати за';

  @override
  String get groupNone => 'Немає';

  @override
  String get groupToday => 'Сьогодні';

  @override
  String get groupYesterday => 'Вчора';

  @override
  String get groupPrevious7Days => 'Попередні 7 днів';

  @override
  String get groupPrevious30Days => 'Попередні 30 днів';

  @override
  String get groupFolders => 'Папки';

  @override
  String get groupOther => 'Інше';

  @override
  String get sizeZero => 'Нуль байтів';

  @override
  String sizeLessThan(String size) {
    return 'Менше ніж $size';
  }

  @override
  String sizeBetween(String from, String to) {
    return 'Від $from до $to';
  }

  @override
  String sizeAtLeast(String size) {
    return '$size або більше';
  }

  @override
  String get menuSettings => 'Параметри…';

  @override
  String get settingsTitle => 'Параметри Finder';

  @override
  String get settingsGeneral => 'Загальні';

  @override
  String get settingsSidebar => 'Бічна панель';

  @override
  String get settingsAdvanced => 'Додатково';

  @override
  String get settingsNewWindowsShow => 'Нові вікна показують:';

  @override
  String get settingsDefaultView => 'Вигляд за умовчанням:';

  @override
  String get settingsAppearance => 'Оформлення:';

  @override
  String get settingsLanguage => 'Мова:';

  @override
  String get settingsShowInSidebar =>
      'Показувати ці елементи на бічній панелі:';

  @override
  String get settingsBookmarks => 'Папки із закладками';

  @override
  String get settingsExternalDrives => 'Зовнішні диски';

  @override
  String get settingsShowHidden => 'Показувати приховані файли';

  @override
  String get settingsFoldersOnTop => 'Папки зверху під час сортування';

  @override
  String get settingsThumbnails =>
      'Показувати попередній перегляд зображень у піктограмах';

  @override
  String get settingsWarnEmptyTrash => 'Попереджати перед очищенням смітника';

  @override
  String get settingsNewWindowsNote =>
      'Вибір групування, сортування і вигляду застосовується до відкритих і нових вікон.';

  @override
  String get appearanceSystem => 'Системне';

  @override
  String get appearanceLight => 'Світле';

  @override
  String get appearanceDark => 'Темне';

  @override
  String get languageSystem => 'Системна';

  @override
  String get viewIcons => 'Піктограми';

  @override
  String get viewList => 'Список';

  @override
  String get viewColumns => 'Стовпці';

  @override
  String get placeHome => 'Домівка';

  @override
  String get placeDesktop => 'Робочий стіл';

  @override
  String get placeDocuments => 'Документи';

  @override
  String get placeDownloads => 'Завантаження';

  @override
  String get placePictures => 'Зображення';

  @override
  String get placeMusic => 'Музика';

  @override
  String get placeVideos => 'Відео';

  @override
  String get tooltipNewTab => 'Нова вкладка';

  @override
  String get tooltipCloseTab => 'Закрити вкладку';

  @override
  String get menuOpenInNewTab => 'Відкрити в новій вкладці';

  @override
  String get menuCloseOtherTabs => 'Закрити інші вкладки';

  @override
  String get menuMoveTabToNewWindow => 'Перемістити вкладку до нового вікна';

  @override
  String get menuMergeAllWindows => 'Об’єднати всі вікна';

  @override
  String mergedWindows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Об’єднано $count вікна',
      many: 'Об’єднано $count вікон',
      few: 'Об’єднано $count вікна',
      one: 'Об’єднано $count вікно',
      zero: 'Немає інших вікон Finder для об’єднання',
    );
    return '$_temp0';
  }

  @override
  String get settingsDisplay => 'Екран';

  @override
  String get settingsOpenFoldersInTabs =>
      'Відкривати папки у вкладках замість нових вікон';

  @override
  String get settingsAccentColor => 'Колір акценту:';

  @override
  String get settingsTextSize => 'Розмір тексту:';

  @override
  String get settingsIconSize => 'Розмір піктограм:';

  @override
  String get settingsShowPathBar => 'Показувати рядок шляху';

  @override
  String get settingsShowStatusBar => 'Показувати рядок стану';

  @override
  String get settingsShowExtensions => 'Показувати всі розширення імен файлів';

  @override
  String get settingsEnterRenames => 'Enter для перейменування (як у macOS)';

  @override
  String get accentBlue => 'Синій';

  @override
  String get accentPurple => 'Фіолетовий';

  @override
  String get accentPink => 'Рожевий';

  @override
  String get accentRed => 'Червоний';

  @override
  String get accentOrange => 'Помаранчевий';

  @override
  String get accentYellow => 'Жовтий';

  @override
  String get accentGreen => 'Зелений';

  @override
  String get accentGraphite => 'Графітовий';

  @override
  String get splitDropHint => 'Відпустіть, щоб показати поруч';

  @override
  String get menuSplitView => 'Показати поруч';

  @override
  String get menuExitSplitView => 'Вийти з розділеного вигляду';

  @override
  String get settingsRestoreTabs => 'Знову відкривати вкладки з минулого разу';

  @override
  String get menuUndo => 'Скасувати';

  @override
  String get menuRedo => 'Повторити';

  @override
  String conflictTitle(String name, String folder) {
    return '«$name» уже існує в «$folder»';
  }

  @override
  String get conflictBody =>
      'Бажаєте замінити? Замінений елемент буде переміщено до смітника.';

  @override
  String get conflictReplace => 'Замінити';

  @override
  String get conflictKeepBoth => 'Залишити обидва';

  @override
  String get conflictSkip => 'Пропустити';

  @override
  String conflictApplyToAll(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Зробити те саме для наступних конфліктів: $count',
      one: 'Зробити те саме для наступного конфлікту',
    );
    return '$_temp0';
  }

  @override
  String transferCopying(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Копіювання елементів ($count) до «$dest»',
      one: 'Копіювання 1 елемента до «$dest»',
    );
    return '$_temp0';
  }

  @override
  String transferMoving(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Переміщення елементів ($count) до «$dest»',
      one: 'Переміщення 1 елемента до «$dest»',
    );
    return '$_temp0';
  }

  @override
  String transferBytes(String done, String total) {
    return '$done з $total';
  }

  @override
  String transferRemaining(String time) {
    return 'залишилося приблизно $time';
  }

  @override
  String get searchIn => 'Пошук:';

  @override
  String searchScopeSubfolders(String folder) {
    return '«$folder» і підпапки';
  }

  @override
  String get searchScopeThisFolder => 'Лише ця папка';

  @override
  String get searchByName => 'Ім’я';

  @override
  String get searchByContents => 'Ім’я та вміст';

  @override
  String get searching => 'Пошук…';

  @override
  String get columnLocation => 'Розташування';

  @override
  String get tagRed => 'Червоний';

  @override
  String get tagOrange => 'Помаранчевий';

  @override
  String get tagYellow => 'Жовтий';

  @override
  String get tagGreen => 'Зелений';

  @override
  String get tagBlue => 'Синій';

  @override
  String get tagPurple => 'Фіолетовий';

  @override
  String get tagGray => 'Сірий';

  @override
  String get sidebarTags => 'Теги';

  @override
  String get sidebarDevices => 'Пристрої';

  @override
  String taggedIn(String tag, String folder) {
    return 'Позначено тегом $tag у «$folder»';
  }

  @override
  String get tooltipRecentFolders => 'Останні папки';

  @override
  String get recentNone => 'Немає останніх папок';

  @override
  String get menuClearRecents => 'Очистити меню';

  @override
  String get settingsTheme => 'Тема';

  @override
  String themeEditingFor(String mode) {
    return 'Кольори для оформлення «$mode». Світле й темне мають власні кольори.';
  }

  @override
  String get themeAccent => 'Колір акценту';

  @override
  String get themeSelection => 'Вибране';

  @override
  String get themeFolder => 'Папки';

  @override
  String get themeWindow => 'Тло вікна';

  @override
  String get themeSidebar => 'Бічна панель';

  @override
  String get themeToolbar => 'Панель інструментів';

  @override
  String get themeReset => 'Типово';

  @override
  String get themeResetAll => 'Скинути всі кольори';

  @override
  String get colorPickerTitle => 'Вибрати колір';

  @override
  String get colorHue => 'Відтінок';

  @override
  String get colorSaturation => 'Насиченість';

  @override
  String get colorBrightness => 'Яскравість';

  @override
  String get settingsUpdates => 'Оновлення';

  @override
  String get updateAutoCheck => 'Автоматично перевіряти оновлення';

  @override
  String get updateCheckNow => 'Перевірити';

  @override
  String get updateChecking => 'Перевірка оновлень…';

  @override
  String get updateUpToDate => 'Finder оновлено до останньої версії.';

  @override
  String get updateAvailable => 'Доступна нова версія Finder.';

  @override
  String get updateInstall => 'Оновити';

  @override
  String get updateInstalling =>
      'Завантаження й збирання оновлення. Це може тривати кілька хвилин…';

  @override
  String get updateInstalled => 'Оновлення встановлено.';

  @override
  String get updateRestart => 'Перезапустити Finder';

  @override
  String updateFailed(String reason) {
    return 'Не вдалося оновити: $reason';
  }

  @override
  String get updateUnsupported =>
      'Ця збірка не може оновлюватися сама. Встановіть її через install.sh, щоб отримувати оновлення.';

  @override
  String get themeEffects => 'Ефекти';

  @override
  String get themeSidebarOpacity => 'Непрозорість бічної панелі';

  @override
  String get themeWindowOpacity => 'Непрозорість вікна';

  @override
  String get themeGlass => 'Стиль «скло» для меню, діалогів і панелей';

  @override
  String themeBlurHint(String appId) {
    return 'Щоб розмити стільницю за Finder, встановіть розширення GNOME «Blur my Shell» і ввімкніть його для $appId.';
  }
}
