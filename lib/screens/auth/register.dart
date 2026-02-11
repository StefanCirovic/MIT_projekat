import 'package:e_menza/screens/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:e_menza/consts/validator.dart';
import 'package:e_menza/services/assets_manager.dart';
import 'package:e_menza/services/my_app_functions.dart';
import 'package:e_menza/widgets/subtitle_text.dart';
import 'package:e_menza/widgets/title_text.dart';
import 'package:e_menza/screens/root_screen.dart';
import 'package:e_menza/providers/student_providers.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  static const routName = "/RegisterScreen";
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool obscureText = true;
  bool _isLoading = false;
  late final TextEditingController _cardNumberController,
      _emailController,
      _pinController,
      _pinConfirmController;
  late final FocusNode _cardNumberFocusNode,
      _emailFocusNode,
      _pinFocusNode,
      _pinConfirmFocusNode;
  final _formkey = GlobalKey<FormState>();
  @override
  void initState() {
    _cardNumberController = TextEditingController();
    _emailController = TextEditingController();
    _pinController = TextEditingController();
    _pinConfirmController = TextEditingController();

    _cardNumberFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _pinFocusNode = FocusNode();
    _pinConfirmFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    if (mounted) {
      _cardNumberController.dispose();
      _emailController.dispose();
      _pinController.dispose();
      _pinConfirmController.dispose();
      // Focus Nodes
      _cardNumberFocusNode.dispose();
      _emailFocusNode.dispose();
      _pinFocusNode.dispose();
      _pinConfirmFocusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _registerFCT() async {
    final isValid = _formkey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (!isValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final studentProvider =
          Provider.of<StudentProvider>(context, listen: false);
      final result = await studentProvider.register(
        _cardNumberController.text.trim(),
        _pinController.text.trim(),
        _emailController.text.trim(),
      );

      if (result == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uspešno ste registrovali PIN!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
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
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
// const BackButton(),
                const SizedBox(
                  height: 60,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "${AssetsManager.imagePath}/logo.png",
                      height: 60,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "FTN Script Store",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                const Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TitlesTextWidget(label: "Welcome back!"),
                        SubtitleTextWidget(label: "Your welcome message"),
                      ],
                    )),
                const SizedBox(
                  height: 30,
                ),

                const SizedBox(
                  height: 30,
                ),
                Form(
                  key: _formkey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Broj kartice
                      TextFormField(
                        controller: _cardNumberController,
                        focusNode: _cardNumberFocusNode,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Broj kartice',
                          prefixIcon: Icon(
                            Icons.credit_card,
                          ),
                        ),
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).requestFocus(_emailFocusNode);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Unesite broj kartice';
                          }
                          if (value.length < 7) {
                            return 'Broj kartice mora imati najmanje 7 cifara';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      TextFormField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: "Email address",
                          prefixIcon: Icon(
                            IconlyLight.message,
                          ),
                        ),
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).requestFocus(_pinFocusNode);
                        },
                        validator: (value) {
                          return MyValidators.emailValidator(value);
                        },
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      // PIN
                      TextFormField(
                        controller: _pinController,
                        focusNode: _pinFocusNode,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        obscureText: obscureText,
                        decoration: InputDecoration(
                          hintText: "PIN",
                          prefixIcon: const Icon(Icons.lock),
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
                        ),
                        onFieldSubmitted: (value) {
                          FocusScope.of(context)
                              .requestFocus(_pinConfirmFocusNode);
                        },
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
                      const SizedBox(
                        height: 16.0,
                      ),
                      // Potvrda PIN-a
                      TextFormField(
                        controller: _pinConfirmController,
                        focusNode: _pinConfirmFocusNode,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.number,
                        obscureText: obscureText,
                        decoration: InputDecoration(
                          hintText: "Potvrdi PIN",
                          prefixIcon: const Icon(Icons.lock),
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
                        ),
                        onFieldSubmitted: (value) async {
                          await _registerFCT();
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Potvrdite PIN';
                          }
                          if (value != _pinController.text) {
                            return 'PIN-ovi se ne poklapaju';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 36.0,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                12.0,
                              ),
                            ),
                          ),
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(IconlyLight.addUser),
                          label: Text(
                              _isLoading ? "Registracija..." : "Registruj PIN"),
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  await _registerFCT();
                                },
                        ),
                      ),
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
