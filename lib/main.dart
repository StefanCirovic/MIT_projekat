import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_menza/consts/theme_data.dart';
import 'package:e_menza/providers/theme_provider.dart';
import 'package:e_menza/screens/home_screen.dart';
import 'package:e_menza/screens/root_screen.dart';
import 'package:e_menza/screens/auth/login.dart';
import 'package:e_menza/screens/auth/register.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          return ThemeProvider();
        }),
      ],
      child: Consumer(builder: (context, themeProvider, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) {
              return ThemeProvider();
            })
          ],
          child:
              Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
            return MaterialApp(
                title: 'E_MENZA',
                theme: Styles.themeData(
                    isDarkTheme: themeProvider.getIsDarkTheme,
                    context: context),
                //home: const RootScreen(),
                home: const LoginScreen(),
                routes: {
                  RootScreen.routeName: (context) => const RootScreen(),
                  RegisterScreen.routName: (context) => const RegisterScreen(),
                  LoginScreen.routeName: (context) => const LoginScreen(),
                });
          }),
        );
      }),
    );
  }
}
