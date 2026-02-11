import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_menza/consts/theme_data.dart';
import 'package:e_menza/providers/theme_provider.dart';
import 'package:e_menza/screens/root_screen.dart';
import 'package:e_menza/screens/auth/login.dart';
import 'package:e_menza/screens/auth/register.dart';
import 'package:e_menza/screens/auth/forgot_pin_screen.dart';
import 'package:e_menza/providers/student_providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) {
          return ThemeProvider();
        }),
      ],
      child: Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
        return MaterialApp(
            title: 'E_MENZA',
            theme: Styles.themeData(
                isDarkTheme: themeProvider.getIsDarkTheme, context: context),
            home: const LoginScreen(),
            routes: {
              RootScreen.routeName: (context) => const RootScreen(),
              RegisterScreen.routName: (context) => const RegisterScreen(),
              LoginScreen.routeName: (context) => const LoginScreen(),
              ForgotPinScreen.routeName: (context) => const ForgotPinScreen(),
            });
      }),
    );
  }
}
