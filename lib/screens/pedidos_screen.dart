import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:papelerias/screens/contactenos.dart';
import 'package:papelerias/screens/notificaciones.dart';
import 'package:papelerias/screens/perfil_screen.dart';
import '../services/carrito_service.dart';
import '../services/comprobante_service.dart';
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

  // ---- Comprobante Nequi ----
  Uint8List? _compBytes;
  String? _compUrl;
  int? _idComprobante;
  String _estadoComp = 'ninguno'; // ninguno | subiendo | pendiente | aprobado | rechazado
  Timer? _timer;

  bool get _esNequi => _metodoPago == 'Nequi';

  @override
  void initState() {
    super.initState();
    _recuperarComprobante();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _nombre.dispose();
    _direccion.dispose();
    _telefono.dispose();
    super.dispose();
  }

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  // ---------- Comprobante ----------

  // Si el cliente ya había subido uno (y no lo ha usado), lo recupera
  Future<void> _recuperarComprobante() async {
    if (!Sesion.activa) return;
    try {
      final c = await ComprobanteService.vigente(Sesion.token!);
      if (c == null || !mounted) return;
      setState(() {
        _idComprobante = c.id;
        _compUrl = c.imagen;
        _estadoComp = c.estado;
      });
      if (c.estado == 'pendiente') _vigilar();
    } catch (_) {}
  }

  Future<void> _adjuntarComprobante() async {
    if (!Sesion.activa) {
      _mensaje('Inicia sesión para adjuntar el comprobante');
      return;
    }

    XFile? archivo;
    Uint8List bytes;
    try {
      archivo = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (archivo == null) return; // canceló
      bytes = await archivo.readAsBytes();
    } catch (_) {
      if (mounted) _mensaje('No se pudo abrir la galería');
      return;
    }

    _timer?.cancel();
    setState(() {
      _compBytes = bytes;
      _compUrl = null;
      _idComprobante = null;
      _estadoComp = 'subiendo';
    });

    try {
      final c = await ComprobanteService.subir(
        token: Sesion.token!,
        bytes: bytes,
        nombreArchivo: archivo.name,
        monto: CarritoService.instancia.total,
      );
      if (!mounted) return;
      setState(() {
        _idComprobante = c.id;
        _estadoComp = c.estado;
      });
      _mensaje('Comprobante enviado. Espera a que el administrador valide tu pago');
      _vigilar();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _compBytes = null;
        _estadoComp = 'ninguno';
      });
      _mensaje(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // Pregunta cada 5 segundos si el administrador ya validó el pago
  void _vigilar() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (t) async {
      final id = _idComprobante;
      if (id == null || !Sesion.activa) {
        t.cancel();
        return;
      }
      try {
        final c = await ComprobanteService.consultar(Sesion.token!, id);
        if (!mounted) return;
        if (c.estado != 'pendiente') {
          t.cancel();
          setState(() => _estadoComp = c.estado);
          _mensaje(c.estado == 'aprobado'
              ? 'Pago validado. Ya puedes realizar tu pedido'
              : 'Tu comprobante fue rechazado. Adjunta uno nuevo');
        }
      } catch (_) {}
    });
  }

  // Mensaje de por qué no se puede pedir todavía (null = sí se puede)
  String? _bloqueoNequi() {
    if (!_esNequi) return null;
    switch (_estadoComp) {
      case 'aprobado':
        return null;
      case 'pendiente':
        return 'Tu pago aún no ha sido validado por el administrador';
      case 'subiendo':
        return 'Espera a que termine de subir el comprobante';
      case 'rechazado':
        return 'Tu comprobante fue rechazado. Adjunta uno nuevo';
      default:
        return 'Adjunta el comprobante de pago de Nequi';
    }
  }

  // ---------- Pedido ----------

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
    final bloqueo = _bloqueoNequi();
    if (bloqueo != null) {
      _mensaje(bloqueo);
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
        idComprobante: _esNequi ? _idComprobante : null,
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
                      estadoComprobante: _estadoComp,
                      comprobanteBytes: _compBytes,
                      comprobanteUrl: _compUrl,
                      onAdjuntar: _adjuntarComprobante,
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