import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

class StoryRepository {
  final String storyApiUrl = 'http://54.86.247.121:8000/story';
  final String audioApiUrl = 'http://54.86.247.121:8000/audio';
  final String musicAdditionApiUrl = 'http://54.86.247.121:8000/music_addition';

  Future<Map<String, String>> generateStory({
    required String event,
    required String age,
    required String topic,
    required String child_name,
    required String gender,
    required String relation,
    required String relative_name,
    required String genre,
    required String lessons,
    required String length,
    required String language,
  }) async {
    final response = await http.post(Uri.parse(storyApiUrl),
        body: jsonEncode(
          {
            'event': event,
            'age': age,
            'topic': topic,
            'child_name': child_name,
            'gender': gender,
            'relation': relation,
            'relative_name': relative_name,
            'genre': genre,
            'lessons': lessons,
            'length': 200,
            'language': language,
          },
        ));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final Map<String, String> storyMap = {
        "title": responseData["title"] ?? "",
        "story": responseData["story"] ?? "",
      };
      return storyMap;
    } else {
      throw Exception('Failed to generate story: ${response.body}');
    }
  }

  Future<File> speechToText({
    required String text,
    required String language,
  }) async {
    final response = await http.post(
      Uri.parse(audioApiUrl),
      body: jsonEncode({
        'text': text,
        'language': language,
      }),
    );

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;

      // Get the app's temporary directory
      final directory = await getTemporaryDirectory();

      // Define the file path to save the audio
      final audioFilePath = '${directory.path}/story_audio.mp3';

      // Write the audio file to the temporary directory
      final audioFile = File(audioFilePath);
      await audioFile.writeAsBytes(bytes);
      print('///$audioFile');
      return audioFile;
    } else {
      throw Exception('Failed to generate audio: ${response.body}');
    }
  }

  Future<File> addMusicToAudio({
    required String event,
    required File audioFile,
  }) async {
    print('llle$event');
    // Create a multipart request to upload the audio file along with the event
    final request =
        http.MultipartRequest('POST', Uri.parse(musicAdditionApiUrl));
    request.fields['event'] = event;
    request.files
        .add(await http.MultipartFile.fromPath('audiofile', audioFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final bytes = await response.stream.toBytes();

      // Save the received MP3 file to the temporary directory
      final directory = await getTemporaryDirectory();
      final musicAddedAudioFilePath = '${directory.path}/music_added_audio.mp3';
      final musicAddedAudioFile = File(musicAddedAudioFilePath);
      await musicAddedAudioFile.writeAsBytes(bytes);
      print('Music added audio saved at: $musicAddedAudioFile');
      return musicAddedAudioFile;
    } else {
      throw Exception('Failed to add music to audio: ${response.reasonPhrase}');
    }
  }

  Future<String> uploadAudioToFirebase(File audioFile) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('fav_stories/${audioFile.path.split('/').last}');
      await storageRef.putFile(audioFile);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print("Error uploading file to Firebase Storage: $e");
      throw Exception('Failed to upload audio to Firebase');
    }
  }
}
