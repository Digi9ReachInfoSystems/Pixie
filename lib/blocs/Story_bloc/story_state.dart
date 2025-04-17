import 'package:equatable/equatable.dart';
import 'dart:io';

// Abstract base class for all states
abstract class StoryState extends Equatable {
  const StoryState();

  @override
  List<Object?> get props => [];
}

// Initial state, when nothing has happened yet
class StoryInitial extends StoryState {}

// State when the app is loading, like during an API call
class StoryLoading extends StoryState {}

// State when the play button is loading, like during an API call
class StoryAudioLoading extends StoryState {}

// State when a story is successfully generated
class StorySuccess extends StoryState {
  final Map<String, String> story;

  const StorySuccess({required this.story});

  @override
  List<Object?> get props => [story];
}

// State when the audio file is successfully generated from text
class StoryAudioSuccess extends StoryState {
  final File audioFile;

  const StoryAudioSuccess({required this.audioFile});

  @override
  List<Object?> get props => [audioFile];
}

// Recorded audio
class RecordedStoryAudioSuccess extends StoryState {
  final File musicAddedaudioFile;

  const RecordedStoryAudioSuccess({required this.musicAddedaudioFile});

  @override
  List<Object?> get props => [musicAddedaudioFile];
}

//Record audio navbar
class RecordaudioScreen extends StoryState {}

// Recording screen
class StartRecordaudioScreen extends StoryState {}

// State when there is an error
class StoryFailure extends StoryState {
  final String error;

  const StoryFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class AudioRecording extends StoryState {}

class AudioRecorded extends StoryState {
  final String audioPath;

  AudioRecorded({required this.audioPath});
}

class AudioStopped extends StoryState {
  final String audioPath;

  AudioStopped({required this.audioPath});
}

class Stopplayingstate extends StoryState {
  const Stopplayingstate();
}

class AudioUploading extends StoryState {}

class AudioUploaded extends StoryState {
  final String audioUrl;

  AudioUploaded(this.audioUrl);
}

class AudioUploadError extends StoryState {
  final String error;

  AudioUploadError(this.error);
}
