import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'src/presentation/theme/quire_tokens.dart';
import 'src/presentation/views/quire_home_screen.dart';
import 'src/features/photo_upload/services/quire_moment_uploader.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Native phone status bar configuration:
  // Transparent status bar with dark icons (matching the phone system clock & battery naturally)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: QuireTokens.paperLight,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const QuireApp());
}

class QuireApp extends StatelessWidget {
  const QuireApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quire',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: QuireTokens.paperLight,
        fontFamily: QuireTokens.fontSerif,
        colorScheme: ColorScheme.fromSeed(
          seedColor: QuireTokens.accentLight,
          surface: QuireTokens.surfaceLight,
          background: QuireTokens.paperLight,
        ),
        useMaterial3: true,
      ),
      home: QuireHomeScreen(
        momentUploader: MockQuireMomentUploader(),
      ),
    );
  }
}
