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

class _FavoriteTipsPageState extends State<FavoriteTipsPage> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  bool _showFilterBar = true;
  double _lastScrollOffset = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _animationController.value = 1.0;

    // Preload tips when the page is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<TipsViewModel>(context, listen: false);
      if (!viewModel.isInitialized) {
        viewModel.loadTips();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final currentOffset = _scrollController.offset;
    
    if (currentOffset <= 0 || currentOffset < _lastScrollOffset) {
      if (!_showFilterBar) {
        setState(() {
          _showFilterBar = true;
        });
        _animationController.forward();
      }
    } 
    else if (currentOffset > _lastScrollOffset) {
      if (_showFilterBar) {
        setState(() {
          _showFilterBar = false;
        });
        _animationController.reverse();
      }
    }
    
    _lastScrollOffset = currentOffset;
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
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: theme.brightness == Brightness.dark ? Colors.white: Colors.black
        ),
      ),
      body: Column(
        children: [
          // Animated filter bar
          SizeTransition(
            sizeFactor: _animation,
            child: FadeTransition(
              opacity: _animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -1),
                  end: Offset.zero,
                ).animate(_animation),
                child: Consumer<TipsViewModel>(
                  builder: (context, viewModel, child) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: viewModel.categories.map((category) {
                            final bool isSelected = viewModel.selectedCategory == category['id'];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: FilledButton(
                                onPressed: () => viewModel.onCategorySelected(category['id']!),
                                style: FilledButton.styleFrom(
                                  backgroundColor: isSelected 
                                    ? colorScheme.primary 
                                    : colorScheme.surfaceVariant,
                                  foregroundColor: isSelected 
                                    ? colorScheme.onPrimary 
                                    : colorScheme.onSurfaceVariant,
                                ),
                                child: Text(category['name']!),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          // Tips list
          Expanded(
            child: Consumer<TipsViewModel>(
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
                  controller: _scrollController,
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
          ),
        ],
      ),
    );
  }
}