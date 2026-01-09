import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class SignupEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Update individual fields in Step 1
class SignupFirstNameChanged extends SignupEvent {
  final String firstName;
  SignupFirstNameChanged(this.firstName);

  @override
  List<Object?> get props => [firstName];
}

class SignupLastNameChanged extends SignupEvent {
  final String lastName;
  SignupLastNameChanged(this.lastName);

  @override
  List<Object?> get props => [lastName];
}

class SignupEmailChanged extends SignupEvent {
  final String email;
  SignupEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

class SignupPasswordChanged extends SignupEvent {
  final String password;
  SignupPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class SignupConfirmPasswordChanged extends SignupEvent {
  final String confirmPassword;
  SignupConfirmPasswordChanged(this.confirmPassword);

  @override
  List<Object?> get props => [confirmPassword];
}

class SignupProfilePhotoChanged extends SignupEvent {
  final File? photo;
  SignupProfilePhotoChanged(this.photo);

  @override
  List<Object?> get props => [photo];
}

/// Update fields in Step 3 (Interests & Bio)
class SignupInterestToggled extends SignupEvent {
  final String interest;
  SignupInterestToggled(this.interest);

  @override
  List<Object?> get props => [interest];
}

class SignupBioChanged extends SignupEvent {
  final String bio;
  SignupBioChanged(this.bio);

  @override
  List<Object?> get props => [bio];
}

/// Submit basic info (Step 1) - sends OTP email
class SignupBasicInfoSubmitted extends SignupEvent {
  // Triggered when user taps "Continue" on Step 1
  // Backend sends OTP to email
}

/// OTP entered by user
class SignupOtpChanged extends SignupEvent {
  final String otp;
  SignupOtpChanged(this.otp);

  @override
  List<Object?> get props => [otp];
}

/// Submit OTP for verification
class SignupOtpSubmitted extends SignupEvent {
  // Triggered when user submits 6-digit OTP
  // Backend validates OTP and returns JWT
}

/// Resend OTP
class SignupOtpResendRequested extends SignupEvent {
  // Triggered when user taps "Resend OTP"
}

/// Complete profile after OTP verification (Step 3)
class SignupProfileCompleted extends SignupEvent {
  // Triggered when user taps "Complete Signup" on Step 3
  // Sends interests and bio with JWT to backend
}

/// Reset signup flow
class SignupReset extends SignupEvent {}