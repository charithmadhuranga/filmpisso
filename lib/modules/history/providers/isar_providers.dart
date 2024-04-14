import 'package:isar/isar.dart';
import 'package:filmpisso/main.dart';
import 'package:filmpisso/models/chapter.dart';
import 'package:filmpisso/models/history.dart';
import 'package:filmpisso/models/manga.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'isar_providers.g.dart';

@riverpod
Stream<List<History>> getAllHistoryStream(GetAllHistoryStreamRef ref,
    {required bool isManga}) async* {
  yield* isar.historys
      .filter()
      .idIsNotNull()
      .and()
      .chapter((q) => q.manga((q) => q.isMangaEqualTo(isManga)))
      .watch(fireImmediately: true);
}
