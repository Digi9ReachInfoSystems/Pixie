import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pixieapp/blocs/Library_bloc/library_bloc.dart';
import 'package:pixieapp/blocs/Library_bloc/library_event.dart';
import 'package:pixieapp/blocs/Library_bloc/library_state.dart';
import 'package:pixieapp/const/colors.dart';
import 'package:pixieapp/widgets/analytics.dart';
import 'package:pixieapp/widgets/loading_widget.dart';
import 'package:pixieapp/widgets/navbar.dart';
import 'package:url_launcher/url_launcher.dart';

class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  @override
  void initState() {
    super.initState();

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<FetchStoryBloc>().add(FetchStories(
          FirebaseFirestore.instance.collection('users').doc(user?.uid)));
    }
    AnalyticsService.logScreenView(
      screenName: '/Library',
      screenClass: 'Library Screen',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    return BlocBuilder<FetchStoryBloc, StoryState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xfff9f3cd),
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          AppColors.textColorGrey,
                          AppColors.textColorSettings,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ).createShader(
                        Rect.fromLTWH(0.0, 0.0, bounds.width, bounds.height),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "My Stories",
                            style: theme.textTheme.headlineMedium!.copyWith(
                                fontSize: 24,
                                color: AppColors.textColorWhite,
                                fontWeight: FontWeight.w700),
                          ),
                          IconButton(
                            onPressed: () {
                              context.go('/searchPage');
                            },
                            icon: SvgPicture.asset(
                              'assets/images/search.svg',
                              width: 25,
                              height: 25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: SizedBox(
                      width: width,
                      height: 45,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            filterChoicechip(
                              ontap: () => context
                                  .read<FetchStoryBloc>()
                                  .add(const AddfilterEvent(filter: '')),
                              title: 'All',
                              theme: theme,
                              selected:
                                  state is StoryLoaded && state.filter == '',
                            ),
                            filterChoicechip(
                              ontap: () => context
                                  .read<FetchStoryBloc>()
                                  .add(const AddfilterEvent(filter: 'Bedtime')),
                              title: 'Bedtime',
                              theme: theme,
                              selected: state is StoryLoaded &&
                                  state.filter == 'Bedtime',
                            ),
                            filterChoicechip(
                              ontap: () => context.read<FetchStoryBloc>().add(
                                  const AddfilterEvent(filter: 'Playtime')),
                              title: 'Playtime',
                              theme: theme,
                              selected: state is StoryLoaded &&
                                  state.filter == 'Playtime',
                            ),
                            filterChoicechip(
                              ontap: () => context
                                  .read<FetchStoryBloc>()
                                  .add(const AddfilterEvent(filter: 'Liked')),
                              title: 'Liked',
                              theme: theme,
                              selected: state is StoryLoaded &&
                                  state.filter == 'Liked',
                            ),
                            filterChoicechip(
                              ontap: () => context
                                  .read<FetchStoryBloc>()
                                  .add(const AddfilterEvent(filter: 'English')),
                              title: 'English',
                              theme: theme,
                              selected: state is StoryLoaded &&
                                  state.filter == 'English',
                            ),
                            filterChoicechip(
                              ontap: () => context
                                  .read<FetchStoryBloc>()
                                  .add(const AddfilterEvent(filter: 'Hindi')),
                              title: 'Hindi',
                              theme: theme,
                              selected: state is StoryLoaded &&
                                  state.filter == 'Hindi',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: Row(
                      children: [
                        SvgPicture.asset('assets/images/updownarrow.svg'),
                        const SizedBox(width: 10),
                        Text(
                          'Recents',
                          style:
                              theme.textTheme.bodySmall!.copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _buildStoryContent(state, theme),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: const NavBar(),
        );
      },
    );
  }

  Future<void> openWhatsAppChat(String text) async {
    final encodedText = Uri.encodeComponent(text);

    final url = "https://wa.me/?text=$encodedText";

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch WhatsApp';
    }
  }

  Widget filterChoicechip({
    required ThemeData theme,
    required bool selected,
    required String title,
    required void Function() ontap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: ElevatedButton(
        onPressed: ontap,
        style: ElevatedButton.styleFrom(
          elevation: 2,
          minimumSize: const Size(50, 32),
          maximumSize: const Size(200, 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          foregroundColor: selected ? AppColors.kpurple : AppColors.kwhiteColor,
          backgroundColor: selected ? AppColors.kpurple : AppColors.kwhiteColor,
        ),
        child: Text(
          title,
          style: theme.textTheme.bodyMedium!.copyWith(
              color: selected ? AppColors.kwhiteColor : AppColors.kblackColor,
              fontSize: 13,
              fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

  Widget _buildStoryContent(StoryState state, ThemeData theme) {
    if (state is StoryLoading) {
      return const Center(child: LoadingWidget());
    } else if (state is StoryLoaded) {
      if (state.filteredStories.isEmpty) {
        return const Center(child: Text("No stories found"));
      }

      return ListView.builder(
        itemCount: state.filteredStories.length,
        itemBuilder: (context, index) {
          final story = state.filteredStories[index];
          final DocumentReference storyRef =
              story['reference']; // Get reference

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: storylistCard(
              audiourl: story['audiofile'],
              genre: story['genre'] ?? 'Funny',
              theme: theme,
              title: story['title'],
              story: story['story'] ?? 'story',
              storytype: story['storytype'],
              duration: _formatCreatedTime(story['createdTime']),
              image: '',
              storyRef: storyRef,
              ontap: () {
                if (storyRef != null && storyRef is DocumentReference) {
                  context.push('/Firebasestorylibrary', extra: storyRef);
                }
              },
            ),
          );
        },
      );
    } else if (state is StoryError) {
      return Center(child: Text(state.error));
    }

    return const SizedBox();
  }

  Widget storylistCard({
    required String genre,
    required ThemeData theme,
    required String title,
    required String storytype,
    required String duration,
    required String image,
    required String story,
    required String audiourl,
    required DocumentReference storyRef,
    required void Function() ontap,
  }) {
    return InkWell(
      onTap: ontap,
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: AppColors.kwhiteColor,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.kgreyColor.withOpacity(0.4),
                    blurRadius: 7,
                    spreadRadius: 0.5,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: genre == "Surprise me"
                  ? Image.asset(
                      'assets/images/surpriceme.png',
                      fit: BoxFit.fill,
                    )
                  : genre == "Funny"
                      ? Image.asset('assets/images/FUNNY.png')
                      : genre == "Horror"
                          ? Image.asset('assets/images/HORROR.png')
                          : genre == "Adventure"
                              ? Image.asset('assets/images/adventure.png')
                              : genre == "Action"
                                  ? Image.asset('assets/images/Action.png')
                                  : Image.asset('assets/images/ScI-Fi.png'),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium!
                        .copyWith(fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                  Row(
                    children: [
                      Text(storytype,
                          style: theme.textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.w500, fontSize: 16)),
                      const Text(
                        ' - ',
                        style: TextStyle(fontWeight: FontWeight.w400),
                      ),
                      Text(duration,
                          style: theme.textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.w500, fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: IconButton(
                onPressed: () {
                  openWhatsAppChat(
                      '''🎧Hey! Listen to the personalized story I created for my child. \n\n$title\n\n$audiourl \n\nYou can create such personalized audio stories for your children too! Download the app now \n For ios app:https://apps.apple.com/us/app/pixie-dream-create-inspire/id6737147663\n\n For Android app : https://play.google.com/store/apps/details?id=com.fabletronic.pixie.''');
                },
                icon: SvgPicture.asset(
                  'assets/images/share.svg',
                  width: 25,
                  height: 25,
                  color: AppColors.kblackColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatCreatedTime(Timestamp? timestamp) {
  if (timestamp == null) return 'Unknown Date';

  final DateTime dateTime = timestamp.toDate();
  final Duration difference = DateTime.now().difference(dateTime);

  if (difference.inMinutes < 1) {
    return 'Just now';
  } else if (difference.inMinutes == 1) {
    return '1 min ago';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} mins ago';
  } else if (difference.inHours == 1) {
    return '1 hr ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} hrs ago';
  } else if (difference.inDays == 1) {
    return '1 day ago';
  } else {
    return '${difference.inDays} days ago';
  }
}
