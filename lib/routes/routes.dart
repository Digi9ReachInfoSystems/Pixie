import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pixieapp/blocs/Auth_bloc/auth_bloc.dart';
import 'package:pixieapp/blocs/Auth_bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pixieapp/models/story_model.dart';
import 'package:pixieapp/pages/AddCharacter.dart/add_character.dart';
import 'package:pixieapp/pages/AllStories/all_stories.dart';
import 'package:pixieapp/pages/CreateAccount/createaccount.dart';
import 'package:pixieapp/pages/CreateAccount/login_with_phone.dart';
import 'package:pixieapp/pages/CreateAccountWithMail/create_account_with_email.dart';
import 'package:pixieapp/pages/FirebaseStory/firebasestory.dart';
import 'package:pixieapp/pages/FirebaseStory/firebasestorylibrary.dart';
import 'package:pixieapp/pages/Firebase_suggested_story.dart/suggested_strory.dart';
import 'package:pixieapp/pages/IntroductionPages/introduction_pages.dart';
import 'package:pixieapp/pages/Library/Library.dart';
import 'package:pixieapp/pages/Otp_Verification/otp_verification.dart';
import 'package:pixieapp/pages/SearchStories/search_page.dart';
import 'package:pixieapp/pages/SettingsPage/about.dart';
import 'package:pixieapp/pages/SettingsPage/feedback.dart';
import 'package:pixieapp/pages/SettingsPage/profile_page.dart';
import 'package:pixieapp/pages/SettingsPage/settings_page.dart';
import 'package:pixieapp/pages/SplashScreen/splash_screen.dart';
import 'package:pixieapp/pages/SplashScreen/story_confirmtion_page.dart';
import 'package:pixieapp/pages/audioPlay/audioplay_page.dart';
import 'package:pixieapp/pages/createStory/createStory_page.dart';
import 'package:pixieapp/pages/error%20page/error_page.dart';
import 'package:pixieapp/pages/login_page/login_page.dart';
import 'package:pixieapp/pages/onboardingPages/onboarding_page.dart';
import 'package:pixieapp/pages/questions_intro_page.dart';
import 'package:pixieapp/pages/storygenerate/storygenerate.dart';
import 'package:pixieapp/widgets/loading_widget.dart';
import 'package:pixieapp/pages/home/home_page.dart' as home;

bool isUserAuthenticated(BuildContext context) {
  final authState = context.read<AuthBloc>().state;
  return authState is AuthAuthenticated || authState is AuthGuest;
}

bool isAuthStateChecked(BuildContext context) {
  final authState = context.read<AuthBloc>().state;
  return authState is! AuthInitial;
}

Future<bool> checkIfNewUser(String userId) async {
  try {
    print("11111");
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    print("2222222");
    if (userDoc.exists) {
      var userData = userDoc.data() as Map<String, dynamic>;
      print("userData['newUser']");
      return userData['newUser'] ?? true;
    }
  } catch (e) {
    print('Error checking Firestore user: $e');
  }
  return true;
}

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        final authState = context.watch<AuthBloc>().state;

        if (authState is AuthInitial) {
          return const SplashScreen();
        } else if (authState is AuthAuthenticated || authState is AuthGuest) {
          final userId =
              authState is AuthAuthenticated ? authState.userId : null;
          return FutureBuilder<bool>(
            future:
                userId != null ? checkIfNewUser(userId) : Future.value(true),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingWidget();
              } else if (snapshot.hasError) {
                return const ErrorPage();
              } else if (snapshot.hasData && snapshot.data == true) {
                return const QuestionsIntroPage();
              } else {
                return const home.HomePage();
              }
            },
          );
        } else if (authState is SignUpScreenOtpSuccessState) {
          return const home.HomePage();
        } else {
          return const OnboardingPage();
        }
      },
    ),
    GoRoute(
      path: '/OtpVerification/:verificationId',
      builder: (BuildContext context, GoRouterState state) {
        final verificationId = state.pathParameters['verificationId']!;
        return OtpVerification(verificationId: verificationId);
      },
    ),
    GoRoute(
        path: '/CreateStoryPage',
        builder: (context, state) {
          final storydata = state.extra as StoryModal;
          return const CreateStoryPage();
        }),
    GoRoute(
      path: '/AddCharacter',
      pageBuilder: (context, state) {
        return const NoTransitionPage(
          child: AddCharacter(),
        );
      },
    ),
    GoRoute(
      path: '/AudioplayPage',
      builder: (context, state) => const AudioplayPage(),
    ),
    GoRoute(
      path: '/CreateAccount',
      builder: (context, state) {
        final String title = state.extra as String;
        return CreateAccount(title: title);
      },
    ),
    GoRoute(
      path: '/loginwithphone',
      builder: (context, state) {
        return const Loginwithphone();
      },
    ),
    GoRoute(
      path: '/Loginpage',
      builder: (context, state) => const Loginpage(),
    ),
    GoRoute(
      path: '/CreateAccountWithEmail',
      builder: (context, state) => const CreateAccountWithEmail(),
    ),
    GoRoute(
      path: '/StoryGeneratePage',
      builder: (context, state) {
        final story = state.extra as Map<String, String>;
        final storytype = state.uri.queryParameters['storytype'];
        final language = state.uri.queryParameters['language'] ?? 'English';
        final genre = state.uri.queryParameters['genre'] ?? "Funny";

        return StoryGeneratePage(
          story: story,
          storytype: storytype!,
          language: language,
          genre: genre,
        );
      },
    ),
    GoRoute(
      path: '/HomePage',
      pageBuilder: (context, state) {
        return const NoTransitionPage(
          child: home.HomePage(),
        );
      },
    ),
    GoRoute(
      path: '/Library',
      pageBuilder: (context, state) {
        return const NoTransitionPage(
          child: Library(),
        );
      },
    ),
    GoRoute(
      path: '/AllStories',
      builder: (context, state) => const AllStories(),
    ),
    GoRoute(
      path: '/searchPage',
      builder: (context, state) => const SearchPage(),
    ),
    GoRoute(
      path: '/questionIntroPage',
      builder: (context, state) => const QuestionsIntroPage(),
    ),
    GoRoute(
      path: '/introductionPages',
      builder: (context, state) => const IntroductionPage(),
    ),
    GoRoute(
      path: '/splashScreen',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/storyconfirmationstory',
      builder: (context, state) => const StoryConfirmationPage(),
    ),
    GoRoute(
      path: '/profilePage',
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: '/feedbackPage',
      builder: (context, state) => const FeedbackPage(),
    ),
    GoRoute(
      path: '/SettingsPage',
      pageBuilder: (context, state) {
        return const NoTransitionPage(
          child: SettingsPage(),
        );
      },
    ),
    GoRoute(
      path: '/aboutPage',
      builder: (context, state) => const AboutPage(),
    ),
    GoRoute(
      path: '/Firebasestory',
      builder: (context, state) {
        final storyDocRef = state.extra as DocumentReference<Object?>;
        return Firebasestory(storyDocRef: storyDocRef);
      },
    ),
    GoRoute(
      path: '/Firebasestorylibrary',
      builder: (context, state) {
        final storyDocRef = state.extra as DocumentReference<Object?>;
        return Firebasestorylibrary(storyDocRef: storyDocRef);
      },
    ),
    GoRoute(
      path: '/Firebasesuggestedstory',
      builder: (context, state) {
        final storyDocRef = state.extra as DocumentReference<Object?>;
        return Firebasesuggestedstory(storyDocRef: storyDocRef);
      },
    ),
    GoRoute(
      path: '/Firebasestory1',
      builder: (context, state) {
        final storyDocRef = state.extra as DocumentReference<Object?>;
        return Firebasestory(storyDocRef: storyDocRef);
      },
      pageBuilder: (context, state) {
        // Return a CustomTransitionPage with no animation
        return CustomTransitionPage(
          child: Firebasestory(
            storyDocRef: state.extra as DocumentReference<Object?>,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // No animation, just return the child immediately
            return child;
          },
        );
      },
    ),
  ],
  redirect: (context, state) {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthInitial) {
      return '/';
    }

    final isLoggedIn =
        authState is AuthAuthenticated || state is AuthAppleSignInSuccess;
    final isGuest = authState is AuthGuest;
    final isOnLoginPage =
        state.uri.toString() == '/Loginpage' || state.uri.toString() == '/';

    // Allow guests to access login/signup pages
    if (isGuest && isOnLoginPage) {
      return null; // No redirection needed
    }

    // Redirect logged-in users trying to access login/signup pages to the home page
    if (isLoggedIn && isOnLoginPage) {
      return '/HomePage';
    }

    // Define protected routes that require authentication
    final protectedRoutes = [
      // '/HomePage',
      '/Library',
      '/AddCharacter',
      "/feedbackPage",
      '/profilePage'
    ];

    // Redirect unauthenticated users trying to access protected routes
    if (!isLoggedIn && protectedRoutes.contains(state.uri.toString())) {
      return '/Loginpage';
    }

    return null; // No redirection needed
  },
);
