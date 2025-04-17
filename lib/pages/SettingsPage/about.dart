import 'package:flutter/material.dart';
import 'package:pixieapp/const/colors.dart';
import 'package:go_router/go_router.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Container(
            height: deviceHeight,
            width: deviceWidth,
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
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 15.0, vertical: 15.0),
                child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                context.pop();
                              },
                              child: const Icon(
                                Icons.arrow_back,
                                color: AppColors.sliderColor,
                                size: 25,
                              ),
                            ),
                            const SizedBox(width: 20),
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  AppColors.textColorGrey,
                                  AppColors.textColorSettings,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ).createShader(
                                Rect.fromLTWH(
                                    0.0, 0.0, bounds.width, bounds.height),
                              ),
                              child: Text(
                                "About",
                                style: theme.textTheme.headlineMedium!.copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textColorWhite),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'About Pixie',
                          style: theme.textTheme.bodyMedium!.copyWith(
                              color: AppColors.textColorblack,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                            'Pixie, a screen-free audio platform for kids \n\nAt Pixie, we understand how challenging it can be to reduce your child’s screen time when equally engaging, meaningful alternatives are hard to find. That’s why we’re on a mission to create audio solutions that can healthily engage your child and allow independent play.\n\nOur first offering, the Pixie Mobile App, empowers parents to craft personalized audio stories for their child, boosting the child’s creativity and encouraging active listening.'),
                        const SizedBox(height: 15),
                        Text(
                          'About team',
                          style: theme.textTheme.bodyMedium!.copyWith(
                              color: AppColors.textColorblack,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                            'Pixie is the creation of a passionate team of parents and child development enthusiasts who share a common goal: to reduce screen time for kids and provide an alternative that supports their cognitive and emotional growth.\n\nTogether, our team is committed to reimagining storytelling for kids and helping families embrace a world beyond screens!'),
                        const SizedBox(height: 20),
                        Text(
                          'Privacy Policy',
                          style: theme.textTheme.bodyMedium!.copyWith(
                              color: AppColors.textColorblack,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 15),
                        Text('''Last Updated: November 14, 2024 
                  
This Privacy Policy explains how Fabletronic Technologies Private Limited (“Pixie”,"we", "us", or "our") collects, uses, and shares information about you when you use the Pixie website or app ("Service") or any related services. By using the Service, you agree to the collection, use, and disclosure of your information as described in this Privacy Policy.

Information We Collect

We collect the following types of information when you use our Service:

Account Information: When you register for an account, participate in interactive features, fill out a form or a survey, communicate with our customer support, or otherwise communicate with us. The information you may provide includes your name, email address, phone number, password, and/or other information you choose to provide.
Usage Information: We collect information about how you use our Service, including your audio and location.

The above facilitates our ability to send you transactional or relationship communications, such as receipts, account notifications, customer service responses, and other administrative messages. It assists us in identifying, preventing, and rectifying technical and security issues;

We use it to personalize your experience, tailor content according to your interests, and shape the advertisements you encounter on other platforms in line with your preferences, interests, and browsing behavior;

We comply with the law by using it to process transactional records for tax filings and other compliance activities. We enforce our Terms of Use and fulfill our legal obligations using this information;
                  
Data Retention

We retain your information for as long as necessary to provide the Service and fulfill the purposes outlined in this Privacy Policy, unless a longer retention period is required or permitted by law.

Data Security
We take reasonable measures, including administrative, technical, and physical safeguards, to protect your information from loss, theft, misuse, unauthorized access, disclosure, alteration, and destruction. We utilize industry-standard security measures. However, no method of transmission over the Internet, or method of electronic storage, is completely secure, and while we strive to protect your personal information, we cannot guarantee its absolute security.

Children's Privacy

The App is intended for users who are at least 18 years old. As part of the App's functionality, you may be asked to create a profile that includes a first name, age, and other information of children. This information is used to generate customized stories for children. This information is kept confidential and is not shared with third parties, except as described in our Privacy Policy.

Third Party Services

Our Service uses third-party service providers to enable certain features and improve the functionality of our service. For the Service, these third-party services include OpenAI and Meta, and ElevenLabs which facilitate the AI-driven story generation in our Service. When you create a story using our Service, we send information that you input into the story generator to these services, which process this data and return AI-generated text to be incorporated into your story. Please note that we do not share any personally identifiable information, such as your name or email address, with these service providers when creating these stories.

For our Service, these third-party service providers have their own privacy policies addressing how they use such information. Please note that we do not control and are not responsible for the privacy practices of these third-party services. We recommend you review their respective privacy policies to understand how they collect, use, and share your data.

Your Rights and Choices
In accordance with applicable law, you may have certain rights regarding the personal information we maintain about you. These may include the rights to access, rectification, deletion, restrict processing, data portability, and withdrawal of consent. Below we describe the processes for you to exercise these rights. 

Access: You have the right to request access to the personal information that we hold about you. This includes a right to access the personal information that constitutes part of your account and other basic information.
Rectification: If you believe that any of the personal information that we hold about you is inaccurate or incomplete, you have a right to request that we correct or complete such personal information.
Deletion: You have the right to request deletion of personal information that we hold about you.
Restrict Processing: You have the right to request that we restrict processing of your personal information where you believe such data to be inaccurate; our processing is unlawful; or that we no longer need to process such data for a particular purpose unless we are not able to delete the data due to a legal or other obligation.
Withdrawal of Consent: If you have consented to our processing of your personal information, you have the right to withdraw your consent at any time, free of charge. This includes cases where you wish to opt out of marketing messages that you receive from us.

To exercise these rights, please contact us at shivbansal@mypixie.in We will respond to your request consistent with applicable laws. To protect your privacy and security, we may require you to verify your identity.

Information for California Residents

This section provides additional disclosures required by the California Consumer Privacy Act (or "CCPA"). Please see below for a list of the personal information we have collected about California consumers in the last 12 months, along with our business and commercial purposes and categories of third parties with whom this information may be shared. For more details about the personal information we collect, including the categories of sources, please see the "Collection of Information" section above.

Categories of personal information we collect
Identifiers, such as your name, phone number, email address, and unique identifiers (like IP address) tied to your browser or device. Characteristics of protected classifications under state or federal law, such as gender and age.Internet or other electronic network activity, such as browsing behavior and information about your usage and interactions with our Service. Other personal information you provide, including opinions, preferences, and personal information contained in product reviews, surveys, or communications. Inferences drawn from the above, such as product interests, and usage insights.

Business or commercial purposes for which we may use your information

Performing or providing our services, such as to maintain accounts, provide customer service, process orders and transactions, and verify customer information.

Improving and maintaining our Service, such as by improving our services and developing new products and services. Debugging, such as to identify and repair errors and other functionality issues.

Communicate with you about marketing and other relationship or transactional messages.

Analyze usage, such as by monitoring trends and activities in connection with use of our Service.

Personalize your online experience, such as by tailoring the content you see on our Service based on your preferences, interests, and browsing behavior. 

Legal reasons, such as to help detect and protect against security incidents, or other malicious, deceptive, fraudulent, or illegal activity.

Parties with whom information may be shared

Companies that provide services to us, such as those that assist us with customer support, subscription and order fulfillment, data analytics, fraud prevention, cloud storage, and payment processing.

Third parties with whom you consent to sharing your information, such as with social media services or academic researchers.

Our advertisers and marketing partners, such as partners that help determine the popularity of content, deliver advertising and content targeted to your interests, and assist in better understanding your online activity.

Government entities or other third parties for legal reasons, such as to comply with law or for other legal reasons as described in our Sharing section. Subject to certain limitations and exceptions, the CCPA provides California consumers the right to request to know more details about the categories and specific pieces of personal information, to delete their personal information, to opt out of any "sales" that may be occurring, and to not be discriminated against for exercising these rights.

We do not "sell" the personal information we collect (and will not sell it in the future without providing a right to opt out). We do allow our advertising partners to collect certain device identifiers and electronic network activity via our Services to show ads that are targeted to your interests on other platforms.

California consumers may make a rights request by emailing us at shivbansal@mypixie.in. We will verify your request by asking you to provide information that matches information we have on file about you. Consumers can also designate an authorized agent to exercise these rights on their behalf. Authorized agents should submit requests through the same channels, but we will require proof that the person is authorized to act on your behalf and may also still ask you to verify your identity with us directly.

Information for European Union Users
If you are a user from the European Union, you have certain rights and protections under the General Data Protection Regulation (GDPR).

Rights of EU Users

Under the GDPR, you have the following rights:

Right to Access: You have the right to request access to your personal data that we process.
Right to Rectification: If the personal data we hold about you is inaccurate or incomplete, you have the right to have this information rectified or, taking into account the purposes of the processing, completed.
Right to Erasure (‘Right to be Forgotten’): You have the right to request the erasure of your personal data.
Right to Restrict Processing: You have the right to request that we restrict the processing of your personal data.
Right to Data Portability: You have the right to receive your personal data in a structured, commonly used, machine-readable format and have the right to transmit those data to another controller without hindrance, where technically feasible.
Right to Object: You have the right to object to the processing of your personal data for reasons related to your particular situation, at any time. The right to object also specifically applies to data processing for direct marketing purposes.
Right not to be subject to Automated Decision-making: You have the right not to be subject to a decision based solely on automated processing, including profiling, which produces legal effects concerning you or similarly significantly affects you.
If you wish to exercise any of these rights, please contact us at shivbansal@mypixie.in. We may ask you to verify your identity for security purposes.

Data Transfers

We wish to remind you that your personal data may be transferred to, stored, and processed in the United States where our servers are located. Some of these countries may not have the same data protection laws as the European Union. We ensure that such data transfers comply with applicable laws, including the GDPR, by relying on legal data transfer mechanisms such as Standard Contractual Clauses.

Data Protection Officer

If you have any questions or concerns about our use of your personal data, you can contact our Data Protection Officer at shivbansal@mypixie.in. Please note that you also have the right to lodge a complaint with your local data protection authority or the appropriate authority under the applicable law.

Cookies, Analytics, and Similar Technologies
We use cookies, analytics, and similar technologies to personalize and enhance your experience on our Website and App. Cookies, web beacons, device identifiers and other technologies collect information about your use of the Services and other websites and online services, including your IP address, device identifiers, web browser, mobile network information, pages viewed, time spent on pages or in apps, links clicked, and conversion information. These technologies allow us to remember your preferences, understand the performance of our Website, provide social media features, and customize content and advertisements relevant to your interests.

You have the right to decide whether to accept or reject cookies. Most browsers automatically accept cookies, but you can modify your browser settings to decline cookies if you prefer. If you choose to decline cookies, some parts of our Website may not work as intended or may not work at all.

Please note that if you choose to remove or reject cookies, this could affect the availability and functionality of our Website. If you have any questions about our use of cookies or other technologies, please email us at shivbansal@mypixie.in.

Changes to This Privacy Policy
We may update this Privacy Policy from time to time. If we make changes, we will notify you by revising the date at the top of the policy and, in some cases, we may provide you with additional notice (such as adding a statement to our website homepage or sending you a notification through the App or by email). Your continued use of our Service after such changes become effective constitutes your acceptance of the new Privacy Policy.
''',
                            style: theme.textTheme.bodyMedium!.copyWith(
                                color: AppColors.textColorblack,
                                fontWeight: FontWeight.w400)),
                        const SizedBox(height: 15),
                        Text(
                          'TERMS OF USE ',
                          style: theme.textTheme.bodyMedium!.copyWith(
                              color: AppColors.textColorblack,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 15),
                        Text('''

Please read these Terms of Use ("Terms") carefully before using the Pixie application ("the Service") provided by Fabletronic Technologies Private Limited ("we," "us," or "Provider"). By accessing or using the Service, you agree to be bound by these Terms. If you do not agree with any part of these Terms, you may not use the Service.

1. Use of the Service

1.1 Eligibility:
You must be at least 18 years old to use the Service. By using the Service, you represent and warrant that you are 18 years of age or older.

1.2 Account Registration:
To access certain features of the Service, you will need to create an account. You agree to provide accurate, current, and complete information during the registration process. You are solely responsible for maintaining the confidentiality of your account and password and for all activities that occur under your account.

1.3 Acceptable Use:
You agree to use the Service in compliance with these Terms and all applicable laws and regulations. You further agree not to:
Use the Service for any unlawful or fraudulent purpose.
Interfere with or disrupt the Service or servers or networks connected to the Service. 
Attempt to gain unauthorized access to the Service or any user accounts or computer systems.
Replicate, modify, or create derivative works of our Service.
Reverse engineer, decompile, or disassemble our Service. 
Transmit any viruses, worms, or other harmful computer code through the Service.
Impersonate any person or entity or falsely state or misrepresent your affiliation with a person or entity.
Collect or store personal information of other users without their consent.
Alter or remove copyright, trademark, or other proprietary rights notices on our Service.

1.4 Content Ownership:
When you submit any material or data to the Service, it is termed as "Input". The resulting creation or product from our Services based on your Input is referred to as the "Output". Together, both Input and Output are addressed as the "User Content". You retain ownership of any intellectual property rights that you hold in the User Content. However, by submitting User Content to the Service, you grant us a non-exclusive, worldwide, royalty-free, sublicensable, and transferable license to use, reproduce, distribute, modify, adapt, publicly display, and perform the User Content in connection with the Service.

2. Copyright and User Responsibility

User-Created Content: Users are solely responsible for the content they create on Pixie, including text, images, and stories.
Originality Requirement: Users are encouraged to create original content and must ensure that their stories do not infringe upon the intellectual property rights of others.
Uniqueness Concerns: Given the nature of AI and machine learning, the Output may sometimes resemble creations of other users. It's possible for Pixie or other users to generate similar or identical content.
Enhancing Our Services: Machine learning thrives on data for improvement. By using Pixie, you agree that we can use your User Content to refine and enhance our Services. 
Advertising and Promotion: Notwithstanding anything to the contrary, we obtain a non-exclusive license to use your User Content for advertising and promotional activities, including featuring it on our website.
Visibility of Public Content: Any Output might be viewed and potentially used by Pixie in ways that might transform or derive from the original.
Rights on User Content: User Content created by users grants Pixie comprehensive rights to utilize and commercialize the content. In return, free users receive a global, non-exclusive, royalty-free license to access and use their generated content for personal or commercial purposes.

3. Liability for Generated Content

Generated content: Pixie is not responsible for content generated in response to user prompts. The platform provides a tool for image generation, but the content of the images is derived from user inputs.
Content Moderation: While Pixie employs moderation measures, the ultimate responsibility for the content lies with the user who created the prompt.
Adult Responsibility: We employ content filters to ensure stories and images generated within the Services are suitable for all ages. However, we cannot guarantee every piece of content will meet everyone's standards or be appropriate for all children. Adults are tasked with reviewing all stories produced by the App before sharing them with children. If you encounter any content you believe is inappropriate or contravenes these Terms, please report it to us for review.


4. Prohibited Content
Inappropriate Material: Users may not create or share stories that contain inappropriate, offensive, or explicit material.
Harmful or Dangerous Content: Content that is harmful, dangerous, encourages illegal activities, or could cause physical or mental harm is strictly prohibited.
Respect and Safety:  Pixie is committed to maintaining a safe, respectful environment. Any content that harasses, bullies, or violates the rights of others is not allowed.

5. Enforcement and Consequences
Violation of Terms: Violation of these terms may result in the removal of content, suspension of account access, or other appropriate actions.
Reporting Mechanisms: Users are encouraged to report any content that they believe violates these terms.  Pixie will review such reports and take action as necessary.

6. Agreement to Terms
By using  Pixie, users agree to abide by these terms of service and acknowledge their responsibility for the content they create and share on the platform.

7. Intellectual Property

7.1 Service Content:
The Service, including its design, graphics, images, and other elements, is owned or licensed by  Pixie and is protected by copyright, trademark, and other intellectual property laws. You may not modify, reproduce, distribute, or create derivative works based on any part of the Service without our prior written consent.
7.2 Trademarks:
"Pixie" and the  Pixie logo are trademarks of  Pixie. You may not use these trademarks without our prior written permission.

8. Disclaimer of Warranty

The Service is provided on an "as is" and "as available" basis, without any warranties of any kind, either expressed or implied. We do not warrant that the Service will be uninterrupted, error-free, or secure. Your use of the Service is at your own risk.

The Service may contain links to or use third-party websites or services that are not owned or controlled by us. We have no control over, and assume no responsibility for the content, privacy policies, or practices of any third-party websites or services. By using the Service, you expressly release us from any and all liability arising from your use of any third-party website or service.

9. Limitation of Liability

To the maximum extent permitted by law, we shall not be liable for any indirect, incidental, consequential, or exemplary damages arising out of or in connection with the use of the Service. In no event shall our total liability exceed the amount paid by you, if any, for accessing or using the Service.

10. Modification of Terms

We reserve the right to modify or revise these Terms at any time. If we make material changes to these Terms, we will notify you by posting a notice on the Service or by sending you an email. Your continued use of the Service after the effective date of the revised Terms constitutes your acceptance of the changes.

11. Termination

We may, in our sole discretion, suspend or terminate your access to the Service at any time and for any reason, without notice or liability.

12. Governing Law and Jurisdiction

These Terms shall be governed by and construed in accordance with the laws of India. Any legal actions or proceedings arising out of or relating to these Terms shall be exclusively brought in the courts located in Bengaluru, and you consent to the personal jurisdiction of such courts.

13. Contact Us
If you have any questions, concerns, or requests regarding these Terms, please contact us at shivbansal@mypixie.in
                  
                  ''',
                            style: theme.textTheme.bodyMedium!.copyWith(
                                color: AppColors.textColorblack,
                                fontWeight: FontWeight.w400)),
                      ]),
                ),
              ),
            )));
  }
}
