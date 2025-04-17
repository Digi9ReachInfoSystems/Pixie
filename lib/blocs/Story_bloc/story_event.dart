import 'dart:io';

import 'package:equatable/equatable.dart';

// Abstract base class for all events
abstract class StoryEvent extends Equatable {
  const StoryEvent();

  @override
  List<Object?> get props => [];
}

// Event for generating a story
class GenerateStoryEvent extends StoryEvent {
  final String event;
  final String age;
  final String topic;
  final String childName;
  final String gender;
  final String relation;
  final String relativeName;
  final String genre;
  final String lessons;
  final String length;
  final String language;
  final String characterName;
  final String city;

  const GenerateStoryEvent(
      {required this.event,
      required this.age,
      required this.topic,
      required this.childName,
      required this.gender,
      required this.relation,
      required this.relativeName,
      required this.genre,
      required this.lessons,
      required this.length,
      required this.language,
      required this.characterName,
      required this.city});

  @override
  List<Object?> get props => [
        event,
        age,
        topic,
        childName,
        gender,
        relation,
        relativeName,
        genre,
        lessons,
        length,
        language,
        characterName,
        city
      ];
}

// Event for converting text to speech
class SpeechToTextEvent extends StoryEvent {
  final String text;
  final String language;
  final String event;

  const SpeechToTextEvent(
      {required this.text, required this.language, required this.event});

  @override
  List<Object?> get props => [text, language];
}

// Event for converting text to speech
class AddMusicEvent extends StoryEvent {
  final String event;
  final File audiofile;

  const AddMusicEvent({
    required this.event,
    required this.audiofile,
  });

  @override
  List<Object?> get props => [event, audiofile];
}

// Event record or leson option
class RecordnavbarEvent extends StoryEvent {
  const RecordnavbarEvent();
}

//  for rocordbutton navbar
class StartRecordnavbarEvent extends StoryEvent {
  const StartRecordnavbarEvent();
}

class StartRecordingEvent extends StoryEvent {}

class StopRecordingEvent extends StoryEvent {}

class StopplayingEvent extends StoryEvent {}
