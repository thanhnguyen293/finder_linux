import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/result.dart';
import '../l10n/app_localizations.dart';
import '../models/file_entry.dart';
import '../models/grouping.dart';
import '../models/place.dart';

/// Decimal units, as Finder uses (1 KB = 1000 bytes).
String formatBytes(int bytes) {
  if (bytes < 1000) return '$bytes bytes';
  const units = ['KB', 'MB', 'GB', 'TB', 'PB'];
  var value = bytes / 1000;
  var unit = 0;
  while (value >= 1000 && unit < units.length - 1) {
    value /= 1000;
    unit++;
  }
  final digits = value >= 100 || unit == 0 ? 0 : 1;
  return '${value.toStringAsFixed(digits)} ${units[unit]}';
}

String formatModified(BuildContext context, DateTime date, {DateTime? now}) {
  final l10n = AppLocalizations.of(context);
  final locale = Localizations.localeOf(context).toLanguageTag();
  final time = DateFormat.Hm(locale).format(date);
  final today = DateUtils.dateOnly(now ?? DateTime.now());
  final day = DateUtils.dateOnly(date);
  if (day == today) return l10n.todayAt(time);
  if (day == today.subtract(const Duration(days: 1))) {
    return l10n.yesterdayAt(time);
  }
  return '${DateFormat.yMMMd(locale).format(date)}, $time';
}

String kindLabel(AppLocalizations l10n, FileEntry e) =>
    e.kind == FileKind.other && e.extension.isNotEmpty
    ? l10n.kindOtherExt(e.extension.toUpperCase())
    : kindName(l10n, e.kind);

String kindName(AppLocalizations l10n, FileKind kind) => switch (kind) {
  FileKind.folder => l10n.kindFolder,
  FileKind.image => l10n.kindImage,
  FileKind.video => l10n.kindVideo,
  FileKind.audio => l10n.kindAudio,
  FileKind.text => l10n.kindText,
  FileKind.code => l10n.kindCode,
  FileKind.pdf => l10n.kindPdf,
  FileKind.archive => l10n.kindArchive,
  FileKind.document => l10n.kindDocument,
  FileKind.spreadsheet => l10n.kindSpreadsheet,
  FileKind.presentation => l10n.kindPresentation,
  FileKind.application => l10n.kindApplication,
  FileKind.other => l10n.kindOther,
};

String groupLabel(BuildContext context, GroupKey key) {
  final l10n = AppLocalizations.of(context);
  final locale = Localizations.localeOf(context).toLanguageTag();
  return switch (key) {
    KindGroup(kind: FileKind.folder) => l10n.groupFolders,
    KindGroup(kind: FileKind.other) => l10n.groupOther,
    KindGroup(:final kind) => kindName(l10n, kind),
    DateGroup(bucket: DateBucket.today) => l10n.groupToday,
    DateGroup(bucket: DateBucket.yesterday) => l10n.groupYesterday,
    DateGroup(bucket: DateBucket.previous7Days) => l10n.groupPrevious7Days,
    DateGroup(bucket: DateBucket.previous30Days) => l10n.groupPrevious30Days,
    DateGroup(bucket: DateBucket.month, :final period?) => DateFormat.MMMM(
      locale,
    ).format(period),
    DateGroup(:final period) => '${period?.year ?? ''}',
    SizeGroup(:final bucket) => switch (bucket) {
      SizeBucket.folders => l10n.groupFolders,
      SizeBucket.zero => l10n.sizeZero,
      SizeBucket.under100KB => l10n.sizeLessThan('100 KB'),
      SizeBucket.from100KB => l10n.sizeBetween('100 KB', '1 MB'),
      SizeBucket.from1MB => l10n.sizeBetween('1 MB', '100 MB'),
      SizeBucket.from100MB => l10n.sizeBetween('100 MB', '1 GB'),
      SizeBucket.atLeast1GB => l10n.sizeAtLeast('1 GB'),
    },
  };
}

String failureMessage(AppLocalizations l10n, Failure f) => switch (f.kind) {
  FailureKind.notFound => l10n.errorFolderNotFound(f.detail),
  FailureKind.nameTaken => l10n.errorNameTaken(f.detail),
  FailureKind.invalidName => l10n.errorInvalidName,
  FailureKind.permissionDenied ||
  FailureKind.other => l10n.errorOperation(f.detail),
};

/// Generic name of a sidebar place kind (Settings lists kinds, not folders).
String placeName(AppLocalizations l10n, PlaceKind kind) => switch (kind) {
  PlaceKind.home => l10n.placeHome,
  PlaceKind.desktop => l10n.placeDesktop,
  PlaceKind.documents => l10n.placeDocuments,
  PlaceKind.downloads => l10n.placeDownloads,
  PlaceKind.pictures => l10n.placePictures,
  PlaceKind.music => l10n.placeMusic,
  PlaceKind.videos => l10n.placeVideos,
  PlaceKind.bookmark => l10n.settingsBookmarks,
  PlaceKind.computer => l10n.placeComputer,
  PlaceKind.volume => l10n.settingsExternalDrives,
  PlaceKind.trash => l10n.placeTrash,
};
