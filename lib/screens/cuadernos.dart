import 'package:flutter/material.dart';
import 'categoria_screen.dart';

/// Pantalla de la categoría Cuadernos.
/// Los productos aparecen cuando el administrador los agrega al inventario
/// en esta categoría.
class PantallaCuadernos extends StatelessWidget {
  const PantallaCuadernos({super.key});

  @override
  Widget build(BuildContext context) {
    return const PantallaCategoria(
      titulo: 'Cuadernos',
      idCategoria: 1, // TODO: pon aquí el id_categoria real de Cuadernos en tu BD
    );
  }
}