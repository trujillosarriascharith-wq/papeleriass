import 'package:flutter/material.dart';
import '../theme/colores.dart';
import '../theme/estilostextos.dart';

/// Botón rosa de los formularios, con indicador de carga.
class BotonFormulario extends StatelessWidget {
  final String texto;
  final bool cargando;
  final VoidCallback onPressed;

  const BotonFormulario({
    super.key,
    required this.texto,
    required this.onPressed,
    this.cargando = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 42,
      child: ElevatedButton(
        onPressed: cargando ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: cargando
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : Text(texto, style: Estilostextos.estilosLetra.copyWith(color: Colors.white)),
      ),
    );
  }
}