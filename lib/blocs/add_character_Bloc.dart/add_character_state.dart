import 'package:equatable/equatable.dart';
import 'package:pixieapp/models/Child_data_model.dart';
import 'package:pixieapp/models/story_model.dart';

class AddCharacterState extends Equatable {
  final int currentPageIndex;
  final Language language;
  final Lovedonces? lovedOnce;
  final String? lessons;
  final int? selectedindexlesson;
  final String? charactorname;
  final int? selectedindexcharactor;
  final int selectedindex;
  final String genre;
  final String musicAndSpeed;
  final bool fav;
  final bool dislike;
  final bool showfeedback;
  final String characterName;

  const AddCharacterState(
      {required this.currentPageIndex,
      required this.language,
      required this.selectedindex,
      required this.selectedindexlesson,
      required this.selectedindexcharactor,
      required this.genre,
      required this.musicAndSpeed,
      required this.fav,
      required this.dislike,
      required this.showfeedback,
      this.lessons,
      this.charactorname,
      this.lovedOnce,
      required this.characterName});

  // Create a copyWith method to update specific parts of the state
  AddCharacterState copyWith(
      {int? currentPageIndex,
      Language? language,
      Lovedonces? lovedOnce,
      String? lessons,
      String? charactorname,
      int? selectedindex,
      int? selectedindexlesson,
      int? selectedindexcharactor,
      bool? fav,
      bool? dislike,
      bool? showfeedback,
      String? genre,
      String? musicAndSpeed,
      String? characterName}) {
    return AddCharacterState(
        currentPageIndex: currentPageIndex ?? this.currentPageIndex,
        language: language ?? this.language,
        lovedOnce: lovedOnce ?? this.lovedOnce,
        selectedindex: selectedindex ?? this.selectedindex,
        lessons: lessons ?? this.lessons,
        selectedindexlesson: selectedindexlesson ?? this.selectedindexlesson,
        charactorname: charactorname ?? this.charactorname,
        selectedindexcharactor:
            selectedindexcharactor ?? this.selectedindexcharactor,
        genre: genre ?? this.genre,
        musicAndSpeed: musicAndSpeed ?? this.musicAndSpeed,
        fav: fav ?? this.fav,
        dislike: dislike ?? this.dislike,
        showfeedback: showfeedback ?? this.showfeedback,
        characterName: characterName ?? this.characterName);
  }

  @override
  List<Object?> get props => [
        currentPageIndex,
        language,
        lovedOnce,
        lessons,
        charactorname,
        selectedindex,
        selectedindexlesson,
        selectedindexcharactor,
        genre,
        musicAndSpeed,
        fav,
        dislike,
        showfeedback,
        characterName
      ];
}
