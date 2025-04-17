import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pixieapp/blocs/Auth_bloc/auth_bloc.dart';
import 'package:pixieapp/blocs/Auth_bloc/auth_event.dart';
import 'package:pixieapp/blocs/Auth_bloc/auth_state.dart';
import 'package:pixieapp/const/colors.dart';
import 'package:pixieapp/widgets/logout_bottom_sheet.dart';
import 'package:pixieapp/widgets/navbar.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pixieapp/widgets/analytics.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AnalyticsService.logScreenView(
      screenName: '/SettingsPage',
      screenClass: 'Settings Screen',
    );
  }

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
                        // Check if the user is a guest
                        final authState = context.read<AuthBloc>().state;
                        if (authState is AuthGuest) {
                          // If guest, navigate to the login page
                          context
                              .read<AuthBloc>()
                              .add(AuthGuestLoginRequested());
                          context.push('/CreateAccount',
                              extra: 'Create an account');
                        } else {
                          AnalyticsService.logEvent(
                              eventName: 'profile_button');
                          // If authenticated, navigate to AddCharacter page
                          context.push('/profilePage');
                        }
                      },
                      icon_path: 'assets/images/profile.svg',
                      theme: theme,
                    ),
                    profilelistCard(
                      title: 'Feedback',
                      ontap: () {
                        // Check if the user is a guest
                        final authState = context.read<AuthBloc>().state;
                        if (authState is AuthGuest) {
                          // If guest, navigate to the login page
                          context
                              .read<AuthBloc>()
                              .add(AuthGuestLoginRequested());
                          context.push('/CreateAccount',
                              extra: 'Create an account');
                        } else {
                          AnalyticsService.logEvent(
                              eventName: 'feedback_button');
                          // If authenticated, navigate to AddCharacter page
                          context.push('/feedbackPage');
                        }
                      },
                      icon_path: 'assets/images/feedbacak.svg',
                      theme: theme,
                    ),
                    profilelistCard(
                      title: 'About',
                      ontap: () async {
                        AnalyticsService.logEvent(eventName: 'about_button');
                        context.push('/aboutPage');
                      },
                      icon_path: 'assets/images/about.svg',
                      theme: theme,
                    ),
                    profilelistCard(
                      title: 'Invite a friend',
                      ontap: () {
                        AnalyticsService.logEvent(
                            eventName: 'invite_friend_button');
                        openWhatsAppChat(
                            '''Hey parent! Create personalized audio stories for your child! Introduce them to AI, inspiring them to think beyond. Pixie – their adventure buddy to reduce screentime. \n\n For ios app:https://apps.apple.com/us/app/pixie-dream-create-inspire/id6737147663\n\n For Android app : https://play.google.com/store/apps/details?id=com.fabletronic.pixie.''');
                      },
                      icon_path: 'assets/images/share.svg',
                      theme: theme,
                    ),
                    profilelistCard(
                      title: 'Logout',
                      ontap: () async {
                        AnalyticsService.logEvent(
                            eventName: 'logout_triggered_button');
                        // Check if the user is a guest
                        final authState = context.read<AuthBloc>().state;
                        if (authState is AuthGuest) {
                          // If guest, navigate to the login page
                          context
                              .read<AuthBloc>()
                              .add(AuthGuestLoginRequested());
                          context.push('/CreateAccount',
                              extra: 'Create an account');
                        } else {
                          await showModalBottomSheet(
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            enableDrag: false,
                            context: context,
                            builder: (context) {
                              return GestureDetector(
                                onTap: () => FocusScope.of(context).unfocus(),
                                child: Padding(
                                  padding: MediaQuery.viewInsetsOf(context),
                                  child: const LogoutBottomSheet(),
                                ),
                              );
                            },
                          );
                        }
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
          color: const Color(0xffe9d6eb),
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Row(
              children: [
                SvgPicture.asset(
                  icon_path,
                  width: 30,
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

Future<void> openWhatsAppChat(String text) async {
  var url = "https://wa.me/?text=$text";
  var uri = Uri.encodeFull(url);

  if (await canLaunchUrl(Uri.parse(uri))) {
    await launchUrl(Uri.parse(uri), mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch WhatsApp';
  }
}
