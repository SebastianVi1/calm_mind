import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_mind/ui/view/on_boarding_screen.dart';
import 'package:re_mind/ui/widgets/build_background.dart';
import 'package:re_mind/ui/widgets/text_field.dart';
import 'package:re_mind/viewmodels/login_view_model.dart';

/// Screen that handles user registration
/// Provides a form for name, email, password, and password confirmation
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  /// Key for form validation and state management
  final _formKey = GlobalKey<FormState>();
  
  /// Controllers for text input fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  /// Loading state for register button
  final bool _isLoading = false;

  /// Cleanup method to dispose of controllers when widget is removed
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  _buildTitle(context),
                  const SizedBox(height: 20),
                  _buildDescription(context),
                  const SizedBox(height: 30),
                  _buildRegisterForm(),
                  const SizedBox(height: 20),
                  _buildRegisterButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the registration screen title
  Widget _buildTitle(BuildContext context) {
    return Text(
      'Registremos tus datos',
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Builds the registration screen description
  Widget _buildDescription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        'Por favor ingresa tus datos para crear una cuenta',
        style: Theme.of(context).textTheme.bodyLarge,
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Builds the registration form with validation
  Widget _buildRegisterForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFieldWidget.buildTextField(
            controller: _nameController,
            label: 'Nombre',
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu nombre';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFieldWidget.buildTextField(
            controller: _emailController,
            label: 'Correo electrónico',
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
            label: 'Contraseña',
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
          const SizedBox(height: 20),
          TextFieldWidget.buildTextField(
            controller: _confirmPasswordController,
            label: 'Confirmar contraseña',
            icon: Icons.lock_outline,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor confirma tu contraseña';
              }
              if (value != _passwordController.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  /// Builds the register button with loading state
  Widget _buildRegisterButton() {
    return Consumer<LoginViewModel>(
      builder: (context, viewModel, child) {
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: viewModel.isLoading ? null : _handleRegister,
            child: viewModel.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    'Registrarse',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
          ),
        );
      },
    );
  }

  /// Handles the registration process
  /// Validates the form and calls the LoginViewModel to register
  void _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      final viewModel = context.read<LoginViewModel>();
      final success = await viewModel.register(
        _emailController.text,
        _passwordController.text,
        _nameController.text,
      );

      if (success) {
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OnBoardingScreen()));
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.error ?? 'Error al registrar usuario'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  Widget _googleButton(){
    final viewModel = context.read<LoginViewModel>();
    return ElevatedButton(
      onPressed: viewModel.isLoading ? null : () async {
        await viewModel.signInWithGoogle();
      },
      child: viewModel.isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Icon(Icons.mail),
    );
  }
}