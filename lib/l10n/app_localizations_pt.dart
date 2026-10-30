// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Finder';

  @override
  String get sectionFavorites => 'Favoritos';

  @override
  String get sectionLocations => 'Locais';

  @override
  String get placeComputer => 'Computador';

  @override
  String get placeTrash => 'Lixeira';

  @override
  String get tooltipBack => 'Voltar';

  @override
  String get tooltipForward => 'Avançar';

  @override
  String get tooltipViewIcons => 'Como ícones';

  @override
  String get tooltipViewList => 'Como lista';

  @override
  String get tooltipViewColumns => 'Como colunas';

  @override
  String get tooltipEject => 'Ejetar';

  @override
  String get searchHint => 'Buscar';

  @override
  String get columnName => 'Nome';

  @override
  String get columnModified => 'Data de modificação';

  @override
  String get columnSize => 'Tamanho';

  @override
  String get columnKind => 'Tipo';

  @override
  String get kindFolder => 'Pasta';

  @override
  String get kindImage => 'Imagem';

  @override
  String get kindVideo => 'Filme';

  @override
  String get kindAudio => 'Áudio';

  @override
  String get kindText => 'Texto simples';

  @override
  String get kindCode => 'Código-fonte';

  @override
  String get kindPdf => 'Documento PDF';

  @override
  String get kindArchive => 'Arquivo compactado';

  @override
  String get kindDocument => 'Documento';

  @override
  String get kindSpreadsheet => 'Planilha';

  @override
  String get kindPresentation => 'Apresentação';

  @override
  String get kindApplication => 'Aplicativo';

  @override
  String get kindOther => 'Documento';

  @override
  String kindOtherExt(String ext) {
    return 'Arquivo $ext';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String selectedOfCount(int selected, int count) {
    return '$selected de $count selecionados';
  }

  @override
  String spaceAvailable(String size) {
    return '$size disponíveis';
  }

  @override
  String get emptyFolder => 'Pasta vazia';

  @override
  String noResults(String query) {
    return 'Nenhum resultado para “$query”';
  }

  @override
  String todayAt(String time) {
    return 'Hoje às $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Ontem às $time';
  }

  @override
  String get menuOpen => 'Abrir';

  @override
  String get menuQuickLook => 'Visualização rápida';

  @override
  String get menuRename => 'Renomear';

  @override
  String get menuDuplicate => 'Duplicar';

  @override
  String get menuCopy => 'Copiar';

  @override
  String get menuCut => 'Recortar';

  @override
  String get menuPaste => 'Colar';

  @override
  String get menuMoveToTrash => 'Mover para a Lixeira';

  @override
  String get menuDeleteImmediately => 'Excluir imediatamente…';

  @override
  String get menuPutBack => 'Colocar de volta';

  @override
  String get menuEmptyTrash => 'Esvaziar Lixeira';

  @override
  String get menuNewFolder => 'Nova pasta';

  @override
  String get menuGetInfo => 'Obter informações';

  @override
  String get menuCopyPath => 'Copiar caminho';

  @override
  String get menuOpenInTerminal => 'Abrir no Terminal';

  @override
  String get menuAddToSidebar => 'Adicionar à barra lateral';

  @override
  String get menuRemoveFromSidebar => 'Remover da barra lateral';

  @override
  String get menuShowHidden => 'Mostrar arquivos ocultos';

  @override
  String get menuHideHidden => 'Ocultar arquivos ocultos';

  @override
  String get menuNewWindow => 'Nova janela';

  @override
  String get goToFolderTitle => 'Ir para a pasta';

  @override
  String get goToFolderHint => 'ex.: ~/Documents ou /etc';

  @override
  String get buttonGo => 'Ir';

  @override
  String get buttonCancel => 'Cancelar';

  @override
  String get buttonDelete => 'Excluir';

  @override
  String get buttonOk => 'OK';

  @override
  String deleteConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Excluir $count itens imediatamente?',
      one: 'Excluir este item imediatamente?',
    );
    return '$_temp0';
  }

  @override
  String get deleteConfirmBody => 'Não é possível desfazer esta ação.';

  @override
  String get emptyTrashConfirmTitle =>
      'Apagar permanentemente os itens da Lixeira?';

  @override
  String get infoKind => 'Tipo';

  @override
  String get infoSize => 'Tamanho';

  @override
  String get infoWhere => 'Local';

  @override
  String get infoModified => 'Modificado';

  @override
  String get infoPermissions => 'Permissões';

  @override
  String get infoCalculating => 'Calculando…';

  @override
  String get untitledFolder => 'pasta sem título';

  @override
  String get copySuffix => 'cópia';

  @override
  String get pathCopied => 'Caminho copiado';

  @override
  String movedToTrash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens movidos para a Lixeira',
      one: '1 item movido para a Lixeira',
    );
    return '$_temp0';
  }

  @override
  String errorFolderNotFound(String path) {
    return 'Não foi possível encontrar a pasta “$path”.';
  }

  @override
  String errorOperation(String message) {
    return 'Não foi possível concluir a operação: $message';
  }

  @override
  String errorNameTaken(String name) {
    return 'O nome “$name” já está em uso.';
  }

  @override
  String get errorInvalidName => 'Esse nome não pode ser usado.';

  @override
  String get quickLookNoPreview => 'Visualização não disponível';

  @override
  String get tooltipGroupSort => 'Agrupar e ordenar';

  @override
  String get menuGroupBy => 'Agrupar por';

  @override
  String get menuSortBy => 'Ordenar por';

  @override
  String get groupNone => 'Nenhum';

  @override
  String get groupToday => 'Hoje';

  @override
  String get groupYesterday => 'Ontem';

  @override
  String get groupPrevious7Days => 'Últimos 7 dias';

  @override
  String get groupPrevious30Days => 'Últimos 30 dias';

  @override
  String get groupFolders => 'Pastas';

  @override
  String get groupOther => 'Outros';

  @override
  String get sizeZero => 'Zero bytes';

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
    return '$size ou mais';
  }

  @override
  String get menuSettings => 'Ajustes…';

  @override
  String get settingsTitle => 'Ajustes do Finder';

  @override
  String get settingsGeneral => 'Geral';

  @override
  String get settingsSidebar => 'Barra lateral';

  @override
  String get settingsAdvanced => 'Avançado';

  @override
  String get settingsNewWindowsShow => 'Novas janelas mostram:';

  @override
  String get settingsDefaultView => 'Visualização padrão:';

  @override
  String get settingsAppearance => 'Aparência:';

  @override
  String get settingsLanguage => 'Idioma:';

  @override
  String get settingsShowInSidebar => 'Mostrar estes itens na barra lateral:';

  @override
  String get settingsBookmarks => 'Pastas favoritas';

  @override
  String get settingsExternalDrives => 'Discos externos';

  @override
  String get settingsShowHidden => 'Mostrar arquivos ocultos';

  @override
  String get settingsFoldersOnTop => 'Manter pastas no topo ao ordenar';

  @override
  String get settingsThumbnails => 'Mostrar prévias de imagens nos ícones';

  @override
  String get settingsWarnEmptyTrash => 'Avisar antes de esvaziar a Lixeira';

  @override
  String get settingsNewWindowsNote =>
      'As opções de agrupamento, ordenação e visualização valem para as janelas abertas e as novas.';

  @override
  String get appearanceSystem => 'Sistema';

  @override
  String get appearanceLight => 'Claro';

  @override
  String get appearanceDark => 'Escuro';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get viewIcons => 'Ícones';

  @override
  String get viewList => 'Lista';

  @override
  String get viewColumns => 'Colunas';

  @override
  String get placeHome => 'Início';

  @override
  String get placeDesktop => 'Mesa';

  @override
  String get placeDocuments => 'Documentos';

  @override
  String get placeDownloads => 'Downloads';

  @override
  String get placePictures => 'Imagens';

  @override
  String get placeMusic => 'Música';

  @override
  String get placeVideos => 'Vídeos';

  @override
  String get tooltipNewTab => 'Nova aba';

  @override
  String get tooltipCloseTab => 'Fechar aba';

  @override
  String get menuOpenInNewTab => 'Abrir em nova aba';

  @override
  String get menuCloseOtherTabs => 'Fechar outras abas';

  @override
  String get menuMoveTabToNewWindow => 'Mover aba para nova janela';

  @override
  String get menuMergeAllWindows => 'Mesclar todas as janelas';

  @override
  String mergedWindows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count janelas mescladas',
      one: '1 janela mesclada',
      zero: 'Não há outras janelas do Finder para mesclar',
    );
    return '$_temp0';
  }

  @override
  String get settingsDisplay => 'Exibição';

  @override
  String get settingsOpenFoldersInTabs =>
      'Abrir pastas em abas em vez de novas janelas';

  @override
  String get settingsAccentColor => 'Cor de destaque:';

  @override
  String get settingsTextSize => 'Tamanho do texto:';

  @override
  String get settingsIconSize => 'Tamanho dos ícones:';

  @override
  String get settingsShowPathBar => 'Mostrar barra de caminho';

  @override
  String get settingsShowStatusBar => 'Mostrar barra de status';

  @override
  String get settingsShowExtensions => 'Mostrar todas as extensões de arquivo';

  @override
  String get settingsEnterRenames =>
      'Pressionar Enter para renomear (estilo macOS)';

  @override
  String get accentBlue => 'Azul';

  @override
  String get accentPurple => 'Roxo';

  @override
  String get accentPink => 'Rosa';

  @override
  String get accentRed => 'Vermelho';

  @override
  String get accentOrange => 'Laranja';

  @override
  String get accentYellow => 'Amarelo';

  @override
  String get accentGreen => 'Verde';

  @override
  String get accentGraphite => 'Grafite';

  @override
  String get splitDropHint => 'Solte para mostrar lado a lado';

  @override
  String get menuSplitView => 'Mostrar lado a lado';

  @override
  String get menuExitSplitView => 'Sair da divisão de tela';

  @override
  String get settingsRestoreTabs => 'Reabrir as abas da última vez';

  @override
  String get menuUndo => 'Desfazer';

  @override
  String get menuRedo => 'Refazer';

  @override
  String conflictTitle(String name, String folder) {
    return '“$name” já existe em “$folder”';
  }

  @override
  String get conflictBody =>
      'Deseja substituí-lo? O item substituído vai para a Lixeira.';

  @override
  String get conflictReplace => 'Substituir';

  @override
  String get conflictKeepBoth => 'Manter ambos';

  @override
  String get conflictSkip => 'Ignorar';

  @override
  String conflictApplyToAll(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Fazer o mesmo nos próximos $count conflitos',
      one: 'Fazer o mesmo no próximo conflito',
    );
    return '$_temp0';
  }

  @override
  String transferCopying(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Copiando $count itens para “$dest”',
      one: 'Copiando 1 item para “$dest”',
    );
    return '$_temp0';
  }

  @override
  String transferMoving(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Movendo $count itens para “$dest”',
      one: 'Movendo 1 item para “$dest”',
    );
    return '$_temp0';
  }

  @override
  String transferBytes(String done, String total) {
    return '$done de $total';
  }

  @override
  String transferRemaining(String time) {
    return 'faltam cerca de $time';
  }

  @override
  String get searchIn => 'Buscar:';

  @override
  String searchScopeSubfolders(String folder) {
    return '“$folder” e subpastas';
  }

  @override
  String get searchScopeThisFolder => 'Somente esta pasta';

  @override
  String get searchByName => 'Nome';

  @override
  String get searchByContents => 'Nome e conteúdo';

  @override
  String get searching => 'Buscando…';

  @override
  String get columnLocation => 'Local';

  @override
  String get tagRed => 'Vermelho';

  @override
  String get tagOrange => 'Laranja';

  @override
  String get tagYellow => 'Amarelo';

  @override
  String get tagGreen => 'Verde';

  @override
  String get tagBlue => 'Azul';

  @override
  String get tagPurple => 'Roxo';

  @override
  String get tagGray => 'Cinza';

  @override
  String get sidebarTags => 'Etiquetas';

  @override
  String taggedIn(String tag, String folder) {
    return 'Com a etiqueta $tag em “$folder”';
  }

  @override
  String get tooltipRecentFolders => 'Pastas Recentes';

  @override
  String get recentNone => 'Nenhuma pasta recente';

  @override
  String get menuClearRecents => 'Limpar Menu';

  @override
  String get settingsTheme => 'Tema';

  @override
  String themeEditingFor(String mode) {
    return 'Cores da aparência $mode. Clara e escura mantêm suas próprias cores.';
  }

  @override
  String get themeAccent => 'Cor de destaque';

  @override
  String get themeSelection => 'Seleção';

  @override
  String get themeFolder => 'Pastas';

  @override
  String get themeWindow => 'Fundo da janela';

  @override
  String get themeSidebar => 'Barra lateral';

  @override
  String get themeToolbar => 'Barra de ferramentas';

  @override
  String get themeReset => 'Usar padrão';

  @override
  String get themeResetAll => 'Redefinir Todas as Cores';

  @override
  String get colorPickerTitle => 'Escolher uma Cor';

  @override
  String get colorHue => 'Matiz';

  @override
  String get colorSaturation => 'Saturação';

  @override
  String get colorBrightness => 'Brilho';

  @override
  String get settingsUpdates => 'Atualizações';

  @override
  String get updateAutoCheck => 'Verificar atualizações automaticamente';

  @override
  String get updateCheckNow => 'Verificar Agora';

  @override
  String get updateChecking => 'Verificando atualizações…';

  @override
  String get updateUpToDate => 'O Finder está atualizado.';

  @override
  String get updateAvailable => 'Uma nova versão do Finder está disponível.';

  @override
  String get updateInstall => 'Atualizar Agora';

  @override
  String get updateInstalling =>
      'Baixando e compilando a atualização. Isso pode levar alguns minutos…';

  @override
  String get updateInstalled => 'A atualização foi instalada.';

  @override
  String get updateRestart => 'Reiniciar o Finder';

  @override
  String updateFailed(String reason) {
    return 'Não foi possível atualizar: $reason';
  }

  @override
  String get updateUnsupported =>
      'Esta versão não pode se atualizar. Instale com install.sh para receber atualizações.';

  @override
  String get themeEffects => 'Efeitos';

  @override
  String get themeSidebarOpacity => 'Opacidade da barra lateral';

  @override
  String get themeWindowOpacity => 'Opacidade da janela';

  @override
  String get themeGlass => 'Estilo vidro para menus, diálogos e painéis';

  @override
  String themeBlurHint(String appId) {
    return 'Para desfocar a mesa atrás do Finder, instale a extensão do GNOME “Blur my Shell” e ative-a para $appId.';
  }
}
