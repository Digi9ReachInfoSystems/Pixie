import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pixieapp/blocs/Auth_bloc/auth_bloc.dart';
import 'package:pixieapp/blocs/Auth_bloc/auth_event.dart';
import 'package:pixieapp/blocs/Auth_bloc/auth_state.dart';
import 'package:pixieapp/blocs/Navbar_Bloc/navbar_bloc.dart';
import 'package:pixieapp/blocs/Navbar_Bloc/navbar_event.dart';
import 'package:pixieapp/blocs/StoryFeedback/story_feedback_bloc.dart';
import 'package:pixieapp/blocs/StoryFeedback/story_feedback_event.dart';
import 'package:pixieapp/blocs/add_character_Bloc.dart/add_character_bloc.dart';
import 'package:pixieapp/blocs/add_character_Bloc.dart/add_character_event.dart';
import 'package:pixieapp/const/colors.dart';
import 'package:pixieapp/widgets/analytics.dart';
import 'package:pixieapp/widgets/loading_widget.dart';
import 'package:pixieapp/widgets/navbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String childName = "child_name"; // Default placeholder
  bool NewUser = true;

  @override
  void initState() {
    super.initState();
    _CheckNewUser();
    _fetchChildName();
    AnalyticsService.logScreenView(
      screenName: '/HomePage',
      screenClass: 'Home Screen',
    );
  }

  // Fetch the authenticated user's child name from Firebase
  Future<void> _fetchChildName() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            childName = userDoc.data()?['child_name'] ?? "child_name";
          });
        }
      }
    } catch (e) {
      print('Error fetching child name: $e');
    }
  }

  Future<void> _CheckNewUser() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            NewUser = userDoc.data()?['newUser'];
          });
        }

        if (NewUser) {
          context.go('/questionIntroPage');
        }
      } else {
        setState(() {
          NewUser = false;
        });
      }
    } catch (e) {
      print('Error fetching child name: $e');
    }
  }

  Future<List<DocumentSnapshot>> _fetchStories() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    // Fetch stories without orderBy, just filter by user_ref
    final snapshot = await FirebaseFirestore.instance
        .collection('fav_stories')
        .where('user_ref', isEqualTo: userRef)
        .get();

    // Manually sort the fetched documents by createdTime in descending order
    final List<DocumentSnapshot> sortedDocs = snapshot.docs.toList()
      ..sort((a, b) {
        // Extract 'createdTime' from documents and compare them
        final aTime = a['createdTime'] as Timestamp?;
        final bTime = b['createdTime'] as Timestamp?;

        if (aTime == null || bTime == null) {
          return 0; // if 'createdTime' is null, treat as equal
        }

        return bTime.compareTo(aTime); // Descending order (most recent first)
      });

    return sortedDocs;
  }

  // Fetch the list of suggested stories from Firebase
  Future<List<DocumentSnapshot>> _fetchSuggestedStories() async {
    return FirebaseFirestore.instance.collection('Suggestedstories').get().then(
          (snapshot) => snapshot.docs,
        );
  }

  // Replace 'child_name' dynamically in the story based on the language
  String formatText(String text, String language) {
    if (language.toLowerCase() == 'hindi') {
      return text.replaceAll(
          'child_name', 'रियो'); // Replace with "राम" in Hindi
    }
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthGuest) {
      // If guest, default name
      return text.replaceAll('child_name', 'Rio');
    }
    print(text.replaceAll('child_name', childName));
    return text.replaceAll('child_name', childName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return NewUser == true
        ? Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xffead4f9),
                  Color(0xfff7f1d1),
                ],
              ),
            ),
            height: double.infinity,
            width: double.infinity,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [Expanded(child: LoadingWidget()), NavBar()],
            ),
          )
        : Scaffold(
            backgroundColor: const Color(0xfff9f3cd),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xffead4f9),
                    Color(0xfff7f1d1),
                  ],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: PopScope(
                    canPop: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context, width),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Stories you created',
                            style: theme.textTheme.headlineLarge!.copyWith(
                                color: AppColors.textColorblue,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(height: 20),
                        FutureBuilder<List<DocumentSnapshot>>(
                            future: _fetchStories(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(child: LoadingWidget());
                              }

                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return SizedBox(
                                    height: height * .21,
                                    child: const Center(
                                        child: Text('No stories found')));
                              }

                              List<DocumentSnapshot> stories = snapshot.data!;

                              return Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: SizedBox(
                                  height: height * .21,
                                  width: width,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 15),
                                            child: ListView.builder(
                                              itemCount: stories.length > 10
                                                  ? 11
                                                  : stories
                                                      .length, // Display 5 stories + 1 extra slot if > 5
                                              scrollDirection: Axis.horizontal,
                                              itemBuilder: (context, index) {
                                                if (index == 10) {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      // Open dialog to display all stories
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            title: const Text(
                                                                'All Stories'),
                                                            content: SizedBox(
                                                              height:
                                                                  300, // Adjust height as needed
                                                              child: ListView
                                                                  .builder(
                                                                itemCount:
                                                                    stories
                                                                        .length,
                                                                itemBuilder:
                                                                    (context,
                                                                        index) {
                                                                  DocumentSnapshot
                                                                      storyDoc =
                                                                      stories[
                                                                          index];
                                                                  Map<String,
                                                                          dynamic>
                                                                      storyData =
                                                                      storyDoc.data() as Map<
                                                                          String,
                                                                          dynamic>;

                                                                  return ListTile(
                                                                    title: Text(
                                                                        storyData['title'] ??
                                                                            'No Title'),
                                                                    onTap: () {
                                                                      Navigator.pop(
                                                                          context); // Close dialog
                                                                      context.push(
                                                                          '/Firebasestory',
                                                                          extra:
                                                                              storyDoc.reference);
                                                                    },
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context); // Close dialog
                                                                },
                                                                child:
                                                                    const Text(
                                                                        'Close'),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: InkWell(
                                                      onTap: () {
                                                        context.go('/Library');
                                                        context
                                                            .read<NavBarBloc>()
                                                            .add(
                                                                const NavBarItemTapped(
                                                                    2));
                                                      },
                                                      child: Container(
                                                        margin: const EdgeInsets
                                                            .only(
                                                            right: 15, left: 0),
                                                        decoration:
                                                            const BoxDecoration(
                                                                color: AppColors
                                                                    .kwhiteColor,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          5),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          5),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          26),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          26),
                                                                )),
                                                        child: Center(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        20),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                IconButton(
                                                                    onPressed:
                                                                        () {
                                                                      context.go(
                                                                          '/Library');
                                                                      context
                                                                          .read<
                                                                              NavBarBloc>()
                                                                          .add(const NavBarItemTapped(
                                                                              2));
                                                                    },
                                                                    icon:
                                                                        const Icon(
                                                                      Icons
                                                                          .arrow_forward_ios_rounded,
                                                                      color: AppColors
                                                                          .textColorblue,
                                                                    )),
                                                                const SizedBox(
                                                                    height: 10),
                                                                Text('View all',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: theme
                                                                        .textTheme
                                                                        .bodyMedium!
                                                                        .copyWith(
                                                                      color: AppColors
                                                                          .textColorblue,
                                                                    )),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }

                                                // suggested stories
                                                DocumentSnapshot storyDoc =
                                                    stories[index];
                                                Map<String, dynamic> storyData =
                                                    storyDoc.data()
                                                        as Map<String, dynamic>;

                                                return storyCard(
                                                  theme: theme,
                                                  title: storyData['title'] ??
                                                      'No Title',
                                                  onTap: () {
                                                    context.push(
                                                        '/Firebasestory',
                                                        extra:
                                                            storyDoc.reference);
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                        const SizedBox(height: 20),
                        _buildSectionTitle('Suggested stories', theme),
                        const SizedBox(height: 10),
                        _buildStoriesSection(
                          _fetchSuggestedStories,
                          '/Firebasesuggestedstory',
                          height,
                          width,
                          theme,
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.center,
                          child: InkWell(
                            onTap: () {
                              // Check if the user is a guest
                              final authState = context.read<AuthBloc>().state;
                              if (authState is AuthGuest) {
                                // If guest, navigate to the login page
                                context
                                    .read<AuthBloc>()
                                    .add(AuthGuestLoginRequested());
                                context.push('/CreateAccount',
                                    extra: 'Create an account');
                              } else {
                                // If authenticated, navigate to AddCharacter page
                                context.push('/feedbackPage');
                              }
                            },
                            child: Text(
                              'Give feedback',
                              style: theme.textTheme.headlineLarge!.copyWith(
                                  color: AppColors.textColorblue,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottomNavigationBar: const NavBar(),
          );
  }

  Widget _buildHeader(BuildContext context, double width) {
    return SizedBox(
      width: double.infinity,
      height: 145,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: InkWell(
              onTap: () {
                context.read<AddCharacterBloc>().add(ResetStateEvent());
                context.push('/AddCharacter');
                // }
              },
              child: Container(
                width: width * .7,
                height: 68,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xffAF52DE), Color(0xff5600FF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(109),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/plus_icon.svg',
                      width: 35,
                      height: 35,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Create Story",
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge!
                          .copyWith(fontSize: width * .06, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Image.asset(
              "assets/images/star.png",
              height: 80,
              width: 80,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: theme.textTheme.headlineLarge!.copyWith(
          color: AppColors.textColorblue,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildStoriesSection(
    Future<List<DocumentSnapshot>> Function() fetchStories,
    String route,
    double height,
    double width,
    ThemeData theme,
  ) {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: fetchStories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LoadingWidget());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox(
            height: height * .21,
            child: const Center(child: Text('No stories found')),
          );
        }

        List<DocumentSnapshot> stories = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.only(left: 16),
          child: SizedBox(
            height: height * .21,
            child: ListView.builder(
              itemCount: stories.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                DocumentSnapshot storyDoc = stories[index];
                Map<String, dynamic> storyData =
                    storyDoc.data() as Map<String, dynamic>;
                String language = storyData['language'] ?? 'English';
                print(
                  formatText(storyData['title'] ?? 'No Title', language),
                );
                return storyCard(
                  title: formatText(storyData['title'] ?? 'No Title', language),
                  theme: theme,
                  onTap: () {
                    context.push(route, extra: storyDoc.reference);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget storyCard({
    required String title,
    required ThemeData theme,
    required void Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Container(
          width: MediaQuery.of(context).size.width * .37,
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: Color(0xffF0E9FF), width: 11),
            ),
            color: AppColors.kwhiteColor,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(26),
              topLeft: Radius.circular(7),
              bottomLeft: Radius.circular(11),
              bottomRight: Radius.circular(26),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  style: theme.textTheme.headlineMedium!.copyWith(
                    color: AppColors.textColorblue,
                    fontSize: MediaQuery.of(context).size.width * .04,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width * .03),
                  child: SvgPicture.asset(
                    'assets/images/play_story.svg',
                    width: 26,
                    height: 26,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
