import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pixieapp/const/colors.dart';
import 'package:pixieapp/widgets/analytics.dart';
class StoryConfirmationPage extends StatefulWidget {
  const StoryConfirmationPage({super.key});

  @override
  State<StoryConfirmationPage> createState() => _StoryConfirmationPageState();
}

class _StoryConfirmationPageState extends State<StoryConfirmationPage> {
   @override
  void initState() {
    super.initState();
    AnalyticsService.logScreenView(
      screenName: '/storyconfirmationstory',
      screenClass: 'Story Confirmation Screen',
    );
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceheight = MediaQuery.of(context).size.height;

    final devicewidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        width: devicewidth,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 248, 244, 187),
              Color.fromARGB(255, 231, 201, 249),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(children: [
              Positioned(
                child: Image.asset(
                  'assets/images/Ellipse 14.png',
                  height: 300,
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Transform.rotate(
                    angle: .2,
                    child: Image.asset(
                      'assets/images/star.png',
                      height: 70,
                      width: 70,
                    ),
                  ),
                ),
              ),
            ]),
            Container(
              height: 150,
              margin: const EdgeInsets.only(left: 40, right: 40),
              decoration: BoxDecoration(
                color: AppColors.kwhiteColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          AppColors.buttonColor1,
                          Color(0xff7995B4),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(
                        Rect.fromLTWH(0.0, 0.0, bounds.width, bounds.height),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 10,
                          bottom: 10,
                        ),
                        child: Text(
                          'Welcome to new adventures!',
                          style: theme.textTheme.bodyLarge!.copyWith(
                              color: AppColors.kwhiteColor,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          AppColors.buttonColor1,
                          Color(0xff7995B4),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(
                        Rect.fromLTWH(0.0, 0.0, bounds.width, bounds.height),
                      ),
                      child: Text(
                        'Do you want to create your first story now?',
                        maxLines: 2,
                        style: theme.textTheme.bodyLarge!.copyWith(
                            color: AppColors.kwhiteColor,
                            fontWeight: FontWeight.w400),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                     AnalyticsService.logEvent(
                            eventName: 'Yes_button');
                    context.push('/AddCharacter');
                  },
                  style: ElevatedButton.styleFrom(
                    surfaceTintColor: AppColors.kpurple,
                    foregroundColor: AppColors.kpurple,
                    shadowColor: AppColors.kpurple,
                    minimumSize: (const Size(150, 50)),
                    elevation: 2,
                    backgroundColor: AppColors.kwhiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Yes'),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                     AnalyticsService.logEvent(
                            eventName: 'No_button');
                    context.push('/HomePage');
                  },
                  style: ElevatedButton.styleFrom(
                    surfaceTintColor: AppColors.kpurple,
                    foregroundColor: AppColors.kpurple,
                    shadowColor: AppColors.kpurple,
                    overlayColor: Colors.transparent,
                    minimumSize: (const Size(150, 50)),
                    elevation: 2,
                    backgroundColor: AppColors.kwhiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'No',
                      style: TextStyle(
                        color: Color(0xFF7E57C2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
