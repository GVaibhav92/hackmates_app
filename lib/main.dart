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

  late final AuthRepository _authRepository;
  late final FeedRepository _feedRepository;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepository(baseUrl: _baseUrl);
    _feedRepository = FeedRepository(
      baseUrl: _baseUrl,
      authRepository: _authRepository,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _authRepository),
        RepositoryProvider.value(value: _feedRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AuthBloc(authRepository: _authRepository),
          ),
          BlocProvider(
            create: (context) => SignupBloc(
              authRepository: _authRepository,
              authBloc: context.read<AuthBloc>(),
            ),
          ),
          BlocProvider(
            create: (context) =>
            FeedBloc(context.read<FeedRepository>())
              ..add(FetchFeed()),
          ),
        ],
        child: Builder(
          builder: (context) {
            final authBloc = context.read<AuthBloc>();
            return MaterialApp.router(
              title: 'Hackmates',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              routerConfig: createAppRouter(authBloc),
            );
          },
        ),
      ),
    );
  }
}
