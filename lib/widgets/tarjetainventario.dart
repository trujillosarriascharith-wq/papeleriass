import 'package:flutter/material.dart';
import '../models/carrito_item.dart';
import '../models/producto_model.dart';
import '../screens/productos_stock.dart';
import '../theme/colores.dart';
import '../theme/estilostextos.dart';

/// Tarjeta de un producto del inventario:
/// foto, nombre, precio y unidades (rojo si quedan pocas, verde si hay suficientes).
class TarjetaInventario extends StatelessWidget {
  final ProductoModel producto;

  const TarjetaInventario({super.key, required this.producto});

  // Pocas unidades = rojo (mismo límite que la pantalla de stock)
  bool get _stockBajo =>
      producto.cantidadStock <= PantallaProductosStock.umbralStockBajo;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryColor, width: 1),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _foto(),
          const SizedBox(width: 12),
          Expanded(child: _informacion()),
          const SizedBox(width: 8),
          _unidades(),
        ],
      ),
    );
  }

  Widget _foto() {
    const tamano = 66.0;
    final img = producto.imagen;
    final error = Container(
      width: tamano,
      height: tamano,
      color: AppColors.fondoComponente,
      child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: img.startsWith('http')
          ? Image.network(img,
              width: tamano, height: tamano, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => error)
          : img.isEmpty
              ? error
              : Image.asset(img,
                  width: tamano, height: tamano, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => error),
    );
  }

  // Nombre arriba y precio debajo
  Widget _informacion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          producto.nombre,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: Estilostextos.estilosLetra.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          formatearPrecio(producto.precio),
          style: Estilostextos.estilosLetra.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: 'serif',
          ),
        ),
      ],
    );
  }

  // Número grande (rojo o verde) + "UD"
  Widget _unidades() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${producto.cantidadStock}',
          style: TextStyle(
            color: _stockBajo ? const Color(0xFFD50000) : const Color(0xFF00D26A),
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text('UD', style: Estilostextos.estilosLetra.copyWith(fontSize: 17)),
      ],
    );
  }
}