import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/auth_repository.dart';

import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  Future<void> _startServerSideGoogleFlow() async {
    final authRepo = context.read<AuthRepository>();
    final backendOauthUrl = '${authRepo.baseUrl}/auth/google';
    final uri = Uri.parse(backendOauthUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/feed');
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final loading = state is AuthLoading;

        return Scaffold(
          backgroundColor: const Color(0xFF0D1117),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      'Sign in to App',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFF0F6FC),
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // EMAIL FIELD
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Username or email address',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF0F6FC),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailCtrl,
                          style: const TextStyle(
                            color: Color(0xFFF0F6FC),
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF0D1117),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(
                                color: Color(0xFF30363D),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(
                                color: Color(0xFF1F6FEB),
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // PASSWORD FIELD
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Password',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFF0F6FC),
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go('/forgot-password'),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(
                                  color: Color(0xFF539BF5),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passCtrl,
                          obscureText: true,
                          style: const TextStyle(
                            color: Color(0xFFF0F6FC),
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF0D1117),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(
                                color: Color(0xFF30363D),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(
                                color: Color(0xFF1F6FEB),
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // SIGN IN BUTTON (email + pass)
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: loading
                            ? null
                            : () {
                          context.read<AuthBloc>().add(
                            EmailLoginRequested(
                              email: _emailCtrl.text.trim(),
                              password: _passCtrl.text,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF238636),
                          foregroundColor: const Color(0xFFFFFFFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 0,
                        ),
                        child: loading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text(
                          'Sign in',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // DIVIDER
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: const Color(0xFF21262D),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or',
                            style: TextStyle(
                              color: Color(0xFF7D8590),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: const Color(0xFF21262D),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // GOOGLE SIGN-IN (SERVER FLOW)
                    SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed:
                        loading ? null : _startServerSideGoogleFlow,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFF0F6FC),
                          side: const BorderSide(
                            color: Color(0xFF30363D),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          backgroundColor: const Color(0xFF21262D),
                        ),
                        icon: Image.network(
                          'https://www.google.com/favicon.ico',
                          width: 20,
                          height: 20,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.g_mobiledata,
                            size: 24,
                          ),
                        ),
                        label: const Text(
                          'Continue with Google',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // REMOVED SIGN IN WITH APPLE (REQUESTED)

                    const SizedBox(height: 32),

                    // SIGN UP BOX
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF30363D),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              color: Color(0xFF539BF5),
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/signup'),
                            child: const Text(
                              'Sign up now',
                              style: TextStyle(
                                color: Color(0xFF539BF5),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
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
      },
    );
  }
}