import 'package:equatable/equatable.dart';
import 'package:hackmates_app/features/auth/models/user_model.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

//App Initialization
class AuthStarted extends AuthEvent {}

//Email Login
class EmailLoginRequested extends AuthEvent {
  final String email;
  final String password;

  EmailLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email];
}
class EmailVerificationCompleted extends AuthEvent {
  final String token;
  EmailVerificationCompleted(this.token);
}

class SignupAuthenticated extends AuthEvent {
  final UserModel user;

  SignupAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

//new user Signup
class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  RegisterRequested({required this.name, required this.email, required this.password});

  @override
  List<Object?> get props => [email];
}

//OAUTH initialization
/// Trigger server-side Google OAuth redirect flow
/// The UI will open the backend OAuth URL (in browser) and wait for deep link with ?key=...
class GoogleServerSideSignInRequested extends AuthEvent {}

/// After receiving the deep link key, dispatch with the key to retrieve the JWT
class GoogleServerSideSignInComplete extends AuthEvent {
  final String key;
  GoogleServerSideSignInComplete(this.key);

  @override
  List<Object?> get props => [key];
}

class AuthLoggedOut extends AuthEvent {}
