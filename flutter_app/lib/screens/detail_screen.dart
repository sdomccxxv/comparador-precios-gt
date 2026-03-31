import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/producto.dart';

class DetailScreen extends StatelessWidget {
  final Producto producto;

  const DetailScreen({super.key, required this.producto});

  Color get _colorTienda => producto.esWalmart
      ? const Color(0xFF0071CE)
      : const Color(0xFFE53935);

  Future<void> _abrirEnTienda() async {
    final uri = Uri.parse(producto.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          producto.tienda,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _colorTienda),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen grande
            Container(
              width: double.infinity,
              height: 260,
              color: Colors.white,
              child: producto.imagen != null
                  ? Image.network(
                      producto.imagen!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.shopping_bag_outlined,
                        size: 80,
                        color: _colorTienda.withOpacity(0.3),
                      ),
                    )
                  : Icon(
                      Icons.shopping_bag_outlined,
                      size: 80,
                      color: _colorTienda.withOpacity(0.3),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge tienda
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _colorTienda.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      producto.tienda,
                      style: TextStyle(
                        color: _colorTienda,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Nombre
                  Text(
                    producto.nombre,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Marca
                  Text(
                    producto.marca,
                    style: const TextStyle(
                        fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  // Precio destacado
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _colorTienda.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: _colorTienda.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Precio',
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Q ${producto.precio.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: _colorTienda,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botón ir a la tienda
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _abrirEnTienda,
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text(
                        'Ver en la tienda',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _colorTienda,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}