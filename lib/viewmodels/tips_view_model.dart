import 'package:flutter/foundation.dart';
import 'package:calm_mind/models/tip.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TipsViewModel extends ChangeNotifier {
  List<Tip> _tips = [];
  List<Tip> _filteredTips = [];
  final List<String> _favoriteTipIds = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;
  String _selectedCategory = 'todos';
  static const String _favoritesKey = 'favorite_tips';

  List<Tip> get tips => _filteredTips;
  List<String> get favoriteTipIds => _favoriteTipIds;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;
  String get selectedCategory => _selectedCategory;
  List<Map<String, String>> get categories => _categories;

  // Define available categories
  final List<Map<String, String>> _categories = [
    {'id': 'todos', 'name': 'Todos'},
    {'id': 'meditacion', 'name': 'Meditación'},
    {'id': 'ejercicio', 'name': 'Ejercicio'},
    {'id': 'nutricion', 'name': 'Nutrición'},
    {'id': 'bienestar', 'name': 'Bienestar'},
  ];

  TipsViewModel() {
    _initializeTips();
  }

  // Update selected category and filter tips
  void onCategorySelected(String categoryId) {
    _selectedCategory = categoryId;
    _filterTips();
    notifyListeners();
  }

  // Filter tips based on selected category
  void _filterTips() {
    if (_selectedCategory == 'todos') {
      _filteredTips = List.from(_tips);
    } else {
      _filteredTips = _tips.where((tip) => 
        tip.category.toLowerCase() == _selectedCategory
      ).toList();
    }
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
          category: 'Meditacion',
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
          category: 'Nutricion',
        ),
        Tip(
          id: '4',
          title: 'Gratitud Diaria',
          content: 'Escribe tres cosas por las que estés agradecido cada día. Esto ayuda a mantener una perspectiva positiva.',
          category: 'Bienestar',
        ),
        Tip(
          id: '5',
          title: 'Respiración Profunda',
          content: 'Practica la respiración 4-7-8: inhala por 4 segundos, mantén por 7 y exhala por 8. Repite 4 veces para reducir el estrés.',
          category: 'Meditacion',
        ),
        Tip(
          id: '6',
          title: 'Hidratación Consciente',
          content: 'Bebe un vaso de agua al despertar y mantén una botella cerca durante el día. La hidratación mejora la concentración y el bienestar.',
          category: 'Nutricion',
        ),
        Tip(
          id: '7',
          title: 'Estiramientos Matutinos',
          content: 'Dedica 5 minutos cada mañana a estirar tu cuerpo. Esto mejora la flexibilidad y prepara tu cuerpo para el día.',
          category: 'Ejercicio',
        ),
        Tip(
          id: '8',
          title: 'Pausas Activas',
          content: 'Cada hora, toma 5 minutos para levantarte, caminar y estirar. Esto mejora la circulación y reduce la tensión muscular.',
          category: 'Ejercicio',
        ),
        Tip(
          id: '9',
          title: 'Mindful Eating',
          content: 'Antes de comer, toma un momento para apreciar los colores y aromas de tu comida. Esto mejora la digestión y el disfrute.',
          category: 'Nutricion',
        ),
        Tip(
          id: '10',
          title: 'Diario de Emociones',
          content: 'Escribe tus emociones diariamente. Esto te ayuda a procesar sentimientos y mantener un mejor equilibrio emocional.',
          category: 'Bienestar',
        ),
        Tip(
          id: '11',
          title: 'Meditación Guiada',
          content: 'Usa una aplicación de meditación guiada para principiantes. 10 minutos al día pueden transformar tu bienestar mental.',
          category: 'Meditacion',
        ),
        Tip(
          id: '12',
          title: 'Snacks Saludables',
          content: 'Prepara snacks saludables como frutas, nueces o yogur. Tener opciones nutritivas a mano evita elecciones impulsivas.',
          category: 'Nutricion',
        ),
        Tip(
          id: '13',
          title: 'Escaneo Corporal',
          content: 'Realiza un escaneo corporal de 5 minutos: recorre mentalmente tu cuerpo desde los pies hasta la cabeza, notando sensaciones y tensiones.',
          category: 'Meditacion',
        ),
        Tip(
          id: '14',
          title: 'Rutina de Yoga Básica',
          content: 'Practica 3 posturas básicas de yoga cada mañana: postura del niño, perro boca abajo y montaña. Mantén cada una por 30 segundos.',
          category: 'Ejercicio',
        ),
        Tip(
          id: '15',
          title: 'Planificación de Comidas',
          content: 'Dedica 30 minutos el domingo para planificar tus comidas de la semana. Esto reduce el estrés y mejora tus elecciones alimenticias.',
          category: 'Nutricion',
        ),
        Tip(
          id: '16',
          title: 'Técnica de Liberación Emocional',
          content: 'Cuando sientas estrés, golpea suavemente con los dedos en el punto de karate (borde de la mano) mientras repites una afirmación positiva.',
          category: 'Bienestar',
        ),
        Tip(
          id: '17',
          title: 'Caminata Consciente',
          content: 'Durante tus caminatas, concéntrate en la sensación de tus pies tocando el suelo y el ritmo de tu respiración. Esto transforma el ejercicio en meditación.',
          category: 'Ejercicio',
        ),
      ];

      _filterTips(); // Apply initial filtering
      await _loadFavoriteTips();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _error = 'Error al inicializar los consejos: $e';
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
      _error = 'Error al cargar los consejos: $e';
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
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favoritesKey, _favoriteTipIds);
      
      notifyListeners();
    } catch (e) {
      _error = 'Error al actualizar favoritos: $e';
      notifyListeners();
    }
  }
} 
