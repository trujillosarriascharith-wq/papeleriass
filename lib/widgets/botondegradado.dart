import 'package:flutter/material.dart';
import '../theme/colores.dart';

/// Botón con degradado rosa (primaryColor -> secondaryColor) y sombra.
/// Se usa en: Iniciar Sesión, Crear cuenta, Enviar, Cambiar Contraseña,
/// Cerrar Sesión.
///
/// - [ancho]: ancho fijo. Si es null, el botón se ajusta a su contenido.
/// - [icono]: opcional, se dibuja a la izquierda del texto
///   (ej. Icons.logout en "Cerrar Sesión").
/// - [cargando]: muestra un indicador y desactiva el botón.
class BotonDegradado extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;
  final bool cargando;
  final IconData? icono;
  final double? ancho;
  final double alto;
  final double radio;

  const BotonDegradado({
    super.key,
    required this.texto,
    required this.onPressed,
    this.cargando = false,
    this.icono,
    this.ancho = 300,// ancho fijo por defecto
    this.alto = 40,
    this.radio = 6,
  });

  @override
  Widget build(BuildContext context) {
    final borde = BorderRadius.circular(radio);
    final activo = !cargando;

    return Opacity(
      opacity: activo ? 1 : 0.7,
      child: Container(
        width: ancho,
        height: alto,
        decoration: BoxDecoration(
          borderRadius: borde,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryColor, AppColors.secondaryColor],
          ),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 3)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: borde,
            onTap: activo ? onPressed : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (cargando)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  else ...[
                    if (icono != null) ...[
                      Icon(icono, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      texto,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}