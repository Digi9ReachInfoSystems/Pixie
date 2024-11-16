import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pixieapp/blocs/AudioBloc/audio_bloc.dart';
import 'package:pixieapp/blocs/Auth_bloc/auth_bloc.dart';
import 'package:pixieapp/blocs/Auth_bloc/auth_event.dart';
import 'package:pixieapp/blocs/Feedback/feedback_bloc.dart';
import 'package:pixieapp/blocs/Library_bloc/library_bloc.dart';
import 'package:pixieapp/blocs/Loading%20Navbar/loadingnavbar_bloc.dart';
import 'package:pixieapp/blocs/Loading%20Navbar/loadingnavbar_event.dart';
import 'package:pixieapp/blocs/Navbar_Bloc/navbar_bloc.dart';
import 'package:pixieapp/blocs/StoryFeedback/story_feedback_bloc.dart';
import 'package:pixieapp/blocs/Story_bloc/story_bloc.dart';
import 'package:pixieapp/blocs/add_character_Bloc.dart/add_character_bloc.dart';
import 'package:pixieapp/blocs/bottom_nav_bloc/bottom_nav_bloc.dart';
import 'package:pixieapp/blocs/introduction/introduction_bloc.dart';
import 'package:pixieapp/const/textstyle.dart';
import 'package:pixieapp/firebase_options.dart';
import 'package:pixieapp/repositories/library_repository.dart';
import 'package:pixieapp/repositories/story_repository.dart';
import 'package:pixieapp/routes/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GoRouter _router = router; // Initialize the router instance

  @override
  void initState() {
    super.initState();
    // Handle dynamic links on startup
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) =>
              AuthBloc(FirebaseAuth.instance)..add(AuthCheckAuthState()),
        ),
        BlocProvider<NavBarBloc>(
          create: (_) => NavBarBloc(),
        ),
        BlocProvider<AddCharacterBloc>(
          create: (_) => AddCharacterBloc(),
        ),
        BlocProvider<StoryBloc>(
          create: (_) => StoryBloc(storyRepository: StoryRepository()),
        ),
        BlocProvider<IntroductionBloc>(
          create: (_) => IntroductionBloc(),
        ),
        BlocProvider(
          create: (context) => FetchStoryBloc(FetchStoryRepository1()),
        ),
        BlocProvider(
          create: (context) => FeedbackBloc(),
        ),
        BlocProvider(
          create: (context) =>
              AudioBloc(AudioPlayer()), // Pass the AudioPlayer instance
        ),
        BlocProvider(
          create: (context) =>
              StoryFeedbackBloc(), // Pass the AudioPlayer instance
        ),
        BlocProvider(
          create: (context) => LoadingNavbarBloc()
            ..add(StartLoadingNavbarEvent()), // Pass the AudioPlayer instance
        ),
      ],
      child: MaterialApp.router(
        routerConfig: _router, // Use the router here
        debugShowCheckedModeBanner: false,
        title: 'Pixie App',
        theme: appTheme(context),
      ),
    );
  }
}
//   void handleDynamicLinks() async {
//     // For initial dynamic link when the app is opened through the link
//     final PendingDynamicLinkData? initialLink =
//         await FirebaseDynamicLinks.instance.getInitialLink();

//     if (initialLink != null) {
//       final Uri deepLink = initialLink.link;
//       _handleDeepLink(deepLink);
//     }

//     // For when the app is already opened and a new link is clicked
//     FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
//       _handleDeepLink(dynamicLinkData.link);
//     }).onError((error) {
//       print('Dynamic Link Failed: $error');
//     });
//   }

//   void _handleDeepLink(Uri link) {
//     if (link.queryParameters.containsKey('id')) {
//       final storyId = link.queryParameters['id'];
//       if (storyId != null) {
//         // Use GoRouter to navigate to the story details page with the storyId
//         _router.go('/storyDetails', extra: storyId);
//       }
//     }
//   }
// }
