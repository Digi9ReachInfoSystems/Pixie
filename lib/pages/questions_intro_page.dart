import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pixieapp/const/colors.dart';
import 'package:pixieapp/widgets/analytics.dart';

class QuestionsIntroPage extends StatelessWidget {
  const QuestionsIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceheight = MediaQuery.of(context).size.height;
    final devicewidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(children: [
        SizedBox(
          width: devicewidth,
          height: deviceheight,
          child: Image.asset(
            'assets/images/background.jpeg',
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
            left: deviceheight * 0.10,
            top: deviceheight * 0.22,
            child: Stack(children: [
              Transform.rotate(
                angle: .05,
                child: Image.asset(
                  'assets/images/tooltip.png',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                  top: deviceheight * 0.03,
                  left: deviceheight * 0.0147,
                  right: deviceheight * 0.0147,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                    ),
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          AppColors.textColorSettings,
                          AppColors.textColorGrey,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(
                        Rect.fromLTWH(0.0, 0.0, bounds.width, bounds.height),
                      ),
                      child: Transform.rotate(
                        angle: .06,
                        child: Text(
                            'Just 2 steps before we can create stories together',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium!.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textColorWhite)),
                      ),
                    ),
                  ))
            ])),
        Positioned(
            right: 0,
            left: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22.0),
                    child: Text(
                      'Share a few details now! You can update them anytime in your profile!',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall!.copyWith(
                          color: AppColors.textColorblack,
                          fontSize: 20,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.85,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                         AnalyticsService.logEvent(
                            eventName: 'Question_continue_button');
                        context.push('/introductionPages');
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        foregroundColor: Colors.white,
                        backgroundColor:
                            Colors.white, // Text (foreground) color
                      ),
                      child: Text("Continue",
                          style: theme.textTheme.bodyLarge!.copyWith(
                              color: AppColors.textColorblue,
                              fontSize: 20,
                              fontWeight: FontWeight.w400)),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ))
      ]),
    );
  }
}
