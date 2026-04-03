import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/producto.dart';
import '../models/historial_precio.dart';
import '../services/api_service.dart';

// StatefulWidget porque necesitamos cargar el historial de forma asíncrona
class DetailScreen extends StatefulWidget {
  final Producto producto;

  const DetailScreen({super.key, required this.producto});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // Lista de registros históricos del producto
  List<HistorialPrecio> _historial = [];

  // Controla el spinner mientras se carga el historial
  bool _cargandoHistorial = true;

  // Color de la tienda: azul para Walmart, rojo para La Torre
  Color get _colorTienda => widget.producto.colorTienda;

  @override
  void initState() {
    super.initState();
    // Cargar historial al abrir la pantalla
    _cargarHistorial();
  }

  // Consulta el historial de precios por EAN al backend
  Future<void> _cargarHistorial() async {
    final ean = widget.producto.ean;

    // Si el producto no tiene EAN no hay historial que mostrar
    if (ean == null || ean.isEmpty) {
      setState(() => _cargandoHistorial = false);
      return;
    }

    final data = await ApiService.obtenerHistorial(ean);

    if (mounted) {
      setState(() {
        _historial = data;
        _cargandoHistorial = false;
      });
    }
  }

  // Abre la URL del producto en el navegador externo
  Future<void> _abrirEnTienda() async {
    final uri = Uri.parse(widget.producto.url);
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
          widget.producto.tienda,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _colorTienda,
          ),
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
            // Imagen grande del producto
            Container(
              width: double.infinity,
              height: 260,
              color: Colors.white,
              child: widget.producto.imagen != null
                  ? Image.network(
                      widget.producto.imagen!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.shopping_bag_outlined,
                        size: 80,
                        color: _colorTienda.withValues(alpha: 0.3),
                      ),
                    )
                  : Icon(
                      Icons.shopping_bag_outlined,
                      size: 80,
                      color: _colorTienda.withValues(alpha: 0.3),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge con el nombre de la tienda
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _colorTienda.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.producto.tienda,
                      style: TextStyle(
                        color: _colorTienda,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Nombre del producto
                  Text(
                    widget.producto.nombre,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Marca del producto
                  Text(
                    widget.producto.marca,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),

                  // EAN solo si está disponible
                  if (widget.producto.ean != null &&
                      widget.producto.ean!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'EAN: ${widget.producto.ean}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Tarjeta de precio actual
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _colorTienda.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _colorTienda.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Precio actual',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Q ${widget.producto.precio.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: _colorTienda,
                          ),
                        ),
                        // Precio anterior tachado si tiene oferta activa
                        if (widget.producto.tieneOferta) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Antes Q ${widget.producto.precioAntes!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Gráfica de historial: solo visible si el producto tiene EAN
                  if (widget.producto.ean != null &&
                      widget.producto.ean!.isNotEmpty)
                    _HistorialChart(
                      historial: _historial,
                      cargando: _cargandoHistorial,
                    ),

                  const SizedBox(height: 24),

                  // Botón para abrir el producto en la tienda online
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _abrirEnTienda,
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text(
                        'Ver en la tienda',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
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

// Widget que renderiza la gráfica de evolución de precios por tienda
class _HistorialChart extends StatelessWidget {
  final List<HistorialPrecio> historial;
  final bool cargando;

  // Colores fijos por tienda
  static const _colorWalmart = Color(0xFF1A75CF);
  static const _colorTorre = Color(0xFFF36A10);

  const _HistorialChart({required this.historial, required this.cargando});

  // Filtra los registros por nombre de tienda
  List<HistorialPrecio> _puntosPorTienda(String tienda) =>
      historial.where((h) => h.tienda == tienda).toList();

  @override
  Widget build(BuildContext context) {
    // Mostrar spinner mientras se espera la respuesta del backend
    if (cargando) {
      return const _ChartContainer(
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    final walmart = _puntosPorTienda('Walmart GT');
    final torre = _puntosPorTienda('La Torre');

    // Necesitamos al menos 2 puntos para dibujar una línea con sentido
    if (walmart.length + torre.length < 2) {
      return const _ChartContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, color: Colors.grey, size: 32),
            SizedBox(height: 8),
            Text(
              'Sin suficiente historial aún',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            SizedBox(height: 4),
            Text(
              'La gráfica aparecerá con más consultas',
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      );
    }

    // Calcular rango de fechas para el eje X
    final todasFechas = historial.map((h) => h.fecha).toList()..sort();
    final fechaMin = todasFechas.first;

    // Calcular rango de precios para el eje Y con margen visual
    final todosPrecios = historial.map((h) => h.precio).toList();
    final precioMin = todosPrecios.reduce((a, b) => a < b ? a : b);
    final precioMax = todosPrecios.reduce((a, b) => a > b ? a : b);
    final margen = (precioMax - precioMin) * 0.2;
    final yMin = (precioMin - margen).clamp(0.0, double.infinity);
    final yMax = precioMax + margen;

    // Convierte un registro a punto (horas desde inicio, precio)
    FlSpot toSpot(HistorialPrecio h) =>
        FlSpot(h.fecha.difference(fechaMin).inHours.toDouble(), h.precio);

    // Construir las líneas de la gráfica por tienda
    final lineas = <LineChartBarData>[
      if (walmart.isNotEmpty)
        LineChartBarData(
          spots: walmart.map(toSpot).toList(),
          isCurved: true,
          color: _colorWalmart,
          barWidth: 2.5,
          dotData: FlDotData(
            show: true,
            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
              radius: 3,
              color: _colorWalmart,
              strokeWidth: 1.5,
              strokeColor: Colors.white,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            color: _colorWalmart.withValues(alpha: 0.08),
          ),
        ),
      if (torre.isNotEmpty)
        LineChartBarData(
          spots: torre.map(toSpot).toList(),
          isCurved: true,
          color: _colorTorre,
          barWidth: 2.5,
          dotData: FlDotData(
            show: true,
            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
              radius: 3,
              color: _colorTorre,
              strokeWidth: 1.5,
              strokeColor: Colors.white,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            color: _colorTorre.withValues(alpha: 0.08),
          ),
        ),
    ];

    return _ChartContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con título y leyenda de colores
          Row(
            children: [
              const Text(
                'Historial de precios',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const Spacer(),
              if (walmart.isNotEmpty) ...[
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: _colorWalmart,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Walmart',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(width: 10),
              ],
              if (torre.isNotEmpty) ...[
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: _colorTorre,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'La Torre',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Gráfica de líneas
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: yMin,
                maxY: yMax,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: Colors.grey.shade100, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  // Eje Y: precio en quetzales
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 52,
                      getTitlesWidget: (val, _) => Text(
                        'Q${val.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                    ),
                  ),
                  // Eje X: fecha en formato día/mes
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: _calcularIntervalo(todasFechas),
                      getTitlesWidget: (val, _) {
                        final fecha = fechaMin.add(
                          Duration(hours: val.toInt()),
                        );
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${fecha.day}/${fecha.month}',
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                // Tooltip al tocar un punto: muestra precio en Q
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots.map((s) {
                      final color = s.bar.color ?? Colors.grey;
                      return LineTooltipItem(
                        'Q ${s.y.toStringAsFixed(2)}',
                        TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                lineBarsData: lineas,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Ajusta el intervalo del eje X según el rango total de fechas
  double _calcularIntervalo(List<DateTime> fechas) {
    if (fechas.length < 2) return 24;
    final rangoHoras = fechas.last.difference(fechas.first).inHours.toDouble();
    if (rangoHoras <= 48) return 12; // menos de 2 días: cada 12h
    if (rangoHoras <= 168) return 24; // menos de 1 semana: cada día
    if (rangoHoras <= 720) return 24 * 7; // menos de 1 mes: cada semana
    return 24 * 14; // más de 1 mes: cada 2 semanas
  }
}

// Contenedor visual reutilizable para la gráfica y sus estados
class _ChartContainer extends StatelessWidget {
  final Widget child;
  const _ChartContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(minHeight: 120),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
