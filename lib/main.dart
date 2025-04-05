import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_mind/ui/themes/theme_config.dart';
import 'package:re_mind/ui/view/home_screen.dart';
import 'package:re_mind/ui/view/on_boarding_screen.dart';
import 'package:re_mind/viewmodels/on_boarding_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
  runApp(MainApp(hasSeenOnboarding: hasSeenOnboarding));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.hasSeenOnboarding});
   final bool hasSeenOnboarding;


  @override
  Widget build(BuildContext context) {
     return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => OnBoardingViewmodel())
        ],
        child: MaterialApp(
    
       debugShowCheckedModeBanner: false, //Hide the debug banner
       theme: Themes.lightTheme,
       title: 'ReMind', //App title
       home: hasSeenOnboarding ? HomeScreen() : OnBoardingScreen(),
     
     ),
      ); 
  }
}
