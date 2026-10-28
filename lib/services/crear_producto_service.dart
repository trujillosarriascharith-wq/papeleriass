
import 'dart:typed_data';
import '../models/producto_model.dart';
import 'producto_service.dart';

/// Guarda un producto nuevo en el servidor (base de datos + imagen en Cloudinary).
class CrearProductoService {
  static Future<void> crear(
    ProductoModel producto,
    Uint8List imagen,
    String nombreImagen,
  ) =>
      ProductoService.crear(
        producto: producto,
        imagen: imagen,
        nombreImagen: nombreImagen,
      );
}