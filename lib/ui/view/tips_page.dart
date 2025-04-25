import 'package:flutter/material.dart';
import 'package:flutter_animate_on_scroll/flutter_animate_on_scroll.dart';
import 'package:provider/provider.dart';
import 'package:re_mind/ui/view/favorite_tips.dart';
import 'package:re_mind/ui/widgets/animated_tip_card.dart';
import 'package:re_mind/viewmodels/tips_view_model.dart';

class TipsPage extends StatelessWidget {
  const TipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Consejos',
          style: theme.textTheme.titleLarge,
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => FavoriteTipsPage()));
              },
              icon: const Icon(Icons.favorite),
            ),
          ],
        ),
      
      body: SafeArea(
        child: Column(
          children: [
            // Header con gradiente y animación de entrada
            
            // Lista de tips
            Expanded(
              child: Consumer<TipsViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            viewModel.error!,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => viewModel.loadTips(),
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (viewModel.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (viewModel.tips.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 48,
                            color: colorScheme.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay tips disponibles',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: viewModel.tips.length,
                    itemBuilder: (context, index) {
                      final tip = viewModel.tips[index];
                      return FadeInDown(
                        
                        config: BaseAnimationConfig(
                          useScrollForAnimation: true,
                          delay: 200.ms,
                          child: WAnimatedTipCard(
                            title: tip.title,
                            content: tip.content,
                            category: tip.category,
                            onTap: () => viewModel.toggleFavorite(tip.id),
                            isFavorite: viewModel.isFavorite(tip.id),
                            index: index,
                          )
                        )
                      );
                        
                        // child: WAnimatedTipCard(
                        //   title: tip.title,
                        //   content: tip.content,
                        //   category: tip.category,
                        //   onTap: () => viewModel.toggleFavorite(tip.id),
                        //   isFavorite: viewModel.isFavorite(tip.id),
                        //   index: index,
                        // ),
                      // );
                    }
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

