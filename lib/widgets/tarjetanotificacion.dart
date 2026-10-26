import 'package:flutter/material.dart';
import '../theme/colores.dart';

/// Tarjeta blanca de una notificación: miniatura, texto, fecha y punto de "no leída".
/// [acciones] muestra widgets debajo (ej. botones Aprobar / Rechazar).
/// [onVerImagen] permite ampliar la miniatura al tocarla.
class TarjetaNotificacion extends StatelessWidget {
  final String texto;
  final String? fecha;
  final bool leida;
  final String? imagen;
  final VoidCallback? onTap;
  final VoidCallback? onVerImagen;
  final Widget? acciones;

  const TarjetaNotificacion({
    super.key,
    required this.texto,
    this.fecha,
    this.leida = true,
    this.imagen,
    this.onTap,
    this.onVerImagen,
    this.acciones,
  });

  String _fecha() {
    final d = DateTime.tryParse(fecha ?? '')?.toLocal();
    if (d == null) return '';
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(d.day)}/${dos(d.month)}/${d.year}  ${dos(d.hour)}:${dos(d.minute)}';
  }

  Widget _miniatura() {
    final vacio = Container(
      width: 44,
      height: 44,
      color: AppColors.primaryColor.withOpacity(0.15),
      child: Icon(Icons.notifications, color: AppColors.primaryColor),
    );
    final foto = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: imagen == null
          ? vacio
          : Image.network(imagen!,
              width: 44, height: 44, fit: BoxFit.cover, errorBuilder: (_, __, ___) => vacio),
    );
    if (imagen == null || onVerImagen == null) return foto;
    return GestureDetector(onTap: onVerImagen, child: foto);
  }

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
        ),
        child: Column(
          children: [
            ListTile(
              onTap: onTap,
              leading: _miniatura(),
              title: Text(
                texto,
                style: TextStyle(fontSize: 14.5, fontWeight: leida ? FontWeight.normal : FontWeight.w700),
              ),
              subtitle: _fecha().isEmpty
                  ? null
                  : Text(_fecha(), style: const TextStyle(fontSize: 11.5, color: Colors.black45)),
              trailing: leida
                  ? null
                  : Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: AppColors.primaryColor, shape: BoxShape.circle),
                    ),
            ),
            if (acciones != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: acciones!,
              ),
          ],
        ),
      );
}