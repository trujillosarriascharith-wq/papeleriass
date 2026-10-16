import 'package:flutter/material.dart';
import '../theme/estilostextos.dart';

/// Sección "Servicios rápidos": fila de iconos informativos con los
/// servicios que ofrece la papelería. Son solo informativos (no se tocan).
class ServiciosRapidos extends StatelessWidget {
  const ServiciosRapidos({super.key});

  // Lista de servicios: para agregar o quitar uno, edita esta lista
  static const List<_Servicio> _servicios = [
    _Servicio('Fotocopias', Icons.content_copy_rounded),
    _Servicio('Impresiones', Icons.print_outlined),
    _Servicio('Plastificado', Icons.layers_outlined),
    _Servicio('Anillado', Icons.menu_book_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Servicios rápidos', style: Estilostextos.estilosTitulo),
        const SizedBox(height: 14),
        Row(
          children: _servicios
              .map((s) => Expanded(child: _ItemServicio(servicio: s)))
              .toList(),
        ),
      ],
    );
  }
}

class _Servicio {
  final String nombre;
  final IconData icono;
  const _Servicio(this.nombre, this.icono);
}

/// Círculo con icono + nombre del servicio (sin acción al tocar).
class _ItemServicio extends StatelessWidget {
  final _Servicio servicio;

  const _ItemServicio({required this.servicio});

  static const Color _fondo = Color(0xFFFDE4EC); // círculo rosa pastel
  static const Color _icono = Color(0xFFEB608C); // icono rosa

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _fondo,
            boxShadow: [
              BoxShadow(
                color: _icono.withAlpha(40),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(servicio.icono, size: 28, color: _icono),
        ),
        const SizedBox(height: 8),
        Text(
          servicio.nombre,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3A3A3A),
          ),
        ),
      ],
    );
  }
}