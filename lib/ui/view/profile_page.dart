import 'package:flutter/material.dart';
import 'package:flutter_animate_on_scroll/flutter_animate_on_scroll.dart';
import 'package:provider/provider.dart';
import 'package:re_mind/ui/view/welcome_screen.dart';
import 'package:re_mind/viewmodels/auth_view_model.dart';
import 'package:re_mind/viewmodels/user_view_model.dart';
import 'package:lottie/lottie.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UserViewModel>(context);
    final user = viewModel.currentUser;

    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Perfil',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Colors.transparent,
        actionsIconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.red : Colors.black,
        ),
        actions: [
          IconButton(onPressed: (){
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Cerrar sesion?'),
                  content: const Text('Seguro que quieres cerrar sesion?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<AuthViewModel>().signOut();
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WelcomeScreen()));
                      },
                      child: const Text('Sí'),
                    ),
                  ],

                );
              },
            );
            
          }, icon: Lottie.asset('assets/animations/loading.json'))
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          
          _buildProfileInfo(context, viewModel, user),
          
          if (viewModel.error != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                viewModel.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
           
        ],
      ),
    );
  }

  Widget _buildProfileImage(BuildContext context, UserViewModel viewModel) {
    return GestureDetector(
      onTap: (){
        viewModel.pickImageFromGallery().then((file) => viewModel.updateProfilePicture(file));
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: viewModel.getProfileImage(),
            fit: BoxFit.cover,
          ),
        ),
        child: viewModel.isLoading
            ? const CircularProgressIndicator()
            : null,
      ),
    );
  }

  Widget _buildProfileInfo(
    BuildContext context,
    UserViewModel viewModel,
    user,
  ) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Container(
      width: deviceWidth * 0.9,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildProfileImage(context, viewModel),
          const SizedBox(height: 20),
          Text(
            'Nombre',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.start,
          ),
          Text(
            user.displayName ?? 'Usuario anonimo',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            'Email',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            user.email ?? 'Usuario anonimo',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          
        ],
      ),
    );
  }
}