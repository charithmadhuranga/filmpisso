import 'package:filmpisso/services/background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:isar/isar.dart';
import 'package:filmpisso/main.dart';
import 'package:filmpisso/models/download.dart';
import 'package:filmpisso/models/settings.dart';
import 'package:filmpisso/providers/l10n_providers.dart';
import 'package:filmpisso/utils/global_style.dart';

class DownloadQueueScreen extends ConsumerWidget {
  const DownloadQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = l10nLocalizations(context);
    return StreamBuilder(
      stream:
          isar.downloads.filter().idIsNotNull().watch(fireImmediately: true),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final entries = snapshot.data!
              .where(
                (element) => element.isDownload == false,
              )
              .where((element) => element.isStartDownload == true)
              .toList();
          final allQueueLength = entries.toList().length;
          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  Text(l10n!.download_queue),
                  const SizedBox(
                    width: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Theme.of(context).focusColor),
                      child: Text(
                        allQueueLength.toString(),
                        style: TextStyle(
                            fontSize: 12,
                            color:
                                Theme.of(context).textTheme.bodySmall!.color),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            body: GroupedListView<Download, String>(
              elements: entries,
              groupBy: (element) => element.chapter.value!.manga.value!.source!,
              groupSeparatorBuilder: (String groupByValue) {
                final sourceQueueLength = entries
                    .where((element) =>
                        element.chapter.value!.manga.value!.source! ==
                        groupByValue)
                    .toList()
                    .length;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6, left: 12),
                  child: Text('$groupByValue ($sourceQueueLength)'),
                );
              },
              itemBuilder: (context, Download element) {
                return SizedBox(
                  height: 60,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.drag_handle),
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  element.chapter.value!.manga.value!.name!,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  "${element.succeeded}/${element.total}",
                                  style: const TextStyle(fontSize: 10),
                                )
                              ],
                            ),
                            Text(
                              element.chapter.value!.name!,
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                tween: Tween<double>(
                                  begin: 0,
                                  end: element.succeeded! / element.total!,
                                ),
                                builder: (context, value, _) =>
                                    LinearProgressIndicator(
                                      value: value,
                                    )),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: PopupMenuButton(
                          popUpAnimationStyle: popupAnimationStyle,
                          child: const Icon(Icons.more_vert),
                          onSelected: (value) async {
                            if (value.toString() == 'Cancel') {
                              final taskIds = (isar.settings
                                              .getSync(227)!
                                              .chapterPageUrlsList ??
                                          [])
                                      .where((e) =>
                                          e.chapterId == element.chapterId!)
                                      .map((e) => e.urls)
                                      .firstOrNull ??
                                  [];
                              FileDownloader()
                                  .cancelTasksWithIds(taskIds)
                                  .then((value) async {
                                await Future.delayed(
                                    const Duration(seconds: 1));
                                isar.writeTxnSync(() {
                                  int id = isar.downloads
                                      .filter()
                                      .chapterIdEqualTo(
                                          element.chapter.value!.id)
                                      .findFirstSync()!
                                      .id!;
                                  isar.downloads.deleteSync(id);
                                });
                              });
                            } else if (value.toString() == 'CancelAll') {
                              final chapterIds = entries
                                  .where((element) =>
                                      element.chapter.value!.name ==
                                      element.chapter.value!.name)
                                  .map((e) => e.chapterId)
                                  .toList();
                              for (var chapterId in chapterIds) {
                                final taskIds = (isar.settings
                                                .getSync(227)!
                                                .chapterPageUrlsList ??
                                            [])
                                        .where((e) => e.chapterId == chapterId!)
                                        .map((e) => e.urls)
                                        .firstOrNull ??
                                    [];
                                await FileDownloader()
                                    .cancelTasksWithIds(taskIds);
                                await Future.delayed(
                                    const Duration(milliseconds: 300));
                                final chapterD = isar.downloads
                                    .filter()
                                    .chapterIdEqualTo(chapterId)
                                    .findFirstSync();
                                if (chapterD != null) {
                                  final verifyId =
                                      isar.downloads.getSync(chapterD.id!);
                                  isar.writeTxnSync(() {
                                    if (verifyId != null) {
                                      isar.downloads.deleteSync(chapterD.id!);
                                    }
                                  });
                                }
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                                value: 'Cancel', child: Text(l10n.cancel)),
                            PopupMenuItem(
                                value: 'CancelAll',
                                child: Text(l10n.cancel_all_for_this_series)),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
              itemComparator: (item1, item2) => item1
                  .chapter.value!.manga.value!.source!
                  .compareTo(item2.chapter.value!.manga.value!.source!),
              order: GroupedListOrder.DESC,
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n!.download_queue),
          ),
          body: Center(child: Text(l10n.no_downloads)),
        );
      },
    );
  }
}
