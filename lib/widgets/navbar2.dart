import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pixieapp/blocs/StoryFeedback/story_feedback_bloc.dart';
import 'package:pixieapp/blocs/StoryFeedback/story_feedback_event.dart';
import 'package:pixieapp/blocs/StoryFeedback/story_feedback_state.dart';
import 'package:pixieapp/blocs/Story_bloc/story_bloc.dart';
import 'package:pixieapp/blocs/Story_bloc/story_event.dart';
import 'package:pixieapp/blocs/Story_bloc/story_state.dart';
import 'package:pixieapp/blocs/add_character_Bloc.dart/add_character_bloc.dart';
import 'package:pixieapp/blocs/add_character_Bloc.dart/add_character_event.dart';
import 'package:pixieapp/blocs/add_character_Bloc.dart/add_character_state.dart';
import 'package:pixieapp/const/colors.dart';
import 'package:pixieapp/widgets/audio_controller.dart';
import 'package:pixieapp/widgets/story_feedback.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pixieapp/widgets/analytics.dart';

class NavBar2 extends StatefulWidget {
  final DocumentReference<Object?>? documentReference;
  final File? audioFile;
  final String story;
  final String title;
  final String firebaseAudioPath;
  final bool suggestedStories;
  final bool firebaseStories;
  final bool dislike;
  final bool liked;
  const NavBar2(
      {super.key,
      required this.documentReference,
      this.audioFile,
      required this.story,
      required this.title,
      required this.firebaseAudioPath,
      required this.suggestedStories,
      required this.firebaseStories,
      required this.dislike,
      required this.liked});

  @override
  State<NavBar2> createState() => _NavBar2State();
}

class _NavBar2State extends State<NavBar2> {
  final player = AudioPlayer();
  final GlobalKey _tooltipKey = GlobalKey();

  void _showTooltip() {
    final dynamic tooltip = _tooltipKey.currentState;
    tooltip?.ensureTooltipVisible();
  }

  // late AudioPlayer audioController.audioPlayer;
  final AudioController _audioController = AudioController();
  User? user = FirebaseAuth.instance.currentUser;
  bool _isPlaying = false;
  bool showfeedback = true;
  bool isDisliked = false;
  bool isDislikeddd = false;
  bool alredayliked = false;
  bool seekInProgress = false;
  double? _tempSeekValue;

  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  @override
  void initState() {
    super.initState();
    initialstate();
    BlocProvider.of<StoryFeedbackBloc>(context).add(ResetFeedbackStateEvent());

    widget.firebaseStories
        ? player.setUrl(widget.firebaseAudioPath)
        : player.setFilePath(widget.audioFile!.path);
    player.positionStream.listen((p) {
      setState(() {
        position = p;
      });
    });
    player.durationStream.listen((d) {
      setState(() {
        duration = d!;
      });
    });
    player.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          position = Duration.zero;
        });
        player.pause();
        player.seek(position);
      }
    });
  }

  initialstate() async {
    if (widget.dislike) {
      final snapshort = await widget.documentReference!.get();
      final storydta = snapshort.data() as Map<String, dynamic>?;

      context.read<StoryFeedbackBloc>().add(UpdateInitialFeedbackEvent(
            liked: false,
            dislike: true,
            customIssue: '',
            issues: [],
            rating: 0,
          ));
    }
    {
      final snapshort = await widget.documentReference!.get();
      final storydta = snapshort.data() as Map<String, dynamic>?;
    }
  }

  Future<bool> _checkUpdate() async {
    try {
      final docSnapshot = await widget.documentReference!.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>?;
        final currentAudioUrl = data?['audiofile'];

        return currentAudioUrl.isEmpty;
      } else {
        return false;
      }
    } catch (e) {
      print('Error checking audio file update: $e');
      return false;
    }
  }

  Future<void> initialfeedback() async {
    if (widget.documentReference != null) {
      final favDocSnapshot = await widget.documentReference!.get();
      final storyData = favDocSnapshot.data() as Map<String, dynamic>?;
      if (storyData!["feedback_ref"] != null) {
        final feedbacksnacpshort = await storyData["feedback_ref"].get();
        final feedback = feedbacksnacpshort.data() as Map<String, dynamic>?;

        context.read<StoryFeedbackBloc>().add(UpdateInitialFeedbackEvent(
            rating: feedback!["rating"] ??
                0, // Default value in case feedback["rating"] is null
            issues: feedback["issues"] ??
                [], // Default empty list if issues is null
            customIssue: feedback["customIssue"] ??
                '', // Default empty string if customIssue is null
            dislike: true,
            liked: false));
      } else if (storyData!["feedback_ref"] != null &&
          storyData!.containsKey('isfav') &&
          storyData!['isfav'] != null) {
        final isFav = storyData!['isfav'];
        if (isFav == true) {
          context.read<StoryFeedbackBloc>().add(UpdateInitialFeedbackEvent(
              rating: 0,
              issues: [],
              customIssue: '',
              dislike: false,
              liked: true));
        } else {
          context.read<StoryFeedbackBloc>().add(UpdateInitialFeedbackEvent(
              rating: 0,
              issues: [],
              customIssue: '',
              dislike: false,
              liked: false));
        }
      }
    }
  }

  @override
  void dispose() {
    _audioController.audioPlayer.dispose();
    player.dispose();
    super.dispose();
  }

  // Function to set the audio source from the audio file path
  Future<void> _setAudioSource() async {
    try {
      // Use the file path directly
      await _audioController.audioPlayer.setFilePath(widget.audioFile!.path);
      print("Audio source set successfully.");
    } catch (e) {
      print("Error loading audio file: $e");
    }
  }

  String formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void stopplaying() {
    if (player.playing) {
      player.pause();
    }
  }

  void handlePlayPause({required AddCharacterState state}) async {
    if (player.playing) {
      player.pause();
    } else {
      player.play();
    }
  }

  void handleSeek(double value) {
    player.seek(Duration(seconds: value.toInt()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<StoryBloc, StoryState>(
      listener: (context, state) async {
        if (state is Stopplayingstate) {
          stopplaying();
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 2, right: 2),
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: Color.fromARGB(0, 134, 7, 7),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            image: DecorationImage(
                image: AssetImage('assets/images/Rectangle 11723.png'),
                fit: BoxFit.fill),
          ),
          child: Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 25, bottom: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          formatDuration(position),
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: AppColors.textColorblue,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          formatDuration(duration),
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: AppColors.textColorblue,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            min: 0,
                            max: duration.inSeconds.toDouble(),
                            value: seekInProgress
                                ? _tempSeekValue!
                                : position.inSeconds.toDouble(),
                            onChangeStart: (value) {
                              // Mark that seeking has started
                              seekInProgress = true;
                              _tempSeekValue = value;
                            },
                            // onChanged: handleSeek,
                            onChanged: (value) {
                              // Temporarily update the slider value
                              _tempSeekValue = value;
                              setState(() {});
                            },
                            onChangeEnd: (value) {
                              // Finalize the seek
                              seekInProgress = false;
                              handleSeek(value);
                            },
                            activeColor: AppColors.kpurple,
                            inactiveColor: AppColors.kwhiteColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                BlocBuilder<AddCharacterBloc, AddCharacterState>(
                  builder: (context, state) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child:
                            BlocBuilder<StoryFeedbackBloc, StoryFeedbackState>(
                                builder: (context, state) {
                          return IconButton(
                            onPressed: () async {
                              AnalyticsService.logEvent(
                                  eventName: 'like_story_button');
                              if (widget.liked == false &&
                                  alredayliked == false) {
                                context.read<StoryFeedbackBloc>().add(
                                    UpdateLikedEvent(
                                        liked: true,
                                        dislike: false,
                                        documentReference:
                                            widget.documentReference!));
                                setState(() {
                                  alredayliked = true;
                                });
                                context
                                    .read<StoryBloc>()
                                    .add(StopplayingEvent());
                                context
                                    .read<StoryBloc>()
                                    .add(StopplayingEvent());
                                context
                                    .read<StoryBloc>()
                                    .add(StopplayingEvent());
                                Future.delayed(
                                    const Duration(milliseconds: 500), () {
                                  context.push('/Firebasestory1',
                                      extra: widget.documentReference);
                                });
                              }
                            },
                            icon: SvgPicture.asset(
                              (state.liked == true && widget.liked == true) ||
                                      widget.liked == true
                                  ? 'assets/images/afterLike.svg'
                                  : 'assets/images/beforeLike.svg',
                              width: 30,
                              height: 30,
                            ),
                          );
                        }),
                      ),
                      BlocBuilder<StoryFeedbackBloc, StoryFeedbackState>(
                        builder: (context, state) {
                          return IconButton(
                            onPressed: () async {
                              AnalyticsService.logEvent(
                                  eventName: 'dislike_story_button');
                              context.read<StoryFeedbackBloc>().add(
                                  UpdateInitialFeedbackEvent(
                                      rating: 0,
                                      issues: [],
                                      customIssue: "",
                                      dislike: false,
                                      liked: false));
                              await showModalBottomSheet(
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                enableDrag: false,
                                context: context,
                                builder: (context) {
                                  return GestureDetector(
                                    onTap: () =>
                                        FocusScope.of(context).unfocus(),
                                    child: Padding(
                                      padding: MediaQuery.viewInsetsOf(context),
                                      child: StoryFeedback(
                                        firebasestory: true,
                                        documentReference:
                                            widget.documentReference!,
                                        story: widget.story,
                                        title: widget.title,
                                        path: widget.firebaseAudioPath,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            icon: SvgPicture.asset(
                              (state.dislike == true &&
                                          widget.dislike == true) ||
                                      widget.dislike == true
                                  ? 'assets/images/afterDislike.svg'
                                  : 'assets/images/beforeDislike.svg',
                              width: 30,
                              height: 30,
                            ),
                          );
                        },
                      ),
                      IconButton(
                        onPressed: () {
                          AnalyticsService.logEvent(
                              eventName: 'playpause_button');
                          handlePlayPause(state: state);
                        },
                        icon: SizedBox(
                          width: 60,
                          height: 60,
                          child: player.playing
                              ? const Icon(
                                  Icons.pause_circle_filled_sharp,
                                  color: AppColors.kpurple,
                                  size: 60,
                                )
                              : SvgPicture.asset(
                                  'assets/images/pausegrad.svg',
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          AnalyticsService.logEvent(
                              eventName: 'add_to_favorites_button');
                          // Show the tooltip programmatically
                          final dynamic tooltip = _tooltipKey.currentState;
                          tooltip?.ensureTooltipVisible();

                          // Simulate feature loading (Optional)
                          Future.delayed(const Duration(seconds: 2), () {
                            print("Feature loading completed");
                          });
                        },
                        icon: Tooltip(
                          key: _tooltipKey, // Add the tooltip key
                          message:
                              'Stay tuned for the magic!', // Tooltip message
                          waitDuration:
                              const Duration(milliseconds: 0), // No wait
                          showDuration:
                              const Duration(seconds: 2), // Show for 2 seconds
                          child: SvgPicture.asset(
                            'assets/images/addToFavorites.svg',
                            width: 25,
                            height: 25,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          AnalyticsService.logEvent(
                              eventName: 'share_story_button');
                          openWhatsAppChat(
                              ''' 🎧Hey! Listen to the personalized story I created for my child.\n\n${widget.title}\n\n ${widget.firebaseAudioPath}\n\nYou can create such personalized audio stories for your children too! Download the app now \n For ios app:https://apps.apple.com/us/app/pixie-dream-create-inspire/id6737147663\n\n For Android app : https://play.google.com/store/apps/details?id=com.fabletronic.pixie.''');
                        },
                        icon: SvgPicture.asset(
                          'assets/images/share.svg',
                          width: 25,
                          height: 25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> updateDislikeFirebaseSuggested({
    //  required bool fav,
    required DocumentReference<Object?> docRef,
  }) async {
    // if (fav) {
    await docRef.update({
      'noOfDislike': FieldValue.arrayUnion([
        FirebaseFirestore.instance.collection('users').doc(user?.uid),
      ]),
    });
    setState(() {
      isUserDisliked(widget.documentReference!);
      isDisliked = true;
    });
    print('disliked');
  }

  Future<void> fetchInitialFeedback(
      {DocumentReference<Object?>? documentReference}) async {
    if (documentReference != null) {
      context.read<StoryFeedbackBloc>().add(
            UpdateInitialFeedbackEvent(
                rating: 0,
                issues: [],
                customIssue: '',
                dislike: true,
                liked: false),
          );
    }
  }

  Future<void> isUserDisliked(DocumentReference docRef) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || widget.suggestedStories == false) {
      setState(() {
        isDisliked = false;
      });
      return; // If user is not logged in, return false
    }

    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    // Get the document snapshot
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      setState(() {
        isDisliked = false;
      }); // If document does not exist, return false
    }

    // Check if the 'noOfDislike' field is present and is a list
    final dislikes = docSnapshot['noOfDislike'] as List?;

    if (dislikes == null) {
      setState(() {
        isDislikeddd = false;
      });
      // If 'noOfDislike' field is not available, return false
    } else {
      if (dislikes.contains(userRef)) {
        setState(() {
          isDislikeddd = true;
        });
      } else {
        setState(() {
          isDislikeddd = false;
        });
      }
    }

    // Check if the current user's reference is in the 'noOfDislike' list
  }

  Future<void> updateFirebase({
    required bool fav,
    required DocumentReference<Object?> docRef,
  }) async {
    if (fav) {
      await docRef.update({
        'isfav': true,
      });
      print('Story added to fav');
    } else {
      await docRef.update({'isfav': false});
      print('Story removed from fav');
    }
  }

  Future<void> updateFirebaseSuggested({
    required bool fav,
    required DocumentReference<Object?> docRef,
  }) async {
    if (fav) {
      await docRef.update({
        'isfav': true,
        'noOfFavorites': FieldValue.arrayUnion([
          FirebaseFirestore.instance.collection('users').doc(user?.uid),
        ]),
      });
      print('Story added to fav');
    } else {
      await docRef.update({
        'isfav': false,
        'noOfFavorites': FieldValue.arrayRemove([
          FirebaseFirestore.instance.collection('users').doc(user?.uid),
        ]),
      });
      print('Story removed from fav');
    }
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
}
