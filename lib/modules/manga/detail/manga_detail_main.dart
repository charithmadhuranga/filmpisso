import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:filmpisso/main.dart';
import 'package:filmpisso/models/source.dart';
import 'package:filmpisso/modules/manga/detail/manga_details_view.dart';
import 'package:filmpisso/modules/manga/detail/providers/update_manga_detail_providers.dart';
import 'package:filmpisso/modules/manga/detail/providers/isar_providers.dart';
import 'package:filmpisso/modules/widgets/error_text.dart';
import 'package:filmpisso/modules/widgets/progress_center.dart';
import 'package:filmpisso/sources/source_test.dart';

class MangaReaderDetail extends ConsumerStatefulWidget {
  final int mangaId;
  const MangaReaderDetail({super.key, required this.mangaId});

  @override
  ConsumerState<MangaReaderDetail> createState() => _MangaReaderDetailState();
}

class _MangaReaderDetailState extends ConsumerState<MangaReaderDetail> {
  @override
  void initState() {
    _init();
    super.initState();
  }

  _init() async {
    await Future.delayed(const Duration(milliseconds: 100));
    await ref.read(
        updateMangaDetailProvider(mangaId: widget.mangaId, isInit: true)
            .future);
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isLoading = true;
  @override
  Widget build(BuildContext context) {
    final manga =
        ref.watch(getMangaDetailStreamProvider(mangaId: widget.mangaId));
    return Scaffold(
        body: manga.when(
      data: (manga) {
        return StreamBuilder(
            stream: isar.sources
                .filter()
                .langContains(manga!.lang!, caseSensitive: false)
                .and()
                .nameContains(manga.source!, caseSensitive: false)
                .and()
                .idIsNotNull()
                .and()
                .isActiveEqualTo(true)
                .and()
                .isAddedEqualTo(true)
                .watch(fireImmediately: true),
            builder: (context, snapshot) {
              final sourceExist = useTestSourceCode
                  ? true
                  : snapshot.hasData && snapshot.data!.isNotEmpty;
              return RefreshIndicator(
                onRefresh: () async {
                  if (sourceExist) {
                    await ref.read(updateMangaDetailProvider(
                            mangaId: manga.id, isInit: false)
                        .future);
                  }
                },
                child: Stack(
                  children: [
                    MangaDetailsView(
                      manga: manga,
                      sourceExist: sourceExist,
                      checkForUpdate: (value) async {
                        if (!_isLoading) {
                          setState(() {
                            _isLoading = true;
                          });
                          if (sourceExist) {
                            await ref.read(updateMangaDetailProvider(
                                    mangaId: manga.id, isInit: false)
                                .future);
                          }
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }
                      },
                    ),
                    if (_isLoading)
                      const Positioned(
                          top: 0,
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: CircularProgressIndicator(),
                          )),
                  ],
                ),
              );
            });
      },
      error: (Object error, StackTrace stackTrace) {
        return ErrorText(error);
      },
      loading: () {
        return const ProgressCenter();
      },
    ));
  }
}
