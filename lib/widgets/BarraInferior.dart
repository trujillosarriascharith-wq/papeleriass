import 'package:flutter/material.dart';
import '../theme/colores.dart';
import '../screens/inicioseseion.dart'; 

/// Barra inferior con degradado.
///
/// Mantiene la misma API de siempre (onInicio, onInicioSesion, onPerfil,
/// onNotificaciones, onCarrito, onContacto): un acceso aparece solo si se le
/// pasa su función.
///
/// Control de sesión (sirve igual para cliente y administrador):
/// - Con sesión iniciada: todos los iconos llevan a su pantalla.
/// - Sin sesión: Inicio, Perfil, Notificaciones y Carrito no abren nada y
///   muestran un mensaje pequeño "Tienes que iniciar sesión".
/// - "Iniciar sesión" y "Contáctenos" siempre están libres.
///
/// Cómo sabe si hay sesión (en este orden):
///  1. el parámetro `estaAutenticado`, si la pantalla lo pasa;
///  2. `BarraInferior.verificadorSesion`, si lo configuraste;
///  3. `BarraInferior.sesionIniciada` (bandera simple, ver abajo).
///
/// Uso más simple (cliente y admin):
///   - al iniciar sesión con éxito:  BarraInferior.sesionIniciada = true;
///   - al cerrar sesión:             BarraInferior.sesionIniciada = false;
class BarraInferior extends StatelessWidget {
  /// Bandera global de sesión (la misma para cliente y administrador).
  static bool sesionIniciada = false;

  /// Alternativa: función que devuelve si hay sesión (tiene prioridad sobre
  /// `sesionIniciada` cuando está configurada).
  static bool Function()? verificadorSesion;

  final VoidCallback? onInicio;
  final VoidCallback? onInicioSesion;
  final VoidCallback? onPerfil;
  final VoidCallback? onNotificaciones;
  final VoidCallback? onCarrito;
  final VoidCallback? onContacto;

  /// Opcional: fuerza el estado de sesión desde la pantalla.
  final bool? estaAutenticado;

  /// Si es false, "Inicio" queda libre aunque no haya sesión.
  final bool inicioRequiereSesion;

  const BarraInferior({
    super.key,
    this.onInicio,
    this.onInicioSesion,
    this.onPerfil,
    this.onNotificaciones,
    this.onCarrito,
    this.onContacto,
    this.estaAutenticado,
    this.inicioRequiereSesion = true,
  });

  bool get _haySesion =>
      estaAutenticado ?? verificadorSesion?.call() ?? sesionIniciada;

  /// Ejecuta [accion]. Si [requiereSesion] y no hay sesión, avisa.
  void _ejecutar(
    BuildContext context,
    VoidCallback accion, {
    required bool requiereSesion,
  }) {
    if (requiereSesion && !_haySesion) {
      _avisarSesionRequerida(context);
      return;
    }
    accion();
  }

  /// Mensaje pequeño con acceso directo a iniciar sesión.
  void _avisarSesionRequerida(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Tienes que iniciar sesión'),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Iniciar sesión',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const InicioSesion()),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Espacio de la barra de gestos del celular, para que no tape los iconos
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final haySesion = _haySesion;

    return Container(
      height: 68 + bottomInset, // alto de la barra
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.primaryColor, AppColors.secondaryColor],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Inicio: libre
          if (onInicio != null)
            Expanded(
              child: _ItemBarra(
                icono: Icons.home_outlined,
                texto: 'Inicio',
                onTap: () =>
                    _ejecutar(context, onInicio!,
                        requiereSesion: inicioRequiereSesion),
              ),
            ),
          // Iniciar sesión: libre, y se oculta si ya hay sesión
          if (onInicioSesion != null && !haySesion)
            Expanded(
              child: _ItemBarra(
                icono: Icons.login_rounded,
                texto: 'Iniciar sesión',
                onTap: () =>
                    _ejecutar(context, onInicioSesion!, requiereSesion: false),
              ),
            ),
          // Requieren sesión
          if (onPerfil != null)
            Expanded(
              child: _ItemBarra(
                icono: Icons.person_outline_rounded,
                texto: 'Perfil',
                onTap: () =>
                    _ejecutar(context, onPerfil!, requiereSesion: true),
              ),
            ),
          if (onNotificaciones != null)
            Expanded(
              child: _ItemBarra(
                icono: Icons.notifications_none_rounded,
                texto: 'Notificaciones',
                onTap: () =>
                    _ejecutar(context, onNotificaciones!, requiereSesion: true),
              ),
            ),
          if (onCarrito != null)
            Expanded(
              child: _ItemBarra(
                icono: Icons.shopping_cart_outlined,
                texto: 'Carrito',
                onTap: () =>
                    _ejecutar(context, onCarrito!, requiereSesion: true),
              ),
            ),
          // Contáctenos: libre, sin necesidad de sesión
          if (onContacto != null)
            Expanded(
              child: _ItemBarra(
                icono: Icons.storefront_outlined,
                texto: 'Contáctenos',
                onTap: () =>
                    _ejecutar(context, onContacto!, requiereSesion: false),
              ),
            ),
        ],
      ),
    );
  }
}

/// Icono + texto que cambian de color con hover / al presionar.
class _ItemBarra extends StatefulWidget {
  final IconData icono;
  final String texto;
  final VoidCallback onTap;

  const _ItemBarra({
    required this.icono,
    required this.texto,
    required this.onTap,
  });

  @override
  State<_ItemBarra> createState() => _ItemBarraState();
}

class _ItemBarraState extends State<_ItemBarra> {
  bool _hover = false;
  bool _presionado = false;

  static const Color _colorNormal = Colors.white;
  static const Color _colorActivo = Color(0xFFFCCB05); // amarillo (el mismo del chatbot)

  @override
  Widget build(BuildContext context) {
    final activo = _hover || _presionado;
    final color = activo ? _colorActivo : _colorNormal;

    return InkWell(
      onTap: widget.onTap,
      onHover: (v) => setState(() => _hover = v),
      onHighlightChanged: (v) => setState(() => _presionado = v),
      splashColor: Colors.white24,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            scale: activo ? 1.15 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Icon(widget.icono, size: 30, color: color),
          ),
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 150),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            child: Text(widget.texto),
          ),
        ],
      ),
    );
  }
}