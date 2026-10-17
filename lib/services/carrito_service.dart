import 'package:flutter/foundation.dart';
import '../models/carrito_item.dart';

class CarritoService extends ChangeNotifier {
  CarritoService._();
  static final CarritoService instancia = CarritoService._();

  final List<CarritoItem> _items = [];

  List<CarritoItem> get items => List.unmodifiable(_items);
  List<CarritoItem> get seleccionados =>
      _items.where((i) => i.seleccionado).toList();

  /// Suma solo los productos seleccionados
  int get total => seleccionados.fold(0, (suma, i) => suma + i.subtotal);

  /// Agrega un producto. Si ya estaba, le suma la cantidad.
  void agregar(CarritoItem nuevo) {
    final indice = _items.indexWhere((i) => i.id == nuevo.id);
    if (indice >= 0) {
      _items[indice].cantidad += nuevo.cantidad;
    } else {
      _items.add(nuevo);
    }
    notifyListeners();
  }

  void sumar(CarritoItem item) {
    item.cantidad++;
    notifyListeners();
  }

  void restar(CarritoItem item) {
    if (item.cantidad > 1) {
      item.cantidad--;
      notifyListeners();
    }
  }

  void seleccionar(CarritoItem item, bool valor) {
    item.seleccionado = valor;
    notifyListeners();
  }

  void eliminar(CarritoItem item) {
    _items.remove(item);
    notifyListeners();
  }

  /// Úsalo cuando el pedido ya se confirmó
  void quitarSeleccionados() {
    _items.removeWhere((i) => i.seleccionado);
    notifyListeners();
  }
}