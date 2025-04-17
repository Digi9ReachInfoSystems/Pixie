import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pixieapp/blocs/StoryFeedback/story_feedback_event.dart'
    as StoryFeedbackEvent;
import 'package:pixieapp/blocs/StoryFeedback/story_feedback_bloc.dart';
import 'package:pixieapp/blocs/StoryFeedback/story_feedback_event.dart';
import 'package:pixieapp/blocs/StoryFeedback/story_feedback_state.dart';
import 'package:pixieapp/blocs/Story_bloc/story_bloc.dart';
import 'package:pixieapp/blocs/Story_bloc/story_event.dart';
import 'package:pixieapp/const/colors.dart';

class StoryFeedback extends StatefulWidget {
  final DocumentReference<Object?>? documentReference;
  final String story;
  final String title;
  final String path;
  final bool textfield;
  final bool firebasestory;

  const StoryFeedback(
      {super.key,
      required this.story,
      required this.title,
      required this.path,
      this.textfield = true,
      required this.documentReference,
      required this.firebasestory});

  @override
  State<StoryFeedback> createState() => _StoryFeedbackState();
}

class _StoryFeedbackState extends State<StoryFeedback> {
  TextEditingController textcontroller = TextEditingController();
  int initialRating = 0;
  List<String> initialIssues = [];
  String initialCustomIssue = '';

  @override
  void dispose() {
    textcontroller.dispose();
    super.dispose();
  }

  Future<void> fetchInitialFeedback() async {
    if (widget.documentReference != null) {
      final docSnapshot = await widget.documentReference!.get();

      if (docSnapshot.exists) {
        final feedbackRefId = docSnapshot['feedback_ref'] as String?;
        if (feedbackRefId != null) {
          final feedbackRef = FirebaseFirestore.instance
              .collection('story_feedback')
              .doc(feedbackRefId);

          final feedbackSnapshot = await feedbackRef.get();

          if (feedbackSnapshot.exists) {
            final feedbackData =
                feedbackSnapshot.data() as Map<String, dynamic>;
            setState(() {
              initialRating = feedbackData['rating'] ?? 0;
              initialIssues = List<String>.from(feedbackData['issues'] ?? []);
              initialCustomIssue = feedbackData['customIssue'] ?? '';
              textcontroller.text = initialCustomIssue;
            });

            context.read<StoryFeedbackBloc>().add(
                  StoryFeedbackEvent.UpdateInitialFeedbackEvent(
                      rating: initialRating,
                      issues: initialIssues,
                      customIssue: initialCustomIssue,
                      liked: false,
                      dislike: true),
                );
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchInitialFeedback();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<StoryFeedbackBloc, StoryFeedbackState>(
      builder: (context, state) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * .7,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () => context.pop(),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: Text(
                      'Skip',
                      style: theme.textTheme.bodyMedium!
                          .copyWith(color: AppColors.textColorWhite),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                    color: AppColors.bottomSheetBackground,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          'Rate your story',
                          style: theme.textTheme.bodyLarge!.copyWith(
                            color: AppColors.textColorblack,
                            fontSize: 23,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0, right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              return Expanded(
                                flex: 1,
                                child: IconButton(
                                  onPressed: () {
                                    context.read<StoryFeedbackBloc>().add(
                                          StoryFeedbackEvent.UpdateRatingEvent(
                                              index + 1),
                                        );
                                  },
                                  icon: Icon(
                                    state.rating > index
                                        ? Icons.star_rate_rounded
                                        : Icons.star_border_rounded,
                                    color: AppColors.kpurple,
                                    size: 50,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Please select one or more issues',
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: AppColors.textColorblack,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          children: [
                            for (var issue in [
                              'Narration speed',
                              'Pronunciation',
                              'Voice modulation',
                              'Background music',
                              'User journey',
                              'Storyline'
                            ])
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: ChoiceChip(
                                  label: Text(
                                    issue,
                                    style: TextStyle(
                                      color: state.issues.contains(issue)
                                          ? AppColors.textColorWhite
                                          : AppColors.textColorblack,
                                    ),
                                  ),
                                  selected: state.issues.contains(issue),
                                  onSelected: (selected) {
                                    context.read<StoryFeedbackBloc>().add(
                                          ToggleIssueEvent(issue),
                                        );
                                  },
                                  selectedColor: AppColors.kpurple,
                                  backgroundColor: AppColors.kwhiteColor,
                                  checkmarkColor: AppColors.textColorWhite,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        widget.textfield
                            ? TextField(
                                onChanged: (value) {
                                  context
                                      .read<StoryFeedbackBloc>()
                                      .add(CustomIssueEvent(value));
                                },
                                cursorColor: AppColors.kpurple,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                controller: textcontroller,
                                minLines: 3,
                                maxLines: 10,
                                decoration: InputDecoration(
                                  hintText: initialCustomIssue.isEmpty
                                      ? 'Type in case other'
                                      : initialCustomIssue,
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                      width: .5,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                      width: .5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: AppColors.kpurple,
                                      width: .5,
                                    ),
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.kblackColor,
                                ),
                              )
                            : const SizedBox(),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 22),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * .7,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: AppColors.kpurple,
                                  backgroundColor: AppColors.kpurple),
                              onPressed: () {
                                context.read<StoryFeedbackBloc>().add(
                                      StoryFeedbackEvent.SubmitFeedbackEvent(
                                        documentReference:
                                            widget.documentReference,
                                        audiopath: widget.path,
                                        story: widget.story,
                                        story_title: widget.title,
                                      ),
                                    );
                                if (widget.firebasestory) {
                                  context
                                      .read<StoryBloc>()
                                      .add(StopplayingEvent());
                                  Future.delayed(const Duration(seconds: 1),
                                      () {
                                    context.push('/Firebasestory1',
                                        extra: widget.documentReference);
                                  });
                                } else {
                                  context.pop();
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Thank you for your feedback")),
                                );
                              },
                              child: Text(
                                'Submit',
                                style: theme.textTheme.bodyMedium!
                                    .copyWith(color: AppColors.textColorWhite),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
