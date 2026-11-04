// import 'producto_model.dart';

// /// Un mensaje del chat: texto + (opcional) productos para mostrar como tarjetas.
// class ChatMensaje {
//   final bool esUsuario;
//   final String texto;
//   final List<ProductoModel> productos;

//   const ChatMensaje({
//     required this.esUsuario,
//     required this.texto,
//     this.productos = const [],
//   });
// }

// /// Lo que devuelve el servidor al enviar un mensaje.
// class RespuestaChat {
//   final String texto;
//   final List<ProductoModel> productos;

//   const RespuestaChat({required this.texto, this.productos = const []});
// }
import 'producto_model.dart';

/// Un mensaje del chat: texto + (opcional) productos para mostrar como tarjetas.
/// Si [esStock] es true, las tarjetas se dibujan como en la pantalla de stock.
class ChatMensaje {
  final bool esUsuario;
  final String texto;
  final List<ProductoModel> productos;
  final bool esStock;

  const ChatMensaje({
    required this.esUsuario,
    required this.texto,
    this.productos = const [],
    this.esStock = false,
  });
}

/// Lo que devuelve el servidor al enviar un mensaje.
class RespuestaChat {
  final String texto;
  final List<ProductoModel> productos;
  final bool esStock;

  const RespuestaChat({
    required this.texto,
    this.productos = const [],
    this.esStock = false,
  });
}