import 'package:flutter/material.dart';
import '../theme/estilostextos.dart';
import '../utils/texto_producto.dart';
import 'campo_etiquetado.dart';

/// Descripción del producto escrita como lista con viñetas:
/// cada característica va en su propia línea (Enter = nueva viñeta).
class CampoDescripcion extends StatelessWidget {
  final TextEditingController controller;

  const CampoDescripcion({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CampoEtiquetado(
          etiqueta: 'Descripción del producto',
          controller: controller,
          tipo: TextInputType.multiline,
          formatos: [FormatoVinetas()],
          maxLineas: 6,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 6, top: 4),
          child: Text(
            'Escribe cada característica en una línea nueva (Enter). '
            'Ej: Marca Norma / 100 hojas',
            style: Estilostextos.estilosLetra.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Colors.black45,
            ),
          ),
        ),
      ],
    );
  }
}