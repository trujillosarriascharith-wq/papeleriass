import 'dart:typed_data';
import '../models/producto_model.dart';

/// Guarda un producto nuevo en el servidor.
class CrearProductoService {
  static Future<void> crear(
    ProductoModel producto,
    Uint8List imagen,
    String nombreImagen,
  ) async {
    // TODO: conectar con tu backend:
    //  1) subir la imagen (imagen / nombreImagen) y obtener su URL
    //  2) crear el producto con producto.toJsonForInsert(), usando esa URL
    //     como 'imagen'
    // Cuando esté listo, borra la línea de abajo.
    throw Exception('Falta conectar el guardado con el servidor');
  }
}