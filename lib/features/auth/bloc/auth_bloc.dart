import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:hackmates_app/features/auth/data/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

//EVENT HANDLERS
class AuthBloc extends Bloc<AuthEvent, AuthState> {

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<EmailLoginRequested>(_onEmailLogin);
    on<SignupAuthenticated>(_onSignupAuthenticated);
    on<GoogleServerSideSignInRequested>(_onGoogleServerSideRequest);
    on<GoogleServerSideSignInComplete>(_onGoogleServerSideComplete);
    on<AuthLoggedOut>(_onLoggedOut);

  }

  final AuthRepository authRepository;

  //App initialization
  FutureOr<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final token = await authRepository.getToken();
      if (token != null) {
        //call to validate token and get current user
        final user = await authRepository.getCurrentUser();
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      //token invalid/expired/network error
      await authRepository.deleteToken();
      emit(AuthUnauthenticated());
    }
  }

//Email and password login
  FutureOr<void> _onEmailLogin(
      EmailLoginRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      final resp = await authRepository.login(
        email: event.email,
        password: event.password,
      );
      final token = resp['access_token'];
      if (token == null) {
        throw Exception('Token missing in login response');
      }

      await authRepository.persistToken(token);

      final user = await authRepository.getCurrentUser();

      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  //signup successfull
  void _onSignupAuthenticated(
      SignupAuthenticated event,
      Emitter<AuthState> emit,
      ) {
    emit(AuthAuthenticated(event.user));
  }

  // Triggers server-side flow: UI should open the backend OAuth URL in browser.
  FutureOr<void> _onGoogleServerSideRequest(GoogleServerSideSignInRequested event, Emitter<AuthState> emit) {
    // This event is only used as a signal for UI to open the backend oauth URL
    // No repository calls here.
  }

  // After deep link with key is received, call backend to exchange for JWT
  FutureOr<void> _onGoogleServerSideComplete(GoogleServerSideSignInComplete event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final resp = await authRepository.fetchJwtByKey(key: event.key);
      final parsed = await authRepository.parseAuthResponse(resp);
      final user = parsed['user'];
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  FutureOr<void> _onLoggedOut(AuthLoggedOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await authRepository.deleteToken();
    emit(AuthUnauthenticated());
  }
}
