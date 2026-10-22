import 'package:flutter/material.dart';
import '../models/carrito_item.dart';
import '../theme/colores.dart';

/// Fila "Total:" (etiqueta rosada) con el valor a la derecha.
class TotalPedido extends StatelessWidget {
  final int total;

  const TotalPedido({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.botonAgregar,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('Total:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        const Spacer(),
        Text(formatearPrecio(total),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }
}