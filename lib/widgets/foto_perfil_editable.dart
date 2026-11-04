import 'package:flutter/material.dart';

/// Foto de perfil redonda con el icono de cámara para cambiarla.
/// Muestra un indicador de carga mientras se sube la foto nueva.
class FotoPerfilEditable extends StatelessWidget {
  final String? fotoUrl;
  final String rutaPorDefecto;
  final bool subiendo;
  final VoidCallback onEditar;

  const FotoPerfilEditable({
    super.key,
    required this.fotoUrl,
    required this.rutaPorDefecto,
    required this.subiendo,
    required this.onEditar,
  });

  @override
  Widget build(BuildContext context) {
    final ImageProvider imagen = fotoUrl != null
        ? NetworkImage(fotoUrl!)
        : AssetImage(rutaPorDefecto);

    return GestureDetector(
      onTap: subiendo ? null : onEditar,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 58,
            backgroundColor: Colors.white, //borde de la foto
            child: CircleAvatar(radius: 54, backgroundImage: imagen),
          ),
          if (subiendo)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black38,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ),
            ),
          const Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Icon(Icons.camera_alt, size: 18, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}