import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'models/report_state.dart';
import 'screens/home_screen.dart';
import 'screens/auth_wrapper.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/plate_instructions_screen.dart';
import 'screens/plate_scanner_screen.dart';
import 'screens/ocr_confirmation_screen.dart';
import 'screens/damage_instructions_screen.dart';
import 'screens/damage_camera_screen.dart';
import 'screens/ai_processing_screen.dart';
import 'screens/ai_results_screen.dart';
import 'screens/final_report_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AccidentReporterApp());
}

class AccidentReporterApp extends StatefulWidget {
  const AccidentReporterApp({super.key});

  @override
  State<AccidentReporterApp> createState() => _AccidentReporterAppState();
}

class _AccidentReporterAppState extends State<AccidentReporterApp> {
  // Single global state instance shared across all routes
  final ReportState _reportState = ReportState();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accident Reporter',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (_) => AuthWrapper(state: _reportState),
              settings: settings,
            );
          case '/home':
            return MaterialPageRoute(
              builder: (_) => HomeScreen(state: _reportState),
              settings: settings,
            );
          case '/login':
            return MaterialPageRoute(
              builder: (_) => const LoginScreen(),
              settings: settings,
            );
          case '/register':
            return MaterialPageRoute(
              builder: (_) => const RegisterScreen(),
              settings: settings,
            );

          case '/plate-instructions':
            return MaterialPageRoute(
              builder: (_) =>
                  PlateInstructionsScreen(state: _reportState),
              settings: settings,
            );
          case '/plate-scanner':
            return MaterialPageRoute(
              builder: (_) => PlateScannerScreen(state: _reportState),
              settings: settings,
            );
          case '/ocr-confirmation':
            return MaterialPageRoute(
              builder: (_) => OcrConfirmationScreen(state: _reportState),
              settings: settings,
            );
          case '/damage-instructions':
            return MaterialPageRoute(
              builder: (_) =>
                  DamageInstructionsScreen(state: _reportState),
              settings: settings,
            );
          case '/damage-camera':
            return MaterialPageRoute(
              builder: (_) => DamageCameraScreen(state: _reportState),
              settings: settings,
            );
          case '/ai-processing':
            return MaterialPageRoute(
              builder: (_) => const AiProcessingScreen(),
              settings: settings,
            );
          case '/ai-results':
            return MaterialPageRoute(
              builder: (_) => AiResultsScreen(state: _reportState),
              settings: settings,
            );
          case '/final-report':
            return MaterialPageRoute(
              builder: (_) => FinalReportScreen(state: _reportState),
              settings: settings,
            );
          default:
            return MaterialPageRoute(
              builder: (_) => AuthWrapper(state: _reportState),
            );
        }
      },
    );
  }
}
