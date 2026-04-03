import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/producto.dart';
import '../models/historial_precio.dart';

class ApiService {
  static const String baseUrl = 'https://comparador-precios-gt.onrender.com';
  // static const String baseUrl = 'http://10.0.2.2:8000'; // emulador Android
  static http.Client _client = http.Client();

  @visibleForTesting
  static void setClient(http.Client client) {
    _client = client;
  }

  @visibleForTesting
  static void resetClient() {
    _client = http.Client();
  }

  static Future<List<Producto>> buscarProductos(String query) async {
    final uri = Uri.parse('$baseUrl/buscar?q=${Uri.encodeComponent(query)}');
    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 60));
      if (response.statusCode == 200 || response.statusCode == 206) {
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

  static Future<List<Producto>> buscarPorEan(String ean) async {
    final uri = Uri.parse(
      '$baseUrl/buscar-ean?ean=${Uri.encodeComponent(ean)}',
    );
    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 60));
      if (response.statusCode == 200 || response.statusCode == 206) {
        final data = jsonDecode(response.body);
        final List resultados = data['resultados'];
        if (resultados.isNotEmpty) {
          return resultados.map((json) => Producto.fromJson(json)).toList();
        }
      }
    } catch (_) {}
    return buscarProductos(ean);
  }

  static Future<List<HistorialPrecio>> obtenerHistorial(String ean) async {
    final uri = Uri.parse('$baseUrl/historial/${Uri.encodeComponent(ean)}');
    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List registros = data['registros'] ?? [];
        return registros.map((j) => HistorialPrecio.fromJson(j)).toList();
      }
    } catch (_) {}
    return [];
  }
}
