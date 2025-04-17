import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:pixieapp/blocs/add_character_Bloc.dart/add_character_bloc.dart';
import 'package:pixieapp/blocs/add_character_Bloc.dart/add_character_event.dart';
import 'package:pixieapp/blocs/add_character_Bloc.dart/add_character_state.dart';
import 'package:pixieapp/blocs/introduction/introduction_event.dart';
import 'package:pixieapp/blocs/introduction/introduction_state.dart';
import 'package:pixieapp/const/colors.dart';
import 'package:pixieapp/models/Child_data_model.dart';
import 'package:pixieapp/widgets/add_charactor_story.dart';
import 'package:pixieapp/widgets/widgets_index.dart';
import '../../blocs/introduction/introduction_bloc.dart';
import 'package:pixieapp/widgets/analytics.dart';

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({super.key});

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  // State field(s) for PageView widget.
  PageController? pageViewController;
  ClildDataModel childdata = ClildDataModel(
    name: '',
    gender: Gender.notselected,
    favthings: ["Motorbike", "Robot", "Monkey", "Race cars"],
    dob: DateTime.now(),
    lovedonce: [],
    moreLovedOnce: [],
  );
  List<String> suggestedCharactersList = [];
  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;

  // State field(s) for ChoiceChips widget.

  final scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedPronounIndex = -1;

  final TextEditingController nameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final TextEditingController mother = TextEditingController();
  final TextEditingController father = TextEditingController();
  final TextEditingController GrandMother = TextEditingController();
  final TextEditingController GrandFather = TextEditingController();
  final TextEditingController pet = TextEditingController();
  final List<String> pronouns = ['He', 'She', 'Prefer not to say'];
  int currentpage_index = 0;

  DateTime? selectedDate;

  Widget _buildPronounButton(
      {required String text,
      required double width,
      required bool selected,
      required VoidCallback ontap}) {
    return InkWell(
      onTap: ontap,
      child: Container(
          height: 50,
          width: width,
          decoration: BoxDecoration(
            color: selected ? AppColors.kpurple : AppColors.kwhiteColor,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Center(
              child: Text(
            text,
            style: TextStyle(
                color:
                    selected ? AppColors.kwhiteColor : AppColors.kblackColor),
          ))),
    );
  }

  @override
  void initState() {
    favThings();
    fetchSuggestedCharacters().then((suggestedlist) {
      setState(() {
        suggestedCharactersList = suggestedlist;
      });
    });
    _focusNode.unfocus();
    super.initState();
  }

  Future<void> favThings() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();

      List<String> fetchedFavThings = List<String>.from(userDoc['fav_things']);
      childdata.favthings = fetchedFavThings;
    } catch (e) {
      print('Error');
    }
  }

  void _showDatePicker(BuildContext context) {
    _focusNode.unfocus();
    final theme = Theme.of(context);
    showModalBottomSheet(
      backgroundColor: AppColors.bottomSheetBackground,
      context: context,
      builder: (BuildContext builder) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 200,
              child: CupertinoTheme(
                data: const CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textColorblue,
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  maximumYear: DateTime.now().year,
                  minimumYear: DateTime.now().year - 20,
                  initialDateTime: selectedDate ?? DateTime.now(),
                  maximumDate: DateTime.now(),
                  mode: CupertinoDatePickerMode.date,
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      selectedDate = newDate;
                    });
                    context
                        .read<IntroductionBloc>()
                        .add(DobChanged(dob: newDate));
                  },
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * .9,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedDate = selectedDate ?? DateTime.now();
                  });
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    backgroundColor: AppColors.buttonblue),
                child: Text('Add',
                    style: theme.textTheme.bodyMedium!
                        .copyWith(color: AppColors.textColorWhite)),
              ),
            ),
            const SizedBox(height: 25)
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    User? user = FirebaseAuth.instance.currentUser;
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color.fromARGB(255, 236, 215, 244),
        key: scaffoldKey,
        body: BlocConsumer<IntroductionBloc, IntroductionState>(
          listener: (context, state) {
            if (state is TextUpdated) {
              childdata.name = state.name;
            }
            if (state is GenderUpdated) {
              // print('ddddddd${state.gender}');
              childdata.gender = state.gender;
            }
            if (state is DobUpdated) {
              //print('ddddddd${state.dob}');
              childdata.dob = state.dob;
            }
            if (state is FavListUpdated) {
              String lastadded = state.favList;
              childdata.favthings.add(lastadded);
              //   print('.....${childdata.favthings}');
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .update({
                'fav_things': childdata.favthings,
              });
            }
          },
          builder: (context, state) {
            return Container(
              width: MediaQuery.sizeOf(context).width * 1.0,
              height: MediaQuery.sizeOf(context).height * 1.0,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 231, 201, 249),
                    Color.fromARGB(255, 248, 244, 187)
                  ],
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: deviceWidth,
                      height: deviceHeight * .9,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20.0, 10.0, 20.0, 0),
                        child: PageView(
                          physics: const NeverScrollableScrollPhysics(),
                          allowImplicitScrolling: false,
                          controller: pageViewController ??=
                              PageController(initialPage: 0),
                          onPageChanged: (index) {
                            setState(() {
                              currentpage_index = index;
                            });
                          },
                          scrollDirection: Axis.horizontal,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 25),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE8DEF8),
                                            borderRadius:
                                                BorderRadius.circular(40.0),
                                          ),
                                          child: IconButton(
                                            onPressed: () async {
                                              context.pop();
                                            },
                                            icon: const Icon(
                                              Icons.arrow_back,
                                              color: AppColors.sliderColor,
                                              size: 23,
                                            ),
                                          )),
                                      const SizedBox(width: 5),
                                      customSlider(percent: 1),
                                      // customSlider(percent: 0),
                                      customSlider(percent: 0),
                                      const SizedBox(width: 10),
                                      Transform.rotate(
                                        angle: .2,
                                        child: Image.asset(
                                          'assets/images/star.png',
                                          width: 70,
                                          height: 80,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Whom are you creating stories for?",
                                          style: theme.textTheme.displaySmall!
                                              .copyWith(
                                                  color:
                                                      AppColors.textColorblue,
                                                  fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "This helps Pixie personalise the stories",
                                          style: theme.textTheme.headlineSmall!
                                              .copyWith(
                                                  color:
                                                      AppColors.textColorblack,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w400),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 20.0, bottom: 10),
                                          child: Text(
                                            "First name",
                                            style: theme
                                                .textTheme.headlineSmall!
                                                .copyWith(
                                                    color: AppColors
                                                        .textColorblack,
                                                    fontWeight:
                                                        FontWeight.w500),
                                          ),
                                        ),

                                        Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.kwhiteColor,
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          child: TextField(
                                            focusNode: _focusNode,
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            style: theme.textTheme.bodyMedium,
                                            controller: nameController,
                                            cursorColor:
                                                AppColors.textColorblue,
                                            onChanged: (value) {
                                              context
                                                  .read<IntroductionBloc>()
                                                  .add(
                                                      TextChanged(name: value));
                                            },
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide.none,
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide.none,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide.none,
                                              ),
                                              errorBorder: InputBorder.none,
                                              focusedErrorBorder:
                                                  InputBorder.none,
                                              disabledBorder: InputBorder.none,
                                              fillColor: AppColors.kwhiteColor,
                                              hintText: 'Your child\'s name',
                                              hintStyle: theme
                                                  .textTheme.bodyMedium
                                                  ?.copyWith(
                                                color:
                                                    AppColors.textColorDimGrey,
                                              ),
                                              focusColor:
                                                  AppColors.textColorblue,
                                            ),
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 20.0, bottom: 10.0),
                                          child: Text(
                                            "Pronoun",
                                            style: theme
                                                .textTheme.headlineSmall!
                                                .copyWith(
                                                    color: AppColors
                                                        .textColorblack,
                                                    fontWeight:
                                                        FontWeight.w500),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            _buildPronounButton(
                                                text: "He",
                                                width: deviceWidth * 0.4305,
                                                ontap: () {
                                                  _focusNode.unfocus();
                                                  context
                                                      .read<IntroductionBloc>()
                                                      .add(GenderChanged(
                                                          gender: Gender.he));
                                                },
                                                selected: childdata.gender ==
                                                        Gender.he
                                                    ? true
                                                    : false),
                                            SizedBox(
                                                width: deviceWidth * 0.0277),
                                            _buildPronounButton(
                                                text: "She",
                                                width: deviceWidth * 0.4305,
                                                ontap: () {
                                                  _focusNode.unfocus();
                                                  context
                                                      .read<IntroductionBloc>()
                                                      .add(GenderChanged(
                                                          gender: Gender.she));
                                                },
                                                selected: childdata.gender ==
                                                        Gender.she
                                                    ? true
                                                    : false),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        _buildPronounButton(
                                            text: "Prefer not to say",
                                            width: deviceWidth * 0.8888,
                                            ontap: () {
                                              _focusNode.unfocus();
                                              context
                                                  .read<IntroductionBloc>()
                                                  .add(GenderChanged(
                                                      gender: Gender
                                                          .prefernottosay));
                                            },
                                            selected: childdata.gender ==
                                                    Gender.prefernottosay
                                                ? true
                                                : false),
                                        const SizedBox(height: 20),

                                        Text(
                                          "Date of Birth",
                                          style: theme.textTheme.headlineSmall!
                                              .copyWith(
                                                  color:
                                                      AppColors.textColorblack,
                                                  fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 20),
                                        GestureDetector(
                                          onTap: () => _showDatePicker(context),
                                          child: Container(
                                            padding: const EdgeInsets.only(
                                                left: 10.0),
                                            width: deviceWidth,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: AppColors.kwhiteColor,
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: selectedDate != null
                                                  ? Text(
                                                      "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: AppColors
                                                            .textColorblack,
                                                      ),
                                                    )
                                                  : const Text(
                                                      "dd/mm/yyyy",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: AppColors
                                                            .textColorDimGrey,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),

                                        // CupertinoButton(
                                        //   child: Text('Done'),
                                        //   onPressed: () =>
                                        //       Navigator.of(context).pop(),
                                        // ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),

                            /******************************************** */

                            // BlocConsumer<AddCharacterBloc, AddCharacterState>(
                            //   listener: (context, state) {
                            //     // TODO: implement listener
                            //   },
                            //   builder: (context, state) {
                            //     return Column(
                            //       mainAxisSize: MainAxisSize.max,
                            //       crossAxisAlignment:
                            //           CrossAxisAlignment.start,
                            //       children: [
                            //         Row(
                            //           mainAxisSize: MainAxisSize.max,
                            //           children: [
                            //             Container(
                            //                 decoration: BoxDecoration(
                            //                   color: const Color(
                            //                       0xFFE8DEF8), // Background color
                            //                   borderRadius:
                            //                       BorderRadius.circular(40.0),
                            //                 ),
                            //                 child: IconButton(
                            //                   onPressed: () async {
                            //                     pageViewController
                            //                         ?.previousPage(
                            //                       duration: const Duration(
                            //                           milliseconds: 300),
                            //                       curve: Curves.ease,
                            //                     );
                            //                   },
                            //                   icon: const Icon(
                            //                     Icons.arrow_back,
                            //                     color: AppColors.sliderColor,
                            //                     size: 23,
                            //                   ),
                            //                 )),
                            //             const SizedBox(width: 5),
                            //             customSlider(percent: 0),
                            //             customSlider(percent: 1),
                            //             customSlider(percent: 0),
                            //             const SizedBox(width: 10),
                            //             Transform.rotate(
                            //               angle: .2,
                            //               child: Image.asset(
                            //                 'assets/images/star.png',
                            //                 width: 70,
                            //                 height: 80,
                            //               ),
                            //             ),
                            //           ],
                            //         ),
                            //         Text(
                            //           'What are ${childdata.name}\'s favorite things?',
                            //           style: theme.textTheme.displaySmall!
                            //               .copyWith(
                            //                   color: AppColors.textColorblue,
                            //                   fontWeight: FontWeight.w600),
                            //         ),
                            //         const SizedBox(height: 8),
                            //         Text(
                            //           "We can feature them in stories",
                            //           style: theme.textTheme.headlineSmall!
                            //               .copyWith(
                            //                   color: AppColors.textColorblack,
                            //                   fontWeight: FontWeight.w400,
                            //                   fontSize: 20),
                            //         ),
                            //         const SizedBox(height: 30),
                            //         Text(
                            //           'Select one',
                            //           style: theme.textTheme.displaySmall!
                            //               .copyWith(
                            //                   color: AppColors.kgreyColor,
                            //                   fontWeight: FontWeight.w400,
                            //                   fontSize: 20),
                            //         ),
                            //         const SizedBox(height: 15),
                            //         StreamBuilder<DocumentSnapshot>(
                            //           stream: FirebaseFirestore.instance
                            //               .collection('users')
                            //               .doc(user!.uid)
                            //               .snapshots(), // Listening for real-time updates to the user document
                            //           builder: (context, snapshot) {
                            //             if (snapshot.connectionState ==
                            //                 ConnectionState.waiting) {
                            //               return const Center(
                            //                   child: LoadingWidget());
                            //             }

                            //             if (snapshot.hasError) {
                            //               return Center(
                            //                   child: Text(
                            //                       'Error: ${snapshot.error}'));
                            //             }

                            //             if (snapshot.hasData) {
                            //               var userData = snapshot.data!.data()
                            //                   as Map<String, dynamic>;

                            //               List<dynamic> charactors =
                            //                   userData['storycharactors'] ??
                            //                       [];

                            //               if (charactors.isEmpty) {
                            //                 return const Center(
                            //                     child: Text(
                            //                         'No character found.'));
                            //               }

                            //               return Wrap(
                            //                 children: List<Widget>.generate(
                            //                     charactors.length,
                            //                     (int indexx) {
                            //                   // Accessing each lesson by index
                            //                   String charactorsitem = charactors[
                            //                       indexx]; // Get the lesson data for the current index
                            //                   return Padding(
                            //                     padding:
                            //                         const EdgeInsets.all(5.0),
                            //                     child: SizedBox(
                            //                       height: 48,
                            //                       child: ChoiceChip(
                            //                         side: const BorderSide(
                            //                             width: .4,
                            //                             color: Color.fromARGB(
                            //                                 255,
                            //                                 152,
                            //                                 152,
                            //                                 152)),
                            //                         shadowColor: Colors.black,
                            //                         onSelected: (value) {
                            //                           // Trigger an event or do something with the selected lesson
                            //                           context
                            //                               .read<
                            //                                   AddCharacterBloc>()
                            //                               .add(AddcharactorstoryEvent(
                            //                                   charactorsitem,
                            //                                   selectedindexcharactor:
                            //                                       indexx));
                            //                           // print(
                            //                           //     charactorsitem);
                            //                         },
                            //                         selectedColor:
                            //                             AppColors.kpurple,
                            //                         elevation: 3,
                            //                         checkmarkColor:
                            //                             AppColors.kwhiteColor,
                            //                         label: Text(
                            //                             charactorsitem
                            //                                 .toString(),
                            //                             style: theme.textTheme
                            //                                 .bodyMedium!
                            //                                 .copyWith(
                            //                               fontWeight:
                            //                                   FontWeight.w400,
                            //                               color: state
                            //                                           .selectedindexcharactor ==
                            //                                       indexx
                            //                                   ? AppColors
                            //                                       .kwhiteColor
                            //                                   : AppColors
                            //                                       .kblackColor,
                            //                             ) // Display the lesson name or string representation

                            //                             ),
                            //                         selected: state
                            //                                 .selectedindexcharactor ==
                            //                             indexx, // Set the selection based on index
                            //                         shape:
                            //                             RoundedRectangleBorder(
                            //                           side: BorderSide.none,
                            //                           borderRadius:
                            //                               BorderRadius
                            //                                   .circular(40),
                            //                         ),
                            //                         padding:
                            //                             const EdgeInsets.all(
                            //                                 12),
                            //                       ),
                            //                     ),
                            //                   );
                            //                 }),
                            //               );
                            //             }

                            //             return const Center(
                            //                 child:
                            //                     Text('No character found.'));
                            //           },
                            //         ),
                            //         addbutton(
                            //             title: "Add a character",
                            //             width: 180,
                            //             theme: theme,
                            //             onTap: () async {
                            //               await showModalBottomSheet(
                            //                 isScrollControlled: true,
                            //                 backgroundColor:
                            //                     Colors.transparent,
                            //                 enableDrag: false,
                            //                 context: context,
                            //                 builder: (context) {
                            //                   return GestureDetector(
                            //                     onTap: () =>
                            //                         FocusScope.of(context)
                            //                             .unfocus(),
                            //                     child: Padding(
                            //                       padding:
                            //                           MediaQuery.viewInsetsOf(
                            //                               context),
                            //                       child:
                            //                           const AddCharactorStory(),
                            //                     ),
                            //                   );
                            //                 },
                            //               );
                            //             }),

                            //         // StreamBuilder(
                            //         //     stream: FirebaseFirestore.instance
                            //         //         .collection('users')
                            //         //         .doc(user!.uid)
                            //         //         .snapshots(),
                            //         //     builder: (context, snapshot) {
                            //         //       if (snapshot.connectionState ==
                            //         //           ConnectionState.waiting) {
                            //         //         return const Center(
                            //         //             child:
                            //         //                 CircularProgressIndicator());
                            //         //       }

                            //         //       if (snapshot.hasError) {
                            //         //         return Center(
                            //         //             child: Text(
                            //         //                 'Error: ${snapshot.error}'));
                            //         //       }

                            //         //       if (snapshot.hasData) {
                            //         //         var userData = snapshot.data!.data()
                            //         //             as Map<String, dynamic>;

                            //         //         List<dynamic> addyourowns =
                            //         //             userData['fav_things'] ?? [];

                            //         //         if (addyourowns.isEmpty) {
                            //         //           return const Center(
                            //         //               child: Text(
                            //         //                   'No fav things found.'));
                            //         //         }

                            //         //         return Wrap(
                            //         //             children: List<Widget>.generate(
                            //         //                 addyourowns.length,
                            //         //                 (int index) {
                            //         //           var addyourown = addyourowns[index];
                            //         //           return Padding(
                            //         //             padding:
                            //         //                 const EdgeInsets.all(5.0),
                            //         //             child: SizedBox(
                            //         //               height: 48,
                            //         //               child: ChoiceChip(
                            //         //                 elevation: 3,
                            //         //                 shadowColor: AppColors
                            //         //                     .kgreyColor
                            //         //                     .withOpacity(0.3),
                            //         //                 label: Text(addyourown,
                            //         //                     style: theme
                            //         //                         .textTheme.bodyMedium!
                            //         //                         .copyWith(
                            //         //                             fontWeight:
                            //         //                                 FontWeight
                            //         //                                     .w400,
                            //         //                             color: AppColors
                            //         //                                 .textColorblack)),
                            //         //                 selected: false,
                            //         //                 selectedColor:
                            //         //                     AppColors.kpurple,
                            //         //                 checkmarkColor:
                            //         //                     AppColors.kwhiteColor,
                            //         //                 shape: RoundedRectangleBorder(
                            //         //                   side: BorderSide.none,
                            //         //                   borderRadius:
                            //         //                       BorderRadius.circular(
                            //         //                           40),
                            //         //                 ),
                            //         //               ),
                            //         //             ),
                            //         //           );
                            //         //         }));
                            //         //       }
                            //         //       return const Center(
                            //         //           child: Text('No favthings found.'));
                            //         //     }),
                            //         // addbutton(
                            //         //     title: "Add your own",
                            //         //     width: 180,
                            //         //     theme: theme,
                            //         //     onTap: () async {
                            //         //       await showModalBottomSheet(
                            //         //         isScrollControlled: true,
                            //         //         backgroundColor: Colors.transparent,
                            //         //         enableDrag: false,
                            //         //         context: context,
                            //         //         builder: (context) {
                            //         //           return const AddFavoritesBottomsheet();
                            //         //         },
                            //         //       );
                            //         //     })
                            //       ],
                            //     );
                            //   },
                            // ),

                            /**************************************************** */

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 25),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE8DEF8),
                                            borderRadius:
                                                BorderRadius.circular(40.0),
                                          ),
                                          child: IconButton(
                                            onPressed: () {
                                              pageViewController?.previousPage(
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                curve: Curves.ease,
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.arrow_back,
                                              color: AppColors.sliderColor,
                                              size: 23,
                                            ),
                                          )),
                                      const SizedBox(width: 5),
                                      customSlider(percent: 0),
                                      // customSlider(percent: 0),
                                      customSlider(percent: 1),
                                      const SizedBox(width: 10),
                                      Transform.rotate(
                                        angle: .2,
                                        child: Image.asset(
                                          'assets/images/star.png',
                                          width: 70,
                                          height: 80,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Who are ${childdata.name}\'s loved ones?',
                                          style: theme.textTheme.displaySmall!
                                              .copyWith(
                                                  color:
                                                      AppColors.textColorblue,
                                                  fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "We can feature them in stories",
                                          style: theme.textTheme.headlineSmall!
                                              .copyWith(
                                                  color:
                                                      AppColors.textColorblack,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w400),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 30.0, bottom: 15.0),
                                          child: Text(
                                            "Answer atleast one",
                                            style: theme
                                                .textTheme.headlineSmall!
                                                .copyWith(
                                                    color:
                                                        AppColors.textColorGrey,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 20),
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Relations(
                                              theme: theme,
                                              relationName: 'Mother',
                                              controller: mother,
                                              onChanged: (mom) {
                                                setState(() {
                                                  mother.text = mom;
                                                  childdata.lovedonce.add(
                                                      Lovedonces(
                                                          name: mom,
                                                          relation: "Mother"));
                                                });
                                              },
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            Relations(
                                              theme: theme,
                                              relationName: 'Father',
                                              controller: father,
                                              onChanged: (dad) {
                                                setState(() {
                                                  childdata.lovedonce.add(
                                                      Lovedonces(
                                                          name: dad,
                                                          relation: "Father"));
                                                });
                                              },
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            Relations(
                                              theme: theme,
                                              relationName: 'Grandmother',
                                              controller: GrandMother,
                                              onChanged: (GM) {
                                                setState(() {
                                                  childdata.lovedonce.add(
                                                      Lovedonces(
                                                          name: GM,
                                                          relation:
                                                              "Grandmother"));
                                                });
                                              },
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            Relations(
                                              theme: theme,
                                              relationName: 'Grandfather',
                                              controller: GrandFather,
                                              onChanged: (GF) {
                                                setState(() {
                                                  childdata.lovedonce.add(
                                                      Lovedonces(
                                                          name: GF,
                                                          relation:
                                                              "Grandfather"));
                                                });
                                              },
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            Relations(
                                              theme: theme,
                                              relationName: 'Younger Sister',
                                              controller: pet,
                                              onChanged: (pett) {
                                                setState(() {
                                                  childdata.lovedonce.add(
                                                      Lovedonces(
                                                          name: pett,
                                                          relation:
                                                              "Younger Sister"));
                                                });
                                              },
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            StreamBuilder<DocumentSnapshot>(
                                              stream: FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(user?.uid)
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const Center(
                                                      child: LoadingWidget());
                                                }

                                                if (!snapshot.hasData ||
                                                    snapshot.data == null) {
                                                  return const Center(
                                                      child: Text(
                                                          "No data found"));
                                                }

                                                var data = snapshot.data!.data()
                                                    as Map<String, dynamic>;
                                                var moreLovedOnes =
                                                    data['moreLovedOnes']
                                                        as List<dynamic>?;

                                                if (moreLovedOnes == null ||
                                                    moreLovedOnes.isEmpty) {
                                                  return const Center(
                                                      child: Text(""));
                                                }

                                                return Column(
                                                  children: moreLovedOnes
                                                      .map((lovedOne) {
                                                    String relationName =
                                                        lovedOne['relation'] ??
                                                            '';
                                                    String name =
                                                        lovedOne['name'] ?? '';

                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 20.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Expanded(
                                                            flex: 2,
                                                            child: Text(
                                                              relationName,
                                                              style: theme
                                                                  .textTheme
                                                                  .bodyMedium!
                                                                  .copyWith(
                                                                color: AppColors
                                                                    .textColorblack,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 3,
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 10),
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                color: AppColors
                                                                    .kwhiteColor,
                                                              ),
                                                              width:
                                                                  deviceWidth *
                                                                      0.5555,
                                                              height: 48,
                                                              child: Center(
                                                                child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  child: Text(
                                                                    name,
                                                                    style: theme
                                                                        .textTheme
                                                                        .bodyMedium!
                                                                        .copyWith(
                                                                            color:
                                                                                AppColors.textColorblack,
                                                                            fontWeight: FontWeight.w400),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }).toList(),
                                                );
                                              },
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  enableDrag: false,
                                                  context: context,
                                                  builder: (context) {
                                                    return const AddLovedOnesBottomSheet();
                                                  },
                                                );
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10.0),
                                                child: Container(
                                                    width: deviceWidth,
                                                    height: 47,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: const Color
                                                                .fromARGB(255,
                                                                178, 178, 178)),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(40)),
                                                    child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Icon(
                                                            Icons.add,
                                                            color: AppColors
                                                                .textColorblack,
                                                            size: 20,
                                                          ),
                                                          const SizedBox(
                                                              width: 10),
                                                          Text(
                                                              'Add a loved one',
                                                              style: theme
                                                                  .textTheme
                                                                  .bodyMedium!
                                                                  .copyWith(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500)),
                                                        ])),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 25),
                      child: SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.85,
                        height: 60,
                        child: ElevatedButton(
                            onPressed: () async {
                              AnalyticsService.logEvent(
                                  eventName: 'introduction_done_button');
                              if (currentpage_index == 0 &&
                                  childdata.name.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor:
                                        AppColors.snackBarBackground,
                                    content: Text(
                                      "Please enter Child name.",
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                              color: AppColors.textColorblue,
                                              fontWeight: FontWeight.w400),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              } else if (currentpage_index == 0 &&
                                  childdata.gender == Gender.notselected) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor:
                                        AppColors.snackBarBackground,
                                    content: Text(
                                      "Please select gender",
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                              color: AppColors.textColorblue,
                                              fontWeight: FontWeight.w400),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              } else if (currentpage_index == 0 &&
                                  selectedDate == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor:
                                        AppColors.snackBarBackground,
                                    content: Text(
                                      "Please select date of birth",
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                              color: AppColors.textColorblue,
                                              fontWeight: FontWeight.w400),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              } else if ((currentpage_index == 1) &&
                                      mother.text.trim().isNotEmpty ||
                                  father.text.trim().isNotEmpty ||
                                  GrandMother.text.trim().isNotEmpty ||
                                  GrandFather.text.trim().isNotEmpty ||
                                  pet.text.trim().isNotEmpty) {
                                childdata.lovedonce.add(Lovedonces(
                                    relation: "Mother",
                                    name: mother.text.isNotEmpty
                                        ? mother.text
                                        : ""));
                                childdata.lovedonce.add(Lovedonces(
                                    relation: "Father",
                                    name: father.text.isNotEmpty
                                        ? father.text
                                        : ""));
                                childdata.lovedonce.add(Lovedonces(
                                    relation: "Grandmother",
                                    name: GrandMother.text.isNotEmpty
                                        ? GrandMother.text
                                        : ""));
                                childdata.lovedonce.add(Lovedonces(
                                    relation: "Grandfather",
                                    name: GrandFather.text.isNotEmpty
                                        ? GrandFather.text
                                        : ""));
                                childdata.lovedonce.add(Lovedonces(
                                    relation: "Younger Sister",
                                    name: pet.text.isNotEmpty ? pet.text : ""));
                                List<Map<String, dynamic>> lovedOnceList =
                                    childdata.lovedonce
                                        .map((lovedonce) => lovedonce.toMap())
                                        .toList();

                                try {
                                  // Get the currently authenticated user
                                  BlocProvider.of<IntroductionBloc>(context)
                                      .add(loadingEvent());
                                  User? user =
                                      FirebaseAuth.instance.currentUser;

                                  if (user != null) {
                                    String userId = user.uid; // Get the user ID

                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(userId)
                                        .update({
                                      'email': user.email,
                                      'phone': user.phoneNumber,

                                      'child_name': childdata.name,
                                      'gender': childdata.gender == Gender.he
                                          ? 'He'
                                          : childdata.gender == Gender.she
                                              ? 'She'
                                              : 'Prefer not to say',
                                      // 'fav_things': childdata.favthings,
                                      'dob': childdata.dob,

                                      'displayName':
                                          "displayName", // Update as needed
                                      'photoURL':
                                          "photoURL", // Update as needed
                                      'newUser': false,
                                    });
                                    await addToLovedonce(userId, lovedOnceList);
                                    context.go('/splashScreen');
                                  } else {
                                    print("No user is currently signed in.");
                                  }
                                } catch (e) {
                                  print("Error updating user data: $e");
                                }
                              } else if ((currentpage_index == 1) &&
                                  mother.text.trim().isEmpty &&
                                  father.text.trim().isEmpty &&
                                  GrandMother.text.trim().isEmpty &&
                                  GrandFather.text.trim().isEmpty &&
                                  pet.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor:
                                        AppColors.snackBarBackground,
                                    content: Text(
                                      "Answer atleast one",
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                              color: AppColors.textColorblue,
                                              fontWeight: FontWeight.w400),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              } else {
                                await pageViewController?.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              foregroundColor: Colors.white,
                              backgroundColor: ((currentpage_index == 0 &&
                                      (childdata.name.trim().isNotEmpty) &&
                                      !(childdata.gender ==
                                          Gender.notselected) &&
                                      (selectedDate != null)))
                                  ? AppColors.buttonblue
                                  : (currentpage_index == 1 &&
                                          (mother.text.isNotEmpty ||
                                              father.text.isNotEmpty ||
                                              GrandMother.text.isNotEmpty ||
                                              GrandFather.text.isNotEmpty ||
                                              pet.text.isNotEmpty))
                                      ? AppColors.buttonblue
                                      : AppColors.buttonwhite,
                            ),
                            child: (currentpage_index == 1)
                                ? state is loadingState
                                    ? const LoadingWidget()
                                    : Text("Done",
                                        style: theme.textTheme.bodyLarge!
                                            .copyWith(
                                                color: (currentpage_index ==
                                                                1) &&
                                                            mother.text
                                                                .trim()
                                                                .isNotEmpty ||
                                                        father.text
                                                            .trim()
                                                            .isNotEmpty ||
                                                        GrandMother.text
                                                            .trim()
                                                            .isNotEmpty ||
                                                        GrandFather.text
                                                            .trim()
                                                            .isNotEmpty ||
                                                        pet.text
                                                            .trim()
                                                            .isNotEmpty
                                                    ? AppColors.textColorWhite
                                                    : AppColors.textColorblue,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w400))
                                : Text("Continue",
                                    style: theme.textTheme.bodyLarge!.copyWith(
                                        color: ((childdata.name
                                                    .trim()
                                                    .isNotEmpty) &&
                                                !(childdata.gender ==
                                                    Gender.notselected) &&
                                                (selectedDate != null))
                                            ? AppColors.textColorWhite
                                            : AppColors.textColorblack,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400))),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget choicechipbutton(
          {required ThemeData theme,
          required String title,
          required VoidCallback ontap,
          required bool selected}) =>
      Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.9,
          height: 60,
          child: ElevatedButton(
            onPressed: () async {},
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              foregroundColor: selected == true
                  ? AppColors.buttonblue
                  : AppColors.buttonwhite,
              backgroundColor: selected == true
                  ? AppColors.buttonblue
                  : AppColors.buttonwhite, // Text (foreground) color
            ),
            child: Text(title,
                style: theme.textTheme.bodyLarge!.copyWith(
                    color: selected == true
                        ? AppColors.textColorWhite
                        : AppColors.textColorblack,
                    fontWeight: FontWeight.w500)),
          ),
        ),
      );
  Widget customSlider({required double percent}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(5.0, 0.0, 0.0, 0.0),
        child: LinearPercentIndicator(
          percent: percent,
          lineHeight: 9.0,
          animation: true,
          animateFromLastPercent: true,
          progressColor: AppColors.sliderColor,
          backgroundColor: AppColors.sliderBackground,
          barRadius: const Radius.circular(20.0),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget addbutton(
      {required ThemeData theme,
      required String title,
      required double width,
      required VoidCallback onTap,
      double height = 47}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
                border:
                    Border.all(color: const Color.fromARGB(255, 178, 178, 178)),
                borderRadius: BorderRadius.circular(40)),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add,
                    color: AppColors.textColorblack,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(title,
                      style: theme.textTheme.bodyMedium!
                          .copyWith(fontWeight: FontWeight.w500)),
                ])),
      ),
    );
  }
}

class Relations extends StatelessWidget {
  const Relations({
    super.key,
    required this.theme,
    required this.relationName,
    required this.controller,
    required this.onChanged,
  });
  final Function(String)? onChanged;
  final TextEditingController controller;
  final ThemeData theme;
  final String relationName;

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            relationName,
            style: theme.textTheme.bodyMedium!.copyWith(
                color: AppColors.textColorblack,
                fontWeight: FontWeight.w400,
                fontSize: 16),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.kwhiteColor,
            ),
            width: deviceWidth * 0.5555,
            height: 48,
            child: TextField(
              textCapitalization: TextCapitalization.sentences,
              style: theme.textTheme.bodyMedium,
              controller: controller,
              textAlign: TextAlign.left,
              cursorColor: AppColors.textColorblue,
              onChanged: (value) {},
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                // hintText: 'Type ${relationName.toLowerCase()}\'s name',
                hintText: 'Type name here',

                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textColorDimGrey,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FormFieldController<T> extends ValueNotifier<T?> {
  FormFieldController(this.initialValue) : super(initialValue);

  final T? initialValue;

  void reset() => value = initialValue;
  void update() => notifyListeners();
}

class FormListFieldController<T> extends FormFieldController<List<T>> {
  final List<T>? _initialListValue;

  FormListFieldController(super.initialValue)
      : _initialListValue = List<T>.from(initialValue ?? []);

  @override
  void reset() => value = List<T>.from(_initialListValue ?? []);
}

Future<List<String>> fetchSuggestedCharacters() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  try {
    // Fetch the first document from the `admin_data` collection
    QuerySnapshot querySnapshot =
        await firestore.collection('admin_data').limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      // Access the first document
      var data = querySnapshot.docs.first.data() as Map<String, dynamic>;

      // Extract `suggested_characters` and ensure it is a list of strings
      List<dynamic> characters = data['suggested_characters'] ?? [];
      return characters.map((e) => e.toString()).toList();
    } else {
      print('No document found in admin_data.');
      return [];
    }
  } catch (e) {
    print('Error fetching suggested characters: $e');
    return [];
  }
}

Future<void> addToLovedonce(String documentId, List<dynamic> newData) async {
  try {
    // Reference to your collection and document
    var docRef = FirebaseFirestore.instance.collection('users').doc(documentId);

    // Fetch the existing list from Firestore
    var docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      var existingData = docSnapshot.data()?['loved_once'] ?? [];

      // Check if any new item is already present in the list
      List<dynamic> dataToAdd = [];
      for (var newItem in newData) {
        if (!existingData.contains(newItem)) {
          dataToAdd.add(newItem); // Add only unique items
        }
      }

      // If there's new data to add, update the Firestore document
      if (dataToAdd.isNotEmpty) {
        await docRef.update({
          'loved_once': FieldValue.arrayUnion(dataToAdd),
        });
        print('Data added successfully!');
      } else {
        print('No new data to add.');
      }
    } else {
      print('Document does not exist.');
    }
  } catch (e) {
    print('Error adding data: $e');
  }
}
