import 'package:calm_mind/ui/view/achievements_screen.dart';
import 'package:calm_mind/viewmodels/achievement_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:calm_mind/ui/view/therapy_page.dart';
import 'package:calm_mind/ui/view/welcome_screen.dart';
import 'package:calm_mind/ui/widgets/end_drawer.dart'; // Importamos el EndDrawer
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
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Perfil', style: Theme.of(context).textTheme.titleLarge),
        actions: [
          IconButton(
            onPressed: () {
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
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WelcomeScreen(),
                            ),
                          );
                        },
                        child: const Text('Sí'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedLogout02,
              color:
                  Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
            ),
          ),
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      // Agregamos el mismo EndDrawer usado en el resto de la aplicación
      endDrawer: WEndDrawer(),
      body: SingleChildScrollView(
        // Wrap with SingleChildScrollView
        child: ConstrainedBox(
          // Add constraints
          constraints: BoxConstraints(
            minHeight:
                screenSize.height -
                kToolbarHeight -
                MediaQuery.of(context).padding.top,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
          ),
        ),
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
          child:
              viewModel.isLoading
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

  Widget _buildBadgeObtained() {
    List<String> assets =
        context.read<AchievementViewModel>().getUnlockedBadges();
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blueGrey, Colors.redAccent],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: GestureDetector(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AchievementsScreen()),
                ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  assets.map((asset) {
                    return Image.asset(asset, width: 45);
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(
    BuildContext context,
    UserViewModel viewModel,
    user,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Container(
      width: screenSize.width * (isSmallScreen ? 0.95 : 0.9),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
      margin: EdgeInsets.all(isSmallScreen ? 8 : 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 16),
          Column(
            children: [
              Text(
                'ID de Usuario',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.badge,
                          size: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: SelectableText(
                            user.uid,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 14),
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(text: user.uid),
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('ID copiado al portapapeles'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          tooltip: 'Copiar ID',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildAchievementsSection(context, viewModel),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.assignment_outlined),
              label: const Text('Volver a hacer el cuestionario'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OnBoardingScreen(),
                  ),
                );
              },
            ),
          ),
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
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            context.read<NavigationViewModel>().changeIndex(1);
                            final lastSessionId =
                                chatViewModel.sessions.keys.last;
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
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
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
    );
  }

  Widget _buildAchievementsSection(
    BuildContext context,
    UserViewModel viewModel,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Logros',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.emoji_events,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AchievementsScreen(),
                      ),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              return Consumer<AchievementViewModel>(
                builder: (context, achievementVM, _) {
                  final badges = achievementVM.getUnlockedBadges();

                  if (badges.isEmpty) {
                    return Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.workspace_premium,
                            size: 48,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Completa actividades para desbloquear logros',
                            textAlign: TextAlign.center,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children:
                        badges.map((badge) => _buildBadgeItem(badge)).toList(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem(String badgeAsset) {
    return Container(
      width: 60,
      height: 60,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Image.asset(badgeAsset, fit: BoxFit.contain),
    );
  }
}
