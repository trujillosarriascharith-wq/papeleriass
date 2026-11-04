
// import 'package:flutter/material.dart';
// import '../widgets/BarraInferior.dart';
// import '../models/carrito_item.dart';
// import '../models/producto_model.dart';
// import '../services/carrito_service.dart';
// import '../theme/colores.dart';
// import '../theme/estilostextos.dart';

// /// Tarjeta de producto para las pantallas de categoría:
// /// foto, descripción, precio, contador (- 1 +) y botón "Agregar al carrito".
// /// Al tocar la foto se abre en grande (con zoom).
// class TarjetaProducto extends StatefulWidget {
//   final ProductoModel producto;

//   const TarjetaProducto({super.key, required this.producto});

//   @override
//   State<TarjetaProducto> createState() => _TarjetaProductoState();
// }

// class _TarjetaProductoState extends State<TarjetaProducto> {
//   int _cantidad = 1;
//   bool _agregando = false;

//   // Disponible si está activo y queda stock
//   bool get _disponible =>
//       widget.producto.cantidadStock > 0 &&
//       widget.producto.estado.toLowerCase() == 'activo';

//   // ¿El usuario ya inició sesión? (se activa en InicioSesion al hacer login)
//   bool get _haIniciadoSesion => BarraInferior.sesionIniciada;

//   void _aviso(String mensaje) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context)
//       ..hideCurrentSnackBar()
//       ..showSnackBar(
//         SnackBar(
//           content: Text(mensaje),
//           backgroundColor: AppColors.botonAgregar,
//           duration: const Duration(seconds: 2),
//         ),
//       );
//   }

//   void _sumar() {
//     if (_cantidad < widget.producto.cantidadStock) {
//       setState(() => _cantidad++);
//     } else {
//       _aviso('Solo hay ${widget.producto.cantidadStock} disponibles');
//     }
//   }

//   void _restar() {
//     if (_cantidad > 1) setState(() => _cantidad--);
//   }

//   Future<void> _agregarAlCarrito() async {
//     // Si no hay sesión iniciada, se avisa y no se agrega nada
//     if (!_haIniciadoSesion) {
//       _aviso('Debes iniciar sesión para agregar productos al carrito');
//       return;
//     }

//     final p = widget.producto;
//     setState(() => _agregando = true);

//     // El carrito se guarda en la base de datos; devuelve null si salió bien
//     final error = await CarritoService.instancia.agregar(
//       CarritoItem(
//         id: p.idProducto.toString(),
//         nombre: p.nombre,
//         descripcion: p.descripcion,
//         precio: p.precio,
//         imagen: p.imagen,
//         cantidad: _cantidad,
//         stock: p.cantidadStock, // tope de piezas disponibles
//       ),
//     );

//     if (!mounted) return;
//     setState(() => _agregando = false);

//     if (error != null) {
//       _aviso(error);
//       return;
//     }
//     _aviso('${p.nombre} agregado al carrito');
//     setState(() => _cantidad = 1);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: const [
//           BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
//         ],
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _foto(),
//           const SizedBox(width: 12),
//           Expanded(child: _informacion()),
//         ],
//       ),
//     );
//   }

//   // ---------- Imagen ----------

//   /// Dibuja la imagen (red o asset). Se usa en la tarjeta y en la vista grande.
//   Widget _imagen(
//     String img, {
//     double? ancho,
//     double? alto,
//     BoxFit fit = BoxFit.cover,
//   }) {
//     final error = Container(
//       width: ancho,
//       height: alto,
//       color: AppColors.fondoComponente,
//       child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
//     );

//     if (img.isEmpty) return error;

//     if (img.startsWith('http')) {
//       return Image.network(
//         img,
//         width: ancho,
//         height: alto,
//         fit: fit,
//         errorBuilder: (_, __, ___) => error,
//         loadingBuilder: (_, child, progreso) {
//           if (progreso == null) return child;
//           return SizedBox(
//             width: ancho,
//             height: alto,
//             child: const Center(child: CircularProgressIndicator()),
//           );
//         },
//       );
//     }

//     return Image.asset(
//       img,
//       width: ancho,
//       height: alto,
//       fit: fit,
//       errorBuilder: (_, __, ___) => error,
//     );
//   }

//   /// Foto pequeña de la tarjeta; al tocarla se abre en grande.
//   Widget _foto() {
//     const tamano = 110.0;
//     final img = widget.producto.imagen;

//     return GestureDetector(
//       onTap: img.isEmpty ? null : _verImagenGrande,
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(10),
//         child: _imagen(img, ancho: tamano, alto: tamano),
//       ),
//     );
//   }

//   /// Abre la imagen en grande. Se puede hacer zoom con los dedos (pellizcar)
//   /// y se cierra tocando fuera de la imagen o con la X.
//   void _verImagenGrande() {
//     final img = widget.producto.imagen;
//     if (img.isEmpty) return;

//     showDialog(
//       context: context,
//       barrierColor: Colors.black87,
//       builder: (ctx) => Dialog(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         insetPadding: const EdgeInsets.all(12),
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             InteractiveViewer(
//               minScale: 1,
//               maxScale: 5,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: _imagen(img, fit: BoxFit.contain),
//               ),
//             ),
//             Positioned(
//               top: 0,
//               right: 0,
//               child: IconButton(
//                 onPressed: () => Navigator.of(ctx).pop(),
//                 icon: const Icon(Icons.close_rounded),
//                 color: Colors.white,
//                 iconSize: 28,
//                 tooltip: 'Cerrar',
//                 style: IconButton.styleFrom(backgroundColor: Colors.black54),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ---------- Información ----------

//   Widget _informacion() {
//     final p = widget.producto;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Descripción:', style: Estilostextos.estilosLetra),
//         const SizedBox(height: 4),
//         for (final linea in p.descripcion)
//           Padding(
//             padding: const EdgeInsets.only(bottom: 2),
//             child: Text(
//               '•  $linea',
//               style: Estilostextos.estilosLetra.copyWith(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         const SizedBox(height: 6),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               formatearPrecio(p.precio),
//               style: Estilostextos.estilosTitulo.copyWith(fontSize: 17),
//             ),
//             if (_disponible) _contador(),
//           ],
//         ),
//         const SizedBox(height: 8),
//         SizedBox(
//           width: double.infinity,
//           height: 38,
//           child: ElevatedButton(
//             onPressed: (_disponible && !_agregando) ? _agregarAlCarrito : null,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.botonAgregar,
//               foregroundColor: Colors.black,
//               disabledBackgroundColor: Colors.grey.shade300,
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(19),
//               ),
//             ),
//             child: FittedBox(
//               fit: BoxFit.scaleDown,
//               child: Text(
//                 _disponible ? 'Agregar al carrito' : 'Agotado',
//                 style: Estilostextos.estilosLetra,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // Botón rosa "-  1  +"
//   Widget _contador() {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.botonAgregar,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           InkWell(
//             onTap: _restar,
//             borderRadius: BorderRadius.circular(8),
//             child: const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               child: Icon(Icons.remove, size: 16, color: Colors.black),
//             ),
//           ),
//           Text('$_cantidad', style: Estilostextos.estilosLetra),
//           InkWell(
//             onTap: _sumar,
//             borderRadius: BorderRadius.circular(8),
//             child: const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               child: Icon(Icons.add, size: 16, color: Colors.black),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import '../widgets/BarraInferior.dart';
// import '../models/carrito_item.dart';
// import '../models/producto_model.dart';
// import '../services/carrito_service.dart';
// import '../theme/colores.dart';
// import '../theme/estilostextos.dart';

// /// Tarjeta de producto para las pantallas de categoría:
// /// foto, descripción, precio, contador (- 1 +) y botón "Agregar al carrito".
// /// Al tocar la foto se abre en grande (con zoom).
// class TarjetaProducto extends StatefulWidget {
//   final ProductoModel producto;

//   const TarjetaProducto({super.key, required this.producto});

//   @override
//   State<TarjetaProducto> createState() => _TarjetaProductoState();
// }

// class _TarjetaProductoState extends State<TarjetaProducto> {
//   int _cantidad = 1;
//   bool _agregando = false;

//   // Disponible si está activo y queda stock
//   bool get _disponible =>
//       widget.producto.cantidadStock > 0 &&
//       widget.producto.estado.toLowerCase() == 'activo';

//   // ¿El usuario ya inició sesión? (se activa en InicioSesion al hacer login)
//   bool get _haIniciadoSesion => BarraInferior.sesionIniciada;

//   void _aviso(String mensaje) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context)
//       ..hideCurrentSnackBar()
//       ..showSnackBar(
//         SnackBar(
//           content: Text(mensaje),
//           backgroundColor: AppColors.botonAgregar,
//           duration: const Duration(seconds: 2),
//         ),
//       );
//   }

//   void _sumar() {
//     if (_cantidad < widget.producto.cantidadStock) {
//       setState(() => _cantidad++);
//     } else {
//       _aviso('Solo hay ${widget.producto.cantidadStock} disponibles');
//     }
//   }

//   void _restar() {
//     if (_cantidad > 1) setState(() => _cantidad--);
//   }

//   Future<void> _agregarAlCarrito() async {
//     // Si no hay sesión iniciada, se avisa y no se agrega nada
//     if (!_haIniciadoSesion) {
//       _aviso('Debes iniciar sesión para agregar productos al carrito');
//       return;
//     }

//     final p = widget.producto;
//     setState(() => _agregando = true);

//     // El carrito se guarda en la base de datos; devuelve null si salió bien
//     final error = await CarritoService.instancia.agregar(
//       CarritoItem(
//         id: p.idProducto.toString(),
//         nombre: p.nombre,
//         descripcion: p.descripcion,
//         precio: p.precio,
//         imagen: p.imagen,
//         cantidad: _cantidad,
//         stock: p.cantidadStock, // tope de piezas disponibles
//       ),
//     );

//     if (!mounted) return;
//     setState(() => _agregando = false);

//     if (error != null) {
//       _aviso(error);
//       return;
//     }
//     _aviso('${p.nombre} agregado al carrito');
//     setState(() => _cantidad = 1);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: const [
//           BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
//         ],
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _foto(),
//           const SizedBox(width: 12),
//           Expanded(child: _informacion()),
//         ],
//       ),
//     );
//   }

//   // ---------- Imagen ----------

//   /// Dibuja la imagen (red o asset). Se usa en la tarjeta y en la vista grande.
//   Widget _imagen(
//     String img, {
//     double? ancho,
//     double? alto,
//     BoxFit fit = BoxFit.cover,
//   }) {
//     final error = Container(
//       width: ancho,
//       height: alto,
//       color: AppColors.fondoComponente,
//       child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
//     );

//     if (img.isEmpty) return error;

//     if (img.startsWith('http')) {
//       return Image.network(
//         img,
//         width: ancho,
//         height: alto,
//         fit: fit,
//         errorBuilder: (_, __, ___) => error,
//         loadingBuilder: (_, child, progreso) {
//           if (progreso == null) return child;
//           return SizedBox(
//             width: ancho,
//             height: alto,
//             child: const Center(child: CircularProgressIndicator()),
//           );
//         },
//       );
//     }

//     return Image.asset(
//       img,
//       width: ancho,
//       height: alto,
//       fit: fit,
//       errorBuilder: (_, __, ___) => error,
//     );
//   }

//   /// Foto pequeña de la tarjeta; al tocarla se abre en grande.
//   Widget _foto() {
//     const tamano = 110.0;
//     final img = widget.producto.imagen;

//     return GestureDetector(
//       onTap: img.isEmpty ? null : _verImagenGrande,
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(10),
//         child: _imagen(img, ancho: tamano, alto: tamano),
//       ),
//     );
//   }

//   /// Abre la imagen en grande. Se puede hacer zoom con los dedos (pellizcar)
//   /// y se cierra tocando fuera de la imagen o con la X.
//   void _verImagenGrande() {
//     final img = widget.producto.imagen;
//     if (img.isEmpty) return;

//     showDialog(
//       context: context,
//       barrierColor: Colors.black87,
//       builder: (ctx) => Dialog(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         insetPadding: const EdgeInsets.all(12),
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             InteractiveViewer(
//               minScale: 1,
//               maxScale: 5,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: _imagen(img, fit: BoxFit.contain),
//               ),
//             ),
//             Positioned(
//               top: 0,
//               right: 0,
//               child: IconButton(
//                 onPressed: () => Navigator.of(ctx).pop(),
//                 icon: const Icon(Icons.close_rounded),
//                 color: Colors.white,
//                 iconSize: 28,
//                 tooltip: 'Cerrar',
//                 style: IconButton.styleFrom(backgroundColor: Colors.black54),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ---------- Información ----------

//   Widget _informacion() {
//     final p = widget.producto;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Nombre del producto (el mismo con que se guardó en el inventario)
//         Text(
//           p.nombre,
//           style: Estilostextos.estilosTitulo.copyWith(fontSize: 16),
//         ),
//         const SizedBox(height: 6),
//         Text('Descripción:', style: Estilostextos.estilosLetra),
//         const SizedBox(height: 4),
//         for (final linea in p.descripcion)
//           Padding(
//             padding: const EdgeInsets.only(bottom: 2),
//             child: Text(
//               '•  $linea',
//               style: Estilostextos.estilosLetra.copyWith(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         const SizedBox(height: 6),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               formatearPrecio(p.precio),
//               style: Estilostextos.estilosTitulo.copyWith(fontSize: 17),
//             ),
//             if (_disponible) _contador(),
//           ],
//         ),
//         const SizedBox(height: 8),
//         SizedBox(
//           width: double.infinity,
//           height: 38,
//           child: ElevatedButton(
//             onPressed: (_disponible && !_agregando) ? _agregarAlCarrito : null,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.botonAgregar,
//               foregroundColor: Colors.black,
//               disabledBackgroundColor: Colors.grey.shade300,
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(19),
//               ),
//             ),
//             child: FittedBox(
//               fit: BoxFit.scaleDown,
//               child: Text(
//                 _disponible ? 'Agregar al carrito' : 'Agotado',
//                 style: Estilostextos.estilosLetra,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // Botón rosa "-  1  +"
//   Widget _contador() {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.botonAgregar,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           InkWell(
//             onTap: _restar,
//             borderRadius: BorderRadius.circular(8),
//             child: const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               child: Icon(Icons.remove, size: 16, color: Colors.black),
//             ),
//           ),
//           Text('$_cantidad', style: Estilostextos.estilosLetra),
//           InkWell(
//             onTap: _sumar,
//             borderRadius: BorderRadius.circular(8),
//             child: const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               child: Icon(Icons.add, size: 16, color: Colors.black),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../widgets/BarraInferior.dart';
import '../models/carrito_item.dart';
import '../models/producto_model.dart';
import '../services/carrito_service.dart';
import '../theme/colores.dart';
import '../theme/estilostextos.dart';

/// Tarjeta de producto para las pantallas de categoría.
/// Diseño: foto grande a la izquierda (ocupa toda la altura, recortada con
/// bordes redondeados) y a la derecha nombre, descripción, precio,
/// contador (- 1 +) y botón "Agregar al carrito".
/// Al tocar la foto se abre en grande (con zoom).
class TarjetaProducto extends StatefulWidget {
  final ProductoModel producto;

  const TarjetaProducto({super.key, required this.producto});

  @override
  State<TarjetaProducto> createState() => _TarjetaProductoState();
}

class _TarjetaProductoState extends State<TarjetaProducto> {
  int _cantidad = 1;
  bool _agregando = false;

  // Disponible si está activo y queda stock
  bool get _disponible =>
      widget.producto.cantidadStock > 0 &&
      widget.producto.estado.toLowerCase() == 'activo';

  // ¿El usuario ya inició sesión? (se activa en InicioSesion al hacer login)
  bool get _haIniciadoSesion => BarraInferior.sesionIniciada;

  void _aviso(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: AppColors.botonAgregar,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _sumar() {
    if (_cantidad < widget.producto.cantidadStock) {
      setState(() => _cantidad++);
    } else {
      _aviso('Solo hay ${widget.producto.cantidadStock} disponibles');
    }
  }

  void _restar() {
    if (_cantidad > 1) setState(() => _cantidad--);
  }

  Future<void> _agregarAlCarrito() async {
    // Si no hay sesión iniciada, se avisa y no se agrega nada
    if (!_haIniciadoSesion) {
      _aviso('Debes iniciar sesión para agregar productos al carrito');
      return;
    }

    final p = widget.producto;
    setState(() => _agregando = true);

    // El carrito se guarda en la base de datos; devuelve null si salió bien
    final error = await CarritoService.instancia.agregar(
      CarritoItem(
        id: p.idProducto.toString(),
        nombre: p.nombre,
        descripcion: p.descripcion,
        precio: p.precio,
        imagen: p.imagen,
        cantidad: _cantidad,
        stock: p.cantidadStock, // tope de piezas disponibles
      ),
    );

    if (!mounted) return;
    setState(() => _agregando = false);

    if (error != null) {
      _aviso(error);
      return;
    }
    _aviso('${p.nombre} agregado al carrito');
    setState(() => _cantidad = 1);
  }

  // ---------- Tarjeta ----------

  @override
  Widget build(BuildContext context) {
    return Container(
      // Margen un poco mayor para que la sombra no se corte con la pantalla
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      padding: const EdgeInsets.all(10),
      constraints: const BoxConstraints(minHeight: 210),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        // Borde fino para definir el contorno de la tarjeta
        border: Border.all(color: Colors.black.withOpacity(0.06), width: 1),
        boxShadow: [
          // Sombra difusa que rodea todo el borde
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 0),
          ),
          // Sombra inferior más marcada para dar profundidad
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      // IntrinsicHeight + stretch: la foto se estira a todo el alto de la tarjeta
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 5, child: _foto()),
            const SizedBox(width: 14),
            Expanded(flex: 7, child: _informacion()),
          ],
        ),
      ),
    );
  }

  // ---------- Imagen ----------

  /// Dibuja la imagen (red o asset). Se usa en la tarjeta y en la vista grande.
  Widget _imagen(
    String img, {
    double? ancho,
    double? alto,
    BoxFit fit = BoxFit.cover,
  }) {
    final error = Container(
      width: ancho,
      height: alto,
      color: AppColors.fondoComponente,
      child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
    );

    if (img.isEmpty) return error;

    if (img.startsWith('http')) {
      return Image.network(
        img,
        width: ancho,
        height: alto,
        fit: fit,
        errorBuilder: (_, __, ___) => error,
        loadingBuilder: (_, child, progreso) {
          if (progreso == null) return child;
          return SizedBox(
            width: ancho,
            height: alto,
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      );
    }

    return Image.asset(
      img,
      width: ancho,
      height: alto,
      fit: fit,
      errorBuilder: (_, __, ___) => error,
    );
  }

  /// Foto grande de la tarjeta (recortada para llenar todo el espacio).
  /// Al tocarla se abre en grande.
  Widget _foto() {
    final img = widget.producto.imagen;

    return GestureDetector(
      onTap: img.isEmpty ? null : _verImagenGrande,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: _imagen(
                img,
                ancho: double.infinity,
                alto: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            // Iconito que indica que la foto se puede ampliar
            if (img.isNotEmpty)
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.zoom_out_map_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Abre la imagen en grande. Se puede hacer zoom con los dedos (pellizcar)
  /// y se cierra tocando fuera de la imagen o con la X.
  void _verImagenGrande() {
    final img = widget.producto.imagen;
    if (img.isEmpty) return;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _imagen(img, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: () => Navigator.of(ctx).pop(),
                icon: const Icon(Icons.close_rounded),
                color: Colors.white,
                iconSize: 28,
                tooltip: 'Cerrar',
                style: IconButton.styleFrom(backgroundColor: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Información ----------

  Widget _informacion() {
    final p = widget.producto;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nombre del producto
        Text(
          p.nombre,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Estilostextos.estilosTitulo.copyWith(
            fontSize: 18,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),

        // Descripción
        Text(
          'DESCRIPCIÓN',
          style: Estilostextos.estilosLetra.copyWith(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: Colors.black45,
          ),
        ),
        const SizedBox(height: 4),
        for (final linea in p.descripcion)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              '•  $linea',
              style: Estilostextos.estilosLetra.copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                height: 1.25,
                color: Colors.black87,
              ),
            ),
          ),

        // Empuja precio y botón hacia abajo cuando sobra espacio
        const Spacer(),
        const SizedBox(height: 10),

        // Precio + contador
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  formatearPrecio(p.precio),
                  style: Estilostextos.estilosTitulo.copyWith(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 6),
            if (_disponible) _contador(),
          ],
        ),
        const SizedBox(height: 10),

        // Botón
        SizedBox(
          width: double.infinity,
          height: 42,
          child: ElevatedButton(
            onPressed: (_disponible && !_agregando) ? _agregarAlCarrito : null,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.botonAgregar,
              foregroundColor: Colors.black,
              disabledBackgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(21),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _disponible ? 'Agregar al carrito' : 'Agotado',
                style: Estilostextos.estilosLetra.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Botón rosa "-  1  +"
  Widget _contador() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.botonAgregar,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _restar,
            borderRadius: BorderRadius.circular(10),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 7, vertical: 5),
              child: Icon(Icons.remove, size: 16, color: Colors.black),
            ),
          ),
          Text('$_cantidad', style: Estilostextos.estilosLetra),
          InkWell(
            onTap: _sumar,
            borderRadius: BorderRadius.circular(10),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 7, vertical: 5),
              child: Icon(Icons.add, size: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}