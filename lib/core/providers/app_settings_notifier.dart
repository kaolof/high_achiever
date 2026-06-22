import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsNotifier extends ChangeNotifier {
  static const _keyShowTokensTab = 'show_tokens_tab';
  static const _keyFlipMode = 'flip_mode';
  static const _keyOnboardingCompleted = 'onboarding_completed';
  static const _keyFullscreenIntroSeen = 'fullscreen_intro_seen';

  final SharedPreferences _prefs;

  AppSettingsNotifier(this._prefs);

  bool get onboardingCompleted =>
      _prefs.getBool(_keyOnboardingCompleted) ?? false;

  set onboardingCompleted(bool value) {
    _prefs.setBool(_keyOnboardingCompleted, value);
    notifyListeners();
  }

  /// Whether the one-time "how fullscreen / flip mode works" overlay has been
  /// shown. Set the first time the user opens the fullscreen timer.
  bool get fullscreenIntroSeen =>
      _prefs.getBool(_keyFullscreenIntroSeen) ?? false;

  set fullscreenIntroSeen(bool value) {
    _prefs.setBool(_keyFullscreenIntroSeen, value);
    notifyListeners();
  }

  bool get showTokensTab => _prefs.getBool(_keyShowTokensTab) ?? false;

  set showTokensTab(bool value) {
    _prefs.setBool(_keyShowTokensTab, value);
    notifyListeners();
  }

  bool get flipMode => _prefs.getBool(_keyFlipMode) ?? true;

  set flipMode(bool value) {
    _prefs.setBool(_keyFlipMode, value);
    notifyListeners();
  }
}
