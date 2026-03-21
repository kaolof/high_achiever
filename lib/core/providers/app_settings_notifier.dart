import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsNotifier extends ChangeNotifier {
  static const _keyShowTokensTab = 'show_tokens_tab';
  static const _keyFlipMode = 'flip_mode';

  final SharedPreferences _prefs;

  AppSettingsNotifier(this._prefs);

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
