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
import 'package:pixieapp/blocs/introduction/introduction_bloc.dart';
import 'package:pixieapp/const/textstyle.dart';
import 'package:pixieapp/firebase_options.dart';
import 'package:pixieapp/repositories/library_repository.dart';
import 'package:pixieapp/repositories/story_repository.dart';
import 'package:pixieapp/routes/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('11111');
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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
    requestNotificationPermissions();
    super.initState();
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

void requestNotificationPermissions() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  // Process your data here
}
