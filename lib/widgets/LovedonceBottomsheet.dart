import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pixieapp/blocs/add_character_Bloc.dart/add_character_bloc.dart';
import 'package:pixieapp/blocs/add_character_Bloc.dart/add_character_event.dart';
import 'package:pixieapp/blocs/add_character_Bloc.dart/add_character_state.dart';
import 'package:pixieapp/const/colors.dart';
import 'package:pixieapp/models/Child_data_model.dart';

class LovedonceBottomsheet extends StatefulWidget {
  const LovedonceBottomsheet({super.key});

  @override
  State<LovedonceBottomsheet> createState() => _LovedonceBottomsheetState();
}

class _LovedonceBottomsheetState extends State<LovedonceBottomsheet> {
  @override
  List<Lovedonces> lovedOnceList = [];
  int? selectedlovedone;
  void initState() {
    super.initState();
    fetchLovedOnes().then((lovedOnes) {
      setState(() {
        lovedOnceList = lovedOnes;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<AddCharacterBloc, AddCharacterState>(
        builder: (context, state) => Container(
              height: MediaQuery.of(context).size.height * .6,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                  color: AppColors.bottomSheetBackground,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18))),
              child: Padding(
                padding: const EdgeInsets.only(top: 25, left: 20, right: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select a loved one',
                        style: theme.textTheme.displayMedium?.copyWith(
                            color: AppColors.textColorblue,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Wrap(
                            children: List<Widget>.generate(
                                lovedOnceList.length, (int index) {
                          return Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: ChoiceChip(
                              onSelected: (value) {
                                context.read<AddCharacterBloc>().add(
                                    AddLovedOnceEvent(lovedOnceList[index],
                                        selectedindex: index));
                                context.pop();
                              },
                              side: const BorderSide(
                                  width: .4,
                                  color: Color.fromARGB(255, 152, 152, 152)),
                              shadowColor: Colors.black,
                              selectedColor: AppColors.kpurple,
                              elevation: 3,
                              checkmarkColor: AppColors.kwhiteColor,
                              label: Text(
                                (lovedOnceList[index].relation == "Mother" ||
                                        lovedOnceList[index].relation ==
                                            "Father" ||
                                        lovedOnceList[index].relation ==
                                            "Grandfather" ||
                                        lovedOnceList[index].relation ==
                                            "Grandmother" ||
                                        lovedOnceList[index].relation ==
                                            'Maternal Grandfather' ||
                                        lovedOnceList[index].relation ==
                                            "Maternal Grandmother")
                                    ? lovedOnceList[index].relation
                                    : lovedOnceList[index].name,
                                style: TextStyle(
                                    color: state.selectedindex == index
                                        ? AppColors.kwhiteColor
                                        : AppColors.kblackColor),
                              ),
                              selected:
                                  state.selectedindex == index ? true : false,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              padding: const EdgeInsets.all(16),
                            ),
                          );
                        })),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ));
  }
}

Future<List<Lovedonces>> fetchLovedOnes() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return [];

  DocumentSnapshot doc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  List<dynamic> lovedOnceData = doc['loved_once'] ?? [];

  return lovedOnceData
      .where(
          (item) => item['name'] != null && item['name'].toString().isNotEmpty)
      .map((item) => Lovedonces.fromMap(item))
      .toList();
}
