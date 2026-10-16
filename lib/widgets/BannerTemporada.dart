import 'package:flutter/material.dart';

/// Banner de temporada: tarjeta ancha con degradado suave, título, subtítulo
/// y un botón. Para cambiar de temporada (regreso a clases, Halloween,
/// Navidad...) solo cambia los textos, el icono y los colores al usarlo.
class BannerTemporada extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final String textoBoton;
  final IconData icono;
  final List<Color> colores;
  final VoidCallback? onTap;

  const BannerTemporada({
    super.key,
    this.titulo = 'Día de los Niños',
    this.subtitulo = 'Útiles, detalles y sorpresas para los más pequeños',
    this.textoBoton = 'Consúltanos',
    this.icono = Icons.celebration_rounded,
    this.colores = const [Color(0xFFFF8FAB), Color(0xFFFFB38A)],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: colores,
        ),
        boxShadow: [
          BoxShadow(
            color: colores.first.withAlpha(90),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Círculos decorativos de fondo
            Positioned(
              right: -30,
              top: -30,
              child: _circulo(110, 35),
            ),
            Positioned(
              right: 50,
              bottom: -40,
              child: _circulo(90, 25),
            ),
            // Contenido
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitulo,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            onTap: onTap,
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 7,
                              ),
                              child: Text(
                                textoBoton,
                                style: TextStyle(
                                  color: colores.first,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Icono grande de la temporada
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(60),
                    ),
                    child: Icon(icono, size: 38, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circulo(double tam, int alpha) => Container(
        width: tam,
        height: tam,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withAlpha(alpha),
        ),
      );
}