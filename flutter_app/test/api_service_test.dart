import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_app/services/api_service.dart';

void main() {
  tearDown(() {
    ApiService.resetClient();
  });

  group('ApiService.buscarProductos', () {
    test('devuelve lista parseada cuando status es 200', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/buscar');
        expect(request.url.queryParameters['q'], 'leche');
        return http.Response(
          jsonEncode({
            'resultados': [
              {
                'tienda': 'Walmart GT',
                'nombre': 'Leche Entera',
                'marca': 'Dos Pinos',
                'precio': 25.9,
                'precio_antes': 30.0,
                'url': 'https://www.walmart.com.gt/leche/p',
                'imagen': null,
                'ean': '7441001616976',
                'coincide_ambas': true,
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      ApiService.setClient(client);
      final productos = await ApiService.buscarProductos('leche');

      expect(productos.length, 1);
      expect(productos.first.nombre, 'Leche Entera');
      expect(productos.first.coincideAmbas, true);
    });

    test('lanza excepcion cuando hay error de red', () async {
      final client = MockClient((request) async {
        throw Exception('sin red');
      });

      ApiService.setClient(client);

      await expectLater(
        ApiService.buscarProductos('arroz'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('ApiService.buscarPorEan', () {
    test('hace fallback a buscarProductos cuando buscar-ean regresa vacio', () async {
      final client = MockClient((request) async {
        if (request.url.path == '/buscar-ean') {
          return http.Response(jsonEncode({'resultados': []}), 200);
        }

        if (request.url.path == '/buscar') {
          return http.Response(
            jsonEncode({
              'resultados': [
                {
                  'tienda': 'La Torre',
                  'nombre': 'Aceite',
                  'marca': 'Mazola',
                  'precio': 40.0,
                  'url': 'https://www.latorre.com.gt/aceite/p',
                  'imagen': null,
                  'ean': '123',
                  'coincide_ambas': false,
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        return http.Response('not found', 404);
      });

      ApiService.setClient(client);
      final productos = await ApiService.buscarPorEan('123');

      expect(productos.length, 1);
      expect(productos.first.nombre, 'Aceite');
    });
  });

  group('ApiService.obtenerHistorial', () {
    test('retorna lista vacia cuando el backend falla', () async {
      final client = MockClient((request) async {
        return http.Response('error', 500);
      });

      ApiService.setClient(client);
      final historial = await ApiService.obtenerHistorial('123');

      expect(historial, isEmpty);
    });
  });
}
