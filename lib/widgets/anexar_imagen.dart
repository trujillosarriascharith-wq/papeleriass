import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/estilostextos.dart';

/// Cuadro "Anexar imagen": al tocarlo abre la galería y muestra la foto
/// elegida (o el icono de cámara si todavía no hay ninguna).
class AnexarImagen extends StatelessWidget {
  final Uint8List? imagen;
  final void Function(Uint8List bytes, String nombre) onElegida;

  const AnexarImagen({super.key, required this.imagen, required this.onElegida});

  Future<void> _elegir(BuildContext context) async {
    try {
      final archivo = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (archivo == null) return; // canceló
      onElegida(await archivo.readAsBytes(), archivo.name);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir la galería')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _elegir(context),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF9E9E9E), Color(0xFF424242)],
              ),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: imagen != null
                  ? Image.memory(imagen!, fit: BoxFit.cover)
                  : const Icon(Icons.photo_camera_rounded, size: 56, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          imagen == null ? 'Anexar imagen' : 'Cambiar imagen',
          style: Estilostextos.estilosLetra,
        ),
      ],
    );
  }
}