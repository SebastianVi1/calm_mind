import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_mind/ui/view/profile_page.dart';
import 'package:re_mind/ui/view/therapy_page.dart';
import 'package:re_mind/ui/view/home_page.dart';
import 'package:re_mind/ui/view/tips_page.dart';
import 'package:re_mind/viewmodels/navigation_view_model.dart';
import 'package:re_mind/viewmodels/user_view_model.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({
    super.key
    });

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationViewModel>(
      builder: (context, navigationViewModel, child) {
        // Lista de páginas correspondientes a cada tab
        
        final List<Widget> pages = [
          const HomePage(),
          const TherapyPage(),
          const TipsPage(),
          ProfilePage(),

        ];

        return Scaffold(
          // Muestra la página actual
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: pages[navigationViewModel.currentIndex],
          ),
          
          bottomNavigationBar: NavigationBar(
            // Índice actual seleccionado
            selectedIndex: navigationViewModel.currentIndex,
            
            // Maneja el cambio de página
            onDestinationSelected: navigationViewModel.changeIndex,
            
            // Estilo del NavigationBar
            height: 70,
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 3,
            
            // Destinos de navegación
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: 'Inicio',
                tooltip: 'Página de inicio',
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person),
                label: 'Terapia',
                tooltip: 'Terapia con un chat de IA',
              ),
              NavigationDestination(
                icon: const Icon(Icons.lightbulb_outline),
                selectedIcon: const Icon(Icons.lightbulb),
                label: 'Consejos',
                tooltip: 'Consejos generales para salud mental',
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person),
                label: 'Perfil',
                tooltip: 'Perfil de usuario',
              ),
            ],
          ),
        );
      },
    );
  }
}