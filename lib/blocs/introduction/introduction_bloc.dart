import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pixieapp/models/Child_data_model.dart';

import 'introduction_event.dart';
import 'introduction_state.dart';

class IntroductionBloc extends Bloc<IntroductionEvent, IntroductionState> {
  IntroductionBloc() : super(IntroductionInitial(gender: Gender.notselected)) {
    on<TextChanged>((event, emit) {
      emit(TextUpdated(name: event.name));
    });

    on<GenderChanged>((event, emit) {
      emit(GenderUpdated(gender: event.gender));
    });

    on<DobChanged>((event, emit) {
      emit(DobUpdated(dob: event.dob));
    });

    on<FavListChanged>((event, emit) {
      emit(FavListUpdated(favList: event.favList));
    });

    on<RelationAdded>((event, emit) {
      emit(RelationUpdated(
          relation: event.relation, relationName: event.relationName));
    });

    on<loadingEvent>((event, emit) {
      emit(loadingState());
    });
  }
}
