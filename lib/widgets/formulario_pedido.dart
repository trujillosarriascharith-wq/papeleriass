import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colores.dart';
import 'campodetexto.dart';

/// Tarjeta rosada con los datos de entrega y el método de pago.
class FormularioPedido extends StatelessWidget {
  final TextEditingController nombre;
  final TextEditingController direccion;
  final TextEditingController telefono;
  final String? metodoPago;
  final ValueChanged<String?> onMetodoPago;

  const FormularioPedido({
    super.key,
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.metodoPago,
    required this.onMetodoPago,
  });

  static const List<String> metodos = ['Nequi', 'Efectivo'];

  OutlineInputBorder _borde() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
      );

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
        ],
      ),
    );
  }
}