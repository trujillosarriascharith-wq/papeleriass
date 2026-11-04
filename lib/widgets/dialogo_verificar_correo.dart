import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../theme/colores.dart';
import 'campodetexto.dart';

/// Ventana para escribir el código de 6 dígitos que llegó al correo nuevo.
/// Se cierra con `true` si el correo quedó confirmado y con `false` si se cancela.
class DialogoVerificarCorreo extends StatefulWidget {
  final String correo;

  const DialogoVerificarCorreo({super.key, required this.correo});

  @override
  State<DialogoVerificarCorreo> createState() => _DialogoVerificarCorreoState();
}

class _DialogoVerificarCorreoState extends State<DialogoVerificarCorreo> {
  final _codigo = TextEditingController();
  bool _cargando = false;
  String? _error;
  String? _info;

  @override
  void dispose() {
    _codigo.dispose();
    super.dispose();
  }

  Future<void> _verificar() async {
    final codigo = _codigo.text.trim();
    if (codigo.length != 6) {
      setState(() {
        _error = 'El código tiene 6 dígitos';
        _info = null;
      });
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
      _info = null;
    });
    final r = await AuthService.verificarCorreoNuevo(codigo);
    if (!mounted) return;

    if (r.exito) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _cargando = false;
        _error = r.mensaje;
      });
    }
  }

  Future<void> _reenviar() async {
    setState(() {
      _cargando = true;
      _error = null;
      _info = null;
    });
    final r = await AuthService.reenviarCodigoCorreo();
    if (!mounted) return;

    setState(() {
      _cargando = false;
      if (r.exito) {
        _info = 'Te enviamos un código nuevo';
      } else {
        _error = r.mensaje;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('Confirma tu nuevo correo'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enviamos un código de 6 dígitos a ${widget.correo}. '
              'Escríbelo para confirmar el cambio.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            CampoTexto(
              etiqueta: 'Código de 6 dígitos',
              icono: Icons.pin_outlined,
              colorIcono: Colors.black,
              bordeColor: AppColors.primaryColor,
              controller: _codigo,
              tipoTeclado: TextInputType.number,
              formatos: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!,
                  style: const TextStyle(color: Colors.red, fontSize: 13)),
            ],
            if (_info != null) ...[
              const SizedBox(height: 8),
              Text(_info!,
                  style: TextStyle(color: Colors.green.shade700, fontSize: 13)),
            ],
            const SizedBox(height: 4),
            TextButton(
              onPressed: _cargando ? null : _reenviar,
              child: const Text('Reenviar código'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _cargando ? null : () => Navigator.of(context).pop(false),
          child: const Text('Más tarde'),
        ),
        ElevatedButton(
          onPressed: _cargando ? null : _verificar,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: _cargando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Verificar'),
        ),
      ],
    );
  }
}