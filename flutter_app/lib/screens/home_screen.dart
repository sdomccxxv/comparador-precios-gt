import 'package:flutter/material.dart';
import '../services/historial_busquedas_service.dart';
import 'result_screen.dart';
import 'scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> _historial = [];

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  // Carga el historial guardado al abrir la pantalla
  Future<void> _cargarHistorial() async {
    final lista = await HistorialBusquedasService.obtener();
    setState(() => _historial = lista);
  }

  void _buscar([String? queryOverride]) {
    final query = (queryOverride ?? _controller.text).trim();
    if (query.isEmpty) return;

    HistorialBusquedasService.agregar(query).then((_) async {
      await HistorialBusquedasService.obtener();
      _cargarHistorial();
    });
    _controller.clear();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ResultsScreen(query: query)),
    ).then((_) => _cargarHistorial());
  }

  Future<void> _eliminarBusqueda(String query) async {
    await HistorialBusquedasService.eliminar(query);
    _cargarHistorial();
  }

  Future<void> _limpiarHistorial() async {
    await HistorialBusquedasService.limpiar();
    _cargarHistorial();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),

              const Icon(
                Icons.shopping_cart_rounded,
                size: 64,
                color: Color(0xFF1976D2),
              ),
              const SizedBox(height: 16),
              const Text(
                'Comparador GT',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Compara precios en Walmart y La Torre',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _TiendaBadge(
                    nombre: 'Walmart GT',
                    color: const Color(0xFF1A75CF),
                    icono: Icons.store,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'vs',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _TiendaBadge(
                    nombre: 'La Torre',
                    color: const Color(0xFFF36A10),
                    icono: Icons.storefront,
                  ),
                ],
              ),

              const SizedBox(height: 48),

              TextField(
                controller: _controller,
                onSubmitted: (_) => _buscar(),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Ej: leche, arroz, aceite...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF1976D2),
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _buscar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Buscar y comparar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ScannerScreen()),
                  ),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text(
                    'Escanear código de barras',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1976D2),
                    side: const BorderSide(
                      color: Color(0xFF1976D2),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              // Historial de búsquedas recientes
              if (_historial.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recientes',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    GestureDetector(
                      onTap: _limpiarHistorial,
                      child: const Text(
                        'Limpiar',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _historial
                      .map(
                        (q) => GestureDetector(
                          onTap: () => _buscar(q),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.history,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  q,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => _eliminarBusqueda(q),
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],

              const Spacer(),
              const Text(
                'Los precios son en quetzales (Q)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _TiendaBadge extends StatelessWidget {
  final String nombre;
  final Color color;
  final IconData icono;

  const _TiendaBadge({
    required this.nombre,
    required this.color,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icono, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            nombre,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
