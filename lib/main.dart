import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:re_mind/firebase_options.dart';
import 'package:re_mind/services/auth/i_auth_service.dart';
import 'package:re_mind/services/auth/firebase_auth_service.dart';
import 'package:re_mind/services/user_service.dart';
import 'package:re_mind/ui/themes/theme_config.dart';
import 'package:re_mind/ui/view/app_wrapper.dart';
import 'package:re_mind/viewmodels/auth_view_model.dart';
import 'package:re_mind/viewmodels/login_view_model.dart';
import 'package:re_mind/viewmodels/on_boarding_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
  bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(MainApp(
    hasSeenOnboarding: hasSeenOnboarding,
    isDarkMode: isDarkMode,
  ));
}

class MainApp extends StatefulWidget {
  const MainApp({
    super.key, 
    required this.hasSeenOnboarding,
    required this.isDarkMode,
  });
  
  final bool hasSeenOnboarding;
  final bool isDarkMode;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late bool _isDarkMode;
  
  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  void toggleTheme() async {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<IAuthService>(
          create: (_) => FirebaseAuthService(),
        ),
        Provider<UserService>(
          create: (_) => UserService(),
        ),
        ChangeNotifierProvider(create: (context) => OnBoardingViewmodel()),
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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: Themes.lightTheme,
        darkTheme: Themes.darkTheme,
        themeMode: ThemeMode.system,
        title: 'ReMind',
        home: const AppWrapper(),
      ),
    );
  }
}
