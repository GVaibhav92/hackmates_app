import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/bloc/auth_state.dart';
import '../features/auth/bloc/auth_event.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/otp_verification_screen.dart';
import '../features/auth/bloc/forgot_password/forgot_password_bloc.dart';
import '../features/auth/presentation/screens/feed_screen.dart';
import '../features/apply/presentation/screens/quick_apply_screen.dart';
import '../features/auth/presentation/screens/create_post_screen.dart';


final appRouter = GoRouter(
  initialLocation: '/splash',

  // Redirect logic based on authentication state
  redirect: (BuildContext context, GoRouterState state) {
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;

    final isAuthenticated = authState is AuthAuthenticated;
    final isLoading = authState is AuthLoading || authState is AuthInitial;

    final currentPath = state.matchedLocation;

    // While checking auth status, stay on splash
    if (isLoading) {
      return currentPath == '/splash' ? null : '/splash';
    }

    // If authenticated and trying to access login/signup
    if (isAuthenticated && (currentPath == '/login' || currentPath == '/signup')) {
      return '/feed';
    }

    // If authenticated and on splash, go to feed
    if (isAuthenticated && currentPath == '/splash') {
      return '/feed';
    }

    return null; // No redirect needed
  },

  routes: [
    // Splash Screen
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // ==================== AUTH ROUTES ====================

    // Login Screen
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    // Signup Screen (Multi-step registration)
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignupScreen(),
    ),

    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => BlocProvider(
        create: (context) => ForgotPasswordBloc(
          authRepository: context.read<AuthRepository>(),
        ),
        child: const ForgotPasswordScreen(),
      ),
    ),

    // OTP Verification Screen
    GoRoute(
      path: '/otp-verification',
      name: 'otp-verification',
      builder: (context, state) {
        final extra = state.extra;
        String email = '';

        if (extra is String) {
          email = extra;
        } else if (extra is Map<String, dynamic>) {
          email = extra['email'] ?? '';
        }

        if (email.isEmpty) {
          Future.microtask(() => context.go('/signup'));
          return const SplashScreen();
        }
        return OtpVerificationScreen(email: email);
      },
    ),


    // OAuth Callback - CRITICAL for Google Sign-In
    GoRoute(
      path: '/oauth/callback',
      name: 'oauth-callback',
      builder: (context, state) {
        final key = state.uri.queryParameters['key'];

        if (key != null && key.isNotEmpty) {
          context.read<AuthBloc>().add(GoogleServerSideSignInComplete(key));
          debugPrint('OAuth callback received with key: $key');
        } else {
          debugPrint('OAuth callback received but no key found');
        }

        return const SplashScreen();
      },
    ),

    // Email Verification Callback - CRITICAL for Signup Flow
    GoRoute(
      path: '/verified',
      name: 'verified',
      builder: (context, state) {
        debugPrint('🔗 /verified route hit');
        debugPrint('🔗 Query params: ${state.uri.queryParameters}');

        final token = state.uri.queryParameters['token'];

        if (token != null && token.isNotEmpty) {
          debugPrint('✅ Token found in /verified route: ${token.substring(0, 20)}...');

          Future.microtask(() {
            context.read<AuthBloc>().add(
              EmailVerificationCompleted(token),
            );
            context.go('/signup', extra: {'verificationToken': token});
          });

          Future.delayed(const Duration(milliseconds: 800), () {
            try {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Email verified! Complete your profile.'),
                  backgroundColor: Color(0xFF238636),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            } catch (e) {
              debugPrint('⚠️ Could not show snackbar: $e');
            }
          });
        } else {
          debugPrint('❌ No token in /verified route');
          Future.microtask(() {
            context.go('/signup');
          });
        }

        return const Scaffold(
          backgroundColor: Color(0xFF0D1117),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Color(0xFF238636),
                ),
                SizedBox(height: 16),
                Text(
                  'Verifying email...',
                  style: TextStyle(
                    color: Color(0xFFF0F6FC),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),

    //CREATE POST
    GoRoute(
      path: '/create-post',
      name: 'create-post',
      builder: (context, state) => const CreatePostScreen(),
    ),

    // ==================== PROTECTED ROUTES ====================

    // Feed Screen (Main app screen after login)
    GoRoute(
      path: '/feed',
      name: 'feed',
      builder: (context, state) => const FeedScreen(),
    ),

    // Quick Apply Screen
    GoRoute(
      path: '/apply',
      name: 'apply',
      builder: (context, state) => const QuickApplyScreen(),
    ),
  ],

  // Error handling
  errorBuilder: (context, state) => Scaffold(
    backgroundColor: const Color(0xFF0D1117),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Color(0xFFDA3633),
          ),
          const SizedBox(height: 16),
          Text(
            'Page not found',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFFF0F6FC),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.matchedLocation,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7D8590),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF238636),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text('Go to Login'),
          ),
        ],
      ),
    ),
  ),
);