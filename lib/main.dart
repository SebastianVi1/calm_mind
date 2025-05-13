import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:re_mind/firebase_options.dart';
import 'package:re_mind/services/auth/i_auth_service.dart';
import 'package:re_mind/services/auth/firebase_auth_service.dart';
import 'package:re_mind/services/relaxing_music_service.dart';
import 'package:re_mind/services/user_service.dart';
import 'package:re_mind/services/deepseek_service.dart';
import 'package:re_mind/ui/themes/theme_config.dart';
import 'package:re_mind/ui/view/app_wrapper.dart';
import 'package:re_mind/viewmodels/auth_view_model.dart';
import 'package:re_mind/viewmodels/login_view_model.dart';
import 'package:re_mind/viewmodels/meditation_view_model.dart';
import 'package:re_mind/viewmodels/mood_view_model.dart';
import 'package:re_mind/viewmodels/navigation_view_model.dart';
import 'package:re_mind/viewmodels/on_boarding_viewmodel.dart';
import 'package:re_mind/viewmodels/chat_view_model.dart';
import 'package:re_mind/viewmodels/relaxing_music_view_model.dart';
import 'package:re_mind/viewmodels/user_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:re_mind/viewmodels/tips_view_model.dart';
import 'package:re_mind/viewmodels/theme_view_model.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
  bool useSystemTheme = prefs.getBool('useSystemTheme') ?? true;
  bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  
  runApp(MainApp(
    hasSeenOnboarding: hasSeenOnboarding,
    useSystemTheme: useSystemTheme,
    isDarkMode: isDarkMode,
  ));
}

class MainApp extends StatefulWidget {
  const MainApp({
    super.key, 
    required this.hasSeenOnboarding,
    required this.useSystemTheme,
    required this.isDarkMode,
  });
  
  final bool hasSeenOnboarding;
  final bool useSystemTheme;
  final bool isDarkMode;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    initializeSplash();
  }

  void initializeSplash() async {
    await Future.delayed(const Duration(seconds: 2));
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserViewModel>(
          create: (_) => UserViewModel(),
        ),
        ChangeNotifierProvider<ThemeViewModel>(
          create: (_) => ThemeViewModel(),
        ),
        Provider<IAuthService>(
          create: (_) => FirebaseAuthService(),
        ),
        Provider<UserService>(
          create: (_) => UserService(),
        ),
        Provider<DeepSeekService>(
          create: (_) => DeepSeekService(),
        ),
        Provider(
          create: (_) => RelaxingMusicService(),
        ),
        ChangeNotifierProvider(
          create: (context) => OnBoardingViewmodel()
        ),
        ChangeNotifierProvider(
          create: (context) => AuthViewModel(
            context.read<IAuthService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => LoginViewModel(
            context.read<IAuthService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => NavigationViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => ChatViewModel(
            context.read<DeepSeekService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => TipsViewModel()
        ),
        ChangeNotifierProvider(
          create: (context) => MoodViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => MeditationViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => RelaxingMusicViewModel(
            context.read<RelaxingMusicService>(),
          )
        ),
        
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeViewModel, child) {
          return AnimatedTheme(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            data: themeViewModel.isDarkModeActive ? Themes.darkTheme : Themes.lightTheme,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              color: themeViewModel.isDarkModeActive 
                ? Themes.darkTheme.scaffoldBackgroundColor 
                : Themes.lightTheme.scaffoldBackgroundColor,
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: Themes.lightTheme,
                darkTheme: Themes.darkTheme,
                themeMode: themeViewModel.useSystemTheme 
                  ? ThemeMode.system 
                  : (themeViewModel.isDarkMode ? ThemeMode.dark : ThemeMode.light),
                title: 'CalmMind',
                home: const AppWrapper(),
              ),
            ),
          );
        }
      ),
    );
  }
}
