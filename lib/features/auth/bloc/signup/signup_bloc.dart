import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:hackmates_app/features/auth/data/auth_repository.dart';
import 'package:hackmates_app/features/auth/bloc/auth_bloc.dart';
import 'package:hackmates_app/features/auth/bloc/auth_event.dart';
import 'package:hackmates_app/features/auth/models/signup_data_model.dart';
import 'signup_event.dart';
import 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  SignupBloc({
    required this.authRepository,
    required this.authBloc,}) : super(const SignupInitial()) {
    // Field change handlers
    on<SignupFirstNameChanged>(_onFirstNameChanged);
    on<SignupLastNameChanged>(_onLastNameChanged);
    on<SignupEmailChanged>(_onEmailChanged);
    on<SignupPasswordChanged>(_onPasswordChanged);
    on<SignupConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<SignupProfilePhotoChanged>(_onProfilePhotoSelected);
    on<SignupInterestToggled>(_onInterestToggled);
    on<SignupBioChanged>(_onBioChanged);

    // OTP flow handlers
    on<SignupBasicInfoSubmitted>(_onBasicInfoSubmitted);
    on<SignupOtpChanged>(_onOtpChanged);
    on<SignupOtpSubmitted>(_onOtpSubmitted);
    on<SignupOtpResendRequested>(_onOtpResendRequested);
    on<SignupProfileCompleted>(_onProfileCompleted);

    // Utility
    on<SignupReset>(_onReset);
  }

  final AuthRepository authRepository;
  final AuthBloc authBloc;

  /// Reset signup flow
  void _onReset(SignupReset event, Emitter<SignupState> emit) {
    emit(const SignupInitial());
  }

  /// FIELD CHANGE HANDLERS

  void _onFirstNameChanged(SignupFirstNameChanged event, Emitter<SignupState> emit) {
    final currentState = state;
    if (currentState is SignupInProgress) {
      emit(currentState.copyWith(
        data: currentState.data.copyWith(firstName: event.firstName),
        clearError: true,
      ));
    } else {
      emit(SignupInProgress(
        data: const SignupDataModel().copyWith(firstName: event.firstName),
      ));
    }
  }

  void _onLastNameChanged(SignupLastNameChanged event, Emitter<SignupState> emit) {
    final currentState = state;
    if (currentState is SignupInProgress) {
      emit(currentState.copyWith(
        data: currentState.data.copyWith(lastName: event.lastName),
        clearError: true,
      ));
    } else {
      emit(SignupInProgress(
        data: const SignupDataModel().copyWith(lastName: event.lastName),
      ));
    }
  }

  void _onEmailChanged(SignupEmailChanged event, Emitter<SignupState> emit) {
    final currentState = state;
    if (currentState is SignupInProgress) {
      emit(currentState.copyWith(
        data: currentState.data.copyWith(email: event.email),
        clearError: true,
      ));
    } else {
      emit(SignupInProgress(
        data: const SignupDataModel().copyWith(email: event.email),
      ));
    }
  }

  void _onPasswordChanged(SignupPasswordChanged event, Emitter<SignupState> emit) {
    final currentState = state;
    if (currentState is SignupInProgress) {
      emit(currentState.copyWith(
        data: currentState.data.copyWith(password: event.password),
        clearError: true,
      ));
    } else {
      emit(SignupInProgress(
        data: const SignupDataModel().copyWith(password: event.password),
      ));
    }
  }

  void _onConfirmPasswordChanged(SignupConfirmPasswordChanged event, Emitter<SignupState> emit) {
    final currentState = state;
    if (currentState is SignupInProgress) {
      emit(currentState.copyWith(
        data: currentState.data.copyWith(confirmPassword: event.confirmPassword),
        clearError: true,
      ));
    } else {
      emit(SignupInProgress(
        data: const SignupDataModel().copyWith(confirmPassword: event.confirmPassword),
      ));
    }
  }

  void _onProfilePhotoSelected(
      SignupProfilePhotoChanged event,
      Emitter<SignupState> emit,
      ) {
    final currentState = state;

    if (currentState is SignupOtpVerified) {
      emit(SignupOtpVerified(
        token: currentState.token,
        data: currentState.data.copyWith(
          profilePhoto: event.photo,
          clearPhoto: event.photo == null,
        ),
      ));
    }
    else if (currentState is SignupCompletingProfile) {
      emit(SignupCompletingProfile(
        token: currentState.token,
        data: currentState.data.copyWith(
          profilePhoto: event.photo,
          clearPhoto: event.photo == null,
        ),
      ));
    }
  }


  void _onInterestToggled(SignupInterestToggled event, Emitter<SignupState> emit) {
    final currentState = state;
    if (currentState is SignupInProgress) {
      final currentInterests = List<String>.from(currentState.data.interests);

      if (currentInterests.contains(event.interest)) {
        currentInterests.remove(event.interest);
      } else {
        currentInterests.add(event.interest);
      }

      emit(currentState.copyWith(
        data: currentState.data.copyWith(interests: currentInterests),
        clearError: true,
      ));
    } else if (currentState is SignupOtpVerified) {
      // Allow interest selection after OTP verification
      final currentInterests = List<String>.from(currentState.data.interests);

      if (currentInterests.contains(event.interest)) {
        currentInterests.remove(event.interest);
      } else {
        currentInterests.add(event.interest);
      }

      emit(SignupOtpVerified(
        data: currentState.data.copyWith(interests: currentInterests),
        token: currentState.token,
      ));
    }
  }

  void _onBioChanged(SignupBioChanged event, Emitter<SignupState> emit) {
    final currentState = state;
    if (currentState is SignupInProgress) {
      emit(currentState.copyWith(
        data: currentState.data.copyWith(bio: event.bio),
      ));
    } else if (currentState is SignupOtpVerified) {
      emit(SignupOtpVerified(
        data: currentState.data.copyWith(bio: event.bio),
        token: currentState.token,
      ));
    }
  }

  /// OTP FLOW HANDLERS

  /// Submit basic info (Step 1) and send OTP
  Future<void> _onBasicInfoSubmitted(
      SignupBasicInfoSubmitted event,
      Emitter<SignupState> emit,
      ) async {
    final currentState = state;
    if (currentState is! SignupInProgress) return;

    // Validate Step 1
    final error = currentState.data.getStep1Error();
    if (error != null) {
      emit(currentState.copyWith(validationError: error));
      return;
    }

    emit(SignupSubmittingBasicInfo(currentState.data));

    try {
      final response = await authRepository.registerAndSendOtp(
        firstName: currentState.data.firstName,
        lastName: currentState.data.lastName,
        email: currentState.data.email,
        password: currentState.data.password,
      );

      emit(SignupOtpSent(
        email: currentState.data.email,
        data: currentState.data,
        message: response['message'] ?? 'OTP sent to your email',
      ));
    } catch (e) {
      emit(SignupFailure(
        message: e.toString().replaceAll('Exception: ', ''),
        data: currentState.data,
      ));
    }
  }

  /// Update OTP as user types
  void _onOtpChanged(SignupOtpChanged event, Emitter<SignupState> emit) {
    final currentState = state;

    if (currentState is SignupOtpSent) {
      emit(SignupOtpInProgress(
        email: currentState.email,
        data: currentState.data,
        otp: event.otp,
      ));
    } else if (currentState is SignupOtpInProgress) {
      emit(currentState.copyWith(otp: event.otp, clearError: true));
    }
  }

  /// Submit OTP for verification
  Future<void> _onOtpSubmitted(
      SignupOtpSubmitted event,
      Emitter<SignupState> emit,
      ) async {
    final currentState = state;
    if (currentState is! SignupOtpInProgress) return;

    if (currentState.otp.length != 6) {
      emit(currentState.copyWith(error: 'Please enter 6-digit code'));
      return;
    }

    emit(SignupVerifyingOtp(
      email: currentState.email,
      data: currentState.data,
      otp: currentState.otp,
    ));

    try {
      final response = await authRepository.verifyOtp(
        email: currentState.email,
        otp: currentState.otp,
      );

      final token = response['token'] as String?;
      if (token == null) {
        throw Exception('No token received from backend');
      }
      await authRepository.persistToken(token);
      // OTP verified successfully - move to interests & bio
      emit(SignupOtpVerified(
        data: currentState.data,
        token: token,
      ));
    } catch (e) {
      emit(SignupOtpInProgress(
        email: currentState.email,
        data: currentState.data,
        otp: currentState.otp,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// Resend OTP
  Future<void> _onOtpResendRequested(
      SignupOtpResendRequested event,
      Emitter<SignupState> emit,
      ) async {
    final currentState = state;

    String email;
    SignupDataModel data;

    if (currentState is SignupOtpSent) {
      email = currentState.email;
      data = currentState.data;
    } else if (currentState is SignupOtpInProgress) {
      email = currentState.email;
      data = currentState.data;
    } else {
      return;
    }

    try {
      final response = await authRepository.resendOtp(email: email);

      emit(SignupOtpSent(
        email: email,
        data: data,
        message: response['message'] ?? 'OTP resent successfully',
      ));
    } catch (e) {
      emit(SignupFailure(
        message: 'Failed to resend OTP: ${e.toString()}',
        data: data,
      ));
    }
  }

  /// Complete profile (interests + bio) after OTP verification
  Future<void> _onProfileCompleted(
      SignupProfileCompleted event,
      Emitter<SignupState> emit,
      ) async {
    final currentState = state;
    if (currentState is! SignupOtpVerified) return;

    // Validate interests
    final error = currentState.data.getStep3Error();
    if (error != null) {
      emit(SignupFailure(
        message: error,
        data: currentState.data,
      ));
      // Re-emit verified state so user can fix and retry
      await Future.delayed(const Duration(milliseconds: 500));
      emit(SignupOtpVerified(
        data: currentState.data,
        token: currentState.token,
      ));
      return;
    }

    emit(SignupCompletingProfile(
      data: currentState.data,
      token: currentState.token,
    ));

    try {
      await authRepository.completeProfile(
        token: currentState.token,
        interests: currentState.data.interests,
        bio: currentState.data.bio,
        profilePhoto: currentState.data.profilePhoto,
      );

      final user = await authRepository.getCurrentUser();

      authBloc.add(
        SignupAuthenticated(user),
      );
      // Profile completed successfully
      emit(SignupCompleted(
        token: currentState.token,
        data: currentState.data,
      ));
    } catch (e) {
      emit(SignupFailure(
        message: e.toString().replaceAll('Exception: ', ''),
        data: currentState.data,
      ));
      // Re-emit verified state so user can retry
      await Future.delayed(const Duration(milliseconds: 500));
      emit(SignupOtpVerified(
        data: currentState.data,
        token: currentState.token,
      ));
    }
  }
}