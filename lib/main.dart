import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:re_mind/firebase_options.dart';
import 'package:re_mind/ui/themes/theme_config.dart';
import 'package:re_mind/ui/view/welcome_screen.dart';
import 'package:re_mind/viewmodels/on_boarding_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<void> main() async{
  
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
  
  //Initize firebase opitons after running the app 
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform //Choose between plataforms
  );
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
       home: WelcomeScreen(),
     
     ),
      ); 
  }
}
