import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pixieapp/blocs/Story_bloc/story_bloc.dart';
import 'package:pixieapp/blocs/Story_bloc/story_event.dart';
import 'package:pixieapp/blocs/add_character_Bloc.dart/add_character_bloc.dart';
import 'package:pixieapp/blocs/add_character_Bloc.dart/add_character_event.dart';
import 'package:pixieapp/blocs/add_character_Bloc.dart/add_character_state.dart';

class NavBar3 extends StatefulWidget {
  final DocumentReference<Object?>? documentReference;
  final bool favstatus;
  final String text;
  final String language;
  final String event;
  const NavBar3(
      {super.key,
      required this.documentReference,
      required this.favstatus,
      required this.text,
      required this.event,
      required this.language});

  @override
  State<NavBar3> createState() => _NavBar3State();
}

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class _NavBar3State extends State<NavBar3> {
  @override
  void initState() {
    context
        .read<AddCharacterBloc>()
        .add(UpdatefavbuttonEvent(widget.favstatus));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddCharacterBloc, AddCharacterState>(
      builder: (context, state) => Padding(
        padding: const EdgeInsets.only(left: 2, right: 2),
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              image: DecorationImage(
                  image: AssetImage('assets/images/navbar.png'))),
          child: Padding(
            padding:
                const EdgeInsets.only(left: 30, right: 30, top: 5, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                IconButton(
                  onPressed: () {},
                  focusColor: Colors.white,
                  color: Colors.white,
                  hoverColor: Colors.white,
                  splashColor: Colors.white,
                  disabledColor: Colors.white,
                  highlightColor: Colors.white,
                  icon: SvgPicture.asset(
                    'assets/images/home_unselect.svg',
                    width: 40,
                    height: 40,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    context.read<StoryBloc>().add(SpeechToTextEvent(
                        event: widget.event,
                        text: widget.text,
                        language: widget.language));
                  },
                  icon: SvgPicture.asset(
                    'assets/images/pausebutton.svg',
                    width: 60,
                    height: 60,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: SizedBox(
                    width: 50,
                    child: IconButton(
                      onPressed: () {
                        context
                            .read<AddCharacterBloc>()
                            .add(UpdatefavbuttonEvent(!state.fav));
                        updatefirebase(
                            docRef: widget.documentReference!, fav: !state.fav);
                      },
                      icon: SvgPicture.asset(
                        state.fav == true
                            ? 'assets/images/Heart_filled.svg'
                            : 'assets/images/Heart.svg',
                        width: state.fav || widget.favstatus == true ? 40 : 25,
                        height: state.fav == true ? 40 : 25,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> updatefirebase(
      {required bool fav, required DocumentReference<Object?> docRef}) async {
    if (fav) {
      // Remove the story from favorites
      await docRef.update({
        'isfav': true,
      });
      print('Story added to fav');
    } else {
      await docRef.update({
        'isfav': false,
      });
      print('Story removed from fav');
    }
  }
}
