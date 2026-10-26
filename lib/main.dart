import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'services/security_provider.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/apk_scanner/apk_scanner_screen.dart';
import 'screens/url_scanner/url_scanner_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.primaryDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SecurityProvider()),
      ],
      child: const QoravulXApp(),
    ),
  );
}

class QoravulXApp extends StatefulWidget {
  const QoravulXApp({super.key});

  @override
  State<QoravulXApp> createState() => _QoravulXAppState();
}

class _QoravulXAppState extends State<QoravulXApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription? _intentSub;

  @override
  void initState() {
    super.initState();
    _handleIncomingShares();

    // Trigger initial scan when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SecurityProvider>().performFullScan();
    });
  }

  @override
  void dispose() {
    _intentSub?.cancel();
    super.dispose();
  }

  void _handleIncomingShares() {
    try {
      // 1. For sharing images or files (APKs coming from Telegram or file managers)
      ReceiveSharingIntent.instance.getMediaStream().listen((List<SharedMediaFile> value) {
        if (value.isNotEmpty) {
          final filePath = value.first.path;
          if (filePath.endsWith('.apk')) {
            _navigatorKey.currentState?.push(
              MaterialPageRoute(builder: (_) => ApkScannerScreen(initialApkPath: filePath)),
            );
          }
        }
      }, onError: (_) {});

      ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) {
        if (value.isNotEmpty) {
          final filePath = value.first.path;
          if (filePath.endsWith('.apk')) {
            _navigatorKey.currentState?.push(
              MaterialPageRoute(builder: (_) => ApkScannerScreen(initialApkPath: filePath)),
            );
          }
        }
      });

      // 2. For sharing text/URLs
      ReceiveSharingIntent.instance.getTextStream().listen((String value) {
        if (value.isNotEmpty) {
          _navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => UrlScannerScreen(initialUrl: value)),
          );
        }
      }, onError: (_) {});

      ReceiveSharingIntent.instance.getInitialText().then((String? value) {
        if (value != null && value.isNotEmpty) {
          _navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => UrlScannerScreen(initialUrl: value)),
          );
        }
      });
    } catch (_) {
      // If sharing intent plugin is not available on test/desktop platform
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const DashboardScreen(),
    );
  }
}
