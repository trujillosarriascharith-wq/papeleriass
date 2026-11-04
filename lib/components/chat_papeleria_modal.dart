//codigo funcionado hoy 11:30
// import 'package:flutter/material.dart';
// import '../services/chatpapeleriaservice.dart';
// import 'chat/chat_header.dart';
// import 'chat/chat_burbuja.dart';
// import 'chat/chat_input_field.dart';

// class ChatPapeleriaModal extends StatefulWidget {
//   const ChatPapeleriaModal({super.key});

//   @override
//   State<ChatPapeleriaModal> createState() => _ChatPapeleriaModalState();
// }

// class _ChatPapeleriaModalState extends State<ChatPapeleriaModal> {
//   final TextEditingController _controller = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final List<Map<String, String>> _mensajes = [
//     {
//       'role': 'bot',
//       'text': '¡Hola! Bienvenido a Papelería Juan Jose. ¿Qué producto, precio o envío te gustaría conocer hoy?',
//     }
//   ];
//   bool _cargando = false;

//   void _enviarMensaje() async {
//     final texto = _controller.text.trim();
//     if (texto.isEmpty || _cargando) return;

//     _controller.clear();
//     setState(() {
//       _mensajes.add({'role': 'user', 'text': texto});
//       _cargando = true;
//     });

//     _scrollHaciaAbajo();

//     final respuesta = await ChatPapeleriaService.enviarMensaje(texto);

//     if (mounted) {
//       setState(() {
//         _mensajes.add({'role': 'bot', 'text': respuesta});
//         _cargando = false;
//       });
//       _scrollHaciaAbajo();
//     }
//   }

//   void _scrollHaciaAbajo() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bottomInset = MediaQuery.of(context).viewInsets.bottom;

//     return Container(
//       height: MediaQuery.of(context).size.height * 0.85,
//       margin: EdgeInsets.only(bottom: bottomInset),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
//       ),
//       child: Column(
//         children: [
//           const ChatHeader(),
//           Expanded(
//             child: ListView.builder(
//               controller: _scrollController,
//               padding: const EdgeInsets.all(16),
//               itemCount: _mensajes.length,
//               itemBuilder: (context, index) {
//                 final item = _mensajes[index];
//                 return ChatBurbuja(
//                   texto: item['text']!,
//                   esUsuario: item['role'] == 'user',
//                 );
//               },
//             ),
//           ),
//           if (_cargando)
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
//               child: Row(
//                 children: [
//                   SizedBox(
//                     width: 14,
//                     height: 14,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       color: Color(0xFFFF8FAB), // ROSADO PASTEL
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                   Text(
//                     'El asesor esta respondiendo...',
//                     style: TextStyle(color: Colors.black45, fontSize: 12),
//                   ),
//                 ],
//               ),
//             ),
//           ChatInputField(
//             controller: _controller,
//             cargando: _cargando,
//             onEnviar: _enviarMensaje,
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../models/chat_mensaje.dart';
import '../services/chatpapeleriaservice.dart';
import '../widgets/tarjetastock.dart';
import 'chat/chat_header.dart';
import 'chat/chat_burbuja.dart';
import 'chat/chat_input_field.dart';
import 'chat/chat_producto_tarjeta.dart';

class ChatPapeleriaModal extends StatefulWidget {
  /// Solo cambia el aspecto (título y saludo). Los permisos reales de
  /// administrador los decide el servidor con el token de sesión.
  final bool esAdmin;

  const ChatPapeleriaModal({super.key, this.esAdmin = false});

  @override
  State<ChatPapeleriaModal> createState() => _ChatPapeleriaModalState();
}

class _ChatPapeleriaModalState extends State<ChatPapeleriaModal> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final List<ChatMensaje> _mensajes;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _mensajes = [
      ChatMensaje(
        esUsuario: false,
        texto: widget.esAdmin
            ? '¡Hola! Puedes preguntarme por productos y precios, o por los productos con poco stock.'
            : '¡Hola! Bienvenido a Papelería Juan Jose. ¿Qué producto, precio o envío te gustaría conocer hoy?',
      ),
    ];
  }

  void _enviarMensaje() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty || _cargando) return;

    _controller.clear();
    setState(() {
      _mensajes.add(ChatMensaje(esUsuario: true, texto: texto));
      _cargando = true;
    });

    _scrollHaciaAbajo();

    final respuesta = await ChatPapeleriaService.enviarMensaje(texto);

    if (mounted) {
      setState(() {
        _mensajes.add(
          ChatMensaje(
            esUsuario: false,
            texto: respuesta.texto,
            productos: respuesta.productos,
            esStock: respuesta.esStock,
          ),
        );
        _cargando = false;
      });
      _scrollHaciaAbajo();
    }
  }

  void _scrollHaciaAbajo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          ChatHeader(esAdmin: widget.esAdmin),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _mensajes.length,
              itemBuilder: (context, index) {
                final item = _mensajes[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.texto.isNotEmpty)
                      ChatBurbuja(texto: item.texto, esUsuario: item.esUsuario),
                    for (final p in item.productos)
                      item.esStock
                          ? TarjetaStock(
                              key: ValueKey('stock_${p.idProducto}'),
                              producto: p,
                            )
                          : ChatProductoTarjeta(producto: p),
                  ],
                );
              },
            ),
          ),
          if (_cargando)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFFF8FAB), // ROSADO PASTEL
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'El asesor esta respondiendo...',
                    style: TextStyle(color: Colors.black45, fontSize: 12),
                  ),
                ],
              ),
            ),
          ChatInputField(
            controller: _controller,
            cargando: _cargando,
            onEnviar: _enviarMensaje,
          ),
        ],
      ),
    );
  }
}