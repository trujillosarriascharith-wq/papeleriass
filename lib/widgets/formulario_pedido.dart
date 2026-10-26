import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colores.dart';
import 'campodetexto.dart';

/// Tarjeta rosada con los datos de entrega y el método de pago.
/// Si el método es Nequi, muestra el botón para adjuntar el comprobante.
class FormularioPedido extends StatelessWidget {
  final TextEditingController nombre;
  final TextEditingController direccion;
  final TextEditingController telefono;
  final String? metodoPago;
  final ValueChanged<String?> onMetodoPago;

  // ---- Comprobante Nequi ----
  /// ninguno | subiendo | pendiente | aprobado | rechazado
  final String estadoComprobante;
  final Uint8List? comprobanteBytes;
  final String? comprobanteUrl;
  final VoidCallback? onAdjuntar;

  const FormularioPedido({
    super.key,
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.metodoPago,
    required this.onMetodoPago,
    this.estadoComprobante = 'ninguno',
    this.comprobanteBytes,
    this.comprobanteUrl,
    this.onAdjuntar,
  });

  static const List<String> metodos = ['Nequi', 'Efectivo'];

  OutlineInputBorder _borde() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
      );

  // ---------- Sección del comprobante ----------

  Widget _vistaPrevia() {
    Widget? img;
    if (comprobanteBytes != null) {
      img = Image.memory(comprobanteBytes!, fit: BoxFit.cover);
    } else if (comprobanteUrl != null && comprobanteUrl!.isNotEmpty) {
      img = Image.network(
        comprobanteUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined),
      );
    }
    if (img == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(height: 150, width: double.infinity, child: img),
      ),
    );
  }

  Widget _estado() {
    IconData icono;
    Color color;
    String texto;
    switch (estadoComprobante) {
      case 'subiendo':
        return const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 8),
            Text('Subiendo comprobante...', style: TextStyle(fontSize: 13)),
          ],
        );
      case 'pendiente':
        icono = Icons.hourglass_top_rounded;
        color = Colors.orange.shade800;
        texto = 'En revisión: el administrador debe validar tu pago';
        break;
      case 'aprobado':
        icono = Icons.check_circle_rounded;
        color = Colors.green.shade700;
        texto = 'Pago validado. Ya puedes realizar el pedido';
        break;
      case 'rechazado':
        icono = Icons.cancel_rounded;
        color = Colors.red.shade700;
        texto = 'Comprobante rechazado. Adjunta uno nuevo';
        break;
      default:
        return const SizedBox.shrink();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icono, color: color, size: 20),
        const SizedBox(width: 6),
        Flexible(
          child: Text(texto,
              style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _seccionComprobante() {
    final bloqueado = estadoComprobante == 'subiendo' ||
        estadoComprobante == 'pendiente' ||
        estadoComprobante == 'aprobado';
    final etiqueta = estadoComprobante == 'rechazado'
        ? 'Adjuntar nuevo comprobante'
        : 'Adjuntar imagen del comprobante de pago';

    return Column(
      children: [
        _vistaPrevia(),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: bloqueado ? null : onAdjuntar,
            icon: const Icon(Icons.upload_file_rounded),
            label: Text(etiqueta, textAlign: TextAlign.center),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryColor,
              side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _estado(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F4),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          CampoTexto(
            etiqueta: 'Nombre',
            bordeColor: AppColors.primaryColor,
            controller: nombre,
          ),
          const SizedBox(height: 12),
          CampoTexto(
            etiqueta: 'Dirección',
            bordeColor: AppColors.primaryColor,
            controller: direccion,
          ),
          const SizedBox(height: 12),
          CampoTexto(
            etiqueta: 'Teléfono',
            bordeColor: AppColors.primaryColor,
            controller: telefono,
            tipoTeclado: TextInputType.phone,
            formatos: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: metodoPago,
            hint: const Text('Método de pago'),
            items: [
              for (final m in metodos)
                DropdownMenuItem(value: m, child: Text(m)),
            ],
            onChanged: onMetodoPago,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.fondoComponente,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: _borde(),
              enabledBorder: _borde(),
              focusedBorder: _borde(),
            ),
          ),
          if (metodoPago == 'Nequi') ...[
            const SizedBox(height: 12),
            _seccionComprobante(),
          ],
        ],
      ),
    );
  }
}