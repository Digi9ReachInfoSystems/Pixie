abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String userId;

  AuthAuthenticated({required this.userId});
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});
}

class LoginScreenLoadingState extends AuthState {}

class LoginScreenInitialState extends AuthState {}

class LoginScreenLoadedState extends AuthState {}

class LoginScreenErrorState extends AuthState {
  String error;
  LoginScreenErrorState({
    required this.error,
  });
}

class PhoneAuthCodeSentSuccess extends AuthState {
  final String verificationId;

  PhoneAuthCodeSentSuccess({required this.verificationId});
}

class SignUpScreenOtpSuccessState extends AuthState {}

class PasswordVisibilityState extends AuthState {
  final bool isPasswordVisible;

  PasswordVisibilityState(this.isPasswordVisible);
}

class AuthAppleSignInSuccess extends AuthState {
  final String userId;
  AuthAppleSignInSuccess({required this.userId});
}

class AuthAppleSignInError extends AuthState {
  final String message;
  AuthAppleSignInError({required this.message});
}

// New State for Guest Login
class AuthGuest extends AuthState {}

class AuthGuestcreateaccount extends AuthState {}
