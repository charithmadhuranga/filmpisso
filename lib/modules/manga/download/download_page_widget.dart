import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:isar/isar.dart';
import 'package:filmpisso/main.dart';
import 'package:filmpisso/models/chapter.dart';
import 'package:filmpisso/models/download.dart';
import 'package:filmpisso/models/settings.dart';
import 'package:filmpisso/providers/l10n_providers.dart';
import 'package:filmpisso/providers/storage_provider.dart';
import 'package:filmpisso/modules/manga/download/providers/download_provider.dart';
import 'package:filmpisso/services/background_downloader/background_downloader.dart';
import 'package:filmpisso/utils/global_style.dart';
import 'package:share_plus/share_plus.dart';

class ChapterPageDownload extends ConsumerStatefulWidget {
  final Chapter chapter;

  const ChapterPageDownload({
    super.key,
    required this.chapter,
  });

  @override
  ConsumerState createState() => _ChapterPageDownloadState();
}

class _ChapterPageDownloadState extends ConsumerState<ChapterPageDownload>
    with AutomaticKeepAliveClientMixin<ChapterPageDownload> {
  List<String> _pageUrls = [];

  final StorageProvider _storageProvider = StorageProvider();

  void _startDownload(bool? useWifi) async {
    await ref.watch(
        downloadChapterProvider(chapter: widget.chapter, useWifi: useWifi)
            .future);
  }

  late final manga = widget.chapter.manga.value!;

  void _sendFile() async {
    final mangaDir =
        await _storageProvider.getMangaMainDirectory(widget.chapter);
    final path =
        await _storageProvider.getMangaChapterDirectory(widget.chapter);

    List<XFile> files = [];

    final cbzFileExist =
        File("${mangaDir!.path}${widget.chapter.name}.cbz").existsSync();
    final mp4FileExist =
        File("${mangaDir.path}${widget.chapter.name}.mp4").existsSync();
    if (cbzFileExist) {
      final cbzFile = File("${mangaDir.path}${widget.chapter.name}.cbz");
      files = [XFile(cbzFile.path)];
    } else if (mp4FileExist) {
      final mp4File = File("${mangaDir.path}${widget.chapter.name}.mp4");
      files = [XFile(mp4File.path)];
    } else {
      files = path!.listSync().map((e) => XFile(e.path)).toList();
    }
    if (files.isNotEmpty) {
      Share.shareXFiles(files, text: widget.chapter.name);
    }
  }

  void _deleteFile() async {
    final mangaDir =
        await _storageProvider.getMangaMainDirectory(widget.chapter);
    final path =
        await _storageProvider.getMangaChapterDirectory(widget.chapter);

    try {
      if (File("${mangaDir!.path}${widget.chapter.name}.cbz").existsSync()) {
        File("${mangaDir.path}${widget.chapter.name}.cbz").deleteSync();
      }
      if (File("${mangaDir.path}${widget.chapter.name}.mp4").existsSync()) {
        File("${mangaDir.path}${widget.chapter.name}.mp4").deleteSync();
      }
      path!.deleteSync(recursive: true);
    } catch (_) {}
    isar.writeTxnSync(() {
      int id = isar.downloads
          .filter()
          .chapterIdEqualTo(widget.chapter.id!)
          .findFirstSync()!
          .id!;
      isar.downloads.deleteSync(id);
    });
  }

  bool _isStarted = false;
  @override
  Widget build(BuildContext context) {
    final l10n = l10nLocalizations(context)!;
    super.build(context);
    return SizedBox(
      height: 41,
      width: 35,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: StreamBuilder(
          stream: isar.downloads
              .filter()
              .idIsNotNull()
              .and()
              .chapterIdEqualTo(widget.chapter.id)
              .watch(fireImmediately: true),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              final entries = snapshot.data!;
              return entries.first.isDownload!
                  ? PopupMenuButton(
                      popUpAnimationStyle: popupAnimationStyle,
                      child: Icon(
                        size: 25,
                        Icons.check_circle,
                        color:
                            Theme.of(context).iconTheme.color!.withOpacity(0.7),
                      ),
                      onSelected: (value) {
                        if (value == 0) {
                          _sendFile();
                        } else if (value == 1) {
                          _deleteFile();
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 0, child: Text(l10n.send)),
                        PopupMenuItem(value: 1, child: Text(l10n.delete)),
                      ],
                    )
                  : entries.first.isStartDownload! &&
                          entries.first.succeeded == 0
                      ? SizedBox(
                          height: 41,
                          width: 35,
                          child: PopupMenuButton(
                            popUpAnimationStyle: popupAnimationStyle,
                            child: _downloadWidget(context, true),
                            onSelected: (value) {
                              if (value == 0) {
                                _cancelTasks();
                              }
                              if (value == 0) {
                                _cancelTasks();
                              } else if (value == 1) {
                                _cancelTasks();
                                _startDownload(false);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                  value: 1,
                                  child: Text(l10n.start_downloading)),
                              PopupMenuItem(value: 0, child: Text(l10n.cancel)),
                            ],
                          ))
                      : entries.first.succeeded != 0
                          ? SizedBox(
                              height: 41,
                              width: 35,
                              child: PopupMenuButton(
                                popUpAnimationStyle: popupAnimationStyle,
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: TweenAnimationBuilder<double>(
                                        duration:
                                            const Duration(milliseconds: 250),
                                        curve: Curves.easeInOut,
                                        tween: Tween<double>(
                                          begin: 0,
                                          end: (entries.first.succeeded! /
                                              entries.first.total!),
                                        ),
                                        builder: (context, value, _) =>
                                            SizedBox(
                                          height: 2,
                                          width: 2,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 19,
                                            value: value,
                                            color: Theme.of(context)
                                                .iconTheme
                                                .color!
                                                .withOpacity(0.7),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.arrow_downward_sharp,
                                          color: (entries.first.succeeded! /
                                                      entries.first.total!) >
                                                  0.5
                                              ? Theme.of(context)
                                                  .scaffoldBackgroundColor
                                              : Theme.of(context)
                                                  .iconTheme
                                                  .color!
                                                  .withOpacity(0.7),
                                        )),
                                  ],
                                ),
                                onSelected: (value) {
                                  if (value == 0) {
                                    _cancelTasks();
                                  }
                                  if (value == 0) {
                                    _cancelTasks();
                                  } else if (value == 1) {
                                    _cancelTasks();
                                    _startDownload(false);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                      value: 1,
                                      child: Text(l10n.start_downloading)),
                                  PopupMenuItem(
                                      value: 0, child: Text(l10n.cancel)),
                                ],
                              ))
                          : entries.first.succeeded == 0
                              ? IconButton(
                                  onPressed: () {
                                    // _startDownload();
                                    setState(() {
                                      _isStarted = true;
                                    });
                                  },
                                  icon: Icon(
                                    FontAwesomeIcons.circleDown,
                                    color: Theme.of(context)
                                        .iconTheme
                                        .color!
                                        .withOpacity(0.7),
                                    size: 25,
                                  ))
                              : SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: PopupMenuButton(
                                    popUpAnimationStyle: popupAnimationStyle,
                                    child: const Icon(
                                      Icons.error_outline_outlined,
                                      color: Colors.red,
                                      size: 25,
                                    ),
                                    onSelected: (value) {
                                      if (value == 0) {
                                        _cancelTasks();
                                        _startDownload(null);
                                        setState(() {
                                          _isStarted = true;
                                        });
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                          value: 0, child: Text(l10n.retry)),
                                    ],
                                  ));
            }
            return _isStarted
                ? SizedBox(
                    height: 50,
                    width: 50,
                    child: PopupMenuButton(
                      popUpAnimationStyle: popupAnimationStyle,
                      child: _downloadWidget(context, true),
                      onSelected: (value) {
                        if (value == 0) {
                          _cancelTasks();
                        } else if (value == 1) {
                          _cancelTasks();
                          _startDownload(false);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                            value: 1, child: Text(l10n.start_downloading)),
                        PopupMenuItem(value: 0, child: Text(l10n.cancel)),
                      ],
                    ))
                : IconButton(
                    splashRadius: 5,
                    iconSize: 17,
                    onPressed: () {
                      _startDownload(null);
                      setState(() {
                        _isStarted = true;
                      });
                    },
                    icon: _downloadWidget(context, false),
                  );
          },
        ),
      ),
    );
  }

  void _cancelTasks() async {
    setState(() {
      _isStarted = false;
    });
    _pageUrls = (isar.settings.getSync(227)!.chapterPageUrlsList ?? [])
            .where((element) => element.chapterId == widget.chapter.id)
            .map((e) => e.urls)
            .firstOrNull ??
        [];
    await FileDownloader().cancelTasksWithIds(_pageUrls);
    await Future.delayed(const Duration(seconds: 2));
    final chapterD = isar.downloads
        .filter()
        .chapterIdEqualTo(widget.chapter.id!)
        .findFirstSync();
    if (chapterD != null) {
      final verifyId = isar.downloads.getSync(chapterD.id!);
      isar.writeTxnSync(() {
        if (verifyId != null) {
          isar.downloads.deleteSync(chapterD.id!);
        }
      });
    }
  }

  @override
  bool get wantKeepAlive => true;
}

Widget _downloadWidget(BuildContext context, bool isLoading) {
  return Stack(
    children: [
      Align(
          alignment: Alignment.center,
          child: Icon(
            size: 18,
            Icons.arrow_downward_sharp,
            color: Theme.of(context).iconTheme.color!.withOpacity(0.7),
          )),
      Align(
        alignment: Alignment.center,
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            value: isLoading ? null : 1,
            color: Theme.of(context).iconTheme.color!.withOpacity(0.7),
            strokeWidth: 2,
          ),
        ),
      ),
    ],
  );
}
