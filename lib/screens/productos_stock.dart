import 'package:flutter/material.dart';
import 'package:papelerias/screens/perfil_admin.dart';
import '../models/producto_model.dart';
import '../theme/colores.dart';
import '../theme/estilostextos.dart';
import '../widgets/BarraInferior.dart';
import '../widgets/encabezado_admin.dart';
import '../widgets/fondodegradado.dart';
import '../widgets/menu_lateral_admin.dart';
import '../widgets/panel_gris.dart';
import '../widgets/tarjetastock.dart';

/// Productos con pocas unidades. Aparecen solos cuando el stock baja.
class PantallaProductosStock extends StatefulWidget {
  const PantallaProductosStock({super.key});

  /// Un producto se considera "bajo de stock" cuando le quedan
  /// esta cantidad de unidades o menos. Cámbiala si quieres otro límite.
  static const int umbralStockBajo = 5;

  @override
  State<PantallaProductosStock> createState() => _PantallaProductosStockState();
}

class _PantallaProductosStockState extends State<PantallaProductosStock> {
  List<ProductoModel> _productos = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  /// Trae los productos del inventario.
  Future<List<ProductoModel>> _pedirProductos() async {
    // TODO: pedir al backend todos los productos del inventario,
    // por ejemplo con tu producto_service.dart.
    return [];
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final todos = await _pedirProductos();

      // Solo los activos con pocas unidades, del que menos tiene al que más
      final bajos = todos
          .where((p) =>
              p.estado.toLowerCase() == 'activo' &&
              p.cantidadStock <= PantallaProductosStock.umbralStockBajo)
          .toList()
        ..sort((a, b) => a.cantidadStock.compareTo(b.cantidadStock));

      if (mounted) setState(() => _productos = bajos);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  // ---------- Navegación ----------

  // Vuelve a la pantalla principal del administrador
  void _irAlInicio() {
    Navigator.popUntil(context, (ruta) => ruta.isFirst);
  }

  void _abrirPerfil() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PerfilAdmin()),
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

    // Ningún producto con pocas unidades: no se muestra nada
    if (_productos.isEmpty) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        itemCount: _productos.length,
        itemBuilder: (_, i) => TarjetaStock(
          key: ValueKey(_productos[i].idProducto),
          producto: _productos[i],
        ),
      ),
    );
  }

  // Panel gris con el título "Stock" y la lista
  Widget _panel() {
    return PanelGris(
      child: Column(
        children: [
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Stock', style: Estilostextos.estilosTitulo),
              const SizedBox(width: 12),
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFE59A00),
                size: 36,
              ),
            ],
          ),
          Expanded(child: _contenido()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      drawer: const MenuLateralAdmin(opcionActiva: 'Productos en stock'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              FondoDegradado(
                alto: 100,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                child: const EncabezadoAdmin(),
              ),
              Expanded(child: _panel()),
            ],
          ),
        ),
      ),
      // Barra inferior del administrador: Inicio y Perfil
      bottomNavigationBar: BarraInferior(
        onInicio: _irAlInicio,
        onPerfil: _abrirPerfil,
      ),
    );
  }
}