import 'package:bloc/bloc.dart';
import 'package:hackmates_app/features/auth/data/auth_repository.dart';
import 'package:hackmates_app/features/auth/bloc/forgot_password/forgot_password_event.dart';
import 'package:hackmates_app/features/auth/bloc/forgot_password/forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final AuthRepository authRepository;
  String _email = '';

  ForgotPasswordBloc({required this.authRepository})
      : super(ForgotPasswordInitial()) {

    on<ForgotPasswordEmailChanged>((event, emit) {
      _email = event.email;
    });

    on<ForgotPasswordSubmitted>((event, emit) async {
      if (_email.isEmpty) {
        emit(ForgotPasswordFailure('Please enter your email'));
        return;
      }

      emit(ForgotPasswordSubmitting());

      try {
        final resp = await authRepository.forgotPassword(email: _email);

        emit(ForgotPasswordSuccess(
          resp['message'] ?? 'Password reset link sent to your email',
        ));
      } catch (e) {
        emit(ForgotPasswordFailure(
          e.toString().replaceAll('Exception: ', ''),
        ));
      }
    });
  }
}
