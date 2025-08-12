import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_links/app_links.dart';
import 'package:sqflite/sqflite.dart';

import 'Model/user_profile.dart';
import 'Screens/display_profile.dart';
import 'Screens/splash_screen.dart';
import 'Theme/theme.dart';
import 'utils/stream_builder.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
Logger logger = Logger();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // FFI setup (for desktop only)
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit(); // required
    databaseFactory = databaseFactoryFfi; // this is the missing piece
  }

  if (!kIsWeb) {
    await _requestStoragePermission();
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  runApp(MyApp());
}

Future<void> _requestStoragePermission() async {
  final status = await Permission.photos.request();
  if (status.isDenied || status.isPermanentlyDenied) {
    openAppSettings();
  }
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    StreamUtil.dashboardBottomSubject.add(0);
    if (!kIsWeb) _initDeepLinkListener();
  }

  void _initDeepLinkListener() {
    final appLinks = AppLinks();

    _linkSub = appLinks.uriLinkStream.listen((Uri uri) async {
      if (uri.path == '/vcf' && uri.queryParameters['file'] != null) {
        final filePath = uri.queryParameters['file']!;
        final file = File(filePath);

        if (await file.exists()) {
          final content = await file.readAsString();
          final card = _parseVcfToProfile(content);

          if (card != null) {
            final context = navigatorKey.currentContext;
            if (context != null) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => DisplayProfileScreen(card: card)));
            }
          }
        }
      }
    }, onError: (error) => debugPrint('Deep link error: $error'));
  }

  VisitingCard? _parseVcfToProfile(String content) {
    final lines = content.split(RegExp(r'\r?\n')).where((l) => l.trim().isNotEmpty).toList();

    final Map<String, String> fields = {};
    final List<String> extras = [];

    for (var line in lines) {
      final trimmed = line.trim();

      if (trimmed.startsWith('FN:')) {
        fields['name'] = trimmed.substring(3).trim();
      } else if (trimmed.startsWith('ORG:')) {
        fields['company'] = trimmed.substring(4).trim();
      } else if (trimmed.startsWith('EMAIL:')) {
        fields['email'] = trimmed.substring(6).trim();
      } else if (trimmed.startsWith('TEL:')) {
        fields['phone'] = trimmed.substring(4).trim();
      } else if (trimmed.startsWith('ADR:')) {
        fields['address'] = trimmed.substring(4).trim();
      } else if (!trimmed.startsWith('BEGIN:VCARD') && !trimmed.startsWith('VERSION') && !trimmed.startsWith('END:VCARD')) {
        extras.add(trimmed);
      }
    }

    if (fields.isEmpty) return null;

    return VisitingCard(type: CardType.other, fields: fields, extras: extras, qrData: content);
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'NFC / QR Profile',
          theme: appTheme,
          navigatorKey: navigatorKey,
          home: SplashScreen(),
        );
      },
    );
  }
}
