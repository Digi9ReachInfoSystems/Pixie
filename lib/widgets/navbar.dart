import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pixieapp/blocs/Navbar_Bloc/navbar_bloc.dart';
import 'package:pixieapp/blocs/Navbar_Bloc/navbar_event.dart';
import 'package:pixieapp/blocs/Navbar_Bloc/navbar_state.dart';
import 'package:pixieapp/blocs/add_character_Bloc.dart/add_character_bloc.dart';
import 'package:pixieapp/blocs/add_character_Bloc.dart/add_character_event.dart';
import 'package:pixieapp/const/colors.dart';
import 'package:go_router/go_router.dart';

class NavBar extends StatelessWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 2, right: 2),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(12)),
          color: AppColors.kwhiteColor,
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 15,
          ),
          child: BlocBuilder<NavBarBloc, NavBarState>(
            builder: (context, state) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  _buildNavItem(
                    context: context,
                    index: 0,
                    label: 'Home',
                    iconSelected: 'assets/images/home_selected.svg',
                    iconUnselected: 'assets/images/home_unselect.svg',
                    isSelected:
                        state.selectedIndex == 0 || state.selectedIndex == 1,
                    route: '/HomePage',
                  ),
                  _buildNavItem(
                    context: context,
                    index: 1,
                    label: 'Create',
                    iconSelected: 'assets/images/create_selected.svg',
                    iconUnselected: 'assets/images/story.svg',
                    isSelected: state.selectedIndex == 5,
                    route: '/AddCharacter',
                  ),
                  _buildNavItem(
                    context: context,
                    index: 2,
                    label: 'Library',
                    iconSelected: 'assets/images/Library_selected.svg',
                    iconUnselected: 'assets/images/Library.svg',
                    isSelected: state.selectedIndex == 2,
                    route: '/Library',
                  ),
                  _buildNavItem(
                    context: context,
                    index: 3,
                    label: 'Settings',
                    iconSelected: 'assets/images/settings_selected.svg',
                    iconUnselected: 'assets/images/navbar_icon3.svg',
                    isSelected: state.selectedIndex == 3,
                    route: '/SettingsPage',
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required String label,
    required String iconSelected,
    required String iconUnselected,
    required bool isSelected,
    required String route,
  }) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          child: IconButton(
            onPressed: () {
              // Check if the user is a guest
              // final authState = context.read<AuthBloc>().state;
              // if (authState is AuthGuest && label == 'Create' ||
              //     label == 'Library') {
              //   // If guest, navigate to the login page
              //   context.read<AuthBloc>().add(AuthGuestLoginRequested());
              //   context.push('/CreateAccount');
              // } else {
              context.read<NavBarBloc>().add(NavBarItemTapped(index));
              if (index == 1) {
                context.read<AddCharacterBloc>().add(ResetStateEvent());
                context.push(route);
              } else {
                context.go(route);
              }
              // }
            },
            icon: SvgPicture.asset(
              isSelected ? iconSelected : iconUnselected,
              width: MediaQuery.of(context).size.width * .1,
            ),
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: isSelected ? AppColors.kpurple : AppColors.kblackColor),
        ),
      ],
    );
  }
}
