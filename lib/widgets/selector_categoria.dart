import 'package:flutter/material.dart';
import '../theme/colores.dart';
import 'campo_etiquetado.dart';

/// Categoría disponible al ingresar un producto.
/// IMPORTANTE: los id deben ser los mismos que usas en menu_lateral.dart
/// (el idCategoria de cada PantallaCategoria) y en tu tabla de categorías.
class Categoria {
  final int id;
  final String nombre;
  const Categoria(this.id, this.nombre);
}

const List<Categoria> categoriasProducto = [
  Categoria(1, 'Cuadernos'),
  Categoria(2, 'Colores'),
  Categoria(3, 'Cartucheras'),
  Categoria(4, 'Temperas'),
  Categoria(5, 'Marcadores'),
  Categoria(6, 'Pegamentos'),
];

/// Lista desplegable para elegir la categoría del producto.
/// Tiene el mismo estilo que [CampoTexto] (borde rosado y esquinas redondeadas).
class SelectorCategoria extends StatelessWidget {
  final int? valor;
  final ValueChanged<int?> onChanged;

  const SelectorCategoria({super.key, required this.valor, required this.onChanged});

  InputDecoration _decoracion() {
    final borde = OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
    );
    return InputDecoration(
      filled: true,
      fillColor: AppColors.fondoComponente,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: borde,
      enabledBorder: borde,
      focusedBorder: borde,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CampoConEtiqueta(
      etiqueta: 'Categoría',
      campo: DropdownButtonFormField<int>(
        value: valor,
        isExpanded: true,
        hint: const Text('Selecciona una categoría'),
        decoration: _decoracion(),
        borderRadius: BorderRadius.circular(16),
        items: [
          for (final c in categoriasProducto)
            DropdownMenuItem(value: c.id, child: Text(c.nombre)),
        ],
        onChanged: onChanged,
      ),
    );
  }
}