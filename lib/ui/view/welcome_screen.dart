import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:calm_mind/ui/constants/app_constants.dart';
import 'package:calm_mind/ui/view/login_screen.dart';
import 'package:calm_mind/ui/view/on_boarding_screen.dart';

import 'package:calm_mind/ui/widgets/build_logo.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        top: false,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                
                const SizedBox(height: 30,),
                _buildTitle(context),
                const SizedBox(height: 40,),
                WBuildLogo.buildLogo(context: context),
                const SizedBox(height: 20,),
                _buildSlogan(context),
                const SizedBox(height: 50),
                _buildLoginButton(context),
                _buildSignUpButton(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
            AppConstants.appName,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 40
            ),
            )
        ],
      );
  }

  Widget _buildSlogan(BuildContext context) {
    return SizedBox(
      height: 100,
      width: 220,
      child: AnimatedTextKit(
        pause: Duration(milliseconds: 1000),
        isRepeatingAnimation: false,
        animatedTexts: [
          TypewriterAnimatedText(
            
            curve: Curves.linear,
            AppConstants.appSlogan,
            textStyle: Theme.of(context).textTheme.displaySmall?.copyWith(overflow: TextOverflow.ellipsis),
            speed: Duration(milliseconds: 100),
            cursor: '_',
            textAlign: TextAlign.center

          ),

        ],
      ),
    );
  }  

  Widget _buildLoginButton(BuildContext context){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: SizedBox(
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                  child: Text(AppConstants.loginButtonText, 
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white) ),
                ),
              ),
            ),
          ),    
        ],
      ),
    );
  }

  Widget _buildSignUpButton(BuildContext context){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: SizedBox(
                height: 60,
                child: ElevatedButton(
                
                  onPressed: () {
                                       Navigator.push(

                      context,
                      MaterialPageRoute(
                        builder: (context) => OnBoardingScreen()
                      )
                    );
                  },
                  child: Text(AppConstants.continueWithoutUser, 
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white) ),
                ),
              ),
            ),
          ),    
        ],
      ),
    );
  }

}
