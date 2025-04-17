import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:pixieapp/blocs/Story_bloc/story_bloc.dart';
import 'package:pixieapp/blocs/Story_bloc/story_event.dart';
import 'package:pixieapp/blocs/Story_bloc/story_state.dart';
import 'package:pixieapp/blocs/add_character_Bloc.dart/add_character_bloc.dart';
import 'package:pixieapp/const/colors.dart';

class BottomNavRecord extends StatefulWidget {
  // final DocumentReference<Object?>? documentReference;
  const BottomNavRecord({super.key});

  @override
  State<BottomNavRecord> createState() => _BottomNavRecordState();
}

class _BottomNavRecordState extends State<BottomNavRecord> {
  Timer _timer = Timer.periodic(
    Duration(seconds: 1),
    (timer) {},
  );
  int _elapsedTimeInSeconds = 0; // Time in seconds
  bool _isRecording = false;

  @override
  void initState() {
    requestpermission();
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void requestpermission() async {
    try {
      var status = await Permission.microphone.status;
      // print('Microphone permission status: $status');
      // print("***********");
      // If permission is denied or restricted, request it
      if (status.isDenied || status.isRestricted) {
        // print('Microphone permission status before request: $status');
        status = await Permission.microphone.request();

        // Log the status after the request
        // print('Microphone permission status after request: $status');

        // If permission is still not granted, return an error
        if (!status.isGranted) {
          return;
        }
      }
    } catch (error) {
      // print(error);
    }
  }

  // Start or stop recording
  void _toggleRecording() {
    if (_isRecording) {
      _timer.cancel(); // Stop the timer
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _elapsedTimeInSeconds++;
        });
      });
      // _isRecording = true;
    }

    setState(() {
      _isRecording = !_isRecording;
    });
  }

  // Reset the timer
  void _resetTimer() {
    _timer.cancel();
    setState(() {
      _elapsedTimeInSeconds = 0;
      _isRecording = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    int minutes = _elapsedTimeInSeconds ~/ 60;
    int seconds = _elapsedTimeInSeconds % 60;
    return BlocListener<StoryBloc, StoryState>(
      listener: (context, state) async {
        if (state is AudioUploaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Audio uploaded successfully')),
          );
        } else if (state is AudioUploadError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading audio: ${state.error}')),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 10),
        height: 200,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(12)),
          image: DecorationImage(
              image: AssetImage('assets/images/Rectangle 11723.png'),
              fit: BoxFit.fill),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BlocBuilder<StoryBloc, StoryState>(
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextButton(
                          onPressed: () {
                            if (state is AudioStopped) {}
                            // _resetTimer;
                            _timer.cancel();
                            setState(() {
                              _elapsedTimeInSeconds = 0;
                              _isRecording = false;
                            });

                            _timer = Timer.periodic(const Duration(seconds: 1),
                                (timer) {
                              setState(() {
                                _elapsedTimeInSeconds++;
                              });
                            });
                            context
                                .read<StoryBloc>()
                                .add(StartRecordingEvent());
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: (state is AudioStopped)
                                ? AppColors.buttonblue
                                : AppColors.buttonblue
                                    .withOpacity(.4), // Text color
                            backgroundColor:
                                Colors.transparent, // Button background color
                          ),
                          child: const Text(
                            "Record Again",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: state is AudioRecording
                            ? Column(
                                children: [
                                  Text(
                                    ' ${formatElapsedTime(_elapsedTimeInSeconds)}',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: AppColors.buttonblue,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          // _toggleRecording();
                                          _timer.cancel();
                                          context
                                              .read<StoryBloc>()
                                              .add(StopRecordingEvent());
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color:
                                                      const Color(0xff6F6F6F),
                                                  width: 2)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Container(
                                              height: 40,
                                              width: 40,
                                              decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(7)),
                                                color: AppColors.buttonblue,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    ' ${formatElapsedTime(_elapsedTimeInSeconds)}',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: AppColors.buttonblue,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 15),
                                  InkWell(
                                    onTap: () async {
                                      // _toggleRecording;
                                      _timer.cancel();
                                      setState(() {
                                        _elapsedTimeInSeconds = 0;
                                        _isRecording = false;
                                      });
                                      _timer = Timer.periodic(
                                          const Duration(seconds: 1), (timer) {
                                        setState(() {
                                          _elapsedTimeInSeconds++;
                                        });
                                      });

                                      context
                                          .read<StoryBloc>()
                                          .add(StartRecordingEvent());
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: const Color(0xff6F6F6F),
                                              width: 2)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Container(
                                          height: 80,
                                          width: 80,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.buttonblue,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      Expanded(
                        flex: 1,
                        child: TextButton(
                          onPressed: () {
                            if (state is AudioStopped) {
                              final addcharacterState =
                                  context.read<AddCharacterBloc>().state;

                              // print(addcharacterState.musicAndSpeed);
                              context.read<StoryBloc>().add(AddMusicEvent(
                                  event: addcharacterState.musicAndSpeed ??
                                      "bedtime",
                                  audiofile: File(state.audioPath)));
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: (state is AudioStopped)
                                ? AppColors.buttonblue
                                : AppColors.buttonblue
                                    .withOpacity(.4), // Text color
                            backgroundColor:
                                Colors.transparent, // Button background color
                          ),
                          child: const Text(
                            "Save Recording",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

String formatElapsedTime(int secondss) {
  // Create a Duration object from seconds
  Duration duration = Duration(seconds: secondss);

  // Format it as HH:mm:ss
  String hours = duration.inHours.toString().padLeft(2, '0');
  String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

  return '$hours:$minutes:$seconds';
}
