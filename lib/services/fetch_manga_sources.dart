import 'dart:convert';
import 'package:dart_eval/stdlib/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:filmpisso/eval/dart/compiler/compiler.dart';
import 'package:filmpisso/eval/dart/runtime/runtime.dart';
import 'package:filmpisso/main.dart';
import 'package:filmpisso/models/source.dart';
import 'package:filmpisso/modules/more/settings/browse/providers/browse_state_provider.dart';
import 'package:filmpisso/services/http/m_client.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'fetch_manga_sources.g.dart';

@riverpod
Future fetchMangaSourcesList(FetchMangaSourcesListRef ref,
    {int? id, required reFresh}) async {
  if (ref.watch(checkForExtensionsUpdateStateProvider) || reFresh) {
    await fetchSourcesList(
        sourcesIndexUrl:
            "https://charithmadhuranga.github.io/filmpisso-extensions/index.json",
        refresh: reFresh,
        id: id,
        ref: ref,
        isManga: true);
  }
}

Future<void> fetchSourcesList(
    {int? id,
    required bool refresh,
    required String sourcesIndexUrl,
    required AutoDisposeRef ref,
    required bool isManga}) async {
  final http = MClient.init();
  final req = await http.get(Uri.parse(sourcesIndexUrl));

  final sourceList =
      (jsonDecode(req.body) as List).map((e) => Source.fromJson(e)).toList();

  final info = await PackageInfo.fromPlatform();
  isar.writeTxnSync(() async {
    for (var source in sourceList) {
      if (source.appMinVerReq != null) {
        if (compareVersions(info.version, source.appMinVerReq!) > -1) {
          if ((source.isManga ?? true) == isManga) {
            if (id != null) {
              if (id == source.id) {
                final sourc = isar.sources.getSync(id)!;
                final req = await http.get(Uri.parse(source.sourceCodeUrl!));
                final headers = await getHeaders(req.body, source.baseUrl!);
                isar.writeTxnSync(() {
                  isar.sources.putSync(sourc
                    ..headers = headers ?? ""
                    ..isAdded = true
                    ..sourceCode = req.body
                    ..sourceCodeUrl = source.sourceCodeUrl
                    ..id = id
                    ..apiUrl = source.apiUrl
                    ..baseUrl = source.baseUrl
                    ..dateFormat = source.dateFormat
                    ..dateFormatLocale = source.dateFormatLocale
                    ..hasCloudflare = source.hasCloudflare
                    ..iconUrl = source.iconUrl
                    ..typeSource = source.typeSource
                    ..lang = source.lang
                    ..isNsfw = source.isNsfw
                    ..name = source.name
                    ..version = source.version
                    ..versionLast = source.version
                    ..isManga = source.isManga
                    ..isFullData = source.isFullData ?? false
                    ..appMinVerReq = source.appMinVerReq
                    ..sourceCodeLanguage = source.sourceCodeLanguage
                    ..additionalParams = source.additionalParams ?? "");
                });
                // log("successfully installed or updated");
              }
            } else if (isar.sources.getSync(source.id!) != null) {
              // log("exist");
              final sourc = isar.sources.getSync(source.id!)!;
              if (sourc.isAdded!) {
                if (compareVersions(sourc.version!, source.version!) < 0) {
                  // log("update aivalable auto update");
                  if (ref.watch(autoUpdateExtensionsStateProvider)) {
                    final req =
                        await http.get(Uri.parse(source.sourceCodeUrl!));
                    final headers = await getHeaders(req.body, source.baseUrl!);
                    isar.writeTxnSync(() {
                      isar.sources.putSync(sourc
                        ..headers = headers ?? ""
                        ..isAdded = true
                        ..sourceCode = req.body
                        ..sourceCodeUrl = source.sourceCodeUrl
                        ..id = source.id
                        ..apiUrl = source.apiUrl
                        ..baseUrl = source.baseUrl
                        ..dateFormat = source.dateFormat
                        ..dateFormatLocale = source.dateFormatLocale
                        ..hasCloudflare = source.hasCloudflare
                        ..iconUrl = source.iconUrl
                        ..typeSource = source.typeSource
                        ..lang = source.lang
                        ..isNsfw = source.isNsfw
                        ..name = source.name
                        ..version = source.version
                        ..versionLast = source.version
                        ..isManga = source.isManga
                        ..isFullData = source.isFullData ?? false
                        ..appMinVerReq = source.appMinVerReq
                        ..sourceCodeLanguage = source.sourceCodeLanguage
                        ..additionalParams = source.additionalParams ?? "");
                    });
                  } else {
                    // log("update aivalable");
                    isar.sources.putSync(sourc..versionLast = source.version);
                  }
                }
              }
            } else {
              isar.sources.putSync(Source()
                ..sourceCodeUrl = source.sourceCodeUrl
                ..id = source.id
                ..sourceCode = source.sourceCode
                ..apiUrl = source.apiUrl
                ..baseUrl = source.baseUrl
                ..dateFormat = source.dateFormat
                ..dateFormatLocale = source.dateFormatLocale
                ..hasCloudflare = source.hasCloudflare
                ..iconUrl = source.iconUrl
                ..typeSource = source.typeSource
                ..lang = source.lang
                ..isNsfw = source.isNsfw
                ..name = source.name
                ..version = source.version
                ..versionLast = source.version
                ..isManga = source.isManga
                ..sourceCodeLanguage = source.sourceCodeLanguage
                ..isFullData = source.isFullData ?? false
                ..appMinVerReq = source.appMinVerReq);
              // log("new source");
            }
          }
        }
      }
    }
  });
  checkIfSourceIsObsolete(sourceList, isManga);
}

void checkIfSourceIsObsolete(List<Source> sourceList, bool isManga) {
  for (var source in isar.sources
      .filter()
      .idIsNotNull()
      .isMangaEqualTo(isManga)
      .findAllSync()) {
    if (sourceList.isNotEmpty && !(source.isLocal ?? false)) {
      final ids =
          sourceList.where((e) => e.id != null).map((e) => e.id).toList();
      if (ids.isNotEmpty) {
        if (!ids.contains(source.id)) {
          isar.writeTxnSync(
              () => isar.sources.putSync(source..isObsolete = true));
        }
      }
    }
  }
}

int compareVersions(String version1, String version2) {
  List<String> v1Components = version1.split('.');
  List<String> v2Components = version2.split('.');

  for (int i = 0; i < v1Components.length && i < v2Components.length; i++) {
    int v1Value = int.parse(
        v1Components.length == i + 1 && v1Components[i].length == 1
            ? "${v1Components[i]}0"
            : v1Components[i]);
    int v2Value = int.parse(
        v2Components.length == i + 1 && v2Components[i].length == 1
            ? "${v2Components[i]}0"
            : v2Components[i]);

    if (v1Value < v2Value) {
      return -1;
    } else if (v1Value > v2Value) {
      return 1;
    }
  }

  if (v1Components.length < v2Components.length) {
    return -1;
  } else if (v1Components.length > v2Components.length) {
    return 1;
  }

  return 0;
}

Future<String?> getHeaders(String codeSource, String baseUrl) async {
  try {
    final bytecode = compilerEval(codeSource);
    final runtime = runtimeEval(bytecode);
    runtime.args = [$String(baseUrl)];
    var res = await runtime.executeLib(
      'package:filmpisso/main.dart',
      'getHeader',
    );
    Map<String, String> headers = {};
    if (res is $Map) {
      headers = res.$reified
          .map((key, value) => MapEntry(key.toString(), value.toString()));
    }
    return jsonEncode(headers);
  } catch (_) {
    return null;
  }
}
