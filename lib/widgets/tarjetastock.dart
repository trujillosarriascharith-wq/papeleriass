import 'package:flutter/material.dart';
import '../models/producto_model.dart';
import '../theme/colores.dart';
import '../theme/estilostextos.dart';

/// Tarjeta de un producto con pocas unidades:
/// foto, nombre y las unidades que quedan en rojo.
class TarjetaStock extends StatelessWidget {
  final ProductoModel producto;

  const TarjetaStock({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
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
          Expanded(
            child: Text(
              producto.nombre,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Estilostextos.estilosLetra.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
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

  // Número rojo grande + "UD"
  Widget _unidades() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${producto.cantidadStock}',
          style: const TextStyle(
            color: Color(0xFFD50000),
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text('UD', style: Estilostextos.estilosLetra.copyWith(fontSize: 17)),
      ],
    );
  }
}