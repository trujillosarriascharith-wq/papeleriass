import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colores.dart';

/// Campo de texto blanco y redondeado con ícono a la izquierda.
///
/// - [icono]: ícono izquierdo (opcional; sin él no se muestra ninguno).
/// - [prefijo]: widget propio para el lado izquierdo. Si se pasa, reemplaza
///   a [icono].
/// - [bordeColor]: si se pasa, dibuja un borde de ese color.
/// - [colorIcono]: color del ícono izquierdo (por defecto AppColors.secondaryColor).
/// - [formatos]: restricciones de escritura, ej: solo números.
/// - [maxLineas]: líneas máximas del campo (no aplica a contraseñas).
class CampoTexto extends StatefulWidget {
  final String etiqueta;
  final IconData? icono;
  final Widget? prefijo;
  final Color? bordeColor;
  final Color? colorIcono;
  final TextEditingController? controller;
  final bool esPassword;
  final TextInputType tipoTeclado;
  final bool soloLectura;
  final VoidCallback? onTapIconoFinal;
  final IconData? iconoFinal;
  final List<TextInputFormatter>? formatos;
  final int maxLineas;

  const CampoTexto({
    super.key,
    required this.etiqueta,
    this.icono,
    this.prefijo,
    this.bordeColor,
    this.colorIcono,
    this.controller,
    this.esPassword = false,
    this.tipoTeclado = TextInputType.text,
    this.soloLectura = false,
    this.onTapIconoFinal,
    this.iconoFinal,
    this.formatos,
    this.maxLineas = 1,
  });

  @override
  State<CampoTexto> createState() => _CampoTextoState();
}

class _CampoTextoState extends State<CampoTexto> {
  bool _ocultarTexto = true;

  @override
  void initState() {
    super.initState();
    _ocultarTexto = widget.esPassword;
  }

  OutlineInputBorder _borde() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: widget.bordeColor == null
            ? BorderSide.none
            : BorderSide(color: widget.bordeColor!, width: 1.5),
      );

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _ocultarTexto,
      readOnly: widget.soloLectura,
      keyboardType: widget.tipoTeclado,
      inputFormatters: widget.formatos,
      minLines: 1,
      maxLines: widget.esPassword ? 1 : widget.maxLineas,
      decoration: InputDecoration(
        hintText: widget.etiqueta,
        prefixIcon: widget.prefijo ??
            (widget.icono == null
                ? null
                : Icon(widget.icono, color: widget.colorIcono ?? AppColors.secondaryColor)),
        suffixIcon: widget.esPassword
            ? IconButton(
                icon: Icon(_ocultarTexto ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _ocultarTexto = !_ocultarTexto),
              )
            : (widget.iconoFinal != null
                ? IconButton(icon: Icon(widget.iconoFinal), onPressed: widget.onTapIconoFinal)
                : null),
        filled: true,
        fillColor: AppColors.fondoComponente,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: _borde(),
        enabledBorder: _borde(),
        focusedBorder: _borde(),
      ),
    );
  }
}