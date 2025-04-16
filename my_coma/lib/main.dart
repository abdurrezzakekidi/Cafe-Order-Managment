import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_coma/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screens/LoginScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  SharedPreferences prefs = await SharedPreferences.getInstance(); 
  String? savedLanguage = prefs.getString('language') ?? 'en';

  runApp(MyApp(savedLanguage));
}

class MyApp extends StatelessWidget {
  final String languageCode;
  const MyApp(this.languageCode, {super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: Locale(languageCode),
      localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}
