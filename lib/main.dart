import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:orion/ui/welcome_screen.dart';
// Removed shadcn_flutter to avoid conflicts
import 'package:firebase_core/firebase_core.dart';
import 'package:orion/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:isar/isar.dart';
import 'package:orion/services/auth_service.dart';
import 'package:orion/utils/error_handler.dart';
import 'package:orion/utils/loading_manager.dart';
import 'package:orion/utils/feedback_manager.dart';
import 'package:orion/utils/connectivity_manager.dart';
import 'package:orion/utils/performance_monitor.dart';
import 'package:orion/utils/cache_manager.dart';
import 'package:orion/state/app_state_manager.dart';
import 'package:orion/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables
    await dotenv.load(fileName: ".env");

    // Validate configuration
    if (!AppConfig.validateConfig()) {
      throw Exception('Invalid application configuration');
    }

    // Print configuration summary in debug mode
    AppConfig.printConfigSummary();

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Isar for non-web platforms
    if (!kIsWeb) {
      await Isar.initializeIsarCore(download: true);
    }

    // Initialize services
    await _initializeServices();

    runApp(const MyApp());
  } catch (error, stackTrace) {
    // Handle initialization errors
    ErrorHandler.handleError(
      error,
      stackTrace,
      context: 'App Initialization',
      severity: ErrorSeverity.critical,
    );

    // Still run the app but with error state
    runApp(const MyApp());
  }
}

/// Initialize all app services
Future<void> _initializeServices() async {
  try {
    // Initialize performance monitoring
    PerformanceMonitor().initialize();

    // Initialize cache manager
    await CacheManager().initialize();

    // Initialize connectivity manager
    await ConnectivityManager().initialize();

    // Initialize app state manager
    AppStateManager().initialize();

    // Initialize auth service
    AuthService().initialize();

    if (kIsWeb || kDebugMode) {
      debugPrint('All services initialized successfully');
    }
  } catch (e) {
    if (kIsWeb || kDebugMode) {
      debugPrint('Error initializing services: $e');
    }
    // Don't rethrow - app can still function with limited capabilities
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orion',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
        ),
        scaffoldBackgroundColor: Colors.black,
      ),
      scaffoldMessengerKey: FeedbackManager.scaffoldMessengerKey,
      home: const AppWrapper(),
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  @override
  void initState() {
    super.initState();

    // Listen to global errors and show them to user
    ErrorHandler().errorStream.listen((error) {
      if (mounted && error.showToUser) {
        ErrorHandler.showErrorToUser(context, error);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityIndicator(
      child: LoadingOverlay(
        showGlobalLoading: true,
        child: const WelcomeScreen(),
      ),
    );
  }
}
