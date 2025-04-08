import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:re_mind/ui/constants/app_constants.dart';
import 'package:re_mind/ui/view/register_screen.dart';
import 'package:re_mind/ui/widgets/build_background.dart';
import 'package:re_mind/ui/widgets/build_logo.dart';
import 'package:re_mind/ui/widgets/text_field.dart';

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
  
  /// Loading state for login button
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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

  /// Builds a reusable text field with custom styling
  

  /// Builds the login button with loading state
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: (){
          _handleLogin();
        },
        
        child: Text(
          'Iniciar sesión',
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ),
    );
  }

  /// Builds the registration link
  Widget _buildRegisterLink() {
    return  Row(
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
  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      // TODO: implement login logic
      // Aquí iría la lógica de inicio de sesión
      // Por ejemplo: authService.login(...)
    }
  }
}
