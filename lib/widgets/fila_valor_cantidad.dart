import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'campo_etiquetado.dart';

/// Los campos Valor y Cantidad, uno al lado del otro.
/// Valor acepta cualquier carácter; Cantidad solo acepta números.
class FilaValorCantidad extends StatelessWidget {
  final TextEditingController valor;
  final TextEditingController cantidad;

  const FilaValorCantidad({super.key, required this.valor, required this.cantidad});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CampoEtiquetado(etiqueta: 'Valor', controller: valor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: CampoEtiquetado(
            etiqueta: 'Cantidad',
            controller: cantidad,
            tipo: TextInputType.number,
            formatos: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
      ],
    );
  }
}