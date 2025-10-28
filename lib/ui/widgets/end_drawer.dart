import 'package:calm_mind/ui/view/achievements_screen.dart';
import 'package:calm_mind/ui/view/psychologist/selection_screen.dart';
import 'package:calm_mind/viewmodels/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:calm_mind/ui/view/profile_page.dart';
import 'package:calm_mind/ui/view/emergency_screen.dart';
import 'package:calm_mind/viewmodels/theme_view_model.dart';

class WEndDrawer extends StatelessWidget {
  const WEndDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Drawer(
          width: 250,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Lottie.asset(
                      'assets/animations/meditation.json',
                      width: 200,
                    ),
                  ),
                ),
              ),

              ListTile(
                title: const Text('Perfil', textAlign: TextAlign.start),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
                },
                leading: Icon(Icons.person),
              ),

              ListTile(
                enabled: !(context.read<UserViewModel>().isAnonymous ?? false),
                title: const Text('Logros'),
                leading: Icon(Icons.masks_outlined),
                subtitle:
                    context.read<UserViewModel>().isAnonymous ?? false
                        ? Row(
                          children: [
                            Icon(Icons.lock, size: 15),
                            SizedBox(width: 3),
                            Text(
                              'Inicia sesion',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        )
                        : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AchievementsScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('Modo oscuro', textAlign: TextAlign.start),
                leading: Icon(Icons.dark_mode),
                trailing: Consumer<ThemeViewModel>(
                  builder: (context, themeViewModel, child) {
                    return Switch(
                      value: themeViewModel.isDarkModeActive,
                      onChanged: (value) {
                        themeViewModel.toggleTheme();
                      },
                    );
                  },
                ),
              ),

              ListTile(
                title: const Text(
                  'Modulo Profesional',
                  textAlign: TextAlign.start,
                ),
                leading: Icon(Icons.assignment_outlined),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SelectionScreen()),
                  );
                },
              ),
            ],
          ),
        ),
        Positioned(
          right: 10,
          bottom: 20,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EmergencyScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.emergency, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text(
                        'SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
