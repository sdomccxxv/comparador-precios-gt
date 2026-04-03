import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/api_service.dart';
import '../widgets/skeleton_card.dart';
import 'detail_screen.dart';

class ResultsScreen extends StatefulWidget {
  final String query;
  // productos es opcional: si es null, la pantalla los carga internamente
  final List<Producto>? productos;
  // esEan indica si query es un código EAN (viene del scanner)
  final bool esEan;

  const ResultsScreen({
    super.key,
    required this.query,
    this.productos,
    this.esEan = false,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  String _filtro = 'Todos';
  List<Producto> _productos = [];
  bool _cargando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.productos != null) {
      // Si ya vienen productos del scanner, usarlos directamente
      _productos = widget.productos!;
    } else {
      // Cargar desde el backend y mostrar skeleton mientras tanto
      _cargarProductos();
    }
  }

  Future<void> _cargarProductos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final resultado = widget.esEan
          ? await ApiService.buscarPorEan(widget.query)
          : await ApiService.buscarProductos(widget.query);
      if (!mounted) return;
      setState(() => _productos = resultado);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  List<Producto> get _productosFiltrados {
    if (_filtro == 'Walmart GT') {
      return _productos.where((p) => p.esWalmart).toList();
    } else if (_filtro == 'La Torre') {
      return _productos.where((p) => !p.esWalmart).toList();
    }
    return _productos;
  }

  String _eanKey(Producto p) => (p.ean ?? '').trim();

  List<Producto> get _productosAgrupados {
    final filtrados = _productosFiltrados;

    final coincidentes = filtrados.where((p) => p.coincideAmbas).toList();
    final conEanSinCoincidir = filtrados
        .where((p) => !p.coincideAmbas && (p.ean ?? '').isNotEmpty)
        .toList();
    final sinEan = filtrados.where((p) => (p.ean ?? '').isEmpty).toList();

    coincidentes.sort((a, b) {
      final eanCompare = _eanKey(a).compareTo(_eanKey(b));
      if (eanCompare != 0) return eanCompare;
      return a.precio.compareTo(b.precio);
    });

    conEanSinCoincidir.sort((a, b) {
      final eanCompare = _eanKey(a).compareTo(_eanKey(b));
      if (eanCompare != 0) return eanCompare;
      return a.precio.compareTo(b.precio);
    });

    sinEan.sort((a, b) => a.precio.compareTo(b.precio));

    return [...coincidentes, ...conEanSinCoincidir, ...sinEan];
  }

  bool _esInicioGrupoEan(List<Producto> lista, int index) {
    final actual = _eanKey(lista[index]);
    if (actual.isEmpty) return false;
    if (index == 0) return true;
    return _eanKey(lista[index - 1]) != actual;
  }

  Map<String, double> get _precioMinimoPorEan {
    final Map<String, double> minimos = {};
    for (final p in _productosAgrupados) {
      final ean = _eanKey(p);
      if (ean.isEmpty) continue;
      if (!minimos.containsKey(ean) || p.precio < minimos[ean]!) {
        minimos[ean] = p.precio;
      }
    }
    return minimos;
  }

  int get _countWalmart => _productos.where((p) => p.esWalmart).length;
  int get _countTorre => _productos.where((p) => !p.esWalmart).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          '"${widget.query}"',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: Column(
        children: [
          // Resumen de resultados — oculto mientras carga
          if (!_cargando)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _ResumenChip(
                    label: 'Todos',
                    count: _productos.length,
                    color: Colors.grey,
                    seleccionado: _filtro == 'Todos',
                    onTap: () => setState(() => _filtro = 'Todos'),
                  ),
                  const SizedBox(width: 8),
                  _ResumenChip(
                    label: 'Walmart',
                    count: _countWalmart,
                    color: const Color(0xFF1A75CF),
                    seleccionado: _filtro == 'Walmart GT',
                    onTap: () => setState(() => _filtro = 'Walmart GT'),
                  ),
                  const SizedBox(width: 8),
                  _ResumenChip(
                    label: 'La Torre',
                    count: _countTorre,
                    color: const Color(0xFFF36A10),
                    seleccionado: _filtro == 'La Torre',
                    onTap: () => setState(() => _filtro = 'La Torre'),
                  ),
                ],
              ),
            ),

          // Contenido principal
          Expanded(
            child: _cargando
                // Mostrar skeleton mientras se cargan los datos
                ? const SkeletonList()
                : _error != null
                // Mostrar error si falló la carga
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.wifi_off,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No se pudo conectar al servidor',
                            style: TextStyle(fontSize: 15, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _cargarProductos,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _productosAgrupados.isEmpty
                ? const Center(
                    child: Text(
                      'No hay resultados',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _productosAgrupados.length,
                    itemBuilder: (context, index) {
                      final producto = _productosAgrupados[index];
                      final ean = _eanKey(producto);
                      final minimos = _precioMinimoPorEan;

                      final esMasBarato =
                          ean.isNotEmpty &&
                          minimos.containsKey(ean) &&
                          producto.precio == minimos[ean];

                      final mostrarSeparador = _esInicioGrupoEan(
                        _productosAgrupados,
                        index,
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (mostrarSeparador) _SeparadorGrupoEan(ean: ean),
                          _ProductoCard(
                            producto: producto,
                            esMasBarato: esMasBarato,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DetailScreen(producto: producto),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ResumenChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool seleccionado;
  final VoidCallback onTap;

  const _ResumenChip({
    required this.label,
    required this.count,
    required this.color,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: seleccionado ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: seleccionado ? color : color.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            color: seleccionado ? Colors.white : color,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _ProductoCard extends StatelessWidget {
  final Producto producto;
  final bool esMasBarato;
  final VoidCallback onTap;

  const _ProductoCard({
    required this.producto,
    required this.esMasBarato,
    required this.onTap,
  });

  Color get _colorTienda =>
      producto.esWalmart ? const Color(0xFF1A75CF) : const Color(0xFFF36A10);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _colorTienda.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: esMasBarato
              ? Border.all(color: Colors.green.shade400, width: 2)
              : producto.tieneOferta
              ? Border.all(color: Colors.green.shade300, width: 1.5)
              : Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: producto.imagen != null
                    ? Image.network(
                        producto.imagen!,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _PlaceholderImagen(color: _colorTienda),
                      )
                    : _PlaceholderImagen(color: _colorTienda),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _colorTienda.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            producto.tienda,
                            style: TextStyle(
                              color: _colorTienda,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        /*if (producto.coincideAmbas) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'EAN coincidente',
                              style: TextStyle(
                                color: Colors.amber.shade900,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],*/
                        if (esMasBarato) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '🏷️ Más barato',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      producto.nombre,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      producto.marca,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    if (producto.ean != null && producto.ean!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'EAN: ${producto.ean}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (producto.tieneOferta) ...[
                    Text(
                      'Antes Q ${producto.precioAntes!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const Text(
                      'Oferta',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3B6D11),
                      ),
                    ),
                  ],
                  Text(
                    'Q ${producto.precio.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: (esMasBarato || producto.tieneOferta)
                          ? const Color(0xFF3B6D11)
                          : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderImagen extends StatelessWidget {
  final Color color;
  const _PlaceholderImagen({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.shopping_bag_outlined, color: color, size: 30),
    );
  }
}

class _SeparadorGrupoEan extends StatelessWidget {
  final String ean;

  const _SeparadorGrupoEan({required this.ean});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Divider(color: Colors.grey.shade300, thickness: 1),
    );
  }
}
