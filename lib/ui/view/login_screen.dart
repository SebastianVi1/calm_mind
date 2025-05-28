import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calm_mind/models/auth/auth_state.dart';
import 'package:calm_mind/ui/constants/app_constants.dart';
import 'package:calm_mind/ui/view/app_wrapper.dart';
import 'package:calm_mind/ui/view/register_screen.dart';
import 'package:calm_mind/ui/widgets/build_logo.dart';
import 'package:calm_mind/ui/widgets/text_field.dart';
import 'package:calm_mind/viewmodels/login_view_model.dart';
import 'package:lottie/lottie.dart';
import 'package:calm_mind/viewmodels/auth_view_model.dart';

/// Screen that handles user authentication
/// Provides a form for email and password input with validation
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Key for form validation and state management
  final _formKey = GlobalKey<FormState>();
  
  /// Controllers for text input fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  /// Cleanup method to dispose of controllers when widget is removed
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Builds the main scaffold with background and content
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildContent(),
        ],
      ),
    );
  }

  /// Builds the main content of the login screen
  /// Includes logo, welcome text, login form, and registration link
  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            WBuildLogo.buildLogo(context: context),
            const SizedBox(height: 30),
            _buildWelcomeText(),
            const SizedBox(height: 30),
            _buildLoginForm(),
            
            const SizedBox(height: 20),
            _buildLoginButton(),
            const SizedBox(height: 20),
            _buildRegisterLink(),
          ],
        ),
      ),
    );
  }

  /// Builds the welcome text with animation
  /// Displays a static welcome message and an animated login prompt
  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          AppConstants.welcomeText,
          style: Theme.of(context).textTheme.displaySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        AnimatedTextKit(
          pause: Duration(milliseconds: 1000),
          isRepeatingAnimation: false,
          animatedTexts: [
            TypewriterAnimatedText(
              AppConstants.loginRequiredText,
              curve: Curves.linear,
              textStyle: Theme.of(context).textTheme.bodyMedium,
              speed: Duration(milliseconds: 100),
              cursor: '',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the login form with email and password fields
  /// Includes validation for both fields
  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          WBuildTextFieldWidget.buildTextField(
            context: context,
            controller: _emailController,
            label: AppConstants.emailLabel,
            icon: Icons.email_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          WBuildTextFieldWidget.buildTextField(
            context: context,
            controller: _passwordController,
            label: AppConstants.passwordLabel,
            icon: Icons.lock_outline,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  /// Builds the login button with loading state
  Widget _buildLoginButton() {
    return Consumer<LoginViewModel>(
      builder: (context, viewModel, child) {
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: viewModel.isLoading ? null : _handleLogin,
            child: viewModel.isLoading
                ? Lottie.asset('assets/animations/loading.json', width: 24, height: 24)
                : Text(
                    'Sign in',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
          ),
        );
      },
    );
  }

  /// Builds the registration link
  /// Provides navigation to the registration screen
  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextButton(
          style: ButtonStyle(padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 5))),
          child: Text('Sign up'),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen())),
        ),
      ],
    );
  }

  /// Handles the login process
  /// Validates the form and calls the LoginViewModel to sign in
  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final viewModel = context.read<LoginViewModel>();
      final success = await viewModel.login(
        _emailController.text,
        _passwordController.text,
      );

      if (success && mounted) {
        // Wait for authentication state to fully synchronize
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Verify authentication state before navigation
        final authViewModel = context.read<AuthViewModel>();
        if (authViewModel.state.status == AuthStatus.authenticated && mounted) {
          // Navigate and clear navigation stack
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const AppWrapper()),
            (route) => false, // Remove all routes
          );
        } else if (mounted) {
          // If state is not as expected, show a message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error synchronizing session state. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.error ?? 'Error signing in'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
