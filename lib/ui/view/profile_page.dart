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
import 'package:calm_mind/services/user_service.dart';
import 'package:calm_mind/ui/view/on_boarding_screen.dart';


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
      onTap: () {
        viewModel.pickImageFromGallery().then((file) {
          if (file != null) {
            viewModel.updateProfilePicture(file);
          }
        });
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        child: ClipOval(
          child: viewModel.isLoading
              ? const CircularProgressIndicator()
              : Image(
                  image: viewModel.getProfileImage(),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.person,
                      size: 50,
                      color: Theme.of(context).colorScheme.primary,
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildBadgeObtained(){
    List<String> assets = context.read<AchievementViewModel>().getUnlockedBadges();
    return Column(
      children: [

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
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfileImage(context, viewModel),
              const SizedBox(height: 20),
            Column(
                children: [
                  Text(
                    'Nombre',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user.displayName ?? 'Usuario anonimo',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            
            const SizedBox(height: 16),
            Column(
                children: [
                  Text(
                    'Email',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user.email ?? 'Usuario anonimo',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildAchievementsSection(context, viewModel),
              const SizedBox(height: 24),
              Consumer<ChatViewModel>(
                builder: (context, chatViewModel, child) {
                  if (chatViewModel.sessions.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final lastSession = chatViewModel.sessions.values.last;
                  if (lastSession.length < 2) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    children: [
                      Text(
                        'Última sesión',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              'Continuar última sesión',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.arrow_forward, color: Colors.white),
                              onPressed: () {
                                context.read<NavigationViewModel>().changeIndex(1);
                                final lastSessionId = chatViewModel.sessions.keys.last;
                                chatViewModel.continueSession(lastSessionId);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const TherapyPage(),
                                  ),
                                );
                              },
                            ),
                            subtitle: Text(
                              lastSession[1].content,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(16),
                  
                ),
                child: IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Reiniciar cuestionario'),
                        content: const Text('¿Estás seguro de que quieres volver a hacer el cuestionario? Tus respuestas anteriores se perderán.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () async {
                              try {
                                final userService = UserService();
                                await userService.resetQuestionnaire();
                                if (context.mounted) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (context) => const OnBoardingScreen()),
                                    (route) => false,
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              }
                            },
                            child: const Text('Reiniciar'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  tooltip: 'Reiniciar cuestionario',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(BuildContext context, UserViewModel viewModel) {
    // If the user is anonimous, 
    // if (viewModel.isAnonymous == null || viewModel.isAnonymous == true) {
    //   return Container(
    //     padding: const EdgeInsets.all(16),
    //     decoration: BoxDecoration(
    //       color: Theme.of(context).colorScheme.surface, 
    //       borderRadius: BorderRadius.circular(12),
    //       border: Border.all(
    //         color: Theme.of(context).colorScheme.outline.withValues(alpha: .5),
    //       ),
    //     ),
    //     child: Column(
    //       children: [
    //         Icon(
    //           Icons.lock_outline,
    //           size: 32,
    //           color: Theme.of(context).colorScheme.primary,
    //         ),
    //         const SizedBox(height: 8),
    //         Text(
    //           'Inicia sesión para ver tus logros',
    //           style: Theme.of(context).textTheme.titleMedium?.copyWith(
    //             color: Theme.of(context).colorScheme.primary,
    //             fontWeight: FontWeight.bold,
    //           ),
    //         ),
    //         const SizedBox(height: 4),
    //         Text(
    //           'Los usuarios anónimos no pueden acceder a esta función',
    //           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
    //             color: Theme.of(context).colorScheme.onSurfaceVariant,
    //           ),
    //           textAlign: TextAlign.center,
    //         ),
    //       ],
    //     ),
    //   );
    // }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Logros obtenidos',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Aquí irían los logros del usuario
          _buildBadgeObtained(),
        ],
      ),
    );
  }
}
