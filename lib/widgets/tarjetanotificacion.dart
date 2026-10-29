import 'package:flutter/material.dart';
import '../theme/colores.dart';

/// Tarjeta blanca de una notificación: texto (varias líneas), fecha, punto de
/// "no leída", foto del comprobante y [acciones] (botones Aceptar / Rechazar).
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

  Widget _icono() => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.notifications, color: AppColors.primaryColor),
      );

  Widget _foto() {
    final error = Container(
      height: 120,
      alignment: Alignment.center,
      color: Colors.black12,
      child: const Text('No se pudo cargar la imagen'),
    );
    return GestureDetector(
      onTap: onVerImagen,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imagen!,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => error,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final f = _fecha();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _icono(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            texto,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.35,
                              fontWeight: leida ? FontWeight.normal : FontWeight.w600,
                            ),
                          ),
                          if (f.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(f, style: const TextStyle(fontSize: 11.5, color: Colors.black45)),
                          ],
                        ],
                      ),
                    ),
                    if (!leida)
                      Container(
                        margin: const EdgeInsets.only(left: 8, top: 4),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                if (imagen != null && imagen!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _foto(),
                ],
                if (acciones != null) ...[
                  const SizedBox(height: 12),
                  acciones!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}