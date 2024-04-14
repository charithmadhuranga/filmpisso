import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:filmpisso/eval/dart/bridge/m_source.dart';
import 'package:filmpisso/eval/dart/compiler/compiler.dart';
import 'package:filmpisso/eval/javascript/service.dart';
import 'package:filmpisso/eval/dart/model/m_provider.dart';
import 'package:filmpisso/eval/dart/model/source_preference.dart';
import 'package:filmpisso/models/source.dart';
import 'package:filmpisso/eval/dart/runtime/runtime.dart';

List<SourcePreference> getSourcePreference({required Source source}) {
  List<SourcePreference> sourcePreference = [];

  if (source.sourceCodeLanguage == SourceCodeLanguage.dart) {
    try {
      final bytecode = compilerEval(source.sourceCode!);

      final runtime = runtimeEval(bytecode);

      var res = runtime.executeLib('package:filmpisso/main.dart', 'main',
          [$MSource.wrap(source.toMSource())]);
      sourcePreference = (res as MProvider)
          .getSourcePreferences()
          .map((e) => (e is $Value ? e.$reified : e) as SourcePreference)
          .toList();
    } catch (_) {
      return [];
    }
  } else {
    sourcePreference = JsExtensionService(source).getSourcePreferences();
  }

  return sourcePreference;
}
