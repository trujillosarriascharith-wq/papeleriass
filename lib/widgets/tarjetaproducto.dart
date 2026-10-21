import 'package:flutter/material.dart';
import '../widgets/BarraInferior.dart';
import '../models/carrito_item.dart';
import '../models/producto_model.dart';
import '../services/carrito_service.dart';
import '../theme/colores.dart';
import '../theme/estilostextos.dart';

/// Tarjeta de producto para las pantallas de categoría:
/// foto, descripción, precio, contador (- 1 +) y botón "Agregar al carrito".
class TarjetaProducto extends StatefulWidget {
  final ProductoModel producto;

  const TarjetaProducto({super.key, required this.producto});

  @override
  State<TarjetaProducto> createState() => _TarjetaProductoState();
}

class _TarjetaProductoState extends State<TarjetaProducto> {
  int _cantidad = 1;

  // Disponible si está activo y queda stock
  bool get _disponible =>
      widget.producto.cantidadStock > 0 &&
      widget.producto.estado.toLowerCase() == 'activo';

  // ¿El usuario ya inició sesión? (se activa en InicioSesion al hacer login)
  bool get _haIniciadoSesion => BarraInferior.sesionIniciada;

  void _aviso(String mensaje) {
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

  void _agregarAlCarrito() {
    // Si no hay sesión iniciada, se avisa y no se agrega nada
    if (!_haIniciadoSesion) {
      _aviso('Debes iniciar sesión para agregar productos al carrito');
      return;
    }

    final p = widget.producto;

    CarritoService.instancia.agregar(
      CarritoItem(
        id: p.idProducto.toString(),
        nombre: p.nombre,
        descripcion: p.descripcion,
        precio: p.precio,
        imagen: p.imagen,
        cantidad: _cantidad,
      ),
    );

    _aviso('${p.nombre} agregado al carrito');
    setState(() => _cantidad = 1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _foto(),
          const SizedBox(width: 12),
          Expanded(child: _informacion()),
        ],
      ),
    );
  }

  Widget _foto() {
    const tamano = 110.0;
    final img = widget.producto.imagen;
    final error = Container(
      width: tamano,
      height: tamano,
      color: AppColors.fondoComponente,
      child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: img.startsWith('http')
          ? Image.network(img,
              width: tamano, height: tamano, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => error)
          : img.isEmpty
              ? error
              : Image.asset(img,
                  width: tamano, height: tamano, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => error),
    );
  }

  Widget _informacion() {
    final p = widget.producto;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Descripción:', style: Estilostextos.estilosLetra),
        const SizedBox(height: 4),
        for (final linea in p.descripcion)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              '•  $linea',
              style: Estilostextos.estilosLetra.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formatearPrecio(p.precio),
              style: Estilostextos.estilosTitulo.copyWith(fontSize: 17),
            ),
            if (_disponible) _contador(),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 38,
          child: ElevatedButton(
            onPressed: _disponible ? _agregarAlCarrito : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.botonAgregar,
              foregroundColor: Colors.black,
              disabledBackgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(19),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _disponible ? 'Agregar al carrito' : 'Agotado',
                style: Estilostextos.estilosLetra,
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
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _restar,
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Icon(Icons.remove, size: 16, color: Colors.black),
            ),
          ),
          Text('$_cantidad', style: Estilostextos.estilosLetra),
          InkWell(
            onTap: _sumar,
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Icon(Icons.add, size: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}