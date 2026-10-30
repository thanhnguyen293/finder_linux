import 'dart:convert';
import 'dart:ffi';

import 'package:ffi/ffi.dart';

import '../core/result.dart';
import '../models/tag_color.dart';

/// Extended attribute holding a file's tags (freedesktop proposal, used by
/// KDE). Read via libc directly: listing a folder reads every file's tags,
/// and spawning a process per file would be far too slow.
const tagsAttribute = 'user.xdg.tags';

typedef _GetC =
    IntPtr Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Uint8>, Size);
typedef _Get = int Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Uint8>, int);
typedef _SetC =
    Int32 Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Uint8>, Size, Int32);
typedef _Set =
    int Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Uint8>, int, int);
typedef _RemoveC = Int32 Function(Pointer<Utf8>, Pointer<Utf8>);
typedef _Remove = int Function(Pointer<Utf8>, Pointer<Utf8>);

final _libc = DynamicLibrary.process();
final _getxattr = _libc.lookupFunction<_GetC, _Get>('getxattr');
final _setxattr = _libc.lookupFunction<_SetC, _Set>('setxattr');
final _removexattr = _libc.lookupFunction<_RemoveC, _Remove>('removexattr');
final _errno = _libc
    .lookupFunction<Pointer<Int32> Function(), Pointer<Int32> Function()>(
      '__errno_location',
    );

const _enodata = 61;
const _eperm = 1;
const _eacces = 13;
const _enotsup = 95;

/// Tags of [path]; empty when it has none or the filesystem can't store
/// them.
List<String> readTags(String path) {
  final cPath = path.toNativeUtf8();
  final cName = tagsAttribute.toNativeUtf8();
  try {
    final size = _getxattr(cPath, cName, nullptr, 0);
    if (size <= 0) return const [];
    final buf = calloc<Uint8>(size);
    try {
      final read = _getxattr(cPath, cName, buf, size);
      if (read <= 0) return const [];
      return decodeTags(
        utf8.decode(buf.asTypedList(read), allowMalformed: true),
      );
    } finally {
      calloc.free(buf);
    }
  } finally {
    calloc
      ..free(cPath)
      ..free(cName);
  }
}

/// Replaces [path]'s tags; an empty list removes the attribute.
Result<void> writeTags(String path, List<String> tags) {
  final cPath = path.toNativeUtf8();
  final cName = tagsAttribute.toNativeUtf8();
  try {
    final int rc;
    if (tags.isEmpty) {
      rc = _removexattr(cPath, cName);
      if (rc != 0 && _errno().value == _enodata) return const Ok(null);
    } else {
      final bytes = utf8.encode(encodeTags(tags));
      final buf = calloc<Uint8>(bytes.length);
      try {
        buf.asTypedList(bytes.length).setAll(0, bytes);
        rc = _setxattr(cPath, cName, buf, bytes.length, 0);
      } finally {
        calloc.free(buf);
      }
    }
    if (rc == 0) return const Ok(null);
    return Err(switch (_errno().value) {
      _eperm || _eacces => Failure(FailureKind.permissionDenied, path),
      _enotsup => Failure(FailureKind.other, 'Tags unsupported here: $path'),
      final code => Failure(FailureKind.other, 'errno $code: $path'),
    });
  } finally {
    calloc
      ..free(cPath)
      ..free(cName);
  }
}
