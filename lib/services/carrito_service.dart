import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/carrito_item.dart';
import 'api_config.dart';
import 'sesion.dart';

/// Carrito del cliente. Se guarda en la base de datos (/api/carrito), así que
/// sobrevive al cerrar la app y funciona en cualquier dispositivo.
/// Las operaciones que hablan con el servidor devuelven null si salió bien,
/// o el mensaje de error para mostrárselo al usuario.
class CarritoService extends ChangeNotifier {
  CarritoService._();
  static final CarritoService instancia = CarritoService._();

  final List<CarritoItem> _items = [];
  bool _cargando = false;

  List<CarritoItem> get items => List.unmodifiable(_items);
  List<CarritoItem> get seleccionados =>
      _items.where((i) => i.seleccionado).toList();
  bool get cargando => _cargando;

  /// Suma solo los productos seleccionados
  int get total => seleccionados.fold(0, (suma, i) => suma + i.subtotal);

  // ---------- Ayudas internas ----------

  static String get _url => '${ApiConfig.baseUrl}/api/carrito';

  static Future<String> _token() async {
    if (Sesion.activa) return Sesion.token!;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  // Cabeceras con el token, o null si no hay sesión
  static Future<Map<String, String>?> _cabeceras() async {
    final token = await _token();
    if (token.isEmpty) return null;
    return {...ApiConfig.headers, 'Authorization': 'Bearer $token'};
  }

  static String _mensajeError(http.Response r, String porDefecto) {
    try {
      final d = jsonDecode(r.body);
      return (d['error'] ?? d['message'] ?? porDefecto).toString();
    } catch (_) {
      return porDefecto;
    }
  }

  static int _aInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static List<String> _aLista(dynamic v) {
    if (v is List) return v.map((e) => e.toString()).toList();
    if (v is String && v.isNotEmpty) {
      return v.split(', ').where((l) => l.trim().isNotEmpty).toList();
    }
    return [];
  }

  // ---------- Cargar ----------

  /// Trae el carrito guardado en el servidor (con las casillas marcadas
  /// que se guardaron) y reemplaza la lista local.
  Future<void> cargar() async {
    final cabeceras = await _cabeceras();
    if (cabeceras == null) {
      limpiarLocal();
      return;
    }

    _cargando = true;
    notifyListeners();
    try {
      final r = await http
          .get(Uri.parse(_url), headers: cabeceras)
          .timeout(const Duration(seconds: 15));
      if (r.statusCode != 200) throw Exception('Error ${r.statusCode}');

      final datos = jsonDecode(r.body);
      final lista = (datos['items'] as List?) ?? [];

      final nuevos = <CarritoItem>[];
      for (final e in lista) {
        final d = e as Map<String, dynamic>;
        final p = d['productos'];
        if (p is! Map) continue; // producto que ya no existe
        nuevos.add(CarritoItem(
          id: '${d['id_producto']}',
          nombre: (p['nombre'] ?? '').toString(),
          descripcion: _aLista(p['descripcion']),
          precio: _aInt(p['precio']),
          imagen: (p['imagen'] ?? '').toString(),
          cantidad: _aInt(d['cantidad']),
          stock: _aInt(p['cantidad_stock']),
          seleccionado: d['seleccionado'] != false, // casilla guardada
          idDetalle: _aInt(d['id_detalle_carrito']),
        ));
      }
      _items
        ..clear()
        ..addAll(nuevos);
    } catch (_) {
      // Sin conexión: se conserva lo que ya había en pantalla
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  // ---------- Operaciones ----------

  /// Agrega un producto (o suma cantidad si ya estaba). Nunca pasa del stock.
  /// Devuelve null si se agregó, o el mensaje de por qué no se pudo.
  Future<String?> agregar(CarritoItem nuevo) async {
    if (nuevo.stock <= 0) return '${nuevo.nombre} está agotado';

    // Revisión rápida en el teléfono (el servidor vuelve a validar)
    final indice = _items.indexWhere((i) => i.id == nuevo.id);
    final enCarrito = indice >= 0 ? _items[indice].cantidad : 0;
    if (enCarrito + nuevo.cantidad > nuevo.stock) {
      return enCarrito >= nuevo.stock
          ? 'No hay más piezas disponibles de ${nuevo.nombre}: ya tienes el máximo en tu carrito'
          : 'Solo hay ${nuevo.stock} disponibles de ${nuevo.nombre} y ya tienes $enCarrito en tu carrito';
    }

    final cabeceras = await _cabeceras();
    if (cabeceras == null) return 'Inicia sesión para agregar productos al carrito';

    try {
      final r = await http
          .post(
            Uri.parse(_url),
            headers: cabeceras,
            body: jsonEncode({
              'id_producto': int.tryParse(nuevo.id),
              'cantidad': nuevo.cantidad,
            }),
          )
          .timeout(const Duration(seconds: 15));

      await cargar(); // sincroniza con lo que quedó guardado
      if (r.statusCode != 200 && r.statusCode != 201) {
        return _mensajeError(r, 'No se pudo agregar al carrito');
      }
      return null;
    } catch (_) {
      return 'No se pudo conectar con el servidor';
    }
  }

  /// Sube la cantidad en 1. Si ya no hay más piezas, devuelve el aviso.
  Future<String?> sumar(CarritoItem item) async {
    if (item.cantidad >= item.stock) {
      return 'No hay más piezas disponibles de este producto';
    }
    return _cambiarCantidad(item, item.cantidad + 1);
  }

  /// Baja la cantidad en 1 (mínimo 1).
  Future<String?> restar(CarritoItem item) async {
    if (item.cantidad <= 1) return null;
    return _cambiarCantidad(item, item.cantidad - 1);
  }
//kkkkkk
  Future<String?> _cambiarCantidad(CarritoItem item, int nueva) async {
    final cabeceras = await _cabeceras();
    if (cabeceras == null || item.idDetalle == null) {
      return 'No se pudo actualizar el carrito';
    }

    final anterior = item.cantidad;
    item.cantidad = nueva; // se ve al instante
    notifyListeners();

    try {
      final r = await http
          .put(
            Uri.parse('$_url/${item.idDetalle}'),
            headers: cabeceras,
            body: jsonEncode({'cantidad': nueva}),
          )
          .timeout(const Duration(seconds: 15));

      if (r.statusCode != 200) {
        item.cantidad = anterior; // se deshace
        notifyListeners();
        final mensaje = _mensajeError(r, 'No se pudo actualizar la cantidad');
        await cargar(); // trae el stock actualizado del servidor
        return mensaje;
      }
      return null;
    } catch (_) {
      item.cantidad = anterior;
      notifyListeners();
      return 'No se pudo conectar con el servidor';
    }
  }

  /// Marca o desmarca un producto para el pedido. Se guarda en el servidor.
  Future<String?> seleccionar(CarritoItem item, bool valor) async {
    final anterior = item.seleccionado;
    item.seleccionado = valor; // se ve al instante
    notifyListeners();

    final cabeceras = await _cabeceras();
    if (cabeceras == null || item.idDetalle == null) return null;

    try {
      final r = await http
          .put(
            Uri.parse('$_url/${item.idDetalle}'),
            headers: cabeceras,
            body: jsonEncode({'seleccionado': valor}),
          )
          .timeout(const Duration(seconds: 15));

      if (r.statusCode != 200) {
        item.seleccionado = anterior; // se deshace
        notifyListeners();
        return _mensajeError(r, 'No se pudo guardar la selección');
      }
      return null;
    } catch (_) {
      item.seleccionado = anterior;
      notifyListeners();
      return 'No se pudo conectar con el servidor';
    }
  }

  /// Quita un producto del carrito (también en el servidor).
  Future<String?> eliminar(CarritoItem item) async {
    final cabeceras = await _cabeceras();
    _items.remove(item); // desaparece al instante
    notifyListeners();

    if (cabeceras == null || item.idDetalle == null) return null;
    try {
      final r = await http
          .delete(Uri.parse('$_url/${item.idDetalle}'), headers: cabeceras)
          .timeout(const Duration(seconds: 15));
      if (r.statusCode != 200) {
        await cargar();
        return _mensajeError(r, 'No se pudo eliminar el producto');
      }
      return null;
    } catch (_) {
      await cargar();
      return 'No se pudo conectar con el servidor';
    }
  }

  /// Úsalo cuando el pedido ya se confirmó: el backend ya los quitó del carrito
  /// guardado, aquí solo se quitan de la pantalla.
  void quitarSeleccionados() {
    _items.removeWhere((i) => i.seleccionado);
    notifyListeners();
  }

  /// Vacía solo la lista local (se usa al cerrar sesión, para que el
  /// siguiente usuario no vea el carrito del anterior).
  void limpiarLocal() {
    _items.clear();
    notifyListeners();
  }
}