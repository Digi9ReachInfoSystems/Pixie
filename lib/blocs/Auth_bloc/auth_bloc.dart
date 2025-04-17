import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pixieapp/repositories/authModel.dart';
import 'package:pixieapp/widgets/analytics.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth;

  String loginResult = '';
  Authmodel authModel = Authmodel();
  UserCredential? userCredential;
  AuthBloc(this._firebaseAuth) : super(AuthInitial()) {
    on<AuthEmailSignInRequested>(_onEmailSignInRequested);
    on<AuthEmailSignUpRequested>(_onEmailSignUpRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthLogOutRequested>(_onLogOutRequested);
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthCheckAuthState>(_onCheckAuthState);
    on<TogglePasswordVisibilityEvent>(_onAuthShowPassword);
    on<AuthAppleSignInRequested>(_onAppleSignInRequested);
    on<SendOtpToPhoneEvent>((event, emit) async {
      emit(AuthLoading());

      try {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: event.phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) {
            if (!isClosed) {
              add(OnPhoneAuthVerificationCompletedEvent(
                  credential: credential));
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            if (!isClosed) {
              add(OnPhoneAuthErrorEvent(error: e.toString()));
            }
          },
          codeSent: (String verificationId, int? resendToken) {
            if (!isClosed) {
              add(OnPhoneOtpSend(
                  verificationId: verificationId, token: resendToken ?? 0));
            }
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            debugPrint("Code auto-retrieval timed out for $verificationId");
          },
          timeout: Duration.zero,
        );
      } catch (e) {
        emit(LoginScreenErrorState(error: e.toString()));
      }
    });

    on<OnPhoneOtpSend>((event, emit) {
      emit(PhoneAuthCodeSentSuccess(verificationId: event.verificationId));
    });

    on<VerifySentOtp>((event, emit) {
      try {
        emit(AuthLoading());
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: event.verificationId,
          smsCode: event.otpCode,
        );
        if (!isClosed) {
          add(OnPhoneAuthVerificationCompletedEvent(credential: credential));
        }
      } catch (e) {
        emit(LoginScreenErrorState(error: e.toString()));
      }
    });

    on<OnPhoneAuthErrorEvent>((event, emit) {
      emit(LoginScreenErrorState(error: event.error.toString()));
    });

    on<OnPhoneAuthVerificationCompletedEvent>((event, emit) async {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(event.credential);

        String userId = userCredential.user!.uid;
        String? phone = userCredential.user!.phoneNumber;
        String? displayName = userCredential.user!.displayName;
        String? photoURL = userCredential.user!.photoURL;

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        AnalyticsService.logFirebaseAuthEvent(
            userCredential.user, 'phone_auth');
        if (!userDoc.exists) {
          await FirebaseFirestore.instance.collection('users').doc(userId).set({
            'phone': phone,
            'createdAt': DateTime.now(),
            'userId': userId,
            'displayName': displayName,
            'child_name': '',
            'gender': '',
            'fav_things': [],
            'dob': DateTime.now(),
            'loved_once': [],
            'moreLovedOnes': [],
            'photoURL': photoURL,
            'newUser': true,
          });
        }
        emit(AuthAuthenticated(userId: userId));
      } catch (e) {
        emit(LoginScreenErrorState(error: e.toString()));
      }
    });

    // New handler for guest login event
    on<AuthGuestLoginRequested>((event, emit) {
      emit(AuthGuest());
    });
    on<AuthGuestcreateaccountRequested>((event, emit) {
      emit(AuthGuestcreateaccount());
    });
  }

  Future<void> _onCheckAuthState(
      AuthCheckAuthState event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      _firebaseAuth.authStateChanges().listen((User? user) {
        if (emit.isDone) return;
        if (user != null) {
          emit(AuthAuthenticated(userId: user.uid));
        } else {
          emit(AuthUnauthenticated());
        }
      });
    } catch (e) {
      if (!emit.isDone) {
        emit(AuthError(
            message: 'Error checking authentication state: ${e.toString()}'));
      }
    }
  }

  Future<void> _onEmailSignInRequested(
      AuthEmailSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(userId: userCredential.user!.uid));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onEmailSignUpRequested(
      AuthEmailSignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      String userId = userCredential.user!.uid;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      AnalyticsService.logFirebaseAuthEvent(
          userCredential.user, 'email_sign_up');
      if (!userDoc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'email': event.email,
          'phone': '',
          'createdAt': DateTime.now(),
          'userId': userId,
          'child_name': '',
          'gender': '',
          'fav_things': [],
          'dob': DateTime.now(),
          'loved_once': [],
          'moreLovedOnes': [],
          'displayName': "displayName",
          'photoURL': "photoURL",
          'newUser': true
        });
      }
      emit(AuthAuthenticated(userId: userId));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAppleSignInRequested(
      AuthAppleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      // Step 1: Perform Apple Sign-In
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Step 2: Create OAuth credential for Firebase
      final oAuthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Step 3: Sign in to Firebase
      final userCredential =
          await _firebaseAuth.signInWithCredential(oAuthCredential);

      String userId = userCredential.user!.uid;
      String? email = userCredential.user!.email;
      String? displayName = appleCredential.givenName != null &&
              appleCredential.familyName != null
          ? '${appleCredential.givenName} ${appleCredential.familyName}'
          : userCredential.user!.displayName;
      String? photoURL = userCredential.user!.photoURL;

      // Step 4: Check and save user data in Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      AnalyticsService.logFirebaseAuthEvent(
          userCredential.user, 'apple_sign_up');
      if (!userDoc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'email': email,
          'displayName': displayName ?? "Apple User",
          'photoURL': photoURL,
          'createdAt': DateTime.now(),
          'userId': userId,
          'child_name': '',
          'gender': '',
          'fav_things': [],
          'dob': DateTime.now(),
          'loved_once': [],
          'moreLovedOnes': [],
          'newUser': true
        });
      }

      emit(AuthAuthenticated(userId: userId));
    } catch (e) {
      emit(AuthAppleSignInError(
          message: 'Apple Sign-In Failed: ${e.toString()}'));
      debugPrint('Apple Sign-In Failed: $e');
      emit(AuthAppleSignInError(message: 'Apple Sign-In Failed: $e'));
    }
  }

  Future<void> _onGoogleSignInRequested(
      AuthGoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        emit(AuthError(message: 'Google sign-in aborted.'));
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        emit(
            AuthError(message: 'Google authentication failed: missing token.'));
        return;
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      String userId = userCredential.user!.uid;
      String? email = userCredential.user!.email;
      String? displayName = userCredential.user!.displayName;
      String? photoURL = userCredential.user!.photoURL;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      AnalyticsService.logFirebaseAuthEvent(
          userCredential.user, 'google_sign_up');
      if (!userDoc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'email': email,
          'phone': '',
          'displayName': displayName,
          'child_name': '',
          'gender': '',
          'fav_things': [],
          'dob': DateTime.now(),
          'loved_once': [],
          'moreLovedOnes': [],
          'photoURL': photoURL,
          'createdAt': DateTime.now(),
          'userId': userId,
          'newUser': true
        });
      }

      emit(AuthAuthenticated(userId: userId));
    } on PlatformException catch (e) {
      print(e);
      emit(AuthError(message: 'PlatformException: ${e.message}'));
    } catch (e) {
      emit(AuthError(message: 'Google Sign-In Failed: ${e.toString()}'));
    }
  }

  Future<void> _onLogOutRequested(
      AuthLogOutRequested event, Emitter<AuthState> emit) async {
    await _firebaseAuth.signOut();
    emit(AuthUnauthenticated());
  }

  Future<void> _onCheckStatus(
      AuthCheckStatus event, Emitter<AuthState> emit) async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(userId: user.uid));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthShowPassword(
      TogglePasswordVisibilityEvent event, Emitter<AuthState> emit) async {
    final currentVisibility = state is PasswordVisibilityState
        ? (state as PasswordVisibilityState).isPasswordVisible
        : false;
    emit(PasswordVisibilityState(!currentVisibility));
  }
}
