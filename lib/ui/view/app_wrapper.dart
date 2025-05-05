import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:re_mind/models/auth/auth_state.dart';
import 'package:re_mind/services/user_service.dart';
import 'package:re_mind/ui/view/main_screen.dart';
import 'package:re_mind/ui/view/on_boarding_screen.dart';
import 'package:re_mind/ui/view/welcome_screen.dart';
import 'package:re_mind/viewmodels/auth_view_model.dart';

/// Main navigation wrapper for the application
/// Handles routing based on authentication and onboarding status
class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  /// Loading state while checking user status
  bool _isLoading = true;
  
  /// Flag indicating if user has completed onboarding questions
  bool _hasCompletedQuestions = false;

  /// Error message if there's an issue checking the status
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkQuestionStatus();
  }

  /// Checks if the current user has completed the onboarding questions
  /// Updates loading and completion status accordingly
  Future<void> _checkQuestionStatus() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Wait for AuthViewModel to be initialized
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      if (!authViewModel.isInitialized) {
        await Future.delayed(const Duration(milliseconds: 500));
        return _checkQuestionStatus();
      }

      // If user is not authenticated, we don't need to check questions
      if (authViewModel.state.status != AuthStatus.authenticated) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final userService = Provider.of<UserService>(context, listen: false);
      
      // Try to get question status with retries
      bool hasCompleted = false;
      for (int attempt = 0; attempt < 3; attempt++) {
        try {
          hasCompleted = await userService.hasCompletedQuestions();
          if (hasCompleted) break;
          await Future.delayed(const Duration(milliseconds: 500));
        } catch (e) {
          print('Error checking question status (attempt ${attempt + 1}): $e');
          if (attempt < 2) await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      setState(() {
        _hasCompletedQuestions = hasCompleted;
        _isLoading = false;
      });
    } catch (e) {
      print('Error in _checkQuestionStatus: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    // Show loading indicator while checking user status
    if (_isLoading) {
      return  Scaffold(
        body: Center(
          child: Lottie.asset('assets/animations/loading.json',width: 150)
        ),
      );
    }

    // Show error message if there was an issue checking status
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Text('Error: $_error'),
        ),
      );
    }

    // User is not authenticated, show welcome screen
    if (authViewModel.state.status != AuthStatus.authenticated) {
      return const WelcomeScreen();
    }

    // User is authenticated but hasn't completed questions, show onboarding
    if (!_hasCompletedQuestions) {
      return WillPopScope(
        onWillPop: () async => false,
        child: const OnBoardingScreen(),
      );
    }

    // User is authenticated and has completed questions, show home screen
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('¿Salir de la aplicación?'),
            content: const Text('¿Estás seguro de que quieres salir?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Sí'),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: const MainScreen(),
    );
  }
} 