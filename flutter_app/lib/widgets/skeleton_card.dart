import 'package:flutter/material.dart';

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class SkeletonProductoCard extends StatefulWidget {
  const SkeletonProductoCard({super.key});

  @override
  State<SkeletonProductoCard> createState() => _SkeletonProductoCardState();
}

class _SkeletonProductoCardState extends State<SkeletonProductoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen — 70x70 igual que la tarjeta real
            _SkeletonBox(width: 70, height: 70, borderRadius: 10),
            const SizedBox(width: 12),
            // Columna de texto con altura fija de 70px para igualar la imagen
            Expanded(
              child: SizedBox(
                height: 70,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Badge tienda
                    _SkeletonBox(width: 70, height: 16, borderRadius: 8),
                    // Nombre (dos líneas)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SkeletonBox(width: double.infinity, height: 13),
                        const SizedBox(height: 5),
                        _SkeletonBox(width: 160, height: 13),
                      ],
                    ),
                    // Marca y EAN
                    _SkeletonBox(width: 100, height: 11),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Precio con misma altura
            SizedBox(
              height: 70,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SkeletonBox(width: 65, height: 20),
                  _SkeletonBox(width: 18, height: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SkeletonList extends StatelessWidget {
  final int cantidad;
  const SkeletonList({super.key, this.cantidad = 7});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: cantidad,
      itemBuilder: (_, __) => const SkeletonProductoCard(),
    );
  }
}
