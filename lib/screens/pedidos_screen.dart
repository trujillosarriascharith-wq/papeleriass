import 'package:flutter/material.dart';
import 'package:papelerias/screens/contactenos.dart';
import 'package:papelerias/screens/notificaciones.dart';
import 'package:papelerias/screens/perfil_screen.dart';
import '../services/carrito_service.dart';
import '../services/pedido_service.dart';
import '../services/sesion.dart';
import '../theme/colores.dart';
import '../theme/estilostextos.dart';
import '../widgets/BarraInferior.dart';
import '../widgets/botondegradado.dart';
import '../widgets/encabezado_tienda.dart';
import '../widgets/formulario_pedido.dart';
import '../widgets/item_pedido_tarjeta.dart';
import '../widgets/menu_lateral.dart';
import '../widgets/total_pedido.dart';

/// Pedido: productos seleccionados en el carrito + datos de entrega.
class PantallaPedidos extends StatefulWidget {
  const PantallaPedidos({super.key});

  @override
  State<PantallaPedidos> createState() => _PantallaPedidosState();
}

class _PantallaPedidosState extends State<PantallaPedidos> {
  final _nombre = TextEditingController();
  final _direccion = TextEditingController();
  final _telefono = TextEditingController();
  String? _metodoPago;
  bool _enviando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _direccion.dispose();
    _telefono.dispose();
    super.dispose();
  }

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _realizarPedido() async {
    if (_nombre.text.trim().isEmpty ||
        _direccion.text.trim().isEmpty ||
        _telefono.text.trim().isEmpty ||
        _metodoPago == null) {
      _mensaje('Completa todos los datos del pedido');
      return;
    }
    if (!Sesion.activa) {
      _mensaje('Inicia sesión para hacer el pedido');
      return;
    }
    final carrito = CarritoService.instancia;
    setState(() => _enviando = true);
    try {
      await PedidoService.realizar(
        token: Sesion.token!,
        nombre: _nombre.text.trim(),
        direccion: _direccion.text.trim(),
        telefono: _telefono.text.trim(),
        metodoPago: _metodoPago!,
        items: carrito.seleccionados,
        total: carrito.total,
      );
      carrito.quitarSeleccionados();
      if (!mounted) return;
      _mensaje('¡Pedido realizado con éxito!');
      _irAlInicio();
    } catch (e) {
      if (mounted) _mensaje(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  // ---------- Navegación ----------

  void _irAlInicio() => Navigator.popUntil(context, (r) => r.isFirst);

  void _abrir(Widget pantalla) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));

  void _abrirNotificaciones() {
    if (!Sesion.activa) {
      _mensaje('Inicia sesión para ver tus notificaciones');
      return;
    }
    _abrir(PantallaNotificaciones(token: Sesion.token!));
  }

  @override
  Widget build(BuildContext context) {
    final carrito = CarritoService.instancia;

    return Scaffold(
      backgroundColor: AppColors.fondo,
      drawer: const MenuLateral(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              EncabezadoTienda(onInicio: _irAlInicio),
              const SizedBox(height: 16),
              Text('Pedido', style: Estilostextos.estilosTitulo),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    for (final p in carrito.seleccionados)
                      ItemPedidoTarjeta(item: p),
                    const Divider(thickness: 1.5, color: Colors.black87),
                    TotalPedido(total: carrito.total),
                    const SizedBox(height: 16),
                    FormularioPedido(
                      nombre: _nombre,
                      direccion: _direccion,
                      telefono: _telefono,
                      metodoPago: _metodoPago,
                      onMetodoPago: (v) => setState(() => _metodoPago = v),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: BotonDegradado(
                        texto: 'Realizar Pedido',
                        cargando: _enviando,
                        onPressed: _realizarPedido,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // Barra inferior: Perfil, Notificaciones, Carrito y Contáctenos
      bottomNavigationBar: BarraInferior(
        onPerfil: () => _abrir(const PerfilScreen()),
        onNotificaciones: _abrirNotificaciones,
        onCarrito: () => Navigator.pop(context), // vuelve al carrito
        onContacto: () => _abrir(const PantallaContactenos()),
      ),
    );
  }
}