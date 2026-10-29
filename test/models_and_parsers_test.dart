import 'package:finder_linux/models/file_entry.dart';
import 'package:finder_linux/models/place.dart';
import 'package:finder_linux/models/sort_spec.dart';
import 'package:finder_linux/services/places_service.dart';
import 'package:finder_linux/ui/dialogs/simple_dialogs.dart';
import 'package:finder_linux/ui/formatting.dart';
import 'package:flutter_test/flutter_test.dart';

FileEntry entry(String name, {bool dir = false, int size = 0, int day = 1}) =>
    FileEntry(
      path: '/x/$name',
      isDirectory: dir,
      size: size,
      modified: DateTime(2026, 1, day),
      mode: 0x1a4,
    );

void main() {
  group('naturalCompare', () {
    test('orders numbers numerically and ignores case', () {
      final names = ['file10', 'File2', 'file1', 'a'];
      names.sort(naturalCompare);
      expect(names, ['a', 'file1', 'File2', 'file10']);
    });
  });

  group('SortSpec', () {
    test('keeps folders on top in both directions', () {
      final items = [entry('b.txt'), entry('Zeta', dir: true), entry('a.txt')];
      items.sort(const SortSpec(ascending: false).compare);
      expect(items.map((e) => e.name), ['Zeta', 'b.txt', 'a.txt']);
    });

    test('sorts by size then name', () {
      final items = [
        entry('b', size: 5),
        entry('a', size: 5),
        entry('c', size: 1),
      ];
      items.sort(const SortSpec(field: SortField.size).compare);
      expect(items.map((e) => e.name), ['c', 'a', 'b']);
    });

    test('toggling flips direction; dates start newest first', () {
      const spec = SortSpec();
      expect(spec.toggled(SortField.name).ascending, isFalse);
      expect(
        spec.toggled(SortField.modified),
        const SortSpec(field: SortField.modified, ascending: false),
      );
    });
  });

  group('FileEntry', () {
    test('derives kind from extension', () {
      expect(entry('photo.JPG').kind, FileKind.image);
      expect(entry('main.dart').kind, FileKind.code);
      expect(entry('weird.xyz').kind, FileKind.other);
      expect(entry('src', dir: true).kind, FileKind.folder);
      expect(entry('.bashrc').isHidden, isTrue);
    });
  });

  group('parseUserDirs', () {
    test(r'expands $HOME and drops dirs equal to home', () {
      const content = '''
# comment
XDG_DESKTOP_DIR="\$HOME/Desktop"
XDG_DOWNLOAD_DIR="\$HOME/Tải về"
XDG_MUSIC_DIR="\$HOME/"
XDG_TEMPLATES_DIR="\$HOME/Templates"
''';
      final dirs = parseUserDirs(content, '/home/u');
      expect(dirs, {
        PlaceKind.desktop: '/home/u/Desktop',
        PlaceKind.downloads: '/home/u/Tải về',
      });
    });
  });

  group('parseBookmarks', () {
    test('reads local bookmarks with optional labels, skips remote', () {
      const content =
          'file:///home/u/Work%20Stuff\nfile:///srv/data Data Disk\nsftp://host/dir\n';
      expect(parseBookmarks(content), [
        ('/home/u/Work Stuff', 'Work Stuff'),
        ('/srv/data', 'Data Disk'),
      ]);
    });
  });

  group('parseMounts', () {
    test('keeps removable media and unescapes spaces', () {
      const content = '''
/dev/nvme0n1p2 / ext4 rw 0 0
/dev/sdb1 /media/u/My\\040USB vfat rw 0 0
/dev/sdc1 /run/media/u/DISK exfat rw 0 0
tmpfs /run/user/1000 tmpfs rw 0 0
''';
      expect(parseMounts(content), ['/media/u/My USB', '/run/media/u/DISK']);
    });
  });

  group('formatting', () {
    test('formatBytes uses decimal units like Finder', () {
      expect(formatBytes(999), '999 bytes');
      expect(formatBytes(1500), '2 KB');
      expect(formatBytes(2400000), '2.4 MB');
      expect(formatBytes(747000000000), '747 GB');
    });

    test('permissionString', () {
      expect(permissionString(0x1ed), 'rwxr-xr-x');
      expect(permissionString(0x1a4), 'rw-r--r--');
    });
  });
}
