import 'package:filmpisso/eval/dart/bridge/m_source.dart';
import 'package:filmpisso/eval/dart/compiler/compiler.dart';
import 'package:filmpisso/eval/dart/model/m_provider.dart';
import 'package:filmpisso/models/source.dart';
import 'package:filmpisso/eval/dart/runtime/runtime.dart';
import 'package:filmpisso/sources/source_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'get_source_baseurl.g.dart';

@riverpod
String sourceBaseUrl(SourceBaseUrlRef ref, {required Source source}) {
  String? baseUrl;
  if (source.sourceCodeLanguage == SourceCodeLanguage.dart) {
    try {
      final bytecode =
          compilerEval(useTestSourceCode ? testSourceCode : source.sourceCode!);

      final runtime = runtimeEval(bytecode);

      var res = runtime.executeLib('package:filmpisso/main.dart', 'main',
          [$MSource.wrap(source.toMSource())]);
      baseUrl = (res as MProvider).baseUrl;
    } catch (e) {
      baseUrl = source.baseUrl;
    }
  } else {}
  if (baseUrl == null || baseUrl.isEmpty) {
    baseUrl = source.baseUrl;
  }

  return baseUrl!;
}
