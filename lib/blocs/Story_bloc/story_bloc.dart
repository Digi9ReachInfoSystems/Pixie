import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audio_session/audio_session.dart';

import 'package:pixieapp/widgets/audio_controller.dart';
import 'story_event.dart';
import 'story_state.dart';
import 'package:pixieapp/repositories/story_repository.dart';

class StoryBloc extends Bloc<StoryEvent, StoryState> {
  final StoryRepository storyRepository;
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  final AudioController _audioController = AudioController();

  String? _audioPath;

  StoryBloc({required this.storyRepository}) : super(StoryInitial()) {
    _initializeAudio();

    // Event Handlers
    on<GenerateStoryEvent>(_onGenerateStoryEvent);
    on<SpeechToTextEvent>(_onSpeechToTextEvent);
    on<AddMusicEvent>(_onAddMusicEvent);
    on<StartRecordnavbarEvent>(_onStartRecordnavbarEvent);
    on<StartRecordingEvent>((event, emit) async => await _startRecording(emit));
    on<StopRecordingEvent>((event, emit) async => await _stopRecording(emit));
    on<StopplayingEvent>((event, emit) async => await _stopplaying(emit));
  }

  /// Platform-aware audio initialization
  Future<void> _initializeAudio() async {
    try {
      if (Platform.isIOS) {
        var directory = await getApplicationDocumentsDirectory();
        _audioPath = '${directory.path}/';
      } else {
        _audioPath = '/sdcard/Download/appname/';
      }

      await Directory(_audioPath!).create(recursive: true);

      await _recorder.openRecorder();
      await _player.openPlayer();

      if (Platform.isIOS) {
        final session = await AudioSession.instance;
        await session.configure(AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.allowBluetooth |
                  AVAudioSessionCategoryOptions.defaultToSpeaker,
          avAudioSessionMode: AVAudioSessionMode.spokenAudio,
          androidAudioAttributes: const AndroidAudioAttributes(
            contentType: AndroidAudioContentType.speech,
            usage: AndroidAudioUsage.voiceCommunication,
            flags: AndroidAudioFlags.none,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
          androidWillPauseWhenDucked: true,
        ));
      }

      await _recorder.setSubscriptionDuration(const Duration(milliseconds: 10));
      await _player.setSubscriptionDuration(const Duration(milliseconds: 10));

      print('Audio session initialized.');
    } catch (e) {
      print('Failed to initialize audio: $e');
    }
  }

  Future<void> _startRecording(Emitter<StoryState> emit) async {
    try {
      if (!await _checkPermissions()) {
        emit(AudioUploadError('Permissions not granted.'));
        return;
      }

      final String fileName =
          'audio_${DateTime.now().millisecondsSinceEpoch}.aac';
      final String fullPath = '$_audioPath$fileName';

      emit(AudioRecording());

      await _recorder.startRecorder(
        toFile: fullPath,
        codec: Codec.aacMP4,
      );

      print('Recording started: $fullPath');
    } catch (e) {
      emit(AudioUploadError('Start recording failed: $e'));
    }
  }

  Future<void> _stopRecording(Emitter<StoryState> emit) async {
    try {
      final filePath = await _recorder.stopRecorder();
      if (filePath != null) {
        final file = File(filePath);
        if (await file.exists() && (await file.length() > 0)) {
          emit(AudioStopped(audioPath: filePath));
        } else {
          emit(AudioUploadError('Empty or missing file.'));
        }
      } else {
        emit(AudioUploadError('Recording path is null.'));
      }
    } catch (e) {
      emit(AudioUploadError('Stop recording failed: $e'));
    }
  }

  Future<bool> _checkPermissions() async {
    var micStatus = await Permission.microphone.status;
    var storageStatus = await Permission.storage.status;

    if (!micStatus.isGranted) micStatus = await Permission.microphone.request();
    if (!storageStatus.isGranted)
      storageStatus = await Permission.storage.request();

    if (Platform.isAndroid) {
      var manageStorage = await Permission.manageExternalStorage.status;
      if (!manageStorage.isGranted) {
        manageStorage = await Permission.manageExternalStorage.request();
      }
    }

    return micStatus.isGranted && storageStatus.isGranted;
  }

  Future<void> _onGenerateStoryEvent(
      GenerateStoryEvent event, Emitter<StoryState> emit) async {
    emit(StoryLoading());
    try {
      final storyResponse = await storyRepository.generateStory(
        event: event.event,
        age: int.parse(event.age),
        topic: event.topic,
        child_name: event.childName,
        gender: event.gender,
        relation: event.relation,
        relative_name: event.relativeName,
        genre: event.genre,
        lessons: event.lessons,
        length: event.length,
        language: event.language,
        character_name: event.characterName,
        city: event.city,
      );
      emit(StorySuccess(story: storyResponse));
    } catch (e) {
      emit(StoryFailure(error: e.toString()));
    }
  }

  Future<void> _onSpeechToTextEvent(
      SpeechToTextEvent event, Emitter<StoryState> emit) async {
    emit(StoryLoading());
    try {
      final audioFile = await storyRepository.speechToText(
        text: event.text,
        language: event.language,
        event: event.event,
      );
      emit(StoryAudioSuccess(audioFile: audioFile));
    } catch (e) {
      emit(StoryFailure(error: e.toString()));
    }
  }

  Future<void> _onAddMusicEvent(
      AddMusicEvent event, Emitter<StoryState> emit) async {
    emit(StoryLoading());
    try {
      final audioFile = await storyRepository.addMusicToAudio(
        event: event.event,
        audioFile: event.audiofile,
      );
      emit(RecordedStoryAudioSuccess(musicAddedaudioFile: audioFile));
    } catch (e) {
      emit(StoryFailure(error: e.toString()));
    }
  }

  void _onStartRecordnavbarEvent(
      StartRecordnavbarEvent event, Emitter<StoryState> emit) {
    emit(StartRecordaudioScreen());
  }

  Future<void> _stopplaying(Emitter<StoryState> emit) async {
    _audioController.stop();
    emit(const Stopplayingstate());
  }

  @override
  Future<void> close() async {
    try {
      if (_recorder.isRecording) {
        await _recorder.stopRecorder();
      }
      await _recorder.closeRecorder();
      await _player.closePlayer();
    } catch (e) {
      print('Error closing recorder/player: $e');
    }
    return super.close();
  }
}

// Firebase upload helpers (can be moved to a util class if needed)
Future<void> _updateStoryWithAudioUrl(
  DocumentReference<Object?>? storyref,
  String audioUrl,
) async {
  if (storyref != null) {
    try {
      await storyref.update({'audiofile': audioUrl});
    } catch (e) {
      print('Firestore update error: $e');
    }
  }
}

Future<String?> _uploadAudioToStorage(File audioFile) async {
  try {
    final ref = FirebaseStorage.instance
        .ref()
        .child('user_audio')
        .child('${DateTime.now().millisecondsSinceEpoch}.mp3');
    final snapshot = await ref.putFile(audioFile);
    return await snapshot.ref.getDownloadURL();
  } catch (e) {
    print('Audio upload failed: $e');
    return null;
  }
}
