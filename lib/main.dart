import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/providers/app_settings_notifier.dart';
import 'core/services/audio_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/fichas/data/drift_token_repository.dart';
import 'features/fichas/data/token_database.dart';
import 'features/fichas/domain/token_repository.dart';
import 'features/fichas/domain/token_system_notifier.dart';
import 'features/timer/domain/timer_notifier.dart';
import 'navigation/main_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final notifications = NotificationService();
  await notifications.init();
  final tokenRepo = DriftTokenRepository(TokenDatabase());
  await tokenRepo.seedIfEmpty();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    HighAchieverApp(
      prefs: prefs,
      notifications: notifications,
      tokenRepo: tokenRepo,
    ),
  );
}

class HighAchieverApp extends StatelessWidget {
  final SharedPreferences prefs;
  final NotificationService notifications;
  final TokenRepository tokenRepo;
  const HighAchieverApp({
    super.key,
    required this.prefs,
    required this.notifications,
    required this.tokenRepo,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TimerNotifier(prefs, AudioService(), notifications),
        ),
        ChangeNotifierProvider(create: (_) => AppSettingsNotifier(prefs)),
        ChangeNotifierProvider(create: (_) => TokenSystemNotifier(tokenRepo)),
      ],
      child: MaterialApp(
        title: 'High Achiever',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const MainScaffold(),
      ),
    );
  }
}
