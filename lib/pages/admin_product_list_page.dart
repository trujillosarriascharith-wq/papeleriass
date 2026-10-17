import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/producto_model.dart';
import '../services/producto_service.dart';
import '../services/admin_productos_service.dart';
import '../widgets/producto_form_sheet.dart';
import '../widgets/admin_drawer.dart';

// Diálogo de confirmación
Future<bool> _confirmarEliminacion(BuildContext context, String nombre) async {
  final resultado = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Eliminar "$nombre"?'),
      content: const Text('Esta acción no se puede deshacer.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
  return resultado?? false;
}

class AdminProductListPage extends StatefulWidget {
  const AdminProductListPage({super.key});

  @override
  State<AdminProductListPage> createState() => _AdminProductListPageState();
}

class _AdminProductListPageState extends State<AdminProductListPage> {
  static const Color colorPrincipal = Color(0xFF9F6163);

  final ProductoService _productoService = ProductoService();
  late Future<List<ProductoModel>> _productosFuture;

  String _adminNombre = 'Cargando...';
  String _adminEmail = '';

  @override
  void initState() {
    super.initState();
    _productosFuture = _productoService.obtenerProductos();
    _cargarDatosAdmin();
  }

  void _cargarProductos() {
    setState(() {
      _productosFuture = _productoService.obtenerProductos();
    });
  }

  Future<void> _cargarDatosAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _adminNombre = prefs.getString('user_name')?? 'Administrador';
      _adminEmail = prefs.getString('user_email')?? '';
    });
  }

  Future<void> _abrirFormulario(ProductoModel? producto) async {
    final guardado = await ProductoFormSheet.abrir(context, producto: producto);
    if (!guardado ||!mounted) return;
    _cargarProductos();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(producto == null? 'Producto publicado en la carta' : 'Cambios guardados'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _eliminarProducto(ProductoModel producto) async {
    final confirmar = await _confirmarEliminacion(context, producto.nombre);
    if (!confirmar) return;
    try {
      // ADAPTADO A TU MODELO: idProducto es int
      await AdminProductosService.eliminarProducto(producto.idProducto);
      _cargarProductos();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // SOPORTE Image.file + Image.network (NO TOCADO COMO PEDISTE)
  Widget _imagenProducto(String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        color: Colors.pink.shade50,
        child: const Icon(Icons.icecream_rounded, color: Color(0xFF9F6163)),
      );
    }

    final bool esUrlWeb = url.startsWith('http://') || url.startsWith('https://');

    if (esUrlWeb) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey),
      );
    } else {
      return Image.file(
        File(url),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF4F8),
      appBar: AppBar(
        title: const Text('Panel de Administración',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: colorPrincipal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: AdminDrawer(adminNombre: _adminNombre, adminEmail: _adminEmail),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorPrincipal,
        foregroundColor: Colors.white,
        tooltip: 'Nuevo producto',
        onPressed: () => _abrirFormulario(null),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        color: colorPrincipal,
        onRefresh: () async => _cargarProductos(),
        child: FutureBuilder<List<ProductoModel>>(
          future: _productosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: colorPrincipal));
            }

            final productos = snapshot.data?? [];

            if (snapshot.hasError || productos.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 160),
                  Center(
                    child: Text(
                      snapshot.hasError? 'Error: ${snapshot.error}' : 'No hay productos registrados.',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: productos.length,
              itemBuilder: (_, i) {
                final p = productos[i];
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(width: 56, height: 56, child: _imagenProducto(p.imagen)),
                    ),
                    title: Text(
                      p.nombre.isEmpty? 'Sin nombre' : p.nombre,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '\$${p.precio} - Stock: ${p.cantidadStock}',
                      style: const TextStyle(color: colorPrincipal),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Editar',
                          icon: const Icon(Icons.edit, color: colorPrincipal),
                          onPressed: () => _abrirFormulario(p),
                        ),
                        IconButton(
                          tooltip: 'Eliminar',
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _eliminarProducto(p),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}