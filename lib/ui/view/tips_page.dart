import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate_on_scroll/flutter_animate_on_scroll.dart';
import 'package:provider/provider.dart';
import 'package:calm_mind/ui/view/favorite_tips.dart';
import 'package:calm_mind/ui/widgets/drawer_key.dart';
import 'package:calm_mind/viewmodels/tips_view_model.dart';
import 'package:lottie/lottie.dart';
import 'package:calm_mind/ui/constants/animation_constants.dart';
import 'package:calm_mind/services/haptics_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class TipsPage extends StatefulWidget {
  const TipsPage({super.key});

  @override
  State<TipsPage> createState() => _TipsPageState();
}

class _TipsPageState extends State<TipsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showFilterBar = true;
  double _lastScrollOffset = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  int _selectedTipIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _selectedTipIndex = DateTime.now().day % 5;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final currentOffset = _scrollController.offset;
    if (currentOffset <= 0 || currentOffset < _lastScrollOffset) {
      if (!_showFilterBar) setState(() => _showFilterBar = true);
    } else if (currentOffset > _lastScrollOffset) {
      if (_showFilterBar) setState(() => _showFilterBar = false);
    }
    _lastScrollOffset = currentOffset;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 56,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.lightbulb,
                color: Colors.amber,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Consejos',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.amber.withValues(alpha: 0.15),
                theme.scaffoldBackgroundColor,
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              HapticsService.light();
              setState(() => _isSearching = !_isSearching);
              if (!_isSearching) {
                _searchController.clear();
                setState(() => _searchQuery = '');
              }
            },
            icon: Icon(_isSearching ? Icons.close : Icons.search),
          ),
          IconButton(
            onPressed: () {
              HapticsService.light();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoriteTipsPage()),
              );
            },
            icon: Icon(
              Icons.favorite,
              color: Colors.red[400],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_isSearching) _buildSearchBar(theme),
            _buildCategoryFilter(theme),
            Expanded(
              child: Consumer<TipsViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: Lottie.asset(
                              'assets/animations/loading.json',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Cargando consejos...',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (viewModel.error != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.error_outline,
                                size: 48,
                                color: theme.colorScheme.error,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              '¡Ups!',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              viewModel.error!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed: () => viewModel.loadTips(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final tips = _searchQuery.isEmpty
                      ? viewModel.tips
                      : viewModel.tips.where((tip) =>
                          tip.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          tip.content.toLowerCase().contains(_searchQuery.toLowerCase())
                        ).toList();

                  if (tips.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.search_off,
                                size: 48,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No se encontraron consejos',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Intenta con otra búsqueda',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      HapticsService.light();
                      await viewModel.loadTips();
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.all(16),
                      itemCount: tips.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _buildDailyTip(context, theme);
                        }
                        final tip = tips[index - 1];
                        return FadeInUp(
                          config: BaseAnimationConfig(
                            delay: ((index - 1) * 50).ms,
                            child: _TipCard(
                              tip: tip,
                              isFavorite: viewModel.isFavorite(tip.id),
                              onFavorite: () {
                                HapticsService.medium();
                                viewModel.toggleFavorite(tip.id);
                              },
                              onShare: () {
                                HapticsService.light();
                                Share.share('${tip.title}\n\n${tip.content}');
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return AnimatedContainer(
      duration: AppAnimations.short,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar consejos...',
          hintStyle: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.primary,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: theme.colorScheme.surfaceVariant.withValues(alpha: 0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildCategoryFilter(ThemeData theme) {
    return Consumer<TipsViewModel>(
      builder: (context, viewModel, child) {
        return AnimatedSize(
          duration: AppAnimations.short,
          curve: AppAnimations.smooth,
          child: AnimatedOpacity(
            opacity: _showFilterBar ? 1.0 : 0.0,
            duration: AppAnimations.short,
            child: SizedBox(
              height: _showFilterBar ? 60 : 0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: viewModel.categories.length,
                itemBuilder: (context, index) {
                  final category = viewModel.categories[index];
                  final isSelected = viewModel.selectedCategory == category['id'];

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AnimatedScale(
                      scale: isSelected ? 1.05 : 1.0,
                      duration: AppAnimations.micro,
                      child: FilterChip(
                        label: Text(
                          category['name']!,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (_) {
                          HapticsService.selection();
                          viewModel.onCategorySelected(category['id']!);
                        },
                        backgroundColor: theme.colorScheme.surfaceVariant,
                        selectedColor: theme.colorScheme.primary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyTip(BuildContext context, ThemeData theme) {
    final tips = context.watch<TipsViewModel>().tips;
    if (tips.isEmpty) return const SizedBox.shrink();

    final tip = tips[_selectedTipIndex % tips.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.amber.withValues(alpha: 0.3),
              Colors.orange.withValues(alpha: 0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.amber.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Consejo del Día',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[800],
                      ),
                    ),
                    Text(
                      DateFormat('dd MMMM', 'es').format(DateTime.now()),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.amber[800]?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              tip.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tip.content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildTipCategoryChip(tip.category, theme),
                const Spacer(),
                Icon(
                  Icons.format_quote,
                  color: Colors.amber.withValues(alpha: 0.5),
                  size: 32,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCategoryChip(String category, ThemeData theme) {
    final colors = {
      'Meditacion': {'bg': Colors.purple.withValues(alpha: 0.2), 'fg': Colors.purple[800]!},
      'Ejercicio': {'bg': Colors.green.withValues(alpha: 0.2), 'fg': Colors.green[800]!},
      'Nutricion': {'bg': Colors.orange.withValues(alpha: 0.2), 'fg': Colors.orange[800]!},
      'Bienestar': {'bg': Colors.blue.withValues(alpha: 0.2), 'fg': Colors.blue[800]!},
    };

    final colorsMap = colors[category] ?? {'bg': Colors.grey.withValues(alpha: 0.2), 'fg': Colors.grey[800]!};

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorsMap['bg'],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: colorsMap['fg'],
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final dynamic tip;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onShare;

  const _TipCard({
    required this.tip,
    required this.isFavorite,
    required this.onFavorite,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final categoryColors = {
      'Meditacion': {'bg': Colors.purple.withValues(alpha: 0.15), 'icon': '🧘'},
      'Ejercicio': {'bg': Colors.green.withValues(alpha: 0.15), 'icon': '🏃'},
      'Nutricion': {'bg': Colors.orange.withValues(alpha: 0.15), 'icon': '🥗'},
      'Bienestar': {'bg': Colors.blue.withValues(alpha: 0.15), 'icon': '💙'},
    };

    final catData = categoryColors[tip.category] ?? {'bg': Colors.grey.withValues(alpha: 0.15), 'icon': '💡'};

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: InkWell(
        onTap: () => _showTipDetail(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: catData['bg'] as Color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      catData['icon'] as String,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tip.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tip.category,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: onFavorite,
                        icon: AnimatedSwitcher(
                          duration: AppAnimations.short,
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            key: ValueKey(isFavorite),
                            color: isFavorite ? Colors.red : theme.colorScheme.outline,
                          ),
                        ),
                        tooltip: isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
                      ),
                      IconButton(
                        onPressed: onShare,
                        icon: Icon(
                          Icons.share,
                          color: theme.colorScheme.outline,
                        ),
                        tooltip: 'Compartir',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                tip.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTipDetail(BuildContext context) {
    final theme = Theme.of(context);

    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    children: [
                      Text(
                        tip.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tip.category,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        tip.content,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.8,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                context.read<TipsViewModel>().toggleFavorite(tip.id);
                              },
                              icon: Icon(
                                context.read<TipsViewModel>().isFavorite(tip.id)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                              ),
                              label: Text(
                                context.read<TipsViewModel>().isFavorite(tip.id)
                                    ? 'En favoritos'
                                    : 'Agregar a favoritos',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                Share.share('${tip.title}\n\n${tip.content}');
                              },
                              icon: const Icon(Icons.share),
                              label: const Text('Compartir'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
