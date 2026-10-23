import 'package:flutter/material.dart';

/// Foto de una categoría: acepta una URL (http...) o un asset local.
/// Si está vacía o falla, muestra un icono.
class ImagenCategoria extends StatelessWidget {
  final String imagen;

  const ImagenCategoria({super.key, required this.imagen});

  @override
  Widget build(BuildContext context) {
    const icono = Icon(Icons.image_not_supported_outlined, color: Colors.grey);

    if (imagen.isEmpty) return icono;
    if (imagen.startsWith('http')) {
      return Image.network(
        imagen,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => icono,
      );
    }
    return Image.asset(
      imagen,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => icono,
    );
  }
}