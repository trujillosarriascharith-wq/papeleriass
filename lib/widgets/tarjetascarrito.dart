import 'package:flutter/material.dart';
import '../models/carrito_item.dart';
import '../theme/colores.dart';
import '../theme/estilostextos.dart';

/// Tarjeta de un producto del carrito:
/// foto + contador, descripción, casilla, papelera y precio.
class TarjetaCarrito extends StatelessWidget {
  final CarritoItem item;
  final ValueChanged<bool> onSeleccionar;
  final VoidCallback onEliminar;
  final VoidCallback onSumar;
  final VoidCallback onRestar;

  const TarjetaCarrito({
    super.key,
    required this.item,
    required this.onSeleccionar,
    required this.onEliminar,
    required this.onSumar,
    required this.onRestar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _foto(),
              const SizedBox(height: 8),
              _contador(),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(child: _descripcion()),
          _acciones(),
        ],
      ),
    );
  }

  Widget _foto() {
    const tamano = 100.0;
    final error = Container(
      width: tamano,
      height: tamano,
      color: AppColors.fondoComponente,
      child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: item.imagen.startsWith('http')
          ? Image.network(item.imagen,
              width: tamano, height: tamano, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => error)
          : Image.asset(item.imagen,
              width: tamano, height: tamano, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => error),
    );
  }

  // Botón rosa "-  1  +"
  Widget _contador() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.botonAgregar,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onRestar,
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Icon(Icons.remove, size: 16, color: Colors.black),
            ),
          ),
          Text('${item.cantidad}', style: Estilostextos.estilosLetra),
          InkWell(
            onTap: onSumar,
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Icon(Icons.add, size: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _descripcion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Descripción:', style: Estilostextos.estilosLetra),
        const SizedBox(height: 4),
        for (final linea in item.descripcion)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              '•  $linea',
              style: Estilostextos.estilosLetra.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _acciones() {
    return SizedBox(
      width: 72,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            height: 32,
            width: 32,
            child: Checkbox(
              value: item.seleccionado,
              onChanged: (v) => onSeleccionar(v ?? false),
              activeColor: Colors.white,
              checkColor: Colors.black,
              side: const BorderSide(color: Colors.black, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          IconButton(
            onPressed: onEliminar,
            icon: const Icon(Icons.delete_outline, color: Colors.black),
            tooltip: 'Eliminar',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formatearPrecio(item.subtotal),
              style: Estilostextos.estilosTitulo.copyWith(fontSize: 17),
            ),
          ),
        ],
      ),
    );
  }
}