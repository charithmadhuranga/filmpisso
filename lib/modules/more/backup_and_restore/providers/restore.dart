import 'dart:convert';
import 'package:archive/archive_io.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:filmpisso/eval/dart/model/m_bridge.dart';
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
import 'package:filmpisso/modules/more/settings/appearance/providers/blend_level_state_provider.dart';
import 'package:filmpisso/modules/more/settings/appearance/providers/flex_scheme_color_state_provider.dart';
import 'package:filmpisso/modules/more/settings/appearance/providers/pure_black_dark_mode_state_provider.dart';
import 'package:filmpisso/modules/more/settings/appearance/providers/theme_mode_state_provider.dart';
import 'package:filmpisso/providers/l10n_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'restore.g.dart';

@riverpod
void doRestore(DoRestoreRef ref,
    {required String path, required BuildContext context}) {
  final inputStream = InputFileStream(path);
  final archive = ZipDecoder().decodeBuffer(inputStream);
  final backup = jsonDecode(utf8.decode(archive.files.first.content))
      as Map<String, dynamic>;
  if (backup['version'] == "1") {
    try {
      final manga =
          (backup["manga"] as List?)?.map((e) => Manga.fromJson(e)).toList();
      final chapters = (backup["chapters"] as List?)
          ?.map((e) => Chapter.fromJson(e))
          .toList();
      final categories = (backup["categories"] as List?)
          ?.map((e) => Category.fromJson(e))
          .toList();
      final track =
          (backup["tracks"] as List?)?.map((e) => Track.fromJson(e)).toList();
      final trackPreferences = (backup["trackPreferences"] as List?)
          ?.map((e) => TrackPreference.fromJson(e))
          .toList();
      final history = (backup["history"] as List?)
          ?.map((e) => History.fromJson(e))
          .toList();
      final downloads = (backup["downloads"] as List?)
          ?.map((e) => Download.fromJson(e))
          .toList();
      final settings = (backup["settings"] as List?)
          ?.map((e) => Settings.fromJson(e))
          .toList();
      final extensions = (backup["extensions"] as List?)
          ?.map((e) => Source.fromJson(e))
          .toList();
      final extensionsPref = (backup["extensions_preferences"] as List?)
          ?.map((e) => SourcePreference.fromJson(e))
          .toList();

      isar.writeTxnSync(() {
        isar.mangas.clearSync();
        if (manga != null) {
          isar.mangas.putAllSync(manga);
          if (chapters != null) {
            isar.chapters.clearSync();
            for (var chapter in chapters) {
              final manga = isar.mangas.getSync(chapter.mangaId!);
              if (manga != null) {
                isar.chapters.putSync(chapter..manga.value = manga);
                chapter.manga.saveSync();
              }
            }

            isar.downloads.clearSync();
            if (downloads != null) {
              for (var download in downloads) {
                final chapter = isar.chapters.getSync(download.chapterId!);
                if (chapter != null) {
                  isar.downloads.putSync(download..chapter.value = chapter);
                  download.chapter.saveSync();
                }
              }
            }

            isar.historys.clearSync();
            if (history != null) {
              for (var element in history) {
                final chapter = isar.chapters.getSync(element.chapterId!);
                if (chapter != null) {
                  isar.historys.putSync(element..chapter.value = chapter);
                  element.chapter.saveSync();
                }
              }
            }
          }

          isar.categorys.clearSync();
          if (categories != null) {
            isar.categorys.putAllSync(categories);
          }
        }

        isar.tracks.clearSync();
        if (track != null) {
          isar.tracks.putAllSync(track);
        }

        isar.trackPreferences.clearSync();
        if (trackPreferences != null) {
          isar.trackPreferences.putAllSync(trackPreferences);
        }

        isar.sources.clearSync();
        if (extensions != null) {
          isar.sources.putAllSync(extensions);
        }

        isar.sourcePreferences.clearSync();
        if (extensionsPref != null) {
          isar.sourcePreferences.putAllSync(extensionsPref);
        }
        isar.settings.clearSync();
        if (settings != null) {
          isar.settings.putAllSync(settings);
        }
        ref.invalidate(themeModeStateProvider);
        ref.invalidate(blendLevelStateProvider);
        ref.invalidate(flexSchemeColorStateProvider);
        ref.invalidate(pureBlackDarkModeStateProvider);
        ref.invalidate(l10nLocaleStateProvider);
      });
    } catch (e) {
      botToast(e.toString());
    }
    BotToast.showNotification(
        animationDuration: const Duration(milliseconds: 200),
        animationReverseDuration: const Duration(milliseconds: 200),
        duration: const Duration(seconds: 5),
        backButtonBehavior: BackButtonBehavior.none,
        leading: (_) =>
            Image.asset('assets/app_icons/icon-red.png', height: 40),
        title: (_) => const Text(
              "Backup restored!",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
        enableSlideOff: true,
        onlyOne: true,
        crossPage: true);
  }
}
