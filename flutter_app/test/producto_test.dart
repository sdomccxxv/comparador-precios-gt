import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/models/producto.dart';

void main() {
  group('Producto.colorTienda', () {
    test('Walmart GT retorna azul', () {
      final p = Producto(tienda: 'Walmart GT', nombre: '', marca: '', precio: 1, url: '');
      expect(p.colorTienda, const Color(0xFF1A75CF));
    });

    test('La Torre retorna naranja', () {
      final p = Producto(tienda: 'La Torre', nombre: '', marca: '', precio: 1, url: '');
      expect(p.colorTienda, const Color(0xFFF36A10));
    });

    test('Paiz retorna naranja', () {
      final p = Producto(tienda: 'Paiz', nombre: '', marca: '', precio: 1, url: '');
      expect(p.colorTienda, const Color(0xFFFF7300));
    });

    test('Maxi Despensa retorna verde', () {
      final p = Producto(tienda: 'Maxi Despensa', nombre: '', marca: '', precio: 1, url: '');
      expect(p.colorTienda, const Color(0xFF3FA527));
    });

    test('tienda desconocida retorna gris', () {
      final p = Producto(tienda: 'Otra', nombre: '', marca: '', precio: 1, url: '');
      expect(p.colorTienda, const Color(0xFF607D8B));
    });
  });

  group('Producto.fromJson', () {
    test('parsea correctamente todos los campos', () {
      final json = {
        'tienda': 'Paiz',
        'nombre': 'Leche',
        'marca': 'Dos Pinos',
        'precio': 25.9,
        'precio_antes': 30.0,
        'url': 'https://paiz.com.gt/leche/p',
        'imagen': null,
        'ean': '7441001616976',
        'coincide_ambas': true,
      };
      final p = Producto.fromJson(json);
      expect(p.tienda, 'Paiz');
      expect(p.precio, 25.9);
      expect(p.precioAntes, 30.0);
      expect(p.tieneOferta, true);
      expect(p.coincideAmbas, true);
      expect(p.ean, '7441001616976');
    });

    test('precio_antes null no genera oferta', () {
      final p = Producto.fromJson({
        'tienda': 'Walmart GT', 'nombre': '', 'marca': '',
        'precio': 10.0, 'precio_antes': null, 'url': '', 'coincide_ambas': false,
      });
      expect(p.tieneOferta, false);
    });
  });
}