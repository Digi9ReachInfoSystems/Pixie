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
import 'package:pixieapp/pages/CreateAccountWithMail/create_account_with_email.dart';
import 'package:pixieapp/pages/FirebaseStory/firebasestory.dart';
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
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      var userData = userDoc.data() as Map<String, dynamic>;
      return userData['newUser'] ?? false;
    }
  } catch (e) {
    print('Error checking Firestore user: $e');
  }
  return false;
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
                userId != null ? checkIfNewUser(userId) : Future.value(false),
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
      builder: (context, state) => const CreateAccount(),
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

        return StoryGeneratePage(
          story: story,
          storytype: storytype!,
          language: language,
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
      path: '/Firebasesuggestedstory',
      builder: (context, state) {
        final storyDocRef = state.extra as DocumentReference<Object?>;
        return Firebasesuggestedstory(storyDocRef: storyDocRef);
      },
    ),
  ],
  redirect: (context, state) {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthInitial) {
      return '/';
    }

    final loggedIn = authState is AuthAuthenticated || authState is AuthGuest;
    final loggingIn =
        state.uri.toString() == '/' || state.uri.toString() == '/Loginpage';

    if (loggedIn && loggingIn) {
      return '/HomePage';
    }

    final protectedRoutes = [
      '/HomePage',
      '/Library',
      '/SettingsPage',
    ];

    if (!loggedIn && protectedRoutes.contains(state.uri.toString())) {
      return '/';
    }

    return null;
  },
);
