import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:re_mind/ui/view/on_boarding_screen.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/welcome_background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                          'Remind',
                          style: Theme.of(context).textTheme.displayLarge,
                          )
                      ],
                    ),
                  
                
                const SizedBox(height: 40,),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                    child: Image.asset(
                      'assets/images/remind_logo.jpg',
                      scale: 8,
                      fit: BoxFit.cover,
                      
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                SizedBox(
                  height: 100,
                  width: 220,
                  child: AnimatedTextKit(
                    pause: Duration(milliseconds: 1000),
                    isRepeatingAnimation: false,
                    animatedTexts: [
                      TypewriterAnimatedText(
                        
                        curve: Curves.linear,
                        'Relaja tu mente, calma tu ser',
                        textStyle: Theme.of(context).textTheme.displaySmall?.copyWith(overflow: TextOverflow.ellipsis),
                        speed: Duration(milliseconds: 100),
                        cursor: '_',
                        textAlign: TextAlign.center

                      ),
        
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                
                Padding(
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
                              },
                              child: Text('Iniciar sesión', 
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white) ),
                            ),
                          ),
                        ),
                      ),    
                    ],
                  ),
                ),
                Padding(
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
                              child: Text('Continua sin usuario', 
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white) ),
                            ),
                          ),
                        ),
                      ),    
                    ],
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
