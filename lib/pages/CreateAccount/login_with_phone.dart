import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import 'package:pixieapp/blocs/Auth_bloc/auth_bloc.dart';
import 'package:pixieapp/blocs/Auth_bloc/auth_event.dart';
import 'package:pixieapp/blocs/Auth_bloc/auth_state.dart';
import 'package:pixieapp/const/Countries.dart';
import 'package:pixieapp/const/colors.dart';
import 'package:pixieapp/widgets/analytics.dart';
import 'package:pixieapp/widgets/loading_widget.dart';
import 'package:flutter/services.dart';

class Loginwithphone extends StatefulWidget {
  const Loginwithphone({super.key});

  @override
  State<Loginwithphone> createState() => _LoginwithphoneState();
}

TextEditingController countrycodetextEditingController =
    TextEditingController();
TextEditingController mobileNumberController = TextEditingController();
String countryCode = '';
final _formKey = GlobalKey<FormState>();
final FocusNode _focusNode = FocusNode();

class _LoginwithphoneState extends State<Loginwithphone> {
  @override
  void initState() {
    _focusNode.unfocus();
    super.initState();
    AnalyticsService.logScreenView(
      screenName: '/loginwithphone',
      screenClass: 'phone login screen',
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const Center(child: LoadingWidget());
            },
          );
        }
        if (state is PhoneAuthCodeSentSuccess) {
          print('...++....${state.verificationId}');
          context.go('/OtpVerification/${state.verificationId}');
        } else if (state is AuthError) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        if (state is AuthAuthenticated || state is AuthAppleSignInSuccess) {
          Navigator.of(context).pop();
          context.push('/questionIntroPage');
        } else if (state is AuthGuest) {
          context.go("/HomePage");
        } else if (state is AuthError) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        print(state);
      },
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: InkWell(
            onTap: () {
              FocusScope.of(context).unfocus();
              _focusNode.unfocus();
            },
            child: Container(
              width: width,
              height: height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(
                    'assets/images/createaccountbackground.png',
                  ),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: SingleChildScrollView(
                    primary: true,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/createaccountsmily.png',
                            width: width * .2,
                          ),
                          Text(
                            "Sign in to your account",
                            textAlign: TextAlign.center,
                            style: theme.textTheme.displayLarge!.copyWith(
                                fontSize: 34, fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: height * .02),
                          Text(
                            'Your profile and created stories will be saved to your account.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium!.copyWith(),
                          ),
                          SizedBox(height: height * .025),
                          Container(
                            decoration: BoxDecoration(
                                color: AppColors.kwhiteColor,
                                border: Border.all(
                                    color: const Color.fromARGB(
                                        102, 152, 92, 221)),
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 10, top: 10),
                                  child: Text(
                                    "Country/Region",
                                    style: theme.textTheme.bodySmall!
                                        .copyWith(fontSize: 13),
                                  ),
                                ),
                                TypeAheadField<Country>(
                                  builder: (context, controller, focusNode) {
                                    return TextField(
                                      style: theme.textTheme.bodyMedium,
                                      cursorColor: AppColors.kpurple,
                                      controller: controller,
                                      focusNode: focusNode,
                                      decoration: const InputDecoration(
                                          suffixIcon: Icon(
                                            Icons.keyboard_arrow_down_sharp,
                                            color: AppColors.kgreyColor,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color.fromARGB(
                                                    0, 152, 92, 221),
                                                width: 2.0),
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10)),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color.fromARGB(
                                                    0, 152, 92, 221)),
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10)),
                                          ),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color.fromARGB(
                                                    0, 152, 92, 221)),
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10)),
                                          ),
                                          hintText: '🇮🇳 India (+91)',
                                          hintStyle: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w400)),
                                    );
                                  },
                                  controller: countrycodetextEditingController,
                                  suggestionsCallback: (search) {
                                    return countries
                                        .where((country) => country.name
                                            .toLowerCase()
                                            .contains(search.toLowerCase()))
                                        .toList();
                                  },
                                  itemBuilder: (context, Country country) {
                                    return ListTile(
                                        leading: Text(
                                          country.flag,
                                          style: const TextStyle(fontSize: 30),
                                        ),
                                        title: Row(
                                          children: [
                                            SizedBox(
                                              width: 60,
                                              child: Center(
                                                child: Text(
                                                  country.code,
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                            ),
                                            const Text(" -  "),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(country.name,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ));
                                  },
                                  onSelected: (Country country) {
                                    countrycodetextEditingController.text =
                                        "${country.flag}  ${country.code}  -  ${country.name}";

                                    countryCode = country.code;
                                  },
                                ),
                                const Divider(
                                    color: Color.fromARGB(102, 152, 92, 221)),
                                TextFormField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                                  validator: (value) {
                                    String pattern = r'^\+?[0-9]{10,15}$';
                                    RegExp regex = RegExp(pattern);
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your mobile number';
                                    } else if (!regex.hasMatch(value)) {
                                      return 'Enter a valid mobile number';
                                    }
                                    return null;
                                  },
                                  focusNode: _focusNode,
                                  style: theme.textTheme.bodyMedium,
                                  keyboardType: TextInputType.number,
                                  cursorColor: AppColors.kpurple,
                                  controller: mobileNumberController,
                                  autofocus: false,
                                  decoration: const InputDecoration(
                                    hintText: " Mobile number",
                                    hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w400),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        strokeAlign: 5,
                                        color: Color.fromARGB(0, 158, 158, 158),
                                      ),
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color.fromARGB(0, 158, 158, 158),
                                      ),
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              Color.fromARGB(0, 158, 158, 158),
                                          width: 2.0),
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: height * .06),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * .9,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                final isValid =
                                    _formKey.currentState!.validate();

                                if (isValid) {
                                  final phoneNumber =
                                      mobileNumberController.text.trim();
                                  print('.........$countryCode$phoneNumber');
                                  BlocProvider.of<AuthBloc>(context).add(
                                    SendOtpToPhoneEvent(
                                      phoneNumber: countryCode.isNotEmpty
                                          ? '$countryCode$phoneNumber'
                                          : '+91$phoneNumber',
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: AppColors.backgrountdarkpurple,
                              ),
                              child: Text(
                                "Next",
                                style: theme.textTheme.bodyMedium!.copyWith(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                          SizedBox(height: height * .02),
                          Text(
                            'Or',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium!.copyWith(),
                          ),
                          SizedBox(height: height * .02),
                          Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () => context.go('/Loginpage'),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12)),
                                width: MediaQuery.of(context).size.width * .8,
                                height: 50,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: SizedBox(
                                          width: 40,
                                          child: Image.asset(
                                              "assets/images/mail.png")),
                                    ),
                                    Text(
                                      "Sign In with Email Address",
                                      style: theme.textTheme.bodyMedium!
                                          .copyWith(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors
                                                  .backgrountdarkpurple),
                                    ),
                                    const SizedBox()
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () => context
                                  .read<AuthBloc>()
                                  .add(AuthGoogleSignInRequested()),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12)),
                                width: MediaQuery.of(context).size.width * .8,
                                height: 50,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: SizedBox(
                                          width: 40,
                                          child: Image.asset(
                                              "assets/images/googleimg.png")),
                                    ),
                                    Text(
                                      "Sign In with Google",
                                      style: theme.textTheme.bodyMedium!
                                          .copyWith(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors
                                                  .backgrountdarkpurple),
                                    ),
                                    const SizedBox()
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () => context
                                  .read<AuthBloc>()
                                  .add(AuthAppleSignInRequested()),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12)),
                                width: MediaQuery.of(context).size.width * .8,
                                height: 50,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 15),
                                      child: SizedBox(
                                          width: 30,
                                          child: Image.asset(
                                              "assets/images/apple_logo.png")),
                                    ),
                                    Text(
                                      "Sign In with Apple",
                                      style: theme.textTheme.bodyMedium!
                                          .copyWith(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors
                                                  .backgrountdarkpurple),
                                    ),
                                    const SizedBox()
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          RichText(
                              text: TextSpan(
                                  text: 'New user?   ',
                                  style: theme.textTheme.bodyMedium!.copyWith(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.backgrountdarkpurple),
                                  children: [
                                TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      context.go('/CreateAccount',
                                          extra: 'Create an account');
                                    },
                                  text: 'Sign Up',
                                  style: theme.textTheme.bodyMedium!.copyWith(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400,
                                      decoration: TextDecoration.underline,
                                      color: AppColors.backgrountdarkpurple),
                                )
                              ])),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () => context
                                .read<AuthBloc>()
                                .add(AuthGuestLoginRequested()),
                            child: RichText(
                                text: TextSpan(
                              text: 'Continue as guest',
                              style: theme.textTheme.bodyMedium!.copyWith(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.backgrountdarkpurple),
                            )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
