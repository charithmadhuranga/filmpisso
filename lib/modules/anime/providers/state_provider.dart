import 'package:filmpisso/main.dart';
import 'package:filmpisso/models/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'state_provider.g.dart';

@riverpod
class SubtitleSettingsState extends _$SubtitleSettingsState {
  @override
  PlayerSubtitleSettings build() {
    final subSets = isar.settings.getSync(227)!.playerSubtitleSettings;
    if (subSets == null || subSets.backgroundColorA == null) {
      set(PlayerSubtitleSettings(), true);
      return PlayerSubtitleSettings();
    }
    return subSets;
  }

  void set(PlayerSubtitleSettings value, bool end) {
    final settings = isar.settings.getSync(227);
    state = value;
    if (end) {
      isar.writeTxnSync(() =>
          isar.settings.putSync(settings!..playerSubtitleSettings = value));
    }
  }

  void resetColor() {
    final settings = isar.settings.getSync(227);
    state = PlayerSubtitleSettings(
        fontSize: state.fontSize,
        useBold: state.useBold,
        useItalic: state.useItalic);
    isar.writeTxnSync(() => isar.settings.putSync(settings!
      ..playerSubtitleSettings = PlayerSubtitleSettings(
          fontSize: state.fontSize,
          useBold: state.useBold,
          useItalic: state.useItalic)));
  }
}
