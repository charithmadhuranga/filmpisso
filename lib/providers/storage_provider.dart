// ignore_for_file: depend_on_referenced_packages
import 'dart:io';
import 'package:isar/isar.dart';
import 'package:filmpisso/eval/dart/model/source_preference.dart';
import 'package:filmpisso/main.dart';
import 'package:filmpisso/models/category.dart';
import 'package:filmpisso/models/chapter.dart';
import 'package:filmpisso/models/download.dart';
import 'package:filmpisso/models/history.dart';
import 'package:filmpisso/models/manga.dart';
import 'package:filmpisso/models/settings.dart';
import 'package:filmpisso/models/source.dart';
import 'package:filmpisso/models/track.dart';
import 'package:filmpisso/models/track_preference.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

class StorageProvider {
  final RegExp _regExpChar = RegExp(r'[^a-zA-Z0-9 .()\-\s]');
  Future<bool> requestPermission() async {
    Permission permission = Permission.manageExternalStorage;
    if (Platform.isAndroid) {
      if (await permission.isGranted) {
        return true;
      } else {
        final result = await permission.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
        return false;
      }
    }
    return true;
  }

  Future<Directory?> getDefaultDirectory() async {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = Directory("/storage/emulated/0/Filmpisso/");
    } else {
      final dir = await getApplicationDocumentsDirectory();
      directory = Directory("${dir.path}/Filmpisso/");
    }
    return directory;
  }

  Future<Directory?> getBtDirectory() async {
    final gefaultDirectory = await getDefaultDirectory();
    String dbDir = path.join(gefaultDirectory!.path, 'torrents');
    await Directory(dbDir).create(recursive: true);
    return Directory(dbDir);
  }

  Future<Directory?> getIosBackupDirectory() async {
    final gefaultDirectory = await getDefaultDirectory();
    String dbDir = path.join(gefaultDirectory!.path, 'backup');
    await Directory(dbDir).create(recursive: true);
    return Directory(dbDir);
  }

  Future<Directory?> getDirectory() async {
    Directory? directory;
    String path = isar.settings.getSync(227)!.downloadLocation ?? "";
    if (Platform.isAndroid) {
      directory =
          Directory(path.isEmpty ? "/storage/emulated/0/Filmpisso/" : "$path/");
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final p = path.isEmpty ? dir.path : path;
      directory = Directory("$p/Filmpisso/");
    }
    return directory;
  }

  Future<Directory?> getMangaChapterDirectory(
    Chapter chapter,
  ) async {
    final manga = chapter.manga.value!;
    String scanlator = chapter.scanlator!.isNotEmpty
        ? "${chapter.scanlator!.replaceAll(_regExpChar, '_')}_"
        : "";
    final isManga = chapter.manga.value!.isManga!;
    final dir = await getDirectory();
    return Directory(
        "${dir!.path}/downloads/${isManga ? "Manga" : "Anime"}/${manga.source} (${manga.lang!.toUpperCase()})/${manga.name!.replaceAll(_regExpChar, '_')}/$scanlator${chapter.name!.replaceAll(_regExpChar, '_')}/");
  }

  Future<Directory?> getMangaMainDirectory(Chapter chapter) async {
    final manga = chapter.manga.value!;
    final isManga = chapter.manga.value!.isManga!;
    final dir = await getDirectory();
    return Directory(
        "${dir!.path}/downloads/${isManga ? "Manga" : "Anime"}/${manga.source} (${manga.lang!.toUpperCase()})/${manga.name!.replaceAll(_regExpChar, '_')}/");
  }

  Future<Directory?> getDatabaseDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      return dir;
    } else {
      String dbDir = path.join(dir.path, 'Filmpisso', 'databases');
      await Directory(dbDir).create(recursive: true);
      return Directory(dbDir);
    }
  }

  Future<Directory?> getGalleryDirectory() async {
    String gPath = (await getDirectory())!.path;
    if (Platform.isAndroid) {
      gPath = "/storage/emulated/0/Pictures/Filmpisso/";
    } else {
      gPath = path.join(gPath, 'Pictures');
    }
    await Directory(gPath).create(recursive: true);
    return Directory(gPath);
  }

  Future<Isar> initDB(String? path, {bool? inspector = false}) async {
    Directory? dir;
    if (path == null) {
      dir = await getDatabaseDirectory();
    } else {
      dir = Directory(path);
    }

    final isar = Isar.openSync([
      MangaSchema,
      ChapterSchema,
      CategorySchema,
      HistorySchema,
      DownloadSchema,
      SourceSchema,
      SettingsSchema,
      TrackPreferenceSchema,
      TrackSchema,
      SourcePreferenceSchema,
      SourcePreferenceStringValueSchema
    ], directory: dir!.path, name: "filmpissoDb", inspector: inspector!);

    if (isar.settings.filter().idEqualTo(227).isEmptySync()) {
      isar.writeTxnSync(
        () {
          isar.settings.putSync(Settings());
        },
      );
    }

    return isar;
  }
}
