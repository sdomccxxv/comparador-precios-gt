import 'package:shared_preferences/shared_preferences.dart';

// Servicio para guardar y recuperar el historial de búsquedas localmente
class HistorialBusquedasService {
  static const String _key = 'historial_busquedas';
  static const int _maxItems = 8;

  // Retorna la lista de búsquedas recientes
  static Future<List<String>> obtener() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  // Agrega una búsqueda al inicio, elimina duplicados y limita a _maxItems
  static Future<void> agregar(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_key) ?? [];
    lista.removeWhere((q) => q.toLowerCase() == query.toLowerCase());
    lista.insert(0, query);
    if (lista.length > _maxItems) lista.removeLast();
    await prefs.setStringList(_key, lista);
  }

  // Elimina una búsqueda específica
  static Future<void> eliminar(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_key) ?? [];
    lista.removeWhere((q) => q == query);
    await prefs.setStringList(_key, lista);
  }

  // Borra todo el historial
  static Future<void> limpiar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
