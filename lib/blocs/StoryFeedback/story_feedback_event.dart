import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

abstract class StoryFeedbackEvent extends Equatable {
  const StoryFeedbackEvent();

  @override
  List<Object?> get props => [];
}

class UpdateRatingEvent extends StoryFeedbackEvent {
  final int rating;

  const UpdateRatingEvent(this.rating);

  @override
  List<Object?> get props => [rating];
}

class ToggleIssueEvent extends StoryFeedbackEvent {
  final String issue;

  const ToggleIssueEvent(this.issue);

  @override
  List<Object?> get props => [issue];
}

class UpdatedislikeStateEvent extends StoryFeedbackEvent {
  final bool isDisliked;

  const UpdatedislikeStateEvent({required this.isDisliked});
}

class AddCustomIssueEvent extends StoryFeedbackEvent {
  final String issue;

  const AddCustomIssueEvent(this.issue);

  @override
  List<Object?> get props => [issue];
}

class CustomIssueEvent extends StoryFeedbackEvent {
  final String Customissue;

  const CustomIssueEvent(this.Customissue);

  @override
  List<Object?> get props => [Customissue];
}

class SubmitFeedbackEvent extends StoryFeedbackEvent {
  final String story_title;
  final String story;
  final String audiopath;
  final DocumentReference<Object?>? documentReference;

  SubmitFeedbackEvent(
      {required this.story_title,
      required this.story,
      required this.documentReference,
      required this.audiopath});
  @override
  List<Object?> get props => [story_title, story, audiopath, documentReference];
}

class UpdateInitialFeedbackEvent extends StoryFeedbackEvent {
  final int rating;
  final List<String> issues;
  final String customIssue;
  final bool dislike;
  final bool liked;

  UpdateInitialFeedbackEvent(
      {required this.rating,
      required this.issues,
      required this.customIssue,
      required this.dislike,
      required this.liked});
  @override
  List<Object?> get props => [rating, issues, customIssue, dislike, liked];
}

class UpdateLikedEvent extends StoryFeedbackEvent {
  final DocumentReference<Object?>? documentReference;
  final bool liked;
  final bool dislike;

  UpdateLikedEvent({
    required this.liked,
    required this.dislike,
    required this.documentReference,
  });
  @override
  List<Object?> get props => [liked, dislike, documentReference];
}

class ResetFeedbackStateEvent extends StoryFeedbackEvent {}
