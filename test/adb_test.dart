import 'dart:io';

import 'package:finder_linux/core/result.dart';
import 'package:finder_linux/services/adb_service.dart';
import 'package:finder_linux/models/file_entry.dart';
import 'package:finder_linux/services/file_system_service.dart';
import 'package:finder_linux/services/thumbnail_service.dart';
import 'package:finder_linux/services/transfer_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  test('device paths map to the device storage', () {
    expect(isDevicePath('/@adb/emulator-5554/DCIM'), isTrue);
    expect(isDevicePath('/@adb'), isFalse);
    expect(isDevicePath('/home/u'), isFalse);
    expect(isDeviceRoot(deviceRootPath('emulator-5554')), isTrue);
    expect(deviceLocation('/@adb/emulator-5554'), (
      serial: 'emulator-5554',
      remote: '/sdcard',
    ));
    expect(deviceLocation('/@adb/emulator-5554/DCIM/a b.jpg'), (
      serial: 'emulator-5554',
      remote: '/sdcard/DCIM/a b.jpg',
    ));
  });

  test('only online devices are listed', () {
    const out =
        'List of devices attached\n'
        'emulator-5554\tdevice\n'
        'emulator-5556\toffline\n'
        'R58M\tunauthorized\n'
        'R58N          device usb:1-1 model:Pixel_8\n\n';
    expect(parseAdbDevices(out), ['emulator-5554', 'R58N']);
  });

  test('stat listings become entries', () {
    const out =
        'directory|4096|1792467819|2770|DCIM\n'
        'regular file|12|1792467800|660|a|b.txt\n'
        'regular file|0|1792467800|660|.nomedia\n'
        'directory|4096|0|771|.\n'
        'directory|4096|0|771|..\n';
    final entries = parseStatListing(out, '/@adb/e');
    expect(entries.map((e) => e.name), ['DCIM', 'a|b.txt', '.nomedia']);
    expect(entries.first.isDirectory, isTrue);
    expect(entries[1].size, 12);
    expect(entries[1].mode, 0x1b0);
    expect(
      entries.first.modified,
      DateTime.fromMillisecondsSinceEpoch(1792467819000),
    );
  });

  test('device paths fail cleanly without adb', () async {
    const fs = FileSystemService();
    final r = await fs.list('/@adb/emulator-5554');
    expect((r as Err).failure.kind, FailureKind.notFound);
    expect(fs.exists('/@adb/emulator-5554'), isFalse);
  });

  group('with a fake adb', () {
    late Directory root;
    late Directory storage;
    late FileSystemService fs;
    const device = '/@adb/emulator-5554';

    setUp(() async {
      root = await Directory.systemTemp.createTemp('finder_adb');
      storage = await Directory(p.join(root.path, 'sdcard')).create();
      // Runs device commands locally, with /sdcard inside the temp folder.
      final adb = File(p.join(root.path, 'adb'));
      final map = 'sed "s#/sdcard#${storage.path}#g"';
      await adb.writeAsString('''
#!/bin/sh
if [ "\$1" = devices ]; then
  printf 'List of devices attached\\nemulator-5554\\tdevice\\n'; exit 0
fi
shift 2
case "\$1" in
  shell) exec sh -c "\$(printf '%s' "\$2" | $map)" ;;
  emu) printf 'Medium_Phone_API_37.0\\nOK\\n' ;;
  push) exec cp -r "\$2" "\$(printf '%s' "\$3" | $map)" ;;
  pull) shift; [ "\$1" = -a ] && shift
        exec cp -r "\$(printf '%s' "\$1" | $map)" "\$2" ;;
esac
''');
      await Process.run('chmod', ['+x', adb.path]);
      fs = FileSystemService(adb: AdbService(executable: adb.path));
    });

    tearDown(() => root.delete(recursive: true));

    test('lists devices by their AVD name', () async {
      final adb = fs.adb;
      expect(await adb?.devices(), [
        (serial: 'emulator-5554', name: 'Medium Phone API 37.0'),
      ]);
    });

    test('lists, creates, renames and deletes on the device', () async {
      await Directory(p.join(storage.path, 'DCIM')).create();
      await File(p.join(storage.path, 'it\'s.txt')).writeAsString('hello');

      final listed = (await fs.list(device) as Ok).value;
      expect(listed.map((e) => e.name).toSet(), {'DCIM', 'it\'s.txt'});
      expect(fs.isDirectory('$device/DCIM'), isTrue);
      expect((await fs.entry('$device/it\'s.txt'))?.size, 5);

      final missing = await fs.list('$device/Nope');
      expect((missing as Err).failure.kind, FailureKind.notFound);

      final folder = (await fs.createFolder(device, 'untitled') as Ok).value;
      expect(folder, '$device/untitled');
      expect(Directory(p.join(storage.path, 'untitled')).existsSync(), isTrue);

      final renamed = await fs.rename(folder, 'Photos');
      expect((renamed as Ok).value, '$device/Photos');
      final taken = await fs.rename('$device/Photos', 'DCIM');
      expect((taken as Err).failure.kind, FailureKind.nameTaken);

      expect(await fs.trash(['$device/Photos']), isA<Ok>());
      expect(fs.exists('$device/Photos'), isFalse);
    });

    test('device files are previewed from a pulled copy', () async {
      await File(p.join(storage.path, 'a.png')).writeAsString('png');
      final thumbs = ThumbnailService(
        environment: {'HOME': root.path, 'XDG_DATA_DIRS': '/nonexistent'},
        adb: fs.adb,
      );
      FileEntry onDevice(String name, int size) => FileEntry(
        path: '$device/$name',
        isDirectory: false,
        size: size,
        modified: DateTime(2026),
        mode: 0x1b0,
      );
      expect(thumbs.handles(onDevice('a.png', 3)), isTrue);
      expect(thumbs.handles(onDevice('a.txt', 3)), isFalse);
      expect(thumbs.handles(onDevice('big.mp4', 300 << 20)), isFalse);
      expect(
        ThumbnailService(environment: {}).handles(onDevice('a.png', 3)),
        isFalse,
      );

      final thumb = await thumbs.thumbnailFor(onDevice('a.png', 3));
      expect(thumb, isNotNull);
      expect(File(thumb ?? '').lengthSync(), greaterThan(0));
      expect(await fs.localCopy('$device/a.png'), isNotNull);
      expect(await fs.localCopy('$device/missing.png'), isNull);
    });

    test('copies to and from the device', () async {
      final local = await Directory(p.join(root.path, 'local')).create();
      final photo = File(p.join(local.path, 'a.jpg'))..writeAsStringSync('img');
      final transfers = TransferService(fs);

      Future<TransferOutcome> run(String src, String dest, bool move) async {
        final plan = await transfers.plan(
          sources: [src],
          destDir: dest,
          move: move,
          copySuffix: 'copy',
          resolve: (_, _, _) async =>
              (choice: ConflictChoice.cancel, applyToAll: false),
        );
        return transfers.execute(
          (plan as Ok<TransferPlan?>).value!,
          onProgress: (_) {},
          isCancelled: () => false,
        );
      }

      final up = await run(photo.path, device, false);
      expect(up.done, [(photo.path, '$device/a.jpg')]);
      expect(File(p.join(storage.path, 'a.jpg')).readAsStringSync(), 'img');

      await photo.delete();
      final down = await run('$device/a.jpg', local.path, true);
      expect(down.failure, isNull);
      expect(photo.readAsStringSync(), 'img');
      expect(File(p.join(storage.path, 'a.jpg')).existsSync(), isFalse);
    });
  });
}
