import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_mind/ui/widgets/animated_tip_card.dart';
import 'package:re_mind/viewmodels/tips_view_model.dart';
import 'package:lottie/lottie.dart';

class FavoriteTipsPage extends StatefulWidget {
  const FavoriteTipsPage({super.key});

  @override
  State<FavoriteTipsPage> createState() => _FavoriteTipsPageState();
}

class _FavoriteTipsPageState extends State<FavoriteTipsPage> {
  @override
  void initState() {
    super.initState();
    // Preload tips when the page is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<TipsViewModel>(context, listen: false);
      if (!viewModel.isInitialized) {
        viewModel.loadTips();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Consejos favoritos',
          style: theme.textTheme.titleLarge,
        ),
      ),
      body: Consumer<TipsViewModel>(
        builder: (context, viewModel, child) {
          
          if (!viewModel.isInitialized && viewModel.isLoading) {

            return Center(
              child: Lottie.asset('assets/animations/loading.json'),
            );
          }

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

          final favoriteTips = viewModel.tips.where((tip) => viewModel.isFavorite(tip.id)).toList();

          if (favoriteTips.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 48,
                    color: colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay consejos favoritos',
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
            itemCount: favoriteTips.length,
            itemBuilder: (context, index) {
              final tip = favoriteTips[index];
              return WAnimatedTipCard(
                title: tip.title,
                content: tip.content,
                category: tip.category,
                onTap: () => viewModel.toggleFavorite(tip.id),
                isFavorite: true,
                index: index,
              );
            },
          );
        },
      ),
    );
  }
}