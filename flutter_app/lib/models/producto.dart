class Producto {
  final String tienda;
  final String nombre;
  final String marca;
  final double precio;
  final String url;
  final String? imagen;
  final String? ean;
  final bool coincideAmbas;

  Producto({
    required this.tienda,
    required this.nombre,
    required this.marca,
    required this.precio,
    required this.url,
    this.imagen,
    this.ean,
    this.coincideAmbas = false,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      tienda: json['tienda'] ?? '',
      nombre: json['nombre'] ?? '',
      marca: json['marca'] ?? '',
      precio: (json['precio'] as num).toDouble(),
      url: json['url'] ?? '',
      imagen: json['imagen'],
      ean: json['ean']?.toString(),
      coincideAmbas: json['coincide_ambas'] == true,
    );
  }

  // Color por tienda para mostrar en la UI
  bool get esWalmart => tienda == 'Walmart GT';
}
