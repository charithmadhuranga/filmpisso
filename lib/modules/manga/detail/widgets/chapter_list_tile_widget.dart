import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:filmpisso/models/chapter.dart';
import 'package:filmpisso/providers/l10n_providers.dart';
import 'package:filmpisso/utils/date.dart';
import 'package:filmpisso/modules/manga/reader/providers/push_router.dart';
import 'package:filmpisso/utils/extensions/build_context_extensions.dart';
import 'package:filmpisso/utils/extensions/string_extensions.dart';
import 'package:filmpisso/modules/manga/detail/providers/state_providers.dart';
import 'package:filmpisso/modules/manga/download/download_page_widget.dart';

class ChapterListTileWidget extends ConsumerWidget {
  final Chapter chapter;
  final List<Chapter> chapterList;
  final bool sourceExist;
  const ChapterListTileWidget({
    required this.chapterList,
    required this.chapter,
    required this.sourceExist,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLongPressed = ref.watch(isLongPressedStateProvider);
    final l10n = l10nLocalizations(context)!;
    return Container(
      color: chapterList.contains(chapter)
          ? context.primaryColor.withOpacity(0.4)
          : null,
      child: ListTile(
        textColor: chapter.isRead!
            ? context.isLight
                ? Colors.black.withOpacity(0.4)
                : Colors.white.withOpacity(0.3)
            : null,
        selectedColor:
            chapter.isRead! ? Colors.white.withOpacity(0.3) : Colors.white,
        onLongPress: () {
          if (!isLongPressed) {
            ref.read(chaptersListStateProvider.notifier).update(chapter);

            ref
                .read(isLongPressedStateProvider.notifier)
                .update(!isLongPressed);
          } else {
            ref.read(chaptersListStateProvider.notifier).update(chapter);
          }
        },
        onTap: () async {
          if (isLongPressed) {
            ref.read(chaptersListStateProvider.notifier).update(chapter);
          } else {
            pushMangaReaderView(context: context, chapter: chapter);
          }
        },
        title: Row(
          children: [
            chapter.isBookmarked!
                ? Icon(
                    Icons.bookmark,
                    size: 16,
                    color: context.primaryColor,
                  )
                : Container(),
            Flexible(
              child: Text(
                chapter.name!,
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            if ((chapter.manga.value!.isLocalArchive ?? false) == false)
              Text(
                chapter.dateUpload == null || chapter.dateUpload!.isEmpty
                    ? ""
                    : dateFormat(chapter.dateUpload!,
                        ref: ref, context: context),
                style: const TextStyle(fontSize: 11),
              ),
            if (!chapter.isRead!)
              if (chapter.lastPageRead!.isNotEmpty &&
                  chapter.lastPageRead != "1")
                Row(
                  children: [
                    const Text(' • '),
                    Text(
                      !chapter.manga.value!.isManga!
                          ? l10n.episode_progress(Duration(
                                  milliseconds:
                                      int.parse(chapter.lastPageRead!))
                              .toString()
                              .substringBefore("."))
                          : l10n.page(chapter.lastPageRead!),
                      style: TextStyle(
                          fontSize: 11,
                          color: context.isLight
                              ? Colors.black.withOpacity(0.4)
                              : Colors.white.withOpacity(0.3)),
                    ),
                  ],
                ),
            if (chapter.scanlator!.isNotEmpty)
              Row(
                children: [
                  const Text(' • '),
                  Text(
                    chapter.scanlator!,
                    style: TextStyle(
                        fontSize: 11,
                        color: chapter.isRead!
                            ? context.isLight
                                ? Colors.black.withOpacity(0.4)
                                : Colors.white.withOpacity(0.3)
                            : null),
                  ),
                ],
              )
          ],
        ),
        trailing: !sourceExist || (chapter.manga.value!.isLocalArchive ?? false)
            ? null
            : ChapterPageDownload(chapter: chapter),
      ),
    );
  }
}
