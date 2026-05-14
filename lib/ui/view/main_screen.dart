import 'package:calm_mind/ui/widgets/breathing_fab.dart';
import 'package:calm_mind/ui/widgets/drawer_key.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:calm_mind/ui/view/forum_page.dart';
import 'package:calm_mind/ui/view/therapy_page.dart';
import 'package:calm_mind/ui/view/home_page.dart';
import 'package:calm_mind/ui/view/tips_page.dart';
import 'package:calm_mind/ui/widgets/end_drawer.dart';
import 'package:calm_mind/viewmodels/navigation_view_model.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Consumer<NavigationViewModel>(
      builder: (context, navigationViewModel, child) {
        final List<Widget> pages = const [
          HomePage(),
          TherapyPage(),
          TipsPage(),
          ForumPage(),
        ];

        return Scaffold(
          key: context.read<DrawerProvider>().scaffoldKey,
          body: Stack(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: pages[navigationViewModel.currentIndex],
              ),
              Positioned(
                right: 20,
                bottom: 90,
                child: const BreathingFAB(),
              ),
            ],
          ),
          endDrawer: WEndDrawer(),
          bottomNavigationBar: NavigationBar(
            selectedIndex: navigationViewModel.currentIndex,
            onDestinationSelected: navigationViewModel.changeIndex,
            height: 70,
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 3,
            destinations: [
              NavigationDestination(
                icon: HugeIcon(icon: HugeIcons.strokeRoundedHome09, color: textColor),
                selectedIcon: HugeIcon(icon: HugeIcons.strokeRoundedHome09, color: textColor),
                label: 'Inicio',
                tooltip: 'Página de inicio',
              ),
              NavigationDestination(
                icon: HugeIcon(icon: HugeIcons.strokeRoundedChatBot, color: textColor),
                selectedIcon: HugeIcon(icon: HugeIcons.strokeRoundedChatBot, color: textColor),
                label: 'Terapia',
                tooltip: 'Terapia con un chat de IA',
              ),
              NavigationDestination(
                icon: HugeIcon(icon: HugeIcons.strokeRoundedIdea01, color: textColor),
                selectedIcon: HugeIcon(icon: HugeIcons.strokeRoundedIdea01, color: textColor),
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
