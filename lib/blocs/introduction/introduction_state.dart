import 'package:pixieapp/models/Child_data_model.dart';

abstract class IntroductionState {}

class IntroductionInitial extends IntroductionState {
  final Gender gender;

  IntroductionInitial({required this.gender});
}

class TextUpdated extends IntroductionState {
  final String name;
  TextUpdated({required this.name});
}

class GenderUpdated extends IntroductionState {
  final Gender gender;
  GenderUpdated({required this.gender});
}

class DobUpdated extends IntroductionState {
  final DateTime dob;
  DobUpdated({required this.dob});
}

class FavListUpdated extends IntroductionState {
  final String favList;
  FavListUpdated({required this.favList});
}

class RelationUpdated extends IntroductionState {
  final String relation;
  final String relationName;
  RelationUpdated({required this.relation, required this.relationName});
}

class loadingState extends IntroductionState {}
