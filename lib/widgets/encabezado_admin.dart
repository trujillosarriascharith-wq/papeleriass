import 'package:flutter/material.dart';
import '../theme/estilostextos.dart';

/// Fila de arriba de las pantallas del administrador:
/// [menú] [logo] [nombre de la papelería].
/// Ponla dentro de un FondoDegradado; el icono de menú abre el drawer.
class EncabezadoAdmin extends StatelessWidget {
  const EncabezadoAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Builder(
          builder: (ctx) => IconButton(
            onPressed: () => Scaffold.of(ctx).openDrawer(),
            icon: const Icon(Icons.menu_rounded),
            iconSize: 30,
            color: Colors.white,
            tooltip: 'Menú',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ),
        const SizedBox(width: 4),
        const CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white,
          backgroundImage: AssetImage('assets/images/logo2.png'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Papelería y Variedades\nJuan José',
              textAlign: TextAlign.center,
              style: Estilostextos.estilosBienvenida,
            ),
          ),
        ),
        // Mismo ancho que el icono del menú para que el texto quede centrado
        const SizedBox(width: 40),
      ],
    );
  }
}