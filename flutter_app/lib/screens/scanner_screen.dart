import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _procesando = false;
  bool _linterna = false;

  Future<void> _onDetected(BarcodeCapture capture) async {
    if (_procesando) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    final ean = barcode!.rawValue!;
    setState(() => _procesando = true);
    _controller.stop();

    try {
      final productos = await ApiService.buscarProductos(ean);
      if (!mounted) return;

      if (productos.isEmpty) {
        _mostrarError('No se encontró ningún producto con ese código.');
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(
            query: ean,
            productos: productos,
          ),
        ),
      );
    } catch (e) {
      _mostrarError('Error al buscar el producto. ¿Está el servidor activo?');
    }
  }

  void _mostrarError(String mensaje) {
    setState(() => _procesando = false);
    _controller.start();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Producto no encontrado'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Intentar de nuevo'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Escanear producto',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _linterna ? Icons.flash_on : Icons.flash_off,
              color: _linterna ? Colors.yellow : Colors.white,
            ),
            onPressed: () {
              _controller.toggleTorch();
              setState(() => _linterna = !_linterna);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Cámara
          MobileScanner(
            controller: _controller,
            onDetect: _onDetected,
          ),

          // Overlay con ventana de escaneo
          CustomPaint(
            painter: _ScannerOverlayPainter(),
            child: const SizedBox.expand(),
          ),

          // Instrucciones
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (_procesando) ...[
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 16),
                  const Text(
                    'Buscando producto...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ] else ...[
                  const Icon(Icons.qr_code_scanner,
                      color: Colors.white54, size: 32),
                  const SizedBox(height: 12),
                  const Text(
                    'Apunta al código de barras del producto',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'La búsqueda es automática al detectarlo',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black54;
    final cutoutSize = size.width * 0.75;
    final left = (size.width - cutoutSize) / 2;
    final top = (size.height - cutoutSize * 0.5) / 2;
    final cutout = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, cutoutSize, cutoutSize * 0.5),
      const Radius.circular(12),
    );

    // Fondo oscuro alrededor del recuadro
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(cutout)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);

    // Borde del recuadro
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(cutout, borderPaint);

    // Esquinas destacadas
    final cornerPaint = Paint()
      ..color = const Color(0xFF1976D2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const cornerLen = 24.0;
    final r = cutout.outerRect;

    // Esquina superior izquierda
    canvas.drawLine(Offset(r.left, r.top + cornerLen), Offset(r.left, r.top), cornerPaint);
    canvas.drawLine(Offset(r.left, r.top), Offset(r.left + cornerLen, r.top), cornerPaint);
    // Esquina superior derecha
    canvas.drawLine(Offset(r.right - cornerLen, r.top), Offset(r.right, r.top), cornerPaint);
    canvas.drawLine(Offset(r.right, r.top), Offset(r.right, r.top + cornerLen), cornerPaint);
    // Esquina inferior izquierda
    canvas.drawLine(Offset(r.left, r.bottom - cornerLen), Offset(r.left, r.bottom), cornerPaint);
    canvas.drawLine(Offset(r.left, r.bottom), Offset(r.left + cornerLen, r.bottom), cornerPaint);
    // Esquina inferior derecha
    canvas.drawLine(Offset(r.right - cornerLen, r.bottom), Offset(r.right, r.bottom), cornerPaint);
    canvas.drawLine(Offset(r.right, r.bottom), Offset(r.right, r.bottom - cornerLen), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}