import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/audio_service.dart';
import 'core/theme/app_theme.dart';
import 'features/timer/domain/timer_notifier.dart';
import 'navigation/main_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(HighAchieverApp(prefs: prefs));
}

class HighAchieverApp extends StatelessWidget {
  final SharedPreferences prefs;
  const HighAchieverApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TimerNotifier(prefs, AudioService()),
      child: MaterialApp(
        title: 'High Achiever',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const MainScaffold(),
      ),
    );
  }
}
