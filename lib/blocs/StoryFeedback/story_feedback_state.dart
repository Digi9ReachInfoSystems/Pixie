import 'package:equatable/equatable.dart';

class StoryFeedbackState extends Equatable {
  final int rating;
  final List<String> issues;

  const StoryFeedbackState({
    this.rating = 0,
    this.issues = const [],
  });

  StoryFeedbackState copyWith({
    int? rating,
    List<String>? issues,
  }) {
    return StoryFeedbackState(
      rating: rating ?? this.rating,
      issues: issues ?? this.issues,
    );
  }

  @override
  List<Object?> get props => [rating, issues];
}
class DislikeStateUpdated extends StoryFeedbackState {
  final bool isDisliked;

  const DislikeStateUpdated({
    required this.isDisliked,
    
  }) : super();

  @override
  List<Object?> get props => super.props..add(isDisliked);
}
