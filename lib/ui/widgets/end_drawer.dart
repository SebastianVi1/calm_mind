import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:calm_mind/ui/view/profile_page.dart';
import 'package:calm_mind/viewmodels/theme_view_model.dart';

class WEndDrawer extends StatelessWidget {
  const WEndDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
                child: Lottie.asset('assets/animations/meditation.json',width: 200,)
              )
            ),
            
          ),
          
          ListTile(
            title: const Text('Perfil',textAlign: TextAlign.start,),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },

            leading: Icon(Icons.person),
            
          ),
          ListTile(
            title: const Text('Modo oscuro', textAlign: TextAlign.start,),
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
            title: const Text('Terminos y condiciones',textAlign: TextAlign.start,),
            leading: Icon(Icons.file_copy),
            
            
          )
        ],
      ),
    );
  }
}
