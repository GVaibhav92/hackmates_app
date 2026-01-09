import 'package:equatable/equatable.dart';
import 'package:hackmates_app/features/auth/models/signup_data_model.dart';

abstract class SignupState extends Equatable {
  const SignupState();

  @override
  List<Object?> get props => [];
}

/// Initial state when signup flow begins
class SignupInitial extends SignupState {
  const SignupInitial();
}

/// User is filling out Step 1 (basic info)
class SignupInProgress extends SignupState {
  final SignupDataModel data;
  final String? validationError;

  const SignupInProgress({
    required this.data,
    this.validationError,
  });

  @override
  List<Object?> get props => [data, validationError];

  SignupInProgress copyWith({
    SignupDataModel? data,
    String? validationError,
    bool clearError = false,
  }) {
    return SignupInProgress(
      data: data ?? this.data,
      validationError: clearError ? null : (validationError ?? this.validationError),
    );
  }
}

/// Submitting basic info (Step 1) to backend
class SignupSubmittingBasicInfo extends SignupState {
  final SignupDataModel data;

  const SignupSubmittingBasicInfo(this.data);

  @override
  List<Object?> get props => [data];
}

/// OTP sent to email, waiting for user to enter it
class SignupOtpSent extends SignupState {
  final String email;
  final SignupDataModel data;
  final String message;

  const SignupOtpSent({
    required this.email,
    required this.data,
    this.message = 'OTP sent to your email',
  });

  @override
  List<Object?> get props => [email, data, message];
}

/// User is entering OTP
class SignupOtpInProgress extends SignupState {
  final String email;
  final SignupDataModel data;
  final String otp;
  final String? error;

  const SignupOtpInProgress({
    required this.email,
    required this.data,
    required this.otp,
    this.error,
  });

  @override
  List<Object?> get props => [email, data, otp, error];

  SignupOtpInProgress copyWith({
    String? otp,
    String? error,
    bool clearError = false,
  }) {
    return SignupOtpInProgress(
      email: email,
      data: data,
      otp: otp ?? this.otp,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Verifying OTP with backend
class SignupVerifyingOtp extends SignupState {
  final String email;
  final SignupDataModel data;
  final String otp;

  const SignupVerifyingOtp({
    required this.email,
    required this.data,
    required this.otp,
  });

  @override
  List<Object?> get props => [email, data, otp];
}

/// OTP verified successfully, ready for Step 3 (interests & bio)
class SignupOtpVerified extends SignupState {
  final SignupDataModel data;
  final String token; // JWT token from OTP verification (stored in memory)

  const SignupOtpVerified({
    required this.data,
    required this.token,
  });

  @override
  List<Object?> get props => [data, token];
}


/// Completing profile (Step 3) - sending interests & bio
class SignupCompletingProfile extends SignupState {
  final SignupDataModel data;
  final String token;

  const SignupCompletingProfile({
    required this.data,
    required this.token,
  });

  @override
  List<Object?> get props => [data, token];
}

/// Signup completed successfully
class SignupCompleted extends SignupState {
  final String token;
  final SignupDataModel data;

  const SignupCompleted({
    required this.token,
    required this.data,
  });

  @override
  List<Object?> get props => [token, data];
}

/// Signup failed with error
class SignupFailure extends SignupState {
  final String message;
  final SignupDataModel? data; // Preserve data so user doesn't lose input

  const SignupFailure({
    required this.message,
    this.data,
  });

  @override
  List<Object?> get props => [message, data];
}