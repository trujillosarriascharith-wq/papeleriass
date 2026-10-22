import 'package:flutter/material.dart';
import '../theme/estilostextos.dart';
import 'fondodegradado.dart';

/// Encabezado: [menú] [logo] [texto] [inicio]. Debe estar dentro de un
/// Scaffold que tenga `drawer` para que el botón de menú lo abra.
class EncabezadoTienda extends StatelessWidget {
  final VoidCallback onInicio;

  const EncabezadoTienda({super.key, required this.onInicio});

  @override
  Widget build(BuildContext context) {
    const iconConstraints = BoxConstraints(minWidth: 40, minHeight: 40);

    return FondoDegradado(
      alto: 120,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      child: Row(
        children: [
          Builder(
            builder: (ctx) => IconButton(
              onPressed: () => Scaffold.of(ctx).openDrawer(),
              icon: const Icon(Icons.menu_rounded),
              iconSize: 30,
              color: Colors.white,
              tooltip: 'Menú',
              padding: EdgeInsets.zero,
              constraints: iconConstraints,
            ),
          ),
          const SizedBox(width: 4),
          const CircleAvatar(
            radius: 32,
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
          IconButton(
            onPressed: onInicio,
            icon: const Icon(Icons.home_rounded),
            iconSize: 28,
            color: Colors.white,
            tooltip: 'Volver al inicio',
            padding: EdgeInsets.zero,
            constraints: iconConstraints,
          ),
        ],
      ),
    );
  }
}