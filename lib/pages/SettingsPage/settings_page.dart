import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pixieapp/blocs/Auth_bloc/auth_bloc.dart';
import 'package:pixieapp/blocs/Auth_bloc/auth_event.dart';
import 'package:pixieapp/blocs/Auth_bloc/auth_state.dart';
import 'package:pixieapp/blocs/add_character_Bloc.dart/add_character_bloc.dart';
import 'package:pixieapp/blocs/add_character_Bloc.dart/add_character_event.dart';
import 'package:pixieapp/const/colors.dart';
import 'package:pixieapp/widgets/navbar.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xfff9f3cd),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            // Navigate to the login or onboarding page when the user is logged out
            context.go('/Loginpage'); // Or whichever page you want after logout
          }
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xffead4f9),
                Color(0xfff7f1d1),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        AppColors.textColorGrey,
                        AppColors.textColorSettings
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(
                      Rect.fromLTWH(0.0, 0.0, bounds.width, bounds.height),
                    ),
                    child: Text(
                      "Settings",
                      style: theme.textTheme.headlineMedium!.copyWith(
                          fontSize: 24, color: AppColors.textColorWhite),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    profilelistCard(
                      title: 'Profile',
                      ontap: () {
                        context.push('/profilePage');
                      },
                      icon_path: 'assets/images/profile.svg',
                      theme: theme,
                    ),
                    profilelistCard(
                      title: 'Feedback',
                      ontap: () {
                        context.push('/feedbackPage');
                      },
                      icon_path: 'assets/images/feedbacak.svg',
                      theme: theme,
                    ),
                    profilelistCard(
                      title: 'About',
                      ontap: () {},
                      icon_path: 'assets/images/about.svg',
                      theme: theme,
                    ),
                    profilelistCard(
                      title: 'Logout',
                      ontap: () {
                        context.read<AuthBloc>().add(AuthLogOutRequested());
                        context
                            .read<AddCharacterBloc>()
                            .add(const PageChangeEvent(0));
                      },
                      icon_path: 'assets/images/logout.svg',
                      theme: theme,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const NavBar(),
    );
  }

  Widget profilelistCard({
    required ThemeData theme,
    required String title,
    required String icon_path,
    required void Function() ontap,
  }) {
    return GestureDetector(
      onTap: ontap,
      child: Padding(
        padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
        child: Container(
          height: 56,
          width: MediaQuery.of(context).size.width,
          color: Color(0xffe9d6eb),
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Row(
              children: [
                SvgPicture.asset(
                  icon_path,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: theme.textTheme.bodyMedium!.copyWith(fontSize: 16),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
