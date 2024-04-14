import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
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
import 'package:filmpisso/providers/l10n_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';
part 'backup.g.dart';

@riverpod
void doBackUp(DoBackUpRef ref,
    {required List<int> list,
    required String path,
    required BuildContext? context}) {
  Map<String, dynamic> datas = {};
  datas.addAll({"version": "1"});
  if (list.contains(0)) {
    final res = isar.mangas
        .filter()
        .idIsNotNull()
        .favoriteEqualTo(true)
        .isLocalArchiveEqualTo(false)
        .findAllSync()
        .map((e) => e.toJson())
        .toList();
    datas.addAll({"manga": res});
  }
  if (list.contains(1)) {
    final res = isar.categorys
        .filter()
        .idIsNotNull()
        .findAllSync()
        .map((e) => e.toJson())
        .toList();
    datas.addAll({"categories": res});
  }
  if (list.contains(2)) {
    final res = isar.chapters
        .filter()
        .idIsNotNull()
        .findAllSync()
        .map((e) => e.toJson())
        .toList();
    datas.addAll({"chapters": res});
    final res_ = isar.downloads
        .filter()
        .idIsNotNull()
        .findAllSync()
        .map((e) => e.toJson())
        .toList();
    datas.addAll({"downloads": res_});
  }
  if (list.contains(3)) {
    final res = isar.tracks
        .filter()
        .idIsNotNull()
        .findAllSync()
        .map((e) => e.toJson())
        .toList();
    datas.addAll({"tracks": res});
    final res_ = isar.trackPreferences
        .filter()
        .syncIdIsNotNull()
        .findAllSync()
        .map((e) => e.toJson())
        .toList();
    datas.addAll({"trackPreferences": res_});
  }
  if (list.contains(4)) {
    final res = isar.historys
        .filter()
        .idIsNotNull()
        .findAllSync()
        .map((e) => e.toJson())
        .toList();
    datas.addAll({"history": res});
  }
  if (list.contains(5)) {
    final res = isar.settings
        .filter()
        .idIsNotNull()
        .findAllSync()
        .map((e) => e.toJson())
        .toList();
    datas.addAll({"settings": res});
  }
  if (list.contains(6)) {
    final res = isar.sources
        .filter()
        .idIsNotNull()
        .findAllSync()
        .map((e) => e.toJson())
        .toList();
    datas.addAll({"extensions": res});
    final resSourePref = isar.sourcePreferences
        .filter()
        .idIsNotNull()
        .keyIsNotNull()
        .findAllSync()
        .map((e) => e.toJson())
        .toList();
    datas.addAll({"extensions_preferences": resSourePref});
  }
  final regExp = RegExp(r'[^a-zA-Z0-9 .()\-\s]');
  final name =
      'filmpisso_${DateTime.now().toString().replaceAll(regExp, '_').replaceAll(' ', '_')}';
  final backupFilePath = '$path/$name.backup.db';
  final file = File(backupFilePath);

  file.writeAsStringSync(jsonEncode(datas));
  var encoder = ZipFileEncoder();
  encoder.create('$path/$name.backup');
  encoder.addFile(File(backupFilePath));
  encoder.close();
  Directory(backupFilePath).deleteSync(recursive: true);
  final assets = [
    'assets/app_icons/icon-black.png',
    'assets/app_icons/icon-red.png'
  ];
  if (context != null) {
    Navigator.pop(context);
    BotToast.showNotification(
        animationDuration: const Duration(milliseconds: 200),
        animationReverseDuration: const Duration(milliseconds: 200),
        duration: const Duration(seconds: 5),
        backButtonBehavior: BackButtonBehavior.none,
        leading: (_) => Image.asset((assets..shuffle()).first, height: 25),
        title: (_) => const Text(
              "Backup created!",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
        trailing: (_) => UnconstrainedBox(
              alignment: Alignment.topLeft,
              child: ElevatedButton(
                  onPressed: () {
                    Share.shareXFiles([XFile('$path/$name.backup')],
                        text: '$name.backup');
                  },
                  child: Text(context.l10n.share)),
            ),
        enableSlideOff: true,
        onlyOne: true,
        crossPage: true);
  }
}
