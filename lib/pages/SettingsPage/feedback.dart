import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pixieapp/blocs/Feedback/feedback_bloc.dart';
import 'package:pixieapp/blocs/Feedback/feedback_event.dart';
import 'package:pixieapp/blocs/Feedback/feedback_state.dart';
import 'package:pixieapp/const/colors.dart';
import 'package:pixieapp/widgets/analytics.dart';
import 'package:pixieapp/widgets/widgets_index.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  int currentRating = 0;
  late Map<String, Map<String, bool>> currentQuestionsLikedDisliked;

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    // if (user != null) {
    //   context.read<FeedbackBloc>().add(CheckFeedbackEvent(user.uid));
    // }
    currentQuestionsLikedDisliked = _initialQuestions();
    AnalyticsService.logScreenView(
      screenName: '/feedbackPage',
      screenClass: 'Feedback Screen',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocConsumer<FeedbackBloc, FeedbackState>(
        listener: (context, state) {
          if (state is FeedbackSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Feedback submitted!')),
            );
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state is FeedbackLoading) {
            return const Center(child: LoadingWidget());
          } else if (state is FeedbackUpdated) {
            currentRating = state.rating;
            currentQuestionsLikedDisliked = state.questionsLikedDisliked;
          }
          return _buildFeedbackForm(context, theme);
        },
      ),
    );
  }

  Widget _buildFeedbackForm(BuildContext context, ThemeData theme) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

    return Container(
      height: deviceHeight,
      width: deviceWidth,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xffead4f9), Color(0xfff7f1d1)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            const SizedBox(height: 40),
            Text(
              'Rate your experience',
              style: theme.textTheme.headlineMedium!.copyWith(
                color: AppColors.textColorblack,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 30),
            _buildRatingRow(context, theme),
            const SizedBox(height: 30),
            _buildQuestionsCard(theme, deviceWidth, deviceHeight),
            const SizedBox(height: 30),
            _buildContactUsButton(theme),
            const Spacer(),
            _buildSubmitButton(context, theme),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              context.pop();
            },
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.sliderColor,
              size: 25,
            ),
          ),
          const SizedBox(width: 20),
          ShaderMask(
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
            child: Text(
              "Feedback",
              style: theme.textTheme.headlineMedium!.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textColorWhite),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingRow(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () {
            setState(() => currentRating = index + 1);
            context.read<FeedbackBloc>().add(UpdateRatingEvent(currentRating));
          },
          icon: Icon(
            currentRating > index ? Icons.star : Icons.star_border,
            color: AppColors.kpurple,
            size: 50,
          ),
        );
      }),
    );
  }

  Widget _buildQuestionsCard(
      ThemeData theme, double deviceWidth, double deviceHeight) {
    return Card(
      child: Container(
        width: deviceWidth * 0.9,
        // height: deviceHeight * 0.6,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.kwhiteColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: currentQuestionsLikedDisliked.keys.map((question) {
            final liked = currentQuestionsLikedDisliked[question]!['liked']!;
            final disliked =
                currentQuestionsLikedDisliked[question]!['disliked']!;
            return _buildQuestionRow(
              question: question,
              liked: liked,
              disliked: disliked,
              theme: theme,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildQuestionRow({
    required String question,
    required bool liked,
    required bool disliked,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: Text(
            question,
            style: theme.textTheme.bodyMedium!.copyWith(fontSize: 16),
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              currentQuestionsLikedDisliked[question] = {
                'liked': true,
                'disliked': false
              };
            });
            context
                .read<FeedbackBloc>()
                .add(UpdateLikedDislikedEvent(question: question, liked: true));
          },
          icon: SvgPicture.asset(
            liked
                ? 'assets/images/afterLike.svg'
                : 'assets/images/beforeLike.svg',
            width: 30,
            height: 30,
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              currentQuestionsLikedDisliked[question] = {
                'liked': false,
                'disliked': true
              };
            });
            context.read<FeedbackBloc>().add(
                UpdateLikedDislikedEvent(question: question, liked: false));
          },
          icon: SvgPicture.asset(
            disliked
                ? 'assets/images/afterDislike.svg'
                : 'assets/images/beforeDislike.svg',
            width: 30,
            height: 30,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 20.0,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(MediaQuery.of(context).size.width, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: currentRating == 0
              ? AppColors.kwhiteColor
              : AppColors.buttonColor1,
        ),
        onPressed: () {
          User? user = FirebaseAuth.instance.currentUser;

          if (user != null && currentRating != 0) {
            final userRef =
                FirebaseFirestore.instance.collection('users').doc(user.uid);
            context.read<FeedbackBloc>().add(
                  SubmitFeedbackEvent(
                      rating: currentRating,
                      questionsLikedDisliked: currentQuestionsLikedDisliked,
                      userId: user.uid,
                      userref: userRef),
                );
          }
        },
        child: Text(
          'Submit',
          style: theme.textTheme.bodyLarge!.copyWith(
            color: currentRating == 0
                ? AppColors.textColorblue
                : AppColors.textColorWhite,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildContactUsButton(ThemeData theme) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      child: ElevatedButton(
        onPressed: openWhatsAppChat,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          foregroundColor: AppColors.kwhiteColor,
          backgroundColor: AppColors.kwhiteColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Contact us",
              style: theme.textTheme.bodyLarge!.copyWith(
                color: AppColors.textColorblack,
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(width: 10),
            SvgPicture.asset('assets/images/contactus.svg', width: 20),
          ],
        ),
      ),
    );
  }

  Map<String, Map<String, bool>> _initialQuestions() {
    return {
      'Story line': {'liked': false, 'disliked': false},
      'Pronunciation': {'liked': false, 'disliked': false},
      'Voice modulation': {'liked': false, 'disliked': false},
      'Background music': {'liked': false, 'disliked': false},
      'User journey': {'liked': false, 'disliked': false},
    };
  }
}

Future<void> openWhatsAppChat() async {
  const whatsappUrl = 'https://wa.me/+919643221767';
  final uri = Uri.parse(whatsappUrl);

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch WhatsApp';
  }
}
