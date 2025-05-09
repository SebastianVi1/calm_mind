import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:provider/provider.dart';
import 'package:re_mind/ui/view/forum_page.dart';
import 'package:re_mind/ui/view/therapy_page.dart';
import 'package:re_mind/ui/view/home_page.dart';
import 'package:re_mind/ui/view/tips_page.dart';
import 'package:re_mind/ui/widgets/drawer_key.dart';
import 'package:re_mind/ui/widgets/end_drawer.dart';
import 'package:re_mind/viewmodels/navigation_view_model.dart';

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
          const ForumPage(),

        ];

        return Scaffold(
          key: globalScaffoldKey,
          // Muestra la página actual
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: pages[navigationViewModel.currentIndex],
          ),
          endDrawer: WEndDrawer(),
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
                icon:  HugeIcon(icon: HugeIcons.strokeRoundedHome09, color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white),
                selectedIcon: HugeIcon(icon: HugeIcons.strokeRoundedHome09, color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,),
                label: 'Inicio',
                tooltip: 'Página de inicio',
              ),
              NavigationDestination(
                icon: HugeIcon(icon: HugeIcons.strokeRoundedChatBot, color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white),
                selectedIcon: HugeIcon(icon: HugeIcons.strokeRoundedChatBot, color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white),
                label: 'Terapia',
                tooltip: 'Terapia con un chat de IA',
              ),
              NavigationDestination(
                icon:HugeIcon(icon: HugeIcons.strokeRoundedIdea01, color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white),
                selectedIcon: HugeIcon(icon: HugeIcons.strokeRoundedIdea01, color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white),
                label: 'Consejos',
                tooltip: 'Consejos generales para salud mental',
              ),
              NavigationDestination(
                icon: const Icon(Icons.forum_outlined),
                selectedIcon: const Icon(Icons.forum),
                label: 'Foro',
                tooltip: 'Comunidad',
              ),
            ],
          ),
        );
      },
    );
  }
  
}