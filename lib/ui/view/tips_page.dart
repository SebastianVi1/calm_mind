import 'package:flutter/material.dart';
import 'package:flutter_animate_on_scroll/flutter_animate_on_scroll.dart';
import 'package:provider/provider.dart';
import 'package:re_mind/ui/view/favorite_tips.dart';
import 'package:re_mind/ui/widgets/animated_tip_card.dart';
import 'package:re_mind/ui/widgets/drawer_key.dart';
import 'package:re_mind/ui/widgets/end_drawer.dart';
import 'package:re_mind/viewmodels/tips_view_model.dart';
import 'package:lottie/lottie.dart';

/// A page that displays a list of tips with filtering capabilities
/// The filter bar at the top can be shown/hidden based on scroll direction
class TipsPage extends StatefulWidget {
  const TipsPage({super.key});

  @override
  State<TipsPage> createState() => _TipsPageState();
}

class _TipsPageState extends State<TipsPage> with SingleTickerProviderStateMixin {
  // Controller to manage scroll behavior
  late ScrollController _scrollController;
  // Controls the visibility of the filter bar
  bool _showFilterBar = true;
  // Tracks the last scroll position to determine scroll direction
  double _lastScrollOffset = 0;
  // Animation controller for the filter bar
  late AnimationController _animationController;
  // Animation for the filter bar
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // Create animation curve
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    // Start with the filter bar visible
    _animationController.value = 1.0;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Handles scroll events to show/hide the filter bar
  void _onScroll() {
    final currentOffset = _scrollController.offset;
    
    // Show when at top or scrolling up
    if (currentOffset <= 0 || currentOffset < _lastScrollOffset) {
      if (!_showFilterBar) {
        setState(() {
          _showFilterBar = true;
        });
        _animationController.forward();
      }
    } 
    // Hide when scrolling down
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
          'Consejos',
          style: theme.textTheme.titleLarge,
        ),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FavoriteTipsPage()));
            },
            icon: Icon(Icons.favorite_outline, color: theme.brightness == Brightness.dark ? Colors.white: Colors.red[900],),
          ),
          // Botón para abrir el drawer global
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => openGlobalEndDrawer(context),
          ),
        ],
      ),
            
      body: SafeArea(
        child: Column(
          children: [
            // Animated filter bar that shows/hides based on scroll
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
            // Main content area with tips list
            Expanded(
              child: Consumer<TipsViewModel>(
                builder: (context, viewModel, child) {
                  // Error state
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

                  // Loading state
                  if (viewModel.isLoading) {
                    return Center(
                      child: Lottie.asset('assets/animations/loading.json'),
                    );
                  }

                  // Empty state
                  if (viewModel.tips.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 48,
                            color: colorScheme.primary.withAlpha(150),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay consejos disponibles',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface.withAlpha(200),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Tips list
                  return ListView.builder(
                    controller: _scrollController,
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

