import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_mind/ui/constants/app_constants.dart';
import 'package:re_mind/ui/view/home_screen.dart';
import 'package:re_mind/ui/view/register_screen.dart';
import 'package:re_mind/ui/widgets/build_background.dart';
import 'package:re_mind/ui/widgets/build_logo.dart';
import 'package:re_mind/ui/widgets/text_field.dart';
import 'package:re_mind/viewmodels/login_view_model.dart';

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
          BuildBackground.backgroundWelcomeScreen(),
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
            BuildLogo.buildLogo(),
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
              textStyle: Theme.of(context).textTheme.bodyLarge,
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
          TextFieldWidget.buildTextField(
            controller: _emailController,
            label: AppConstants.emailLabel,
            icon: Icons.email_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu correo electrónico';
              }
              if (!value.contains('@')) {
                return 'Ingresa un correo electrónico válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFieldWidget.buildTextField(
            controller: _passwordController,
            label: AppConstants.passwordLabel,
            icon: Icons.lock_outline,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu contraseña';
              }
              if (value.length < 6) {
                return 'La contraseña debe tener al menos 6 caracteres';
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
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    'Iniciar sesión',
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
          '¿No tienes una cuenta?',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        TextButton(
          style: ButtonStyle(padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 5))),
          child: Text('Registrate'),
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

      if (success) {
        if (mounted) {
          print('todo salio bien');
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));// Return to previous screen on success
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.error ?? 'Error al iniciar sesión'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
