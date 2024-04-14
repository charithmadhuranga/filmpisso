import 'package:filmpisso/main.dart';
import 'package:filmpisso/models/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'blend_level_state_provider.g.dart';

@riverpod
class BlendLevelState extends _$BlendLevelState {
  @override
  double build() {
    return isar.settings.getSync(227)!.flexColorSchemeBlendLevel!;
  }

  void setBlendLevel(double blendLevelValue, {bool end = false}) {
    final settings = isar.settings.getSync(227);
    state = blendLevelValue;
    if (end) {
      isar.writeTxnSync(() =>
          isar.settings.putSync(settings!..flexColorSchemeBlendLevel = state));
    }
  }
}
