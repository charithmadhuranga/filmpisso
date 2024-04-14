import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:filmpisso/main.dart';
import 'package:filmpisso/models/download.dart';
import 'package:filmpisso/modules/history/providers/isar_providers.dart';
import 'package:filmpisso/modules/library/providers/library_state_provider.dart';
import 'package:filmpisso/modules/manga/reader/providers/push_router.dart';
import 'package:filmpisso/models/manga.dart';
import 'package:filmpisso/modules/widgets/custom_extended_image_provider.dart';
import 'package:filmpisso/utils/extensions/build_context_extensions.dart';
import 'package:filmpisso/utils/constant.dart';
import 'package:filmpisso/utils/headers.dart';
import 'package:filmpisso/modules/more/providers/incognito_mode_state_provider.dart';
import 'package:filmpisso/modules/widgets/bottom_text_widget.dart';
import 'package:filmpisso/modules/widgets/cover_view_widget.dart';
import 'package:filmpisso/modules/widgets/error_text.dart';
import 'package:filmpisso/modules/widgets/gridview_widget.dart';
import 'package:filmpisso/modules/widgets/manga_image_card_widget.dart';
import 'package:filmpisso/modules/widgets/progress_center.dart';

class LibraryGridViewWidget extends StatefulWidget {
  final bool isCoverOnlyGrid;
  final bool isComfortableGrid;
  final List<int> mangaIdsList;
  final List<Manga> entriesManga;
  final bool language;
  final bool downloadedChapter;
  final bool continueReaderBtn;
  final bool localSource;
  final bool isManga;
  const LibraryGridViewWidget(
      {super.key,
      required this.entriesManga,
      required this.isCoverOnlyGrid,
      this.isComfortableGrid = false,
      required this.language,
      required this.downloadedChapter,
      required this.continueReaderBtn,
      required this.mangaIdsList,
      required this.localSource,
      required this.isManga});

  @override
  State<LibraryGridViewWidget> createState() => _LibraryGridViewWidgetState();
}

class _LibraryGridViewWidgetState extends State<LibraryGridViewWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final isLongPressed = ref.watch(isLongPressedMangaStateProvider);
      final isManga = widget.isManga;

      final gridSize =
          ref.watch(libraryGridSizeStateProvider(isManga: isManga));
      return GridViewWidget(
        gridSize: gridSize,
        childAspectRatio: widget.isComfortableGrid ? 0.642 : 0.69,
        itemCount: widget.entriesManga.length,
        itemBuilder: (context, index) {
          final entry = widget.entriesManga[index];

          return Builder(builder: (context) {
            bool isLocalArchive = entry.isLocalArchive ?? false;
            return Padding(
              padding: const EdgeInsets.all(2),
              child: CoverViewWidget(
                isLongPressed: widget.mangaIdsList.contains(entry.id),
                bottomTextWidget: BottomTextWidget(
                  maxLines: 1,
                  text: entry.name!,
                  isComfortableGrid: widget.isComfortableGrid,
                ),
                isComfortableGrid: widget.isComfortableGrid,
                image: entry.customCoverImage != null
                    ? MemoryImage(entry.customCoverImage as Uint8List)
                        as ImageProvider
                    : CustomExtendedNetworkImageProvider(
                        toImgUrl(
                            entry.customCoverFromTracker ?? entry.imageUrl!),
                        headers: entry.isLocalArchive!
                            ? null
                            : ref.watch(headersProvider(
                                source: entry.source!, lang: entry.lang!)),
                      ),
                onTap: () {
                  if (isLongPressed) {
                    ref.read(mangasListStateProvider.notifier).update(entry);
                  } else {
                    pushToMangaReaderDetail(
                        archiveId: isLocalArchive ? entry.id : null,
                        context: context,
                        lang: entry.lang!,
                        mangaM: entry,
                        source: entry.source!);
                  }
                },
                onLongPress: () {
                  if (!isLongPressed) {
                    ref.read(mangasListStateProvider.notifier).update(entry);

                    ref
                        .read(isLongPressedMangaStateProvider.notifier)
                        .update(!isLongPressed);
                  } else {
                    ref.read(mangasListStateProvider.notifier).update(entry);
                  }
                },
                children: [
                  Stack(
                    children: [
                      Positioned(
                          top: 0,
                          left: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: context.primaryColor,
                              ),
                              child: Row(
                                children: [
                                  if (widget.localSource && isLocalArchive)
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(3),
                                            bottomLeft: Radius.circular(3)),
                                        color: Theme.of(context).hintColor,
                                      ),
                                      child: const Padding(
                                        padding:
                                            EdgeInsets.only(left: 3, right: 3),
                                        child: Text(
                                          "Local",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  if (widget.downloadedChapter)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: Consumer(
                                        builder: (context, ref, child) {
                                          List nbrDown = [];
                                          isar.txnSync(() {
                                            for (var i = 0;
                                                i < entry.chapters.length;
                                                i++) {
                                              final entries = isar.downloads
                                                  .filter()
                                                  .idIsNotNull()
                                                  .chapterIdEqualTo(entry
                                                      .chapters
                                                      .toList()[i]
                                                      .id)
                                                  .findAllSync();

                                              if (entries.isNotEmpty &&
                                                  entries.first.isDownload!) {
                                                nbrDown.add(entries.first);
                                              }
                                            }
                                          });

                                          if (nbrDown.isNotEmpty) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(3),
                                                        bottomLeft:
                                                            Radius.circular(3)),
                                                color:
                                                    Theme.of(context).hintColor,
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 3, right: 3),
                                                child: Text(
                                                  nbrDown.length.toString(),
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            );
                                          } else {
                                            return Container();
                                          }
                                        },
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 3),
                                    child: Text(
                                      entry.chapters.length.toString(),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                      if (widget.language && entry.lang!.isNotEmpty)
                        Positioned(
                            top: 0,
                            right: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Container(
                                color: context.themeData.cardColor,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(3),
                                        bottomLeft: Radius.circular(3)),
                                    color: Theme.of(context).hintColor,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 3, right: 3),
                                    child: Text(
                                      entry.lang!.toUpperCase(),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            )),
                    ],
                  ),
                  if (!widget.isComfortableGrid && !widget.isCoverOnlyGrid)
                    BottomTextWidget(text: entry.name!),
                  if (widget.continueReaderBtn)
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: Padding(
                            padding: const EdgeInsets.all(9),
                            child: Consumer(
                              builder: (context, ref, child) {
                                final history = ref.watch(
                                    getAllHistoryStreamProvider(
                                        isManga: entry.isManga!));
                                return history.when(
                                  data: (data) {
                                    final incognitoMode =
                                        ref.watch(incognitoModeStateProvider);
                                    final entries = data
                                        .where((element) =>
                                            element.mangaId == entry.id)
                                        .toList();
                                    if (entries.isNotEmpty && !incognitoMode) {
                                      return GestureDetector(
                                        onTap: () {
                                          pushMangaReaderView(
                                            context: context,
                                            chapter:
                                                entries.first.chapter.value!,
                                          );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: context.primaryColor
                                                .withOpacity(0.9),
                                          ),
                                          child: const Padding(
                                              padding: EdgeInsets.all(7),
                                              child: Icon(
                                                Icons.play_arrow,
                                                size: 19,
                                                color: Colors.white,
                                              )),
                                        ),
                                      );
                                    }
                                    return GestureDetector(
                                      onTap: () {
                                        pushMangaReaderView(
                                            context: context,
                                            chapter: entry.chapters
                                                .toList()
                                                .reversed
                                                .toList()
                                                .last);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: context.primaryColor
                                              .withOpacity(0.9),
                                        ),
                                        child: const Padding(
                                            padding: EdgeInsets.all(7),
                                            child: Icon(
                                              Icons.play_arrow,
                                              size: 19,
                                              color: Colors.white,
                                            )),
                                      ),
                                    );
                                  },
                                  error: (Object error, StackTrace stackTrace) {
                                    return ErrorText(error);
                                  },
                                  loading: () {
                                    return const ProgressCenter();
                                  },
                                );
                              },
                            )))
                ],
              ),
            );
          });
        },
      );
    });
  }
}
