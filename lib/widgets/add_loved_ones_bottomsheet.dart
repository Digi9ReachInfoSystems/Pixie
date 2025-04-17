import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixieapp/blocs/introduction/introduction_bloc.dart';
import 'package:pixieapp/blocs/introduction/introduction_event.dart';
import 'package:pixieapp/blocs/introduction/introduction_state.dart';
import 'package:pixieapp/const/colors.dart';
import 'package:pixieapp/models/Child_data_model.dart';
import 'package:pixieapp/widgets/loading_widget.dart';

class AddLovedOnesBottomSheet extends StatefulWidget {
  const AddLovedOnesBottomSheet({super.key});

  @override
  State<AddLovedOnesBottomSheet> createState() =>
      _AddLovedOnesBottomSheetState();
}

class _AddLovedOnesBottomSheetState extends State<AddLovedOnesBottomSheet> {
  String? selectedRelation;
  bool isExpanded = false;
  bool isSubmitting = false;
  final FocusNode _focusNode = FocusNode();
  final List<String> relations = [
    'Maternal Grandfather',
    'Maternal Grandmother',
    'Elder Sister',
    'Younger Brother',
    'Elder Brother',
    'Female Friend',
    'Male Friend',
    'Pet Cat',
    'Pet Dog'
  ];
  TextEditingController nameofRelation = TextEditingController();
  @override
  void initState() {
    _focusNode.unfocus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

    return BlocConsumer<IntroductionBloc, IntroductionState>(
      listener: (context, state) {
        if (state is RelationUpdated) {
          Navigator.pop(context); // Go back once relation is added
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            Container(
              height: deviceHeight * 0.8,
              width: deviceWidth,
              decoration: const BoxDecoration(
                color: AppColors.bottomSheetBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Container(
                  padding: const EdgeInsets.only(
                    top: 10,
                    left: 20,
                    right: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Text(
                        'Add a loved one',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textColorblue,
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          _focusNode.unfocus();
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.buttonblue),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedRelation ?? 'Select Relation',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textColorGrey,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Icon(
                                isExpanded
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                                color: AppColors.buttonblue,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Material(
                        elevation: 2,
                        borderRadius: BorderRadius.circular(10),
                        child: TextField(
                          focusNode: _focusNode,
                          textCapitalization: TextCapitalization.sentences,
                          controller: nameofRelation,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.none,
                          ),
                          cursorColor: AppColors.textColorblue,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.kwhiteColor,
                            border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: AppColors.kwhiteColor),
                                borderRadius: BorderRadius.circular(10)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: AppColors.kwhiteColor),
                                borderRadius: BorderRadius.circular(10)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: AppColors.kwhiteColor),
                                borderRadius: BorderRadius.circular(10)),
                            errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: AppColors.kwhiteColor),
                                borderRadius: BorderRadius.circular(10)),
                            hintText: 'Type name',
                            hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textColorGrey,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.9,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  if (selectedRelation != null &&
                                      nameofRelation.text.isNotEmpty) {
                                    setState(() {
                                      isSubmitting = true;
                                    });
                                    User? user =
                                        FirebaseAuth.instance.currentUser;
                                    if (user != null) {
                                      // Add relation to Firestore
                                      await addRelationToFirebase(
                                          user.uid,
                                          selectedRelation!,
                                          nameofRelation.text);
                                      setState(() {
                                        isSubmitting = false;
                                      });
                                      Navigator.pop(context);
                                      FocusScope.of(context).unfocus();
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            foregroundColor: AppColors.kwhiteColor,
                            backgroundColor: AppColors.buttonblue,
                          ),
                          child: isSubmitting
                              ? const LoadingWidget()
                              : Text("Add",
                                  style: theme.textTheme.bodyLarge!.copyWith(
                                      color: AppColors.textColorWhite,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isExpanded)
              Positioned(
                top: deviceHeight * 0.2,
                left: 16,
                right: 16,
                child: Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(8),
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: relations.length,
                    itemBuilder: (context, index) {
                      final relation = relations[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedRelation = relation;
                            isExpanded = false;
                          });
                        },
                        child: Container(
                          color: AppColors.kwhiteColor,
                          height: 50,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          child: Text(
                            relation,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textColorblue,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> addRelationToFirebase(
      String userId, String relation, String name) async {
    // Capitalize the first letter of relation and name
    String capitalizedRelation =
        relation[0].toUpperCase() + relation.substring(1);
    String capitalizedName = name[0].toUpperCase() + name.substring(1);

    final lovedOne = Lovedonces(
      relation: capitalizedRelation,
      name: capitalizedName,
    );

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'loved_once': FieldValue.arrayUnion([lovedOne.toMap()]),
      'moreLovedOnes': FieldValue.arrayUnion([lovedOne.toMap()])
    });
  }
}
