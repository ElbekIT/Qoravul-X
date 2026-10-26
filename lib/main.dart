import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'services/security_provider.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/permission_hub/permission_hub_screen.dart';
import 'screens/apk_scanner/apk_scanner_screen.dart';
import 'screens/url_scanner/url_scanner_screen.dart';

void main() async {
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

  final prefs = await SharedPreferences.getInstance();
  final hasCompletedPermissionSetup = prefs.getBool('has_completed_permission_hub') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SecurityProvider()),
      ],
      child: QoravulXApp(hasCompletedPermissionSetup: hasCompletedPermissionSetup),
    ),
  );
}

class QoravulXApp extends StatefulWidget {
  final bool hasCompletedPermissionSetup;

  const QoravulXApp({super.key, required this.hasCompletedPermissionSetup});

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
      // For sharing files (APKs) or text/URLs (from Telegram, browser, file managers)
      ReceiveSharingIntent.instance.getMediaStream().listen((List<SharedMediaFile> value) {
        if (value.isNotEmpty) {
          final item = value.first;
          final pathOrText = item.path;
          if (pathOrText.endsWith('.apk')) {
            _navigatorKey.currentState?.push(
              MaterialPageRoute(builder: (_) => ApkScannerScreen(initialApkPath: pathOrText)),
            );
          } else if (item.type == SharedMediaType.text ||
              item.type == SharedMediaType.url ||
              pathOrText.startsWith('http://') ||
              pathOrText.startsWith('https://')) {
            _navigatorKey.currentState?.push(
              MaterialPageRoute(builder: (_) => UrlScannerScreen(initialUrl: pathOrText)),
            );
          }
        }
      }, onError: (_) {});

      ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) {
        if (value.isNotEmpty) {
          final item = value.first;
          final pathOrText = item.path;
          if (pathOrText.endsWith('.apk')) {
            _navigatorKey.currentState?.push(
              MaterialPageRoute(builder: (_) => ApkScannerScreen(initialApkPath: pathOrText)),
            );
          } else if (item.type == SharedMediaType.text ||
              item.type == SharedMediaType.url ||
              pathOrText.startsWith('http://') ||
              pathOrText.startsWith('https://')) {
            _navigatorKey.currentState?.push(
              MaterialPageRoute(builder: (_) => UrlScannerScreen(initialUrl: pathOrText)),
            );
          }
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
      home: widget.hasCompletedPermissionSetup
          ? const DashboardScreen()
          : const PermissionHubScreen(isOnboarding: true),
    );
  }
}
