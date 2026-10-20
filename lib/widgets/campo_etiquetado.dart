import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colores.dart';
import '../theme/estilostextos.dart';
import 'campodetexto.dart';

/// Etiqueta pequeña arriba y sombra suave alrededor de cualquier [campo].
class CampoConEtiqueta extends StatelessWidget {
  final String etiqueta;
  final Widget campo;

  const CampoConEtiqueta({super.key, required this.etiqueta, required this.campo});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 4),
          child: Text(
            etiqueta,
            style: Estilostextos.estilosLetra.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: campo,
        ),
      ],
    );
  }
}

/// Tu [CampoTexto] con la etiqueta arriba y el borde rosado del formulario.
class CampoEtiquetado extends StatelessWidget {
  final String etiqueta;
  final TextEditingController controller;
  final TextInputType tipo;
  final List<TextInputFormatter>? formatos;
  final int maxLineas;

  const CampoEtiquetado({
    super.key,
    required this.etiqueta,
    required this.controller,
    this.tipo = TextInputType.text,
    this.formatos,
    this.maxLineas = 1,
  });

  @override
  Widget build(BuildContext context) {
    return CampoConEtiqueta(
      etiqueta: etiqueta,
      campo: CampoTexto(
        etiqueta: '',
        controller: controller,
        tipoTeclado: tipo,
        formatos: formatos,
        maxLineas: maxLineas,
        bordeColor: AppColors.primaryColor,
      ),
    );
  }
}