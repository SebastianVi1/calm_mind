import 'package:flutter/foundation.dart';
import 'package:re_mind/models/tip.dart';
import 'package:re_mind/services/database_service.dart';

class TipsViewModel extends ChangeNotifier {
  List<Tip> _tips = [];
  final List<String> _favoriteTipIds = [];
  bool _isLoading = false;
  String? _error;

  List<Tip> get tips => _tips;
  List<String> get favoriteTipIds => _favoriteTipIds;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void loadTips() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Simulamos una carga de datos con un delay más corto
    Future.delayed(const Duration(seconds: 1), () {
      try {
        

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
      } catch (e) {
        _error = 'Error al cargar los tips: $e';
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  bool isFavorite(String tipId) {
    return _favoriteTipIds.contains(tipId);
  }

  void toggleFavorite(String tipId) {
    if (_favoriteTipIds.contains(tipId)) {
      _favoriteTipIds.remove(tipId);
    } else {
      _favoriteTipIds.add(tipId);
    }
    notifyListeners();
  }
} 