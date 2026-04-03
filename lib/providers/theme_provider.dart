import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/theme_settings.dart';

final themeProvider = NotifierProvider<ThemeNotifier, ThemeSettings>(() {
  return ThemeNotifier();
});

class ThemeNotifier extends Notifier<ThemeSettings> {
  static const _boxName = 'theme_settings';

  @override
  ThemeSettings build() {
    // Synchronously read since the box is opened in main.dart
    final box = Hive.box<ThemeSettings>(_boxName);
    if (box.isNotEmpty) {
      return box.getAt(0)!;
    }
    return ThemeSettings();
  }

  void updateHardwareColor(String hex) {
    state = state.copyWith(hardwareColorHex: hex);
    commitChanges();
  }

  void updateHardwareShape(String shape) {
    state = state.copyWith(hardwareShape: shape);
    commitChanges();
  }

  void updateHardwareSkin(String ref) {
    String hex = state.hardwareColorHex;
    if (ref == 'CH-401') hex = '#131313';
    if (ref == 'SG-882') hex = '#9FD1B8';
    if (ref == 'TC-109') hex = '#FFB4A1';
    if (ref == 'IV-022') hex = '#C9C7B5';
    if (ref == 'EM-055') hex = '#1A3A34';

    state = state.copyWith(hardwareColorHex: hex, hardwareSkinRef: ref);
    commitChanges();
  }

  void updateCassetteSkin(String ref) {
    state = state.copyWith(cassetteSkinRef: ref);
    commitChanges();
  }

  void updateReelType(String type) {
    state = state.copyWith(reelType: type);
    commitChanges();
  }

  void updateLevelMeter(String type) {
    state = state.copyWith(levelMeterType: type);
    commitChanges();
  }

  void updateWindowOpacity(double opacity) {
    state = state.copyWith(windowOpacity: opacity);
    commitChanges();
  }

  void updateCustomSkin(String? base64) {
    state = state.copyWith(customSkinBase64: base64);
    commitChanges();
  }

  void clearCustomSkin() {
    state = state.copyWith(customSkinBase64: '');
    commitChanges();
  }

  void updateButtonColor(String hex) {
    state = state.copyWith(buttonColorHex: hex);
    commitChanges();
  }

  Future<void> commitChanges() async {
    final box = await Hive.openBox<ThemeSettings>(_boxName);
    if (box.isEmpty) {
      await box.add(state);
    } else {
      await box.putAt(0, state);
    }
  }
}
