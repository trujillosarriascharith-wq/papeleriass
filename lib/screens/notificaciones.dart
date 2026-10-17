import 'package:flutter/material.dart';
import 'package:papelerias/screens/carrito_screen.dart';
import 'package:papelerias/screens/contactenos.dart';
import 'package:papelerias/screens/perfil_screen.dart';
import '../theme/colores.dart';
import '../theme/estilostextos.dart';
import '../widgets/BarraInferior.dart';
import '../widgets/fondocurvo.dart';
import '../widgets/menu_lateral.dart';
import '../widgets/tarjetanotificacion.dart';
import '../services/servicio_notificaciones.dart';

class PantallaNotificaciones extends StatefulWidget {
  final String token; // JWT guardado al iniciar sesión
  const PantallaNotificaciones({super.key, required this.token});

  @override
  State<PantallaNotificaciones> createState() => _PantallaNotificacionesState();
}

class _PantallaNotificacionesState extends State<PantallaNotificaciones> {
  List<Map<String, dynamic>> _items = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final datos = await ServicioNotificaciones.obtenerMias(widget.token);
      if (mounted) setState(() => _items = datos);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _eliminar(int i) async {
    final n = _items.removeAt(i);
    setState(() {});
    try {
      await ServicioNotificaciones.eliminar(widget.token, n['id_notificacion']);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('No se pudo eliminar'), backgroundColor: Colors.red.shade700),
      );
      _cargar();
    }
  }

  Future<void> _marcarLeida(Map<String, dynamic> n) async {
    if (n['leida'] == true) return;
    setState(() => n['leida'] = true);
    try {
      await ServicioNotificaciones.marcarLeida(widget.token, n['id_notificacion']);
    } catch (_) {
      if (mounted) setState(() => n['leida'] = false);
    }
  }

  // ---------- Navegación de la barra inferior ----------

  // Vuelve a la pantalla principal del cliente
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

  Widget _centro(String texto, {bool reintentar = false}) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(texto, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
          if (reintentar) TextButton(onPressed: _cargar, child: const Text('Reintentar')),
        ]),
      );

  Widget _fondoBorrar() => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.delete, color: Colors.white),
      );

  Widget _lista() {
    if (_cargando) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _centro(_error!, reintentar: true);
    if (_items.isEmpty) return _centro('No tienes notificaciones');
    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        itemCount: _items.length,
        itemBuilder: (_, i) {
          final n = _items[i];
          return Dismissible(
            key: ObjectKey(n),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => _eliminar(i),
            background: _fondoBorrar(),
            child: TarjetaNotificacion(
              texto: n['mensaje']?.toString() ?? '',
              fecha: n['fecha']?.toString(),
              leida: n['leida'] == true,
              imagen: n['imagen']?.toString(),
              onTap: () => _marcarLeida(n),
            ),
          );
        },
      ),
    );
  }

  Widget _panel() => Container(
        margin: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        decoration: BoxDecoration(
          color: const Color(0xFFE4E4E4),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 24, offset: const Offset(0, 12))],
        ),
        child: ClipRRect(borderRadius: BorderRadius.circular(30), child: _lista()),
      );

  // Fila superior: icono del menú lateral + título centrado
  Widget _encabezado() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Builder(
            builder: (ctx) => IconButton(
              onPressed: () => Scaffold.of(ctx).openDrawer(),
              icon: const Icon(Icons.menu_rounded),
              iconSize: 30,
              color: Colors.black,
              tooltip: 'Menú',
            ),
          ),
          Expanded(
            child: Text(
              'Notificaciones',
              textAlign: TextAlign.center,
              style: Estilostextos.estilosTitulo,
            ),
          ),
          // Mismo ancho que el icono del menú para que el título quede centrado
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      drawer: const MenuLateral(),
      body: FondoCurvo(
        altoCurva: 340,
        child: SafeArea(
          child: Column(children: [
            const SizedBox(height: 4),
            _encabezado(),
            Expanded(child: _panel()),
          ]),
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
}