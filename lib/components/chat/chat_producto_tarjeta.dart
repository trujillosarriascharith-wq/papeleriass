import 'package:flutter/material.dart';
import '../../models/producto_model.dart';

/// Mini tarjeta de producto para mostrar dentro del chat:
/// foto, nombre, precio, disponibilidad y descripción.
class ChatProductoTarjeta extends StatelessWidget {
  final ProductoModel producto;

  const ChatProductoTarjeta({super.key, required this.producto});

  bool get _disponible =>
      producto.cantidadStock > 0 && producto.estado.toLowerCase() == 'activo';

  // 1300 -> $1.300 COP
  String _precio(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
      b.write(s[i]);
    }
    return '\$$b COP';
  }

  // Quita viñetas repetidas y toma máximo 3 líneas de la descripción
  List<String> get _lineas => producto.descripcion
      .join('\n')
      .split('\n')
      .map((l) => l.replaceFirst(RegExp(r'^[•\-\*\s]+'), '').trim())
      .where((l) => l.isNotEmpty)
      .take(3)
      .toList();

  Widget _foto() {
    final img = producto.imagen;
    final vacio = Container(
      width: 90,
      height: 90,
      color: const Color(0xFFFFF0F3),
      child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
    );

    Widget imagen;
    if (img.isEmpty) {
      imagen = vacio;
    } else if (img.startsWith('http')) {
      imagen = Image.network(
        img,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => vacio,
        loadingBuilder: (_, child, progreso) => progreso == null
            ? child
            : SizedBox(
                width: 90,
                height: 90,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
      );
    } else {
      imagen = Image.asset(
        img,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => vacio,
      );
    }

    return ClipRRect(borderRadius: BorderRadius.circular(14), child: imagen);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(8),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.86,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD6E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _foto(),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto.nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3B2A30),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _precio(producto.precio),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFE0557A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _disponible
                      ? 'Disponible (${producto.cantidadStock} und.)'
                      : 'Agotado',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: _disponible ? Colors.green.shade700 : Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                for (final l in _lineas)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 1),
                    child: Text(
                      '•  $l',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        height: 1.25,
                        color: Colors.black87,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}