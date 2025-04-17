import 'package:equatable/equatable.dart';

class StoryFeedbackState extends Equatable {
  final int rating;
  final List<String> issues;
  final String customIssue;
  final bool dislike;
  final bool liked;

  const StoryFeedbackState({
    this.rating = 0,
    this.issues = const [],
    this.customIssue = '',
    this.dislike = false,
    this.liked = false,
  });

  StoryFeedbackState copyWith(
      {int? rating,
      List<String>? issues,
      final String? customIssue,
      final bool? dislike,
      final bool? liked}) {
    return StoryFeedbackState(
        rating: rating ?? this.rating,
        issues: issues ?? this.issues,
        customIssue: customIssue ?? this.customIssue,
        dislike: dislike ?? this.dislike,
        liked: liked ?? this.liked);
  }

  @override
  List<Object?> get props => [rating, issues, customIssue, dislike, liked];
}

class DislikeStateUpdated extends StoryFeedbackState {
  final bool isDisliked;

  const DislikeStateUpdated({
    required this.isDisliked,
  }) : super();

  @override
  List<Object?> get props => super.props..add(isDisliked);
}
