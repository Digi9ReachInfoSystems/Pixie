import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pixieapp/blocs/Auth_bloc/auth_bloc.dart';
import 'package:pixieapp/blocs/Auth_bloc/auth_event.dart';
import 'package:pixieapp/blocs/Auth_bloc/auth_state.dart';
import 'package:pixieapp/const/colors.dart';
import 'package:pixieapp/widgets/loading_widget.dart';

class OtpVerification extends StatefulWidget {
  final String
      verificationId; // Pass the verificationId from the previous screen

  const OtpVerification({super.key, required this.verificationId});

  @override
  State<OtpVerification> createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    print('...................${widget.verificationId}');
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/HomePage');
        } else if (state is LoginScreenErrorState) {
          _focusNode.unfocus();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        } else {
          _focusNode.unfocus();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    "Something went wrong. Check your connection and try again.")),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
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
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/createaccountsmily.png',
                        width: width * .25,
                      ),
                      Text(
                        'Verify your Mobile\nnumber',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displayLarge!.copyWith(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Check your SMS for a code we’ve sent you. It should be there. Else resend.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium!.copyWith(),
                      ),
                      const SizedBox(height: 30),

                      // Updated TextField for OTP input
                      TextField(
                        focusNode: _focusNode,
                        onChanged: (value) {
                          if (value.length == 6) {
                            _focusNode.unfocus();
                          }
                        },
                        cursorColor: AppColors.kpurple,
                        controller: _otpController,
                        decoration: const InputDecoration(
                          disabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.kpurple)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.kpurple)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.kpurple)),
                          labelText: 'Enter OTP',
                          labelStyle: TextStyle(color: AppColors.kpurple),
                          border: OutlineInputBorder(),
                          hintText: '6-digit code',
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: MediaQuery.of(context).size.width * .9,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            String otpCode = _otpController.text.trim();
                            if (otpCode.isEmpty || otpCode.length < 6) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Please enter a valid OTP code'),
                                ),
                              );
                              return;
                            }

                            if (state is! AuthLoading) {
                              BlocProvider.of<AuthBloc>(context).add(
                                VerifySentOtp(
                                  otpCode: _otpController.text,
                                  verificationId: widget.verificationId,
                                ),
                              );
                            }
                            // try {
                            //   final cred = PhoneAuthProvider.credential(
                            //       verificationId: widget.verificationId,
                            //       smsCode: _otpController.text);

                            //   await FirebaseAuth.instance
                            //       .signInWithCredential(cred);
                            //   context.go('/HomePage');
                            // } catch (e) {
                            //   log(e.toString());
                            // }
                          },

                          // state is! AuthLoading
                          //     ? () {
                          //         String otpCode = _otpController.text.trim();
                          //         if (otpCode.isEmpty || otpCode.length < 6) {
                          //           ScaffoldMessenger.of(context).showSnackBar(
                          //             const SnackBar(
                          //               content: Text(
                          //                 'Please enter a valid OTP code',
                          //               ),
                          //             ),
                          //           );
                          //           return;
                          //         }

                          //         // Dispatch the event to verify the OTP
                          //         BlocProvider.of<AuthBloc>(context).add(
                          //           AuthPhoneSignInRequested(
                          //             phoneNumber:
                          //                 '', // Leave empty as it's not needed now
                          //             otpCode: otpCode, // Pass the entered OTP
                          //           ),
                          //         );
                          //       }
                          //     : null,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: AppColors.buttonblue,
                          ),
                          child: state is AuthLoading
                              ? const LoadingWidget()
                              : Text(
                                  "Verify",
                                  style: theme.textTheme.bodyMedium!.copyWith(
                                    color: AppColors.textColorWhite,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                        ),
                      ),

                      // Padding(
                      //   padding: const EdgeInsets.only(top: 3),
                      //   child: Align(
                      //     alignment: Alignment.bottomRight,
                      //     child: TextButton(
                      //       onPressed: () {
                      //         // Logic to resend OTP can be implemented here
                      //       },
                      //       child: Text(
                      //         "Resend code",
                      //         style: theme.textTheme.bodyMedium!.copyWith(
                      //           color: AppColors.textColorblue,
                      //           fontSize: 17,
                      //           fontWeight: FontWeight.w400,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // )
                    ],
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
