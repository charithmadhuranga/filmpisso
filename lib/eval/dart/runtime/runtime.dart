import 'dart:typed_data';
import 'package:dart_eval/dart_eval.dart';
import 'package:filmpisso/eval/dart/plugin.dart';

Runtime runtimeEval(Uint8List bytecode) {
  final runtime = Runtime(bytecode.buffer.asByteData());
  final plugin = MEvalPlugin();
  runtime.addPlugin(plugin);
  return runtime;
}
