import 'package:chat_app/core/common/custom_button.dart';
import 'package:chat_app/core/common/custom_textfield.dart';
import 'package:chat_app/core/utils/ui_utils.dart';
import 'package:chat_app/data/services/service_locator.dart';
import 'package:chat_app/logic/cubits/auth/auth_cubit.dart';
import 'package:chat_app/logic/cubits/auth/auth_state.dart';
import 'package:chat_app/presentation/auth/signup_screen.dart';
import 'package:chat_app/presentation/home/home_screen.dart';
import 'package:chat_app/router/app_router.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool isPasswordVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    // Email validation using RegExp
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    return null;
  }

  void login() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await getIt<AuthCubit>().signIn(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      } catch (e) {
        UiUtils.showErrorSnackBar(context: context, message: e.toString());
      }
    } else {
      UiUtils.showWarningSnackBar(
        context: context,
        message: "Form Validation failed",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      bloc: getIt<AuthCubit>(),
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          getIt<AppRouter>().pushAndRemoveUntil(HomeScreen());
        } else if (state.status == AuthStatus.error && state.error != null) {
          UiUtils.showErrorSnackBar(context: context, message: state.error!);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30),
                    Text(
                      "Create Account",
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Sign in to continue",
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                    ),
                    SizedBox(height: 30),

                    CustomTextField(
                      controller: emailController,
                      hintText: "Email",
                      focusNode: _emailFocusNode,
                      validator: _validateEmail,
                      prefixIcon: Icon(Icons.email_outlined),
                      onFieldSubmitted:
                          (_) => _passwordFocusNode.requestFocus(),
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      controller: passwordController,
                      hintText: "Password",
                      validator: _validatePassword,
                      focusNode: _passwordFocusNode,
                      prefixIcon: Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                      obscureText: isPasswordVisible,
                      onFieldSubmitted: (_) => login(),
                    ),
                    SizedBox(height: 30),
                    CustomButton(
                      onPressed: login,
                      text: "Login",
                      child:
                          state.status == AuthStatus.loading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                "Login",
                                style: TextStyle(color: Colors.white),
                              ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account?  ",
                          style: TextStyle(color: Colors.grey[600]),
                          children: [
                            TextSpan(
                              text: "Sign up",
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () {
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) => SignupScreen(),
                                      //   ),
                                      // );
                                      getIt<AppRouter>().push(SignupScreen());
                                    },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
