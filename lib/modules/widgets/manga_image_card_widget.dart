import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isar/isar.dart';
import 'package:filmpisso/eval/dart/model/m_manga.dart';
import 'package:filmpisso/main.dart';
import 'package:filmpisso/models/manga.dart';
import 'package:filmpisso/models/settings.dart';
import 'package:filmpisso/models/source.dart';
import 'package:filmpisso/modules/manga/detail/manga_detail_main.dart';
import 'package:filmpisso/modules/widgets/custom_extended_image_provider.dart';
import 'package:filmpisso/router/router.dart';
import 'package:filmpisso/utils/extensions/build_context_extensions.dart';
import 'package:filmpisso/utils/constant.dart';
import 'package:filmpisso/utils/headers.dart';
import 'package:filmpisso/modules/widgets/bottom_text_widget.dart';
import 'package:filmpisso/modules/widgets/cover_view_widget.dart';

class MangaImageCardWidget extends ConsumerWidget {
  final Source source;
  final bool isManga;
  final bool isComfortableGrid;
  final MManga? getMangaDetail;

  const MangaImageCardWidget(
      {required this.source,
      super.key,
      required this.getMangaDetail,
      required this.isComfortableGrid,
      required this.isManga});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder(
        stream: isar.mangas
            .filter()
            .langEqualTo(source.lang)
            .nameEqualTo(getMangaDetail!.name)
            .sourceEqualTo(source.name)
            .watch(fireImmediately: true),
        builder: (context, snapshot) {
          final hasData = snapshot.hasData && snapshot.data!.isNotEmpty;
          return CoverViewWidget(
              bottomTextWidget: BottomTextWidget(
                maxLines: 1,
                text: getMangaDetail!.name!,
                isComfortableGrid: isComfortableGrid,
              ),
              isComfortableGrid: isComfortableGrid,
              image: hasData && snapshot.data!.first.customCoverImage != null
                  ? MemoryImage(
                          snapshot.data!.first.customCoverImage as Uint8List)
                      as ImageProvider
                  : CustomExtendedNetworkImageProvider(
                      toImgUrl(hasData
                          ? snapshot.data!.first.customCoverFromTracker ??
                              snapshot.data!.first.imageUrl ??
                              ""
                          : getMangaDetail!.imageUrl!),
                      headers: ref.watch(headersProvider(
                          source: source.name!, lang: source.lang!)),
                      cache: true,
                      cacheMaxAge: const Duration(days: 7)),
              onTap: () {
                pushToMangaReaderDetail(
                    context: context,
                    getManga: getMangaDetail!,
                    lang: source.lang!,
                    source: source.name!,
                    isManga: isManga);
              },
              children: [
                Container(
                    color: hasData && snapshot.data!.first.favorite!
                        ? Colors.black.withOpacity(0.5)
                        : null),
                if (hasData && snapshot.data!.first.favorite!)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        decoration: BoxDecoration(
                            color: context.primaryColor,
                            borderRadius: BorderRadius.circular(5)),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(Icons.collections_bookmark_outlined,
                              size: 16, color: context.dynamicWhiteBlackColor),
                        ),
                      ),
                    ),
                  ),
                if (!isComfortableGrid)
                  BottomTextWidget(
                      isTorrent: source.isTorrent, text: getMangaDetail!.name!)
              ]);
        });
  }
}

class MangaImageCardListTileWidget extends ConsumerWidget {
  final Source source;
  final bool isManga;
  final MManga? getMangaDetail;

  const MangaImageCardListTileWidget(
      {required this.source,
      super.key,
      required this.isManga,
      required this.getMangaDetail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder(
        stream: isar.mangas
            .filter()
            .langEqualTo(source.lang)
            .nameEqualTo(getMangaDetail!.name)
            .sourceEqualTo(source.name)
            .watch(fireImmediately: true),
        builder: (context, snapshot) {
          final hasData = snapshot.hasData && snapshot.data!.isNotEmpty;
          final image = hasData && snapshot.data!.first.customCoverImage != null
              ? MemoryImage(snapshot.data!.first.customCoverImage as Uint8List)
                  as ImageProvider
              : CustomExtendedNetworkImageProvider(
                  toImgUrl(hasData
                      ? snapshot.data!.first.customCoverFromTracker ??
                          snapshot.data!.first.imageUrl ??
                          ""
                      : getMangaDetail!.imageUrl!),
                  headers: ref.watch(headersProvider(
                      source: source.name!, lang: source.lang!)),
                );
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(0),
                  surfaceTintColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  elevation: 0,
                  shadowColor: Colors.transparent),
              onPressed: () {
                pushToMangaReaderDetail(
                    context: context,
                    getManga: getMangaDetail!,
                    lang: source.lang!,
                    source: source.name!,
                    isManga: isManga);
              },
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Stack(
                      children: [
                        Material(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.transparent,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Image(
                              height: 55,
                              width: 40,
                              fit: BoxFit.cover,
                              image: image),
                        ),
                        Container(
                          height: 55,
                          width: 40,
                          color: hasData && snapshot.data!.first.favorite!
                              ? Colors.black.withOpacity(0.5)
                              : null,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      getMangaDetail!.name!,
                      maxLines: 2,
                      style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          color: context.textColor),
                    ),
                  ),
                  if (hasData && snapshot.data!.first.favorite!)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: context.primaryColor,
                            borderRadius: BorderRadius.circular(5)),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(Icons.collections_bookmark_outlined,
                              size: 16, color: context.dynamicWhiteBlackColor),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        });
  }
}

void pushToMangaReaderDetail(
    {MManga? getManga,
    required String lang,
    required BuildContext context,
    required String source,
    int? archiveId,
    Manga? mangaM,
    bool? isManga,
    bool useMaterialRoute = false}) {
  int? mangaId;
  if (archiveId == null) {
    final manga = mangaM ??
        Manga(
            imageUrl: getManga!.imageUrl,
            name: getManga.name!.trim().trimLeft().trimRight(),
            genre: getManga.genre?.map((e) => e.toString()).toList() ?? [],
            author: getManga.author ?? "",
            status: getManga.status ?? Status.unknown,
            description: getManga.description ?? "",
            link: getManga.link,
            source: source,
            lang: lang,
            lastUpdate: 0,
            isManga: isManga ?? true,
            artist: getManga.artist ?? '');
    final empty = isar.mangas
        .filter()
        .langEqualTo(lang)
        .nameEqualTo(manga.name)
        .sourceEqualTo(manga.source)
        .isEmptySync();
    if (empty) {
      isar.writeTxnSync(() {
        isar.mangas.putSync(manga);
      });
    }

    mangaId = isar.mangas
        .filter()
        .langEqualTo(lang)
        .nameEqualTo(manga.name)
        .sourceEqualTo(manga.source)
        .findFirstSync()!
        .id!;
  } else {
    mangaId = archiveId;
  }

  final settings = isar.settings.getSync(227)!;
  final sortList = settings.sortChapterList ?? [];
  final checkIfExist =
      sortList.where((element) => element.mangaId == mangaId).toList();
  if (checkIfExist.isEmpty) {
    isar.writeTxnSync(
      () {
        List<SortChapter>? sortChapterList = [];
        for (var sortChapter in settings.sortChapterList ?? []) {
          sortChapterList.add(sortChapter);
        }
        List<ChapterFilterBookmarked>? chapterFilterBookmarkedList = [];
        for (var sortChapter in settings.chapterFilterBookmarkedList ?? []) {
          chapterFilterBookmarkedList.add(sortChapter);
        }
        List<ChapterFilterDownloaded>? chapterFilterDownloadedList = [];
        for (var sortChapter in settings.chapterFilterDownloadedList ?? []) {
          chapterFilterDownloadedList.add(sortChapter);
        }
        List<ChapterFilterUnread>? chapterFilterUnreadList = [];
        for (var sortChapter in settings.chapterFilterUnreadList ?? []) {
          chapterFilterUnreadList.add(sortChapter);
        }
        sortChapterList.add(SortChapter()..mangaId = mangaId);
        chapterFilterBookmarkedList
            .add(ChapterFilterBookmarked()..mangaId = mangaId);
        chapterFilterDownloadedList
            .add(ChapterFilterDownloaded()..mangaId = mangaId);
        chapterFilterUnreadList.add(ChapterFilterUnread()..mangaId = mangaId);
        isar.settings.putSync(settings
          ..sortChapterList = sortChapterList
          ..chapterFilterBookmarkedList = chapterFilterBookmarkedList
          ..chapterFilterDownloadedList = chapterFilterDownloadedList
          ..chapterFilterUnreadList = chapterFilterUnreadList);
      },
    );
  }

  if (useMaterialRoute) {
    Navigator.push(
        context,
        createRoute(
            page: MangaReaderDetail(
          mangaId: mangaId,
        )));
  } else {
    context.push('/manga-reader/detail', extra: mangaId);
  }
}
