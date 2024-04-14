import 'dart:async';
import 'dart:io';
import 'package:filmpisso/eval/dart/bridge/m_source.dart';
import 'package:filmpisso/eval/dart/model/m_provider.dart';
import 'package:filmpisso/eval/dart/compiler/compiler.dart';
import 'package:filmpisso/eval/javascript/service.dart';
import 'package:filmpisso/models/chapter.dart';
import 'package:filmpisso/models/source.dart';
import 'package:filmpisso/models/video.dart';
import 'package:filmpisso/eval/dart/runtime/runtime.dart';
import 'package:filmpisso/providers/storage_provider.dart';
import 'package:filmpisso/services/torrent_server.dart';
import 'package:filmpisso/sources/utils/utils.dart';
import 'package:filmpisso/sources/source_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'get_video_list.g.dart';

@riverpod
Future<(List<Video>, bool, String?)> getVideoList(
  GetVideoListRef ref, {
  required Chapter episode,
}) async {
  final storageProvider = StorageProvider();
  final mangaDirectory = await storageProvider.getMangaMainDirectory(episode);
  final isLocalArchive = episode.manga.value!.isLocalArchive!;
  final mp4animePath = "${mangaDirectory!.path}${episode.name}.mp4";

  if (await File(mp4animePath).exists() || isLocalArchive) {
    final path = isLocalArchive ? episode.archivePath : mp4animePath;
    return ([Video(path!, episode.name!, path, subtitles: [])], true, null);
  }

  final source =
      getSource(episode.manga.value!.lang!, episode.manga.value!.source!)!;

  if (source.isTorrent) {
    final (videos, infohash) =
        await MTorrentServer().getTorrentPlaylist(episode.url!);
    return (videos, false, infohash);
  }
  List<Video> list = [];
  if (source.sourceCodeLanguage == SourceCodeLanguage.dart) {
    final bytecode =
        compilerEval(useTestSourceCode ? testSourceCode : source.sourceCode!);

    final runtime = runtimeEval(bytecode);

    var res = runtime.executeLib('package:filmpisso/main.dart', 'main',
        [$MSource.wrap(source.toMSource())]);
    list = (await (res as MProvider).getVideoList(episode.url!));
  } else {
    list = await JsExtensionService(source).getVideoList(episode.url!);
  }
  return (list, false, null);
}
