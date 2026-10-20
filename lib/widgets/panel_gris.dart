import 'package:flutter/material.dart';

/// Panel gris redondeado donde van el contenido de las pantallas del
/// administrador (formulario, lista de stock, inventario...).
class PanelGris extends StatelessWidget {
  final Widget child;

  const PanelGris({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE4E4E4),
        borderRadius: BorderRadius.circular(28),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: child,
      ),
    );
  }
}