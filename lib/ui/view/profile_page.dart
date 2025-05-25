import 'dart:ui';

import 'package:calm_mind/ui/view/achievements_screen.dart';
import 'package:calm_mind/viewmodels/achievement_view_model.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:calm_mind/ui/view/therapy_page.dart';
import 'package:calm_mind/ui/view/welcome_screen.dart';
import 'package:calm_mind/ui/widgets/end_drawer.dart';  // Importamos el EndDrawer
import 'package:calm_mind/viewmodels/auth_view_model.dart';
import 'package:calm_mind/viewmodels/chat_view_model.dart';
import 'package:calm_mind/viewmodels/navigation_view_model.dart';
import 'package:calm_mind/viewmodels/user_view_model.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Clave local para el Scaffold del ProfilePage
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UserViewModel>(context);
    final user = viewModel.currentUser;

    
    return Scaffold(
      key: _scaffoldKey,  
      appBar: AppBar(
        title: Text(
          'Perfil',
          style: Theme.of(context).textTheme.titleLarge,
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
            
          }, icon: HugeIcon(icon: HugeIcons.strokeRoundedLogout02, color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white)),
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              
              _scaffoldKey.currentState?.openEndDrawer();
            },
          )
        ],
      ),
      // Agregamos el mismo EndDrawer usado en el resto de la aplicación
      endDrawer: WEndDrawer(),
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
        viewModel.pickImageFromGallery().then((file) {
          viewModel.updateProfilePicture(file);

        } );
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

  Widget _buildBadgeObtained(){
    List<String> assets = context.read<AchievementViewModel>().getUnlockedBadges();
    return Column(
      children: [
        Text(
          'Logros obtenidos',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8,),
        Container(
          
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blue, Colors.blueGrey, Colors.redAccent]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: GestureDetector(
            onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => AchievementsScreen(),)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: assets.map((asset) {
                return Image.asset(
                  asset,
                  width: 45,
                  
                );
              }
              ).toList(),
            ),
          ),
        )
    
      ],
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
         
          _buildBadgeObtained(),
          const SizedBox(height: 15,),
          if (context.read<ChatViewModel>().sessions.isNotEmpty)
            Text(
              'Numa',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Card(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(
                    'Continua tu ultima sesion',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      context.read<NavigationViewModel>().changeIndex(1);
                      final lastSession = context.read<ChatViewModel>().sessions.keys.last;
                      context.read<ChatViewModel>().continueSession(lastSession);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TherapyPage(),
                        ),
                      );
                    },
                    
                  ),
                  subtitle: Text(
                    
                    context.read<ChatViewModel>().sessions.values.last[1].content,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    ),
                ),
              ),
            ),
          
        ],
      ),
    );
  }
}
