import 'package:flutter/material.dart';
import '../theme/colores.dart';

/// Barra inferior con degradado y dos accesos: Iniciar sesión y Contáctenos.
/// Cada uno muestra su nombre y cambia de color al pasar el mouse
/// (web/escritorio) o al mantenerlo presionado (celular).
class BarraInferior extends StatelessWidget {
  final VoidCallback onInicioSesion;
  final VoidCallback onContacto;

  const BarraInferior({
    super.key,
    required this.onInicioSesion,
    required this.onContacto,
  });

  @override
  Widget build(BuildContext context) {
    // Espacio de la barra de gestos del celular, para que no tape los iconos
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      height: 68 + bottomInset, // alto de la barra (cambia el 68 si la quieres más alta o baja)
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
          Expanded(
            child: _ItemBarra(
              icono: Icons.person_outline_rounded,
              texto: 'Iniciar sesión',
              onTap: onInicioSesion,
            ),
          ),
          Expanded(
            child: _ItemBarra(
              icono: Icons.storefront_outlined, // icono de la tienda / información de la papelería
              texto: 'Contáctenos',
              onTap: onContacto,
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

  // Color normal y color cuando el mouse está encima / presionado
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