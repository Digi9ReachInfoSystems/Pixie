import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pixieapp/blocs/Loading%20Navbar/loadingnavbar_bloc.dart';
import 'package:pixieapp/blocs/Loading%20Navbar/loadingnavbar_event.dart';
import 'package:pixieapp/blocs/Loading%20Navbar/loadingnavbar_state.dart';
import 'package:pixieapp/const/colors.dart';
import 'package:pixieapp/widgets/story_feedback.dart';
import 'package:shimmer/shimmer.dart';

class Errornavbar extends StatefulWidget {
  const Errornavbar({super.key});

  @override
  State<Errornavbar> createState() => _ErrornavbarState();
}

class _ErrornavbarState extends State<Errornavbar> {
  @override
  @override
  void initState() {
    context.read<LoadingNavbarBloc>().add(StartLoadingNavbarEvent());
    super.initState();
  }

  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return BlocBuilder<LoadingNavbarBloc, LoadingNavbarState>(
      builder: (context, state) {
        // Determine which section is highlighted based on the state

        return Container(
          padding: const EdgeInsets.only(bottom: 10),
          height: 250,
          width: deviceWidth,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            image: DecorationImage(
              image: AssetImage('assets/images/Rectangle 11723.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Tap \"Try Again\" to wake the wand and continue your magical adventure.",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displaySmall!.copyWith(
                        color: AppColors.textColorblue,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .6,
                    child: ElevatedButton(
                      onPressed: () {
                        context.go('/AddCharacter');
                        //  '/HomePage',
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                            AppColors.textColorblue), // Background color
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                      ),
                      child: const Text(
                        "Try Again",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                ],
              )),
        );
      },
    );
  }
}
