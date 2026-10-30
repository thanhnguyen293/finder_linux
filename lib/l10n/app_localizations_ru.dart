// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Finder';

  @override
  String get sectionFavorites => 'Избранное';

  @override
  String get sectionLocations => 'Места';

  @override
  String get placeComputer => 'Компьютер';

  @override
  String get placeTrash => 'Корзина';

  @override
  String get tooltipBack => 'Назад';

  @override
  String get tooltipForward => 'Вперёд';

  @override
  String get tooltipViewIcons => 'Как значки';

  @override
  String get tooltipViewList => 'Как список';

  @override
  String get tooltipViewColumns => 'Как колонки';

  @override
  String get tooltipEject => 'Извлечь';

  @override
  String get searchHint => 'Поиск';

  @override
  String get columnName => 'Имя';

  @override
  String get columnModified => 'Дата изменения';

  @override
  String get columnSize => 'Размер';

  @override
  String get columnKind => 'Вид';

  @override
  String get kindFolder => 'Папка';

  @override
  String get kindImage => 'Изображение';

  @override
  String get kindVideo => 'Фильм';

  @override
  String get kindAudio => 'Аудио';

  @override
  String get kindText => 'Простой текст';

  @override
  String get kindCode => 'Исходный код';

  @override
  String get kindPdf => 'Документ PDF';

  @override
  String get kindArchive => 'Архив';

  @override
  String get kindDocument => 'Документ';

  @override
  String get kindSpreadsheet => 'Таблица';

  @override
  String get kindPresentation => 'Презентация';

  @override
  String get kindApplication => 'Приложение';

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
      other: '$count объекта',
      many: '$count объектов',
      few: '$count объекта',
      one: '$count объект',
    );
    return '$_temp0';
  }

  @override
  String selectedOfCount(int selected, int count) {
    return 'Выбрано $selected из $count';
  }

  @override
  String spaceAvailable(String size) {
    return 'Доступно: $size';
  }

  @override
  String get emptyFolder => 'Пустая папка';

  @override
  String noResults(String query) {
    return 'Нет результатов для «$query»';
  }

  @override
  String todayAt(String time) {
    return 'Сегодня в $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Вчера в $time';
  }

  @override
  String get menuOpen => 'Открыть';

  @override
  String get menuQuickLook => 'Быстрый просмотр';

  @override
  String get menuRename => 'Переименовать';

  @override
  String get menuDuplicate => 'Дублировать';

  @override
  String get menuCopy => 'Скопировать';

  @override
  String get menuCut => 'Вырезать';

  @override
  String get menuPaste => 'Вставить';

  @override
  String get menuMoveToTrash => 'Переместить в Корзину';

  @override
  String get menuDeleteImmediately => 'Удалить немедленно…';

  @override
  String get menuPutBack => 'Вернуть';

  @override
  String get menuEmptyTrash => 'Очистить Корзину';

  @override
  String get menuNewFolder => 'Новая папка';

  @override
  String get menuGetInfo => 'Свойства';

  @override
  String get menuCopyPath => 'Скопировать путь';

  @override
  String get menuOpenInTerminal => 'Открыть в Терминале';

  @override
  String get menuAddToSidebar => 'Добавить в боковое меню';

  @override
  String get menuRemoveFromSidebar => 'Удалить из бокового меню';

  @override
  String get menuShowHidden => 'Показывать скрытые файлы';

  @override
  String get menuHideHidden => 'Не показывать скрытые файлы';

  @override
  String get menuNewWindow => 'Новое окно';

  @override
  String get goToFolderTitle => 'Переход к папке';

  @override
  String get goToFolderHint => 'напр., ~/Documents или /etc';

  @override
  String get buttonGo => 'Перейти';

  @override
  String get buttonCancel => 'Отменить';

  @override
  String get buttonDelete => 'Удалить';

  @override
  String get buttonOk => 'OK';

  @override
  String deleteConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Удалить $count объекта немедленно?',
      many: 'Удалить $count объектов немедленно?',
      few: 'Удалить $count объекта немедленно?',
      one: 'Удалить $count объект немедленно?',
    );
    return '$_temp0';
  }

  @override
  String get deleteConfirmBody => 'Это действие нельзя отменить.';

  @override
  String get emptyTrashConfirmTitle =>
      'Безвозвратно стереть объекты из Корзины?';

  @override
  String get infoKind => 'Вид';

  @override
  String get infoSize => 'Размер';

  @override
  String get infoWhere => 'Расположение';

  @override
  String get infoModified => 'Изменено';

  @override
  String get infoPermissions => 'Права доступа';

  @override
  String get infoCalculating => 'Вычисление…';

  @override
  String get untitledFolder => 'папка без названия';

  @override
  String get copySuffix => 'копия';

  @override
  String get pathCopied => 'Путь скопирован';

  @override
  String movedToTrash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count объекта перемещено в Корзину',
      many: '$count объектов перемещено в Корзину',
      few: '$count объекта перемещено в Корзину',
      one: '$count объект перемещён в Корзину',
    );
    return '$_temp0';
  }

  @override
  String errorFolderNotFound(String path) {
    return 'Не удалось найти папку «$path».';
  }

  @override
  String errorOperation(String message) {
    return 'Не удалось выполнить операцию: $message';
  }

  @override
  String errorNameTaken(String name) {
    return 'Имя «$name» уже занято.';
  }

  @override
  String get errorInvalidName => 'Это имя использовать нельзя.';

  @override
  String get quickLookNoPreview => 'Предпросмотр недоступен';

  @override
  String get tooltipGroupSort => 'Группировка и сортировка';

  @override
  String get menuGroupBy => 'Группировать по';

  @override
  String get menuSortBy => 'Сортировать по';

  @override
  String get groupNone => 'Нет';

  @override
  String get groupToday => 'Сегодня';

  @override
  String get groupYesterday => 'Вчера';

  @override
  String get groupPrevious7Days => 'Предыдущие 7 дней';

  @override
  String get groupPrevious30Days => 'Предыдущие 30 дней';

  @override
  String get groupFolders => 'Папки';

  @override
  String get groupOther => 'Другое';

  @override
  String get sizeZero => 'Ноль байт';

  @override
  String sizeLessThan(String size) {
    return 'Менее $size';
  }

  @override
  String sizeBetween(String from, String to) {
    return 'От $from до $to';
  }

  @override
  String sizeAtLeast(String size) {
    return '$size или более';
  }

  @override
  String get menuSettings => 'Настройки…';

  @override
  String get settingsTitle => 'Настройки Finder';

  @override
  String get settingsGeneral => 'Основные';

  @override
  String get settingsSidebar => 'Боковое меню';

  @override
  String get settingsAdvanced => 'Дополнения';

  @override
  String get settingsNewWindowsShow => 'Новые окна показывают:';

  @override
  String get settingsDefaultView => 'Вид по умолчанию:';

  @override
  String get settingsAppearance => 'Оформление:';

  @override
  String get settingsLanguage => 'Язык:';

  @override
  String get settingsShowInSidebar => 'Показывать в боковом меню:';

  @override
  String get settingsBookmarks => 'Папки с закладками';

  @override
  String get settingsExternalDrives => 'Внешние диски';

  @override
  String get settingsShowHidden => 'Показывать скрытые файлы';

  @override
  String get settingsFoldersOnTop => 'Папки сверху при сортировке';

  @override
  String get settingsThumbnails => 'Показывать превью изображений на значках';

  @override
  String get settingsWarnEmptyTrash => 'Предупреждать перед очисткой Корзины';

  @override
  String get settingsNewWindowsNote =>
      'Выбранные группировка, сортировка и вид применяются к открытым и новым окнам.';

  @override
  String get appearanceSystem => 'Системное';

  @override
  String get appearanceLight => 'Светлое';

  @override
  String get appearanceDark => 'Тёмное';

  @override
  String get languageSystem => 'Системный';

  @override
  String get viewIcons => 'Значки';

  @override
  String get viewList => 'Список';

  @override
  String get viewColumns => 'Колонки';

  @override
  String get placeHome => 'Домой';

  @override
  String get placeDesktop => 'Рабочий стол';

  @override
  String get placeDocuments => 'Документы';

  @override
  String get placeDownloads => 'Загрузки';

  @override
  String get placePictures => 'Изображения';

  @override
  String get placeMusic => 'Музыка';

  @override
  String get placeVideos => 'Видео';

  @override
  String get tooltipNewTab => 'Новая вкладка';

  @override
  String get tooltipCloseTab => 'Закрыть вкладку';

  @override
  String get menuOpenInNewTab => 'Открыть в новой вкладке';

  @override
  String get menuCloseOtherTabs => 'Закрыть остальные вкладки';

  @override
  String get menuMoveTabToNewWindow => 'Переместить вкладку в новое окно';

  @override
  String get menuMergeAllWindows => 'Объединить все окна';

  @override
  String mergedWindows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Объединено $count окна',
      many: 'Объединено $count окон',
      few: 'Объединено $count окна',
      one: 'Объединено $count окно',
      zero: 'Нет других окон Finder для объединения',
    );
    return '$_temp0';
  }

  @override
  String get settingsDisplay => 'Отображение';

  @override
  String get settingsOpenFoldersInTabs =>
      'Открывать папки во вкладках, а не в новых окнах';

  @override
  String get settingsAccentColor => 'Цвет акцента:';

  @override
  String get settingsTextSize => 'Размер текста:';

  @override
  String get settingsIconSize => 'Размер значков:';

  @override
  String get settingsShowPathBar => 'Показывать строку пути';

  @override
  String get settingsShowStatusBar => 'Показывать строку состояния';

  @override
  String get settingsShowExtensions => 'Показывать все расширения имён файлов';

  @override
  String get settingsEnterRenames => 'Переименовывать по Enter (как в macOS)';

  @override
  String get accentBlue => 'Синий';

  @override
  String get accentPurple => 'Фиолетовый';

  @override
  String get accentPink => 'Розовый';

  @override
  String get accentRed => 'Красный';

  @override
  String get accentOrange => 'Оранжевый';

  @override
  String get accentYellow => 'Жёлтый';

  @override
  String get accentGreen => 'Зелёный';

  @override
  String get accentGraphite => 'Графитовый';

  @override
  String get splitDropHint => 'Отпустите, чтобы показать рядом';

  @override
  String get menuSplitView => 'Показать рядом';

  @override
  String get menuExitSplitView => 'Выйти из разделённого вида';

  @override
  String get settingsRestoreTabs => 'Открывать вкладки с прошлого раза';

  @override
  String get menuUndo => 'Отменить';

  @override
  String get menuRedo => 'Повторить';

  @override
  String conflictTitle(String name, String folder) {
    return '«$name» уже существует в «$folder»';
  }

  @override
  String get conflictBody =>
      'Заменить? Заменённый объект будет перемещён в Корзину.';

  @override
  String get conflictReplace => 'Заменить';

  @override
  String get conflictKeepBoth => 'Оставить оба';

  @override
  String get conflictSkip => 'Пропустить';

  @override
  String conflictApplyToAll(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Сделать то же для следующих конфликтов: $count',
      one: 'Сделать то же для следующего конфликта',
    );
    return '$_temp0';
  }

  @override
  String transferCopying(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Копирование объектов ($count) в «$dest»',
      one: 'Копирование 1 объекта в «$dest»',
    );
    return '$_temp0';
  }

  @override
  String transferMoving(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Перемещение объектов ($count) в «$dest»',
      one: 'Перемещение 1 объекта в «$dest»',
    );
    return '$_temp0';
  }

  @override
  String transferBytes(String done, String total) {
    return '$done из $total';
  }

  @override
  String transferRemaining(String time) {
    return 'осталось примерно $time';
  }

  @override
  String get searchIn => 'Поиск:';

  @override
  String searchScopeSubfolders(String folder) {
    return '«$folder» и вложенные папки';
  }

  @override
  String get searchScopeThisFolder => 'Только эта папка';

  @override
  String get searchByName => 'Имя';

  @override
  String get searchByContents => 'Имя и содержимое';

  @override
  String get searching => 'Поиск…';

  @override
  String get columnLocation => 'Расположение';

  @override
  String get tagRed => 'Красный';

  @override
  String get tagOrange => 'Оранжевый';

  @override
  String get tagYellow => 'Жёлтый';

  @override
  String get tagGreen => 'Зелёный';

  @override
  String get tagBlue => 'Синий';

  @override
  String get tagPurple => 'Фиолетовый';

  @override
  String get tagGray => 'Серый';

  @override
  String get sidebarTags => 'Теги';

  @override
  String taggedIn(String tag, String folder) {
    return 'Тег «$tag» в «$folder»';
  }

  @override
  String get tooltipRecentFolders => 'Недавние папки';

  @override
  String get recentNone => 'Нет недавних папок';

  @override
  String get menuClearRecents => 'Очистить меню';

  @override
  String get settingsTheme => 'Тема';

  @override
  String themeEditingFor(String mode) {
    return 'Цвета для оформления «$mode». У светлого и тёмного свои цвета.';
  }

  @override
  String get themeAccent => 'Цвет акцента';

  @override
  String get themeSelection => 'Выделение';

  @override
  String get themeFolder => 'Папки';

  @override
  String get themeWindow => 'Фон окна';

  @override
  String get themeSidebar => 'Боковое меню';

  @override
  String get themeToolbar => 'Панель инструментов';

  @override
  String get themeReset => 'По умолчанию';

  @override
  String get themeResetAll => 'Сбросить все цвета';

  @override
  String get colorPickerTitle => 'Выбор цвета';

  @override
  String get colorHue => 'Оттенок';

  @override
  String get colorSaturation => 'Насыщенность';

  @override
  String get colorBrightness => 'Яркость';

  @override
  String get settingsUpdates => 'Обновления';

  @override
  String get updateAutoCheck => 'Автоматически проверять обновления';

  @override
  String get updateCheckNow => 'Проверить';

  @override
  String get updateChecking => 'Проверка обновлений…';

  @override
  String get updateUpToDate => 'Установлена последняя версия Finder.';

  @override
  String get updateAvailable => 'Доступна новая версия Finder.';

  @override
  String get updateInstall => 'Обновить';

  @override
  String get updateInstalling =>
      'Загрузка и сборка обновления. Это может занять несколько минут…';

  @override
  String get updateInstalled => 'Обновление установлено.';

  @override
  String get updateRestart => 'Перезапустить Finder';

  @override
  String updateFailed(String reason) {
    return 'Не удалось обновить: $reason';
  }

  @override
  String get updateUnsupported =>
      'Эта сборка не может обновляться сама. Установите её через install.sh, чтобы получать обновления.';

  @override
  String get themeEffects => 'Эффекты';

  @override
  String get themeSidebarOpacity => 'Непрозрачность бокового меню';

  @override
  String get themeWindowOpacity => 'Непрозрачность окна';

  @override
  String get themeGlass => 'Стиль «стекло» для меню, диалогов и панелей';

  @override
  String themeBlurHint(String appId) {
    return 'Чтобы размыть рабочий стол за Finder, установите расширение GNOME «Blur my Shell» и включите его для $appId.';
  }
}
