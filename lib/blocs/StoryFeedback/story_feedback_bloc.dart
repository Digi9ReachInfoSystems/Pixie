import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'story_feedback_event.dart';
import 'story_feedback_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StoryFeedbackBloc extends Bloc<StoryFeedbackEvent, StoryFeedbackState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StoryFeedbackBloc() : super(const StoryFeedbackState()) {
    on<ResetFeedbackStateEvent>((event, emit) {
      emit(state.copyWith(
        liked: false, // Reset liked state
        dislike: false, // Reset disliked state
        rating: 0, // Optionally reset rating or other fields
        issues: [], // Optionally reset any issues list
        customIssue: '', // Optionally reset any custom issue
      ));
    });
    on<UpdateRatingEvent>((event, emit) {
      emit(state.copyWith(rating: event.rating));
    });
    on<UpdatedislikeStateEvent>((event, emit) {
      emit(DislikeStateUpdated(isDisliked: event.isDisliked));
    });
    on<ToggleIssueEvent>((event, emit) {
      final issues = List<String>.from(state.issues);
      if (issues.contains(event.issue)) {
        issues.remove(event.issue);
      } else {
        issues.add(event.issue);
      }
      emit(state.copyWith(issues: issues));
    });

    // on<AddCustomIssueEvent>((event, emit) {
    //   final issues = List<String>.from(state.issues)..add(event.issue);
    //   emit(state.copyWith(issues: issues));
    // });
    on<CustomIssueEvent>((event, emit) {
      // final customissues = List<String>.from(state.customIssue)..add(event.issue);
      emit(state.copyWith(customIssue: event.Customissue));
    });

    on<UpdateInitialFeedbackEvent>((event, emit) {
      emit(state.copyWith(
        rating: event.rating,
        issues: event.issues,
        customIssue: event.customIssue,
      ));
    });

    on<SubmitFeedbackEvent>((event, emit) async {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final userRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);

        if (event.documentReference != null) {
          final favDocSnapshot = await event.documentReference!.get();
          final data = favDocSnapshot.data() as Map<String, dynamic>?;

          if (data != null) {
            final feedbackRef = data['feedback_ref'];

            if (feedbackRef != null) {
              final feedbackDocRef = FirebaseFirestore.instance
                  .collection('story_feedback')
                  .doc(feedbackRef);

              await feedbackDocRef.update({
                'rating': state.rating,
                'issues': state.issues ?? "Not added",
                'customIssue': state.customIssue ?? "no issue",
              });
            } else {
              final feedbackDocRef = await FirebaseFirestore.instance
                  .collection('story_feedback')
                  .add({
                'user_ref': userRef,
                'rating': state.rating,
                'customIssue': state.customIssue ?? "no issue",
                'issues': state.issues ?? "Not added",
                'created_time': FieldValue.serverTimestamp(),
                "story_title": event.story_title ?? "Not added",
                "story": event.story ?? "Not added",
                "audio_path": event.audiopath ?? ''
              });

              await event.documentReference!.update({
                'feedback_ref': feedbackDocRef.id,
                'isfav': false,
              });
            }
          }
        } else {
          print('Document reference is null.');
        }
      } else {
        print('No user logged in.');
      }
      emit(state.copyWith(dislike: true, liked: false));
    });

    on<UpdateLikedEvent>((event, emit) async {
      if (event.documentReference != null) {
        await event.documentReference!
            .update({'isfav': true, 'feedback_ref': FieldValue.delete()});
      }
      emit(state.copyWith(liked: true, dislike: false));
    });
  }
}
