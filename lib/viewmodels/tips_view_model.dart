import 'package:flutter/foundation.dart';
import 'package:re_mind/models/tip.dart';
import 'package:re_mind/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TipsViewModel extends ChangeNotifier {
  List<Tip> _tips = [];
  final List<String> _favoriteTipIds = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;
  static const String _favoritesKey = 'favorite_tips';

  List<Tip> get tips => _tips;
  List<String> get favoriteTipIds => _favoriteTipIds;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

  TipsViewModel() {
    _initializeTips();
  }

  Future<void> _initializeTips() async {
    if (_isInitialized) return;

    try {
      // Preload tips without showing loading state
      _tips = [
        Tip(
          id: '1',
          title: 'Meditación Matutina',
          content: 'Comienza tu día con 5 minutos de meditación. Enfócate en tu respiración y establece una intención positiva para el día.',
          category: 'Meditación',
        ),
        Tip(
          id: '2',
          title: 'Ejercicio Regular',
          content: 'Realiza al menos 30 minutos de ejercicio moderado cada día. Puede ser caminar, yoga o cualquier actividad que disfrutes.',
          category: 'Ejercicio',
        ),
        Tip(
          id: '3',
          title: 'Alimentación Consciente',
          content: 'Come despacio, saborea cada bocado y presta atención a las señales de saciedad de tu cuerpo.',
          category: 'Alimentación',
        ),
        Tip(
          id: '4',
          title: 'Gratitud Diaria',
          content: 'Escribe tres cosas por las que estés agradecido cada día. Esto ayuda a mantener una perspectiva positiva.',
          category: 'Bienestar',
        ),
      ];

      await _loadFavoriteTips();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _error = 'Error al inicializar los tips: $e';
      notifyListeners();
    }
  }

  Future<void> loadTips() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _initializeTips();
    } catch (e) {
      _error = 'Error al cargar los tips: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFavoriteTips() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedFavorites = prefs.getStringList(_favoritesKey) ?? [];
      _favoriteTipIds.clear();
      _favoriteTipIds.addAll(savedFavorites);
    } catch (e) {
      _error = 'Error al cargar los favoritos: $e';
    }
  }

  bool isFavorite(String tipId) {
    return _favoriteTipIds.contains(tipId);
  }

  Future<void> toggleFavorite(String tipId) async {
    try {
      if (_favoriteTipIds.contains(tipId)) {
        _favoriteTipIds.remove(tipId);
      } else {
        _favoriteTipIds.add(tipId);
      }
      
      // Guardar en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favoritesKey, _favoriteTipIds);
      
      notifyListeners();
    } catch (e) {
      _error = 'Error al actualizar favoritos: $e';
      notifyListeners();
    }
  }
} 