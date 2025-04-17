import 'package:pixieapp/models/Child_data_model.dart';

abstract class IntroductionEvent {}

class TextChanged extends IntroductionEvent {
  final String name;
  TextChanged({required this.name});
}

class GenderChanged extends IntroductionEvent {
  final Gender gender;
  GenderChanged({required this.gender});
}

class DobChanged extends IntroductionEvent {
  final DateTime dob;
  DobChanged({required this.dob});
}

class FavListChanged extends IntroductionEvent {
  final String favList;
  FavListChanged({required this.favList});
}

class RelationAdded extends IntroductionEvent {
  final String relation;
  final String relationName;
  RelationAdded({required this.relation, required this.relationName});
}

class loadingEvent extends IntroductionEvent {}
