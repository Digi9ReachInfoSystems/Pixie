import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:pixieapp/blocs/Story_bloc/story_bloc.dart';
import 'package:pixieapp/blocs/Story_bloc/story_event.dart';
import 'package:pixieapp/blocs/Story_bloc/story_state.dart';
import 'package:pixieapp/const/colors.dart';

class BottomNavRecord extends StatefulWidget {
  // final DocumentReference<Object?>? documentReference;
  const BottomNavRecord({super.key});

  @override
  State<BottomNavRecord> createState() => _BottomNavRecordState();
}

class _BottomNavRecordState extends State<BottomNavRecord> {
  @override
  void initState() {
    // requestpermission();
    super.initState();
  }

  void requestpermission() async {
    try {
      var status = await Permission.microphone.status;
      print('Microphone permission status: $status');
      print("***********");
      // If permission is denied or restricted, request it
      if (status.isDenied || status.isRestricted) {
        print('Microphone permission status before request: $status');
        status = await Permission.microphone.request();

        // Log the status after the request
        print('Microphone permission status after request: $status');

        // If permission is still not granted, return an error
        if (!status.isGranted) {
          return;
        }
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.only(bottom: 40),
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
                if (state is AudioRecording) {
                  return ElevatedButton(
                    onPressed: () {
                      context.read<StoryBloc>().add(StopRecordingEvent());
                    },
                    child: const Text("Stop Recording"),
                  );
                }
                if (state is AudioStopped) {
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          context.read<StoryBloc>().add(StartRecordingEvent());
                        },
                        child: const Text("Record Again"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context.read<StoryBloc>().add(AddMusicEvent(
                              event:'',
                              audiofile: File(state.audioPath)));
                        },
                        child: const Text("Save Recording"),
                      ),
                    ],
                  );
                } else {
                  // Initial state

                  return GestureDetector(
                    onTap: () {
                      context.read<StoryBloc>().add(StartRecordingEvent());
                    },
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.buttonblue,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
