import 'package:flutter/material.dart';
import '../models/carrito_item.dart';

/// Producto dentro del pedido: nombre, foto, descripción y precio.
class ItemPedidoTarjeta extends StatelessWidget {
  final CarritoItem item;

  const ItemPedidoTarjeta({super.key, required this.item});

  Widget _foto() {
    const tamano = 100.0;
    const error = SizedBox(
      width: tamano,
      height: tamano,
      child: Icon(Icons.image_not_supported_outlined, color: Colors.grey),
    );
    final imagen = item.imagen.startsWith('http')
        ? Image.network(item.imagen,
            width: tamano, height: tamano, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => error)
        : Image.asset(item.imagen,
            width: tamano, height: tamano, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => error);
    return ClipRRect(borderRadius: BorderRadius.circular(12), child: imagen);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text(item.nombre,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _foto(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Descripción:',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    for (final linea in item.descripcion)
                      Text('•  $linea', style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${item.cantidad} x ${formatearPrecio(item.precio)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        formatearPrecio(item.subtotal),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}