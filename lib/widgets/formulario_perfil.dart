import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/colores.dart';
import 'botondegradado.dart';
import 'campodetexto.dart';
import 'dialogo_verificar_correo.dart';

/// Los 4 campos del perfil (nombre, correo, dirección, teléfono) con lápiz
/// para editar y botón "Guardar cambios". Si se cambia el correo, pide el
/// código de verificación. Lo usan el perfil del usuario y el del administrador.
class FormularioPerfil extends StatefulWidget {
  /// Se llama cada vez que se cargan datos del usuario (guardados o del servidor)
  final ValueChanged<Map<String, dynamic>>? onUsuario;

  const FormularioPerfil({super.key, this.onUsuario});

  @override
  State<FormularioPerfil> createState() => _FormularioPerfilState();
}

class _FormularioPerfilState extends State<FormularioPerfil> {
  static const _rutaGmail = 'assets/icons/gmail.webp';

  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _direccion = TextEditingController();
  final _telefono = TextEditingController();

  final _focoNombre = FocusNode();
  final _focoCorreo = FocusNode();
  final _focoDireccion = FocusNode();
  final _focoTelefono = FocusNode();

  final Set<String> _editando = {};
  Map<String, String> _original = {
    'nombre': '',
    'email': '',
    'direccion': '',
    'telefono': '',
  };
  String _pendiente = ''; // correo nuevo que falta confirmar
  bool _guardando = false;

  bool get _hayCambios =>
      _nombre.text.trim() != _original['nombre'] ||
      _correo.text.trim() != _original['email'] ||
      _direccion.text.trim() != _original['direccion'] ||
      _telefono.text.trim() != _original['telefono'];

  @override
  void initState() {
    super.initState();
    for (final c in [_nombre, _correo, _direccion, _telefono]) {
      c.addListener(_alCambiar);
    }
    _cargar();
  }

  void _alCambiar() {
    if (mounted) setState(() {});
  }

  // Primero muestra lo guardado en el teléfono y luego lo actualiza con el servidor
  Future<void> _cargar() async {
    final guardado = await AuthService.usuarioGuardado();
    if (guardado != null) _aplicar(guardado);

    final fresco = await AuthService.refrescarPerfil();
    if (fresco != null) _aplicar(fresco);
  }

  void _aplicar(Map<String, dynamic> u, {bool forzar = false}) {
    if (!mounted) return;
    widget.onUsuario?.call(u);

    setState(() => _pendiente = u['emailPendiente']?.toString() ?? '');

    // Si el usuario ya está escribiendo, no se le borra lo que puso
    if (_hayCambios && !forzar) return;

    String t(String k) => u[k]?.toString() ?? '';
    _nombre.text = t('nombre');
    _correo.text = t('email');
    _direccion.text = t('direccion');
    _telefono.text = t('telefono');

    setState(() {
      _original = {
        'nombre': _nombre.text.trim(),
        'email': _correo.text.trim(),
        'direccion': _direccion.text.trim(),
        'telefono': _telefono.text.trim(),
      };
    });
  }

  @override
  void dispose() {
    for (final c in [_nombre, _correo, _direccion, _telefono]) {
      c.dispose();
    }
    for (final f in [_focoNombre, _focoCorreo, _focoDireccion, _focoTelefono]) {
      f.dispose();
    }
    super.dispose();
  }

  void _aviso(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  // Lápiz: activa la edición del campo. Check: la termina.
  void _alternar(String clave, FocusNode foco) {
    if (_guardando) return;
    setState(() {
      if (!_editando.remove(clave)) _editando.add(clave);
    });
    if (_editando.contains(clave)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => foco.requestFocus());
    } else {
      foco.unfocus();
    }
  }

  String? _validar(String nombre, String correo, String telefono) {
    if (nombre.isEmpty) return 'El nombre no puede estar vacío';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(correo)) {
      return 'Escribe un correo válido';
    }
    if (telefono.isNotEmpty && !RegExp(r'^[0-9+\s-]{7,20}$').hasMatch(telefono)) {
      return 'Escribe un teléfono válido';
    }
    return null;
  }

  Future<void> _guardar() async {
    FocusScope.of(context).unfocus();

    final nombre = _nombre.text.trim();
    final correo = _correo.text.trim();
    final direccion = _direccion.text.trim();
    final telefono = _telefono.text.trim();

    final error = _validar(nombre, correo, telefono);
    if (error != null) {
      _aviso(error);
      return;
    }

    setState(() => _guardando = true);
    final r = await AuthService.actualizarPerfil(
      nombre: nombre,
      correo: correo,
      direccion: direccion,
      telefono: telefono,
    );
    if (!mounted) return;
    setState(() => _guardando = false);

    if (!r.exito) {
      _aviso(r.mensaje);
      return;
    }

    setState(() => _editando.clear());
    if (r.usuario != null) _aplicar(r.usuario!, forzar: true);

    if (r.requiereVerificacion) {
      _aviso(r.mensaje);
      await _pedirCodigo();
    } else {
      _aviso(r.mensaje);
    }
  }

  // Abre la ventana para escribir el código del correo nuevo
  Future<void> _pedirCodigo() async {
    if (_pendiente.isEmpty) return;

    final confirmado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DialogoVerificarCorreo(correo: _pendiente),
    );
    if (!mounted) return;

    if (confirmado == true) {
      final u = await AuthService.usuarioGuardado();
      if (u != null) _aplicar(u, forzar: true);
      _aviso('Correo actualizado correctamente');
    }
  }

  Widget _campo(
    String clave,
    String etiqueta,
    IconData icono,
    TextEditingController c,
    FocusNode foco, {
    TextInputType tipo = TextInputType.text,
    Widget? prefijo,
  }) {
    final editando = _editando.contains(clave);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: CampoTexto(
        etiqueta: etiqueta,
        icono: icono,
        prefijo: prefijo,
        bordeColor: AppColors.primaryColor, //borde de los campos
        colorIcono: Colors.black,
        controller: c,
        focusNode: foco,
        tipoTeclado: tipo,
        soloLectura: !editando,
        iconoFinal: editando ? Icons.check_rounded : Icons.edit_outlined,
        onTapIconoFinal: () => _alternar(clave, foco),
      ),
    );
  }

  // Aviso amarillo cuando falta confirmar un correo nuevo
  Widget _avisoPendiente() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Falta confirmar tu nuevo correo: $_pendiente',
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _pedirCodigo,
              child: const Text('Ingresar código'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _campo('nombre', 'Nombre', Icons.person_outline, _nombre, _focoNombre),
        _campo(
          'email',
          'Correo',
          Icons.email_outlined,
          _correo,
          _focoCorreo,
          tipo: TextInputType.emailAddress,
          prefijo: Padding(
            padding: const EdgeInsets.all(12),
            child: Image.asset(_rutaGmail, width: 22, height: 22),
          ),
        ),
        if (_pendiente.isNotEmpty) _avisoPendiente(),
        _campo('direccion', 'Dirección', Icons.home_outlined, _direccion,
            _focoDireccion),
        _campo('telefono', 'Teléfono', Icons.phone_outlined, _telefono,
            _focoTelefono,
            tipo: TextInputType.phone),
        if (_guardando)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: CircularProgressIndicator(),
          )
        else if (_hayCambios) ...[
          SizedBox(
            width: 190,
            child: BotonDegradado(
              texto: 'Guardar cambios',
              icono: Icons.save_outlined,
              onPressed: _guardar,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}