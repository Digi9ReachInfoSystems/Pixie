import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pixieapp/blocs/Story_bloc/story_bloc.dart';
import 'package:pixieapp/blocs/Story_bloc/story_event.dart';
import 'package:pixieapp/blocs/Story_bloc/story_state.dart';
import 'package:pixieapp/const/colors.dart';
import 'package:pixieapp/repositories/story_repository.dart';
import 'package:pixieapp/widgets/loading_widget.dart';
import 'package:pixieapp/widgets/progress_nav_bar.dart';
import 'package:pixieapp/widgets/suggestedstorynavbar.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class Firebasesuggestedstory extends StatefulWidget {
  final DocumentReference<Object?> storyDocRef;

  const Firebasesuggestedstory({super.key, required this.storyDocRef});

  @override
  _FirebasesuggestedstoryState createState() => _FirebasesuggestedstoryState();
}

class _FirebasesuggestedstoryState extends State<Firebasesuggestedstory> {
  Map<String, dynamic>? storyData;

  String childName = "child_name";
  File? audioFile;
  String? audioUrl;
  StoryRepository storyRepository = StoryRepository();

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _fetchUserDataAndStory();
  }

  // Fetch the child name from the authenticated user's document
  Future<void> _fetchUserDataAndStory() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            childName = userDoc.data()?['child_name'] ?? "Ram";
            print('Fetched child name: $childName');
          });
        } else {
          print('User document does not exist.');
        }
      } else {
        print('No authenticated user found.');
      }

      // Fetch the story data after getting the child name
      await _fetchStoryData();
    } catch (e) {
      print('Error fetching user or story data: $e');
    }
  }

  Future<void> _fetchStoryData() async {
    try {
      final docSnapshot = await widget.storyDocRef.get();
      if (docSnapshot.exists) {
        Map<String, dynamic>? fetchedStoryData =
            docSnapshot.data() as Map<String, dynamic>?;
        print(fetchedStoryData!['title']);
        // print(fetchedStoryData['feedback_ref'].toString() ?? "null");

        // File? generatedAudioFile = await storyRepository.speechToText(
        //   text: fetchedStoryData?["title"]! + fetchedStoryData?["story"]!,
        //   language: fetchedStoryData?["language"],
        // );
        print(formatText(fetchedStoryData?["title"]) +
            formatText(fetchedStoryData?["story"]));
        context.read<StoryBloc>().add(SpeechToTextEvent(
            language: fetchedStoryData?["language"],
          
            // formatText(fetchedStoryData["title"]) +
            //     formatText(fetchedStoryData["story"]),
            text: formatText("${fetchedStoryData["title"]}.") +
      formatText(fetchedStoryData["story"]),
            event: fetchedStoryData?["event"]));
        // String? geaudioUrl = await _uploadAudioToStorage(generatedAudioFile);
        setState(() {
          storyData = fetchedStoryData;
          // audioFile = generatedAudioFile;
          // audioUrl = geaudioUrl;
        });
        print('Audio file generated: $audioFile');
      } else {
        print('Story document does not exist.');
      }
    } catch (e) {
      print('Error fetching story data: $e');
    }
  }

  Future<String?> _uploadAudioToStorage(File audioFile) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_audio')
          .child('${DateTime.now().millisecondsSinceEpoch}.mp3');

      final uploadTask = storageRef.putFile(audioFile);
      final snapshot = await uploadTask;
      final audioUrl = await snapshot.ref.getDownloadURL();

      print('Audio uploaded: $audioUrl');
      return audioUrl;
    } catch (e) {
      print('Error uploading audio: $e');
      return null;
    }
  }

  // Replace 'child_name' with the appropriate name based on the language
  String formatText(String text) {
    final language = storyData?['language'] ?? 'English';
    final nameToUse = language == 'Hindi' ? 'राम' : childName;
    return text.replaceAll('child_name', nameToUse).replaceAll('. ', '.\n');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    if (storyData == null) {
      return const Scaffold(
        body: Center(child: LoadingWidget()),
      );
    }

    return BlocBuilder<StoryBloc, StoryState>(builder: (context, state) {
      return Scaffold(
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              expandedHeight: deviceHeight * 0.20,
              leadingWidth: deviceWidth,
              collapsedHeight: deviceHeight * 0.08,
              toolbarHeight: deviceHeight * 0.07,
              pinned: true,
              floating: false,
              backgroundColor: const Color(0xff644a98).withOpacity(.99),
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  var top = constraints.biggest.height;
                  bool isCollapsed = top <= kToolbarHeight + 30;

                  return FlexibleSpaceBar(
                    centerTitle: false,
                    titlePadding: EdgeInsets.only(
                        left: 16, bottom: 10, right: deviceWidth * 0.13),
                    title: Text(
                      formatText(storyData?["title"] ?? "No data"),
                      style: theme.textTheme.titleMedium!.copyWith(
                        color: AppColors.textColorWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: isCollapsed ? 5 : 20,
                      ),
                    ),
                    background: Image.asset(
                      'assets/images/appbarbg2.jpg',
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: deviceWidth * 0.01),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.kwhiteColor.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        context.read<StoryBloc>().add(StopplayingEvent());
                        context.pop();
                      },
                    ),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 5,
                  left: deviceHeight * 0.0294,
                  right: deviceHeight * 0.0294,
                  bottom: deviceHeight * 0.0294,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedTextKit(
                      isRepeatingAnimation: false,
                      pause: const Duration(milliseconds: 1000),
                      animatedTexts: [
                        TyperAnimatedText(
                          formatText(storyData?["story"] ?? "No data"),
                          textStyle: theme.textTheme.bodyMedium!.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                          ),
                          speed: const Duration(milliseconds: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: state is StoryAudioSuccess
            ? SuggstedStoryNavbar(
                dislike: storyData?["feedback_ref"] == null ? false : true,
                liked: storyData?["isfav"] == true ? true : false,
                documentReference: widget.storyDocRef,
                audioFile: state.audioFile,
                story: formatText(storyData?["story"] ?? "No data") ??
                    'No Story available',
                title: formatText(storyData?["title"] ?? "No data") ??
                    'No title available',
                firebaseAudioPath: "audioUrl",
                firebaseStories: false,
              )
            : const ProgressNavBar(),
      );
    });
  }
}
