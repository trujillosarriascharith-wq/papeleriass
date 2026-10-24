import 'package:flutter/material.dart';
import 'package:papelerias/screens/carrito_screen.dart';
import 'package:papelerias/screens/contactenos.dart';
import 'package:papelerias/screens/perfil_screen.dart';
import '../models/producto_model.dart';
import '../services/producto_service.dart';
import '../theme/colores.dart';
import '../theme/estilostextos.dart';
import '../widgets/BarraInferior.dart';
import '../widgets/fondodegradado.dart';
import '../widgets/menu_lateral.dart';
import '../widgets/tarjetaproducto.dart';

/// Pantalla genérica de una categoría (Cuadernos, Colores, Cartucheras...).
/// Solo cambian el [titulo] y el [idCategoria] con el que se piden los productos.
class PantallaCategoria extends StatefulWidget {
  final String titulo; // lo que se ve arriba, ej: "Cuadernos"
  final int idCategoria; // id_categoria de la tabla de categorías

  const PantallaCategoria({
    super.key,
    required this.titulo,
    required this.idCategoria,
  });

  @override
  State<PantallaCategoria> createState() => _PantallaCategoriaState();
}

class _PantallaCategoriaState extends State<PantallaCategoria> {
  List<ProductoModel> _productos = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  /// Trae del servidor solo los productos de esta categoría.
  Future<List<ProductoModel>> _pedirProductos() async {
    final todos = await ProductoService.listar(idCategoria: widget.idCategoria);
    // Los clientes ven los productos activos y los agotados (estos con el
    // botón "Agotado"). Los inactivos no se muestran.
    return todos.where((p) {
      final e = p.estado.toLowerCase();
      return e == 'activo' || e == 'agotado';
    }).toList();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final datos = await _pedirProductos();
      if (mounted) setState(() => _productos = datos);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  // ---------- Navegación ----------

  void _irAlInicio() {
    Navigator.popUntil(context, (ruta) => ruta.isFirst);
  }

  void _abrirPerfil() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PerfilScreen()),
    );
  }

  void _abrirCarrito() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PantallaCarrito()),
    );
  }

  void _abrirContactenos() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PantallaContactenos()),
    );
  }

  // ---------- Widgets ----------

  Widget _contenido() {
    if (_cargando) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            TextButton(onPressed: _cargar, child: const Text('Reintentar')),
          ],
        ),
      );
    }

    // Sin productos todavía: no se muestra nada
    if (_productos.isEmpty) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _productos.length,
        itemBuilder: (_, i) => TarjetaProducto(
          key: ValueKey(_productos[i].idProducto),
          producto: _productos[i],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      drawer: MenuLateral(categoriaActiva: widget.titulo),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              FondoDegradado(
                alto: 120,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                child: _encabezado(),
              ),
              const SizedBox(height: 16),
              Text(widget.titulo, style: Estilostextos.estilosTitulo),
              const SizedBox(height: 8),
              Expanded(child: _contenido()),
            ],
          ),
        ),
      ),
      // Barra inferior: Inicio, Perfil, Carrito y Contáctenos
      bottomNavigationBar: BarraInferior(
        onInicio: _irAlInicio,
        onPerfil: _abrirPerfil,
        onCarrito: _abrirCarrito,
        onContacto: _abrirContactenos,
      ),
    );
  }

  // Mismo encabezado del carrito: [menú] [logo] [texto] [inicio]
  Widget _encabezado() {
    const iconConstraints = BoxConstraints(minWidth: 40, minHeight: 40);

    return Row(
      children: [
        Builder(
          builder: (ctx) => IconButton(
            onPressed: () => Scaffold.of(ctx).openDrawer(),
            icon: const Icon(Icons.menu_rounded),
            iconSize: 30,
            color: Colors.white,
            tooltip: 'Menú',
            padding: EdgeInsets.zero,
            constraints: iconConstraints,
          ),
        ),
        const SizedBox(width: 4),
        const CircleAvatar(
          radius: 32,
          backgroundColor: Colors.white,
          backgroundImage: AssetImage('assets/images/logo2.png'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Papelería y Variedades\nJuan José',
              textAlign: TextAlign.center,
              style: Estilostextos.estilosBienvenida,
            ),
          ),
        ),
        IconButton(
          onPressed: _irAlInicio,
          icon: const Icon(Icons.home_rounded),
          iconSize: 28,
          color: Colors.white,
          tooltip: 'Volver al inicio',
          padding: EdgeInsets.zero,
          constraints: iconConstraints,
        ),
      ],
    );
  }
}
