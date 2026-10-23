/// Un producto dentro del carrito.
class CarritoItem {
  final String id;
  final String nombre;
  final List<String> descripcion; // ej: ['Marca Scribe', 'Cuadriculado', '100 Hojas']
  final int precio; // precio de UNA unidad, en pesos
  final String imagen; // URL (http...) o ruta de asset
  int cantidad;
  bool seleccionado;
  int stock; // piezas disponibles en el inventario (tope de la cantidad)
  int? idDetalle; // id de la fila en detalle_carrito (la asigna el servidor)

  CarritoItem({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagen,
    this.cantidad = 1,
    this.seleccionado = true,
    this.stock = 999999,
    this.idDetalle,
  });

  int get subtotal => precio * cantidad;
}

/// 2000 -> $2.000
String formatearPrecio(int valor) {
  final s = valor.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return '\$$b';
}