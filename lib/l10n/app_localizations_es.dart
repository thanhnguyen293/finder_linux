// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Finder';

  @override
  String get sectionFavorites => 'Favoritos';

  @override
  String get sectionLocations => 'Ubicaciones';

  @override
  String get placeComputer => 'Ordenador';

  @override
  String get placeTrash => 'Papelera';

  @override
  String get tooltipBack => 'Atrás';

  @override
  String get tooltipForward => 'Adelante';

  @override
  String get tooltipViewIcons => 'Como iconos';

  @override
  String get tooltipViewList => 'Como lista';

  @override
  String get tooltipViewColumns => 'Como columnas';

  @override
  String get tooltipEject => 'Expulsar';

  @override
  String get searchHint => 'Buscar';

  @override
  String get columnName => 'Nombre';

  @override
  String get columnModified => 'Fecha de modificación';

  @override
  String get columnSize => 'Tamaño';

  @override
  String get columnKind => 'Tipo';

  @override
  String get kindFolder => 'Carpeta';

  @override
  String get kindImage => 'Imagen';

  @override
  String get kindVideo => 'Película';

  @override
  String get kindAudio => 'Audio';

  @override
  String get kindText => 'Texto sin formato';

  @override
  String get kindCode => 'Código fuente';

  @override
  String get kindPdf => 'Documento PDF';

  @override
  String get kindArchive => 'Archivo comprimido';

  @override
  String get kindDocument => 'Documento';

  @override
  String get kindSpreadsheet => 'Hoja de cálculo';

  @override
  String get kindPresentation => 'Presentación';

  @override
  String get kindApplication => 'Aplicación';

  @override
  String get kindOther => 'Documento';

  @override
  String kindOtherExt(String ext) {
    return 'Archivo $ext';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos',
      one: '1 elemento',
    );
    return '$_temp0';
  }

  @override
  String selectedOfCount(int selected, int count) {
    return '$selected de $count seleccionados';
  }

  @override
  String spaceAvailable(String size) {
    return '$size disponibles';
  }

  @override
  String get emptyFolder => 'Carpeta vacía';

  @override
  String noResults(String query) {
    return 'Sin resultados para «$query»';
  }

  @override
  String todayAt(String time) {
    return 'Hoy a las $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Ayer a las $time';
  }

  @override
  String get menuOpen => 'Abrir';

  @override
  String get menuQuickLook => 'Vista rápida';

  @override
  String get menuRename => 'Renombrar';

  @override
  String get menuDuplicate => 'Duplicar';

  @override
  String get menuCopy => 'Copiar';

  @override
  String get menuCut => 'Cortar';

  @override
  String get menuPaste => 'Pegar';

  @override
  String get menuMoveToTrash => 'Mover a la papelera';

  @override
  String get menuDeleteImmediately => 'Eliminar inmediatamente…';

  @override
  String get menuPutBack => 'Devolver';

  @override
  String get menuEmptyTrash => 'Vaciar papelera';

  @override
  String get menuNewFolder => 'Nueva carpeta';

  @override
  String get menuGetInfo => 'Obtener información';

  @override
  String get menuCopyPath => 'Copiar ruta';

  @override
  String get menuOpenInTerminal => 'Abrir en Terminal';

  @override
  String menuOpenInApp(String app) {
    return 'Abrir en $app';
  }

  @override
  String get menuAddToSidebar => 'Añadir a la barra lateral';

  @override
  String get menuRemoveFromSidebar => 'Quitar de la barra lateral';

  @override
  String get menuShowHidden => 'Mostrar archivos ocultos';

  @override
  String get menuHideHidden => 'Ocultar archivos ocultos';

  @override
  String get menuNewWindow => 'Nueva ventana';

  @override
  String get goToFolderTitle => 'Ir a la carpeta';

  @override
  String get goToFolderHint => 'p. ej. ~/Documents o /etc';

  @override
  String get buttonGo => 'Ir';

  @override
  String get buttonCancel => 'Cancelar';

  @override
  String get buttonDelete => 'Eliminar';

  @override
  String get buttonOk => 'OK';

  @override
  String deleteConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Eliminar $count elementos inmediatamente?',
      one: '¿Eliminar este elemento inmediatamente?',
    );
    return '$_temp0';
  }

  @override
  String get deleteConfirmBody => 'Esta acción no se puede deshacer.';

  @override
  String get emptyTrashConfirmTitle =>
      '¿Borrar permanentemente los elementos de la papelera?';

  @override
  String get infoKind => 'Tipo';

  @override
  String get infoSize => 'Tamaño';

  @override
  String get infoWhere => 'Ubicación';

  @override
  String get infoModified => 'Modificado';

  @override
  String get infoPermissions => 'Permisos';

  @override
  String get infoCalculating => 'Calculando…';

  @override
  String get untitledFolder => 'carpeta sin título';

  @override
  String get copySuffix => 'copia';

  @override
  String get pathCopied => 'Ruta copiada';

  @override
  String movedToTrash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos movidos a la papelera',
      one: '1 elemento movido a la papelera',
    );
    return '$_temp0';
  }

  @override
  String errorFolderNotFound(String path) {
    return 'No se encuentra la carpeta «$path».';
  }

  @override
  String errorOperation(String message) {
    return 'No se puede completar la operación: $message';
  }

  @override
  String errorNameTaken(String name) {
    return 'El nombre «$name» ya está en uso.';
  }

  @override
  String get errorInvalidName => 'No se puede usar ese nombre.';

  @override
  String get quickLookNoPreview => 'Vista previa no disponible';

  @override
  String get tooltipGroupSort => 'Agrupar y ordenar';

  @override
  String get menuGroupBy => 'Agrupar por';

  @override
  String get menuSortBy => 'Ordenar por';

  @override
  String get groupNone => 'Ninguno';

  @override
  String get groupToday => 'Hoy';

  @override
  String get groupYesterday => 'Ayer';

  @override
  String get groupPrevious7Days => 'Últimos 7 días';

  @override
  String get groupPrevious30Days => 'Últimos 30 días';

  @override
  String get groupFolders => 'Carpetas';

  @override
  String get groupOther => 'Otros';

  @override
  String get sizeZero => 'Cero bytes';

  @override
  String sizeLessThan(String size) {
    return 'Menos de $size';
  }

  @override
  String sizeBetween(String from, String to) {
    return 'De $from a $to';
  }

  @override
  String sizeAtLeast(String size) {
    return '$size o más';
  }

  @override
  String get menuSettings => 'Ajustes…';

  @override
  String get settingsTitle => 'Ajustes de Finder';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsSidebar => 'Barra lateral';

  @override
  String get settingsAdvanced => 'Avanzado';

  @override
  String get settingsNewWindowsShow => 'Las nuevas ventanas muestran:';

  @override
  String get settingsDefaultView => 'Vista predeterminada:';

  @override
  String get settingsAppearance => 'Apariencia:';

  @override
  String get settingsLanguage => 'Idioma:';

  @override
  String get settingsShowInSidebar =>
      'Mostrar estos elementos en la barra lateral:';

  @override
  String get settingsBookmarks => 'Carpetas marcadas';

  @override
  String get settingsExternalDrives => 'Discos externos';

  @override
  String get settingsShowHidden => 'Mostrar archivos ocultos';

  @override
  String get settingsFoldersOnTop => 'Mantener las carpetas arriba al ordenar';

  @override
  String get settingsThumbnails =>
      'Mostrar vistas previas de imágenes en los iconos';

  @override
  String get settingsWarnEmptyTrash => 'Avisar antes de vaciar la papelera';

  @override
  String get settingsNewWindowsNote =>
      'Las opciones de agrupación, orden y vista se aplican a las ventanas abiertas y a las nuevas.';

  @override
  String get appearanceSystem => 'Sistema';

  @override
  String get appearanceLight => 'Claro';

  @override
  String get appearanceDark => 'Oscuro';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get viewIcons => 'Iconos';

  @override
  String get viewList => 'Lista';

  @override
  String get viewColumns => 'Columnas';

  @override
  String get placeHome => 'Inicio';

  @override
  String get placeDesktop => 'Escritorio';

  @override
  String get placeDocuments => 'Documentos';

  @override
  String get placeDownloads => 'Descargas';

  @override
  String get placePictures => 'Imágenes';

  @override
  String get placeMusic => 'Música';

  @override
  String get placeVideos => 'Vídeos';

  @override
  String get tooltipNewTab => 'Nueva pestaña';

  @override
  String get tooltipCloseTab => 'Cerrar pestaña';

  @override
  String get menuOpenInNewTab => 'Abrir en una pestaña nueva';

  @override
  String get menuCloseOtherTabs => 'Cerrar las otras pestañas';

  @override
  String get menuMoveTabToNewWindow => 'Mover pestaña a una ventana nueva';

  @override
  String get menuMergeAllWindows => 'Combinar todas las ventanas';

  @override
  String mergedWindows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ventanas combinadas',
      one: '1 ventana combinada',
      zero: 'No hay otras ventanas de Finder que combinar',
    );
    return '$_temp0';
  }

  @override
  String get settingsDisplay => 'Visualización';

  @override
  String get settingsOpenFoldersInTabs =>
      'Abrir carpetas en pestañas en lugar de ventanas nuevas';

  @override
  String get settingsAccentColor => 'Color de énfasis:';

  @override
  String get settingsTextSize => 'Tamaño del texto:';

  @override
  String get settingsIconSize => 'Tamaño de los iconos:';

  @override
  String get settingsShowPathBar => 'Mostrar barra de ruta';

  @override
  String get settingsShowStatusBar => 'Mostrar barra de estado';

  @override
  String get settingsShowExtensions =>
      'Mostrar todas las extensiones de archivo';

  @override
  String get settingsEnterRenames =>
      'Pulsar Intro para renombrar (estilo macOS)';

  @override
  String get accentBlue => 'Azul';

  @override
  String get accentPurple => 'Morado';

  @override
  String get accentPink => 'Rosa';

  @override
  String get accentRed => 'Rojo';

  @override
  String get accentOrange => 'Naranja';

  @override
  String get accentYellow => 'Amarillo';

  @override
  String get accentGreen => 'Verde';

  @override
  String get accentGraphite => 'Grafito';

  @override
  String get splitDropHint => 'Suelta para mostrar en paralelo';

  @override
  String get menuSplitView => 'Mostrar en paralelo';

  @override
  String get menuExitSplitView => 'Salir de la vista dividida';

  @override
  String get settingsRestoreTabs => 'Reabrir las pestañas de la última vez';

  @override
  String get menuUndo => 'Deshacer';

  @override
  String get menuRedo => 'Rehacer';

  @override
  String conflictTitle(String name, String folder) {
    return '«$name» ya existe en «$folder»';
  }

  @override
  String get conflictBody =>
      '¿Quieres reemplazarlo? El elemento reemplazado se moverá a la papelera.';

  @override
  String get conflictReplace => 'Reemplazar';

  @override
  String get conflictKeepBoth => 'Conservar ambos';

  @override
  String get conflictSkip => 'Omitir';

  @override
  String conflictApplyToAll(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hacer lo mismo en los siguientes $count conflictos',
      one: 'Hacer lo mismo en el siguiente conflicto',
    );
    return '$_temp0';
  }

  @override
  String transferCopying(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Copiando $count elementos a «$dest»',
      one: 'Copiando 1 elemento a «$dest»',
    );
    return '$_temp0';
  }

  @override
  String transferMoving(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Moviendo $count elementos a «$dest»',
      one: 'Moviendo 1 elemento a «$dest»',
    );
    return '$_temp0';
  }

  @override
  String transferBytes(String done, String total) {
    return '$done de $total';
  }

  @override
  String transferRemaining(String time) {
    return 'quedan unos $time';
  }

  @override
  String get searchIn => 'Buscar:';

  @override
  String searchScopeSubfolders(String folder) {
    return '«$folder» y subcarpetas';
  }

  @override
  String get searchScopeThisFolder => 'Solo esta carpeta';

  @override
  String get searchByName => 'Nombre';

  @override
  String get searchByContents => 'Nombre y contenido';

  @override
  String get searching => 'Buscando…';

  @override
  String get columnLocation => 'Ubicación';

  @override
  String get tagRed => 'Rojo';

  @override
  String get tagOrange => 'Naranja';

  @override
  String get tagYellow => 'Amarillo';

  @override
  String get tagGreen => 'Verde';

  @override
  String get tagBlue => 'Azul';

  @override
  String get tagPurple => 'Morado';

  @override
  String get tagGray => 'Gris';

  @override
  String get sidebarTags => 'Etiquetas';

  @override
  String get sidebarDevices => 'Dispositivos';

  @override
  String menuSendTo(String device) {
    return 'Enviar a $device';
  }

  @override
  String sentToDevice(int count, String device) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se enviaron $count elementos a $device',
      one: 'Se envió 1 elemento a $device',
    );
    return '$_temp0';
  }

  @override
  String taggedIn(String tag, String folder) {
    return 'Con la etiqueta $tag en «$folder»';
  }

  @override
  String get tooltipRecentFolders => 'Carpetas recientes';

  @override
  String get recentNone => 'No hay carpetas recientes';

  @override
  String get menuClearRecents => 'Borrar menú';

  @override
  String get settingsTheme => 'Tema';

  @override
  String themeEditingFor(String mode) {
    return 'Colores del aspecto $mode. El claro y el oscuro guardan sus propios colores.';
  }

  @override
  String get themeAccent => 'Color de acentuación';

  @override
  String get themeSelection => 'Selección';

  @override
  String get themeFolder => 'Carpetas';

  @override
  String get themeWindow => 'Fondo de la ventana';

  @override
  String get themeSidebar => 'Barra lateral';

  @override
  String get themeToolbar => 'Barra de herramientas';

  @override
  String get themeReset => 'Usar valor por omisión';

  @override
  String get themeResetAll => 'Restablecer todos los colores';

  @override
  String get colorPickerTitle => 'Elegir un color';

  @override
  String get colorHue => 'Tono';

  @override
  String get colorSaturation => 'Saturación';

  @override
  String get colorBrightness => 'Brillo';

  @override
  String get settingsUpdates => 'Actualizaciones';

  @override
  String get updateAutoCheck => 'Buscar actualizaciones automáticamente';

  @override
  String get updateCheckNow => 'Comprobar ahora';

  @override
  String get updateChecking => 'Buscando actualizaciones…';

  @override
  String get updateUpToDate => 'Finder está actualizado.';

  @override
  String get updateAvailable => 'Hay una nueva versión de Finder disponible.';

  @override
  String get updateInstall => 'Actualizar ahora';

  @override
  String get updateInstalling =>
      'Descargando y compilando la actualización. Puede tardar unos minutos…';

  @override
  String get updateInstalled => 'La actualización está instalada.';

  @override
  String get updateRestart => 'Reiniciar Finder';

  @override
  String updateFailed(String reason) {
    return 'No se pudo actualizar: $reason';
  }

  @override
  String get updateUnsupported =>
      'Esta compilación no puede actualizarse sola. Instálala con install.sh para recibir actualizaciones.';

  @override
  String get themeEffects => 'Efectos';

  @override
  String get themeSidebarOpacity => 'Opacidad de la barra lateral';

  @override
  String get themeWindowOpacity => 'Opacidad de la ventana';

  @override
  String get themeGlass => 'Estilo cristal en menús, diálogos y paneles';

  @override
  String themeBlurHint(String appId) {
    return 'Para desenfocar el escritorio detrás de Finder, instala la extensión de GNOME “Blur my Shell” y actívala para $appId.';
  }
}
