import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:e_menza/consts/validator.dart';
import 'package:e_menza/screens/auth/register.dart';
import 'package:e_menza/screens/root_screen.dart';
import 'package:e_menza/services/assets_manager.dart';
import 'package:e_menza/widgets/subtitle_text.dart';
import 'package:e_menza/widgets/title_text.dart';
import 'package:provider/provider.dart';
import 'package:e_menza/providers/student_providers.dart';
import 'package:e_menza/screens/auth/forgot_pin_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = "/LoginScreen";
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool obscureText = true;
  late final TextEditingController _cardNumberController;
  late final TextEditingController _pinController;
  late final FocusNode _cardNumberFocusNode;
  late final FocusNode _pinFocusNode;
  final _formkey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    _cardNumberController = TextEditingController();
    _pinController = TextEditingController();

    _cardNumberFocusNode = FocusNode();
    _pinFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _pinController.dispose();
    _cardNumberFocusNode.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loginFct() async {
    final isValid = _formkey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (!isValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final studentProvider =
          Provider.of<StudentProvider>(context, listen: false);
      final success = await studentProvider.login(
        _cardNumberController.text.trim(),
        _pinController.text.trim(),
      );

      if (success) {
        Navigator.of(context).pushReplacementNamed(RootScreen.routeName);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pogrešan broj kartice ili PIN'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Greška: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "${AssetsManager.imagePath}/logo.png",
                      height: 60,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "E MENZA",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: TitlesTextWidget(label: "Welcome back!"),
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formkey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _cardNumberController,
                        focusNode: _cardNumberFocusNode,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "Broj kartice",
                          prefixIcon: Icon(Icons.credit_card),
                        ),
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_pinFocusNode);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Unesite broj kartice';
                          }
                          if (value.length < 6) {
                            return 'Broj kartice mora imati najmanje 7 cifara';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        obscureText: obscureText,
                        controller: _pinController,
                        focusNode: _pinFocusNode,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscureText = !obscureText;
                              });
                            },
                            icon: Icon(
                              obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                          hintText: "PIN",
                          prefixIcon: const Icon(Icons.lock),
                        ),
                        onFieldSubmitted: (_) async => await _loginFct(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Unesite PIN';
                          }
                          if (value.length < 4) {
                            return 'PIN mora imati najmanje 4 cifre';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(ForgotPinScreen.routeName);
                          },
                          child: const SubtitleTextWidget(
                            label: "Zaboravio PIN?",
                            fontStyle: FontStyle.italic,
                            textDecoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          icon: const Icon(Icons.login),
                          label: Text(_isLoading ? "Učitavanje..." : "Login"),
                          onPressed: _isLoading ? null : _loginFct,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SubtitleTextWidget(label: "New here?"),
                          TextButton(
                            child: const SubtitleTextWidget(
                              label: "Sign up",
                              fontStyle: FontStyle.italic,
                              textDecoration: TextDecoration.underline,
                            ),
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(RegisterScreen.routName);
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
