import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:mangayomi/eval/dart/bridge/m_source.dart';
import 'package:mangayomi/eval/dart/compiler/compiler.dart';
import 'package:mangayomi/eval/javascript/service.dart';
import 'package:mangayomi/eval/dart/model/m_provider.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/chapter.dart';
import 'package:mangayomi/models/settings.dart';
import 'package:mangayomi/models/source.dart';
import 'package:mangayomi/modules/manga/archive_reader/providers/archive_reader_providers.dart';
import 'package:mangayomi/modules/manga/reader/reader_view.dart';
import 'package:mangayomi/providers/storage_provider.dart';
import 'package:mangayomi/eval/dart/runtime/runtime.dart';
import 'package:mangayomi/sources/utils/utils.dart';
import 'package:mangayomi/utils/reg_exp_matcher.dart';
import 'package:mangayomi/modules/more/providers/incognito_mode_state_provider.dart';
import 'package:mangayomi/sources/source_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'get_chapter_pages.g.dart';

class GetChapterPagesModel {
  Directory? path;
  List<String> pageUrls = [];
  List<bool> isLocaleList = [];
  List<Uint8List?> archiveImages = [];
  List<UChapDataPreload> uChapDataPreload;
  GetChapterPagesModel(
      {required this.path,
      required this.pageUrls,
      required this.isLocaleList,
      required this.archiveImages,
      required this.uChapDataPreload});
}

@riverpod
Future<GetChapterPagesModel> getChapterPages(
  GetChapterPagesRef ref, {
  required Chapter chapter,
}) async {
  List<UChapDataPreload> uChapDataPreloadp = [];
  Directory? path;
  List<String> pageUrls = [];
  List<bool> isLocaleList = [];
  final settings = isar.settings.getSync(227);
  List<ChapterPageurls>? chapterPageUrlsList =
      settings!.chapterPageUrlsList ?? [];
  final isarPageUrls =
      chapterPageUrlsList.where((element) => element.chapterId == chapter.id);
  final incognitoMode = ref.watch(incognitoModeStateProvider);
  final storageProvider = StorageProvider();
  path = await storageProvider.getMangaChapterDirectory(chapter);
  final mangaDirectory = await storageProvider.getMangaMainDirectory(chapter);

  List<Uint8List?> archiveImages = [];
  final isLocalArchive = (chapter.archivePath ?? '').isNotEmpty;
  if (!chapter.manga.value!.isLocalArchive!) {
    final source =
        getSource(chapter.manga.value!.lang!, chapter.manga.value!.source!)!;
    if (isarPageUrls.isNotEmpty &&
        isarPageUrls.first.urls != null &&
        isarPageUrls.first.urls!.isNotEmpty) {
      pageUrls = isarPageUrls.first.urls!;
    } else {
      if (source.sourceCodeLanguage == SourceCodeLanguage.dart) {
        final bytecode = compilerEval(
            useTestSourceCode ? testSourceCode : source.sourceCode!);

        final runtime = runtimeEval(bytecode);

        var res = await runtime.executeLib('package:mangayomi/main.dart',
            'main', [$MSource.wrap(source.toMSource())]);
        pageUrls = (await (res as MProvider).getPageList(chapter.url!));
      } else {
        
        pageUrls = await JsExtensionService(source).getPageList(chapter.url!);
      }
    }
  }

  if (pageUrls.isNotEmpty || isLocalArchive) {
    if (await File("${mangaDirectory!.path}${chapter.name}.cbz").exists() ||
        isLocalArchive) {
      final path = isLocalArchive
          ? chapter.archivePath
          : "${mangaDirectory.path}${chapter.name}.cbz";
      final local =
          await ref.watch(getArchiveDataFromFileProvider(path!).future);
      for (var image in local.images!) {
        archiveImages.add(image.image!);
        isLocaleList.add(true);
      }
    } else {
      for (var i = 0; i < pageUrls.length; i++) {
        archiveImages.add(null);
        if (await File("${path!.path}" "${padIndex(i + 1)}.jpg").exists()) {
          isLocaleList.add(true);
        } else {
          isLocaleList.add(false);
        }
      }
    }
    if (isLocalArchive) {
      for (var i = 0; i < archiveImages.length; i++) {
        pageUrls.add("");
      }
    }
    if (!incognitoMode) {
      List<ChapterPageurls>? chapterPageUrls = [];
      for (var chapterPageUrl in settings.chapterPageUrlsList ?? []) {
        if (chapterPageUrl.chapterId != chapter.id) {
          chapterPageUrls.add(chapterPageUrl);
        }
      }
      chapterPageUrls.add(ChapterPageurls()
        ..chapterId = chapter.id
        ..urls = pageUrls);
      isar.writeTxnSync(() => isar.settings
          .putSync(settings..chapterPageUrlsList = chapterPageUrls));
    }
    for (var i = 0; i < pageUrls.length; i++) {
      uChapDataPreloadp.add(UChapDataPreload(
          chapter,
          path,
          pageUrls[i],
          isLocaleList[i],
          archiveImages[i],
          i,
          GetChapterPagesModel(
              path: path,
              pageUrls: pageUrls,
              isLocaleList: isLocaleList,
              archiveImages: archiveImages,
              uChapDataPreload: uChapDataPreloadp),
          i));
    }
  }

  return GetChapterPagesModel(
      path: path,
      pageUrls: pageUrls,
      isLocaleList: isLocaleList,
      archiveImages: archiveImages,
      uChapDataPreload: uChapDataPreloadp);
}
