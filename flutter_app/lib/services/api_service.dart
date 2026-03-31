import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/producto.dart';

class ApiService {
  // Mientras desarrollas localmente usa esta URL
  // Cuando subas a Render.com la cambiarás por la URL del servidor
  static const String baseUrl = 'http://10.0.2.2:8000';

  static Future<List<Producto>> buscarProductos(String query) async {
    final uri = Uri.parse('$baseUrl/buscar?q=${Uri.encodeComponent(query)}');

    try {
      final response = await http.get(uri).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List resultados = data['resultados'];
        return resultados.map((json) => Producto.fromJson(json)).toList();
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('No se pudo conectar al servidor: $e');
    }
  }
}