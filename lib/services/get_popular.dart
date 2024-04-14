import 'dart:async';
import 'package:filmpisso/eval/dart/bridge/m_source.dart';
import 'package:filmpisso/eval/javascript/service.dart';
import 'package:filmpisso/eval/dart/model/m_pages.dart';
import 'package:filmpisso/eval/dart/compiler/compiler.dart';
import 'package:filmpisso/eval/dart/model/m_provider.dart';
import 'package:filmpisso/models/source.dart';
import 'package:filmpisso/eval/dart/runtime/runtime.dart';
import 'package:filmpisso/sources/source_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'get_popular.g.dart';

@riverpod
Future<MPages?> getPopular(
  GetPopularRef ref, {
  required Source source,
  required int page,
}) async {
  MPages? popularManga;
  if (source.sourceCodeLanguage == SourceCodeLanguage.dart) {
    try {
      final bytecode =
          compilerEval(useTestSourceCode ? testSourceCode : source.sourceCode!);

      final runtime = runtimeEval(bytecode);

      var res = runtime.executeLib('package:filmpisso/main.dart', 'main',
          [$MSource.wrap(source.toMSource())]);
      popularManga = await (res as MProvider).getPopular(page);
    } catch (e) {
      throw Exception(e);
    }
  } else {
    popularManga = await JsExtensionService(source).getPopular(page);
  }

  return popularManga;
}
