import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'router/app_router.dart';

import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/signup/signup_bloc.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/data/feed_repository.dart';
import 'features/feed/bloc/feed_bloc.dart';
import 'features/feed/bloc/feed_event.dart';

void main() {
  runApp(const HackmatesApp());
}

class HackmatesApp extends StatefulWidget {
  const HackmatesApp({super.key});

  @override
  State<HackmatesApp> createState() => _HackmatesAppState();
}

class _HackmatesAppState extends State<HackmatesApp> {
  final _baseUrl = 'https://uncookable-annelle-combatable.ngrok-free.dev';

  @override
  Widget build(BuildContext context) {
    final authRepo = AuthRepository(baseUrl: _baseUrl);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(
          value: authRepo,
        ),
        RepositoryProvider<FeedRepository>(
          create: (context) =>
              FeedRepository(
                baseUrl: authRepo.baseUrl,
                authRepository: authRepo,
              ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(authRepository: authRepo),
          ),
          BlocProvider(
            create: (context) => SignupBloc(
              authRepository: authRepo,
              authBloc: context.read<AuthBloc>(),
            ),
          ),
          BlocProvider(
            create: (context) =>
            FeedBloc(
              context.read<FeedRepository>(),
            )
              ..add(FetchFeed()),
          ),
        ],
        child: MaterialApp.router(
          title: 'Hackmates',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
