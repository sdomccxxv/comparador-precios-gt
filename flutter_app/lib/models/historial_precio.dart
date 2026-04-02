class HistorialPrecio {
  final String ean;
  final String tienda;
  final double precio;
  final DateTime fecha;

  HistorialPrecio({
    required this.ean,
    required this.tienda,
    required this.precio,
    required this.fecha,
  });

  factory HistorialPrecio.fromJson(Map<String, dynamic> json) {
    return HistorialPrecio(
      ean: json['ean'] ?? '',
      tienda: json['tienda'] ?? '',
      precio: (json['precio'] as num).toDouble(),
      fecha: DateTime.parse(json['fecha']).toLocal(),
    );
  }

  bool get esWalmart => tienda == 'Walmart GT';
}
