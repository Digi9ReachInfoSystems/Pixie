import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixieapp/blocs/Story_bloc/story_bloc.dart';
import 'package:pixieapp/blocs/Story_bloc/story_event.dart';
import 'package:pixieapp/const/colors.dart';
import 'package:pixieapp/widgets/analytics.dart';
class RecordListenNavbar extends StatelessWidget {
  final String story;
  final String title;
  final String language;
  final String event;
  final DocumentReference<Object?>? documentReference;
  const RecordListenNavbar(
      {super.key,
      required this.story,
      required this.title,
      required this.event,
      required this.documentReference,
      required this.language});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.only(bottom: 40),
      height: 180,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12), topRight: Radius.circular(12)),
        image: DecorationImage(
            image: AssetImage('assets/images/Rectangle 11723.png'),
            fit: BoxFit.fill),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            height: 50,
            width: 150,
            child: ElevatedButton(
              onPressed: () {
                  AnalyticsService.logEvent(
                            eventName: 'record_audio_button');
                context.read<StoryBloc>().add(const StartRecordnavbarEvent());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kwhiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              child: Text(
                "Read and record",
                style: theme.textTheme.bodyMedium!.copyWith(
                    color: AppColors.textColorblue,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ),
          SizedBox(
            height: 50,
            width: 150,
            child: ElevatedButton(
              onPressed: () {
                  AnalyticsService.logEvent(
                            eventName: 'listen_audio_button');
                context.read<StoryBloc>().add(SpeechToTextEvent(
                      event: event,
                      text: "$title.<break time=\"1.0s\" />$story",
                      language: language,
                    ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kwhiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              child: Text(
                "Listen",
                style: theme.textTheme.bodyMedium!.copyWith(
                    color: AppColors.textColorblue,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
