// import 'dart:typed_data';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import '../services/auth_service.dart';
// import '../theme/colores.dart';
// import '../theme/estilostextos.dart';
// import '../widgets/botondegradado.dart';
// import '../widgets/campodetexto.dart';
// import '../widgets/fondocurvo.dart';
// import '../widgets/medallonlogo.dart';
// import '../widgets/subbarrainicio.dart';
// import 'verificar_cuenta.dart';

// class Registrarse extends StatefulWidget {
//   const Registrarse({super.key});

//   @override
//   State<Registrarse> createState() => _RegistrarseState();
// }

// class _RegistrarseState extends State<Registrarse> {
//   final _nombre = TextEditingController();
//   final _correo = TextEditingController();
//   final _direccion = TextEditingController();
//   final _telefono = TextEditingController();
//   final _password = TextEditingController();
//   bool _cargando = false;
//   Uint8List? _foto; // foto elegida de la galería

//   @override
//   void dispose() {
//     for (final c in [_nombre, _correo, _direccion, _telefono, _password]) {
//       c.dispose();
//     }
//     super.dispose();
//   }

//   Future<void> _elegirFoto() async {
//     final img = await ImagePicker()
//         .pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 80);
//     if (img == null) return;
//     final bytes = await img.readAsBytes();
//     if (mounted) setState(() => _foto = bytes);
//   }

//   void _aviso(String mensaje) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
//   }

//   Future<void> _crearCuenta() async {
//     final nombre = _nombre.text.trim();
//     final correo = _correo.text.trim();
//     final direccion = _direccion.text.trim();
//     final telefono = _telefono.text.trim();
//     final password = _password.text;

//     if (nombre.isEmpty ||
//         correo.isEmpty ||
//         direccion.isEmpty ||
//         telefono.isEmpty ||
//         password.isEmpty) {
//       _aviso('Completa todos los campos');
//       return;
//     }

//     setState(() => _cargando = true);
//     final r = await AuthService.registrar(
//       nombre: nombre,
//       correo: correo,
//       telefono: telefono,
//       direccion: direccion,
//       password: password,
//       foto: _foto,
//     );
//     if (!mounted) return;
//     setState(() => _cargando = false);

//     _aviso(r.mensaje);
//     if (!r.exito) return;

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => VerificarCuenta(correo: correo)),
//     );
//   }

//   Widget _campo(String etiqueta, IconData icono, TextEditingController c,
//       {bool password = false, TextInputType tipo = TextInputType.text, Widget? prefijo}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: CampoTexto(
//         etiqueta: etiqueta,
//         icono: icono,
//         prefijo: prefijo,
//         controller: c,
//         esPassword: password,
//         tipoTeclado: tipo,
//         bordeColor: AppColors.primaryColor,
//         colorIcono: Colors.black,
//       ),
//     );
//   }

//   Widget _tarjeta() => Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(30),
//           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 24, offset: const Offset(0, 12))],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(30),
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
//             child: Container(
//               width: double.infinity,
//               padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
//               color: Colors.white.withOpacity(0.85),
//               child: Column(children: [
//                 Text('Registrarse', style: Estilostextos.estilosTitulo),
//                 const SizedBox(height: 4),
//                 const Text('Crea tu cuenta para comenzar',
//                     style: TextStyle(fontSize: 13.5, color: Colors.black54)),
//                 const SizedBox(height: 18),
//                 _campo('Nombre', Icons.person_outline, _nombre),
//                 _campo('Correo', Icons.email, _correo,
//                     tipo: TextInputType.emailAddress,
//                     prefijo: Image.asset('assets/images/gmail2.webp', width: 20)),
//                 _campo('Dirección', Icons.home_outlined, _direccion),
//                 _campo('Teléfono', Icons.phone_outlined, _telefono, tipo: TextInputType.phone),
//                 _campo('Contraseña', Icons.lock, _password,
//                     password: true, prefijo: const SizedBox(width: 16)),
//                 const SizedBox(height: 8),
//                 BotonDegradado(texto: 'Crear cuenta', cargando: _cargando, onPressed: _crearCuenta),
//                 const SizedBox(height: 14),
//                 Text('¿Ya tienes una cuenta?', style: Estilostextos.estilosLetra),
//                 TextButton(onPressed: () => Navigator.pop(context), child: const Text('Inicia sesion')),
//               ]),
//             ),
//           ),
//         ),
//       );

//   Widget _formulario() => Stack(
//         alignment: Alignment.topCenter,
//         clipBehavior: Clip.none,
//         children: [
//           Padding(padding: const EdgeInsets.only(top: 59), child: _tarjeta()),
//           MedallonLogo(
//             icono: Icons.person_add_alt_1_rounded,
//             insignia: Icons.photo_camera_rounded,
//             imagen: _foto == null ? null : MemoryImage(_foto!),
//             onInsignia: _elegirFoto,
//           ),
//         ],
//       );

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.fondo,
//       body: FondoCurvo(
//         child: SafeArea(
//           child: Stack(children: [
//             LayoutBuilder(
//               builder: (_, c) => SingleChildScrollView(
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(minHeight: c.maxHeight),
//                   child: Center(
//                     child: Padding(
//                       padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
//                       child: _formulario(),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             const Positioned(top: 8, left: 0, child: SubBarraInicio()),
//           ]),
//         ),
//       ),
//     );
//   }
// }
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../theme/colores.dart';
import '../theme/estilostextos.dart';
import '../widgets/botondegradado.dart';
import '../widgets/campodetexto.dart';
import '../widgets/fondocurvo.dart';
import '../widgets/medallonlogo.dart';
import '../widgets/subbarrainicio.dart';
import 'verificar_cuenta.dart';

class Registrarse extends StatefulWidget {
  const Registrarse({super.key});

  @override
  State<Registrarse> createState() => _RegistrarseState();
}

class _RegistrarseState extends State<Registrarse> {
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _direccion = TextEditingController();
  final _telefono = TextEditingController();
  final _password = TextEditingController();
  bool _cargando = false;
  bool _aceptaTerminos = false; // debe aceptar para poder registrarse
  Uint8List? _foto; // foto elegida de la galería

  @override
  void dispose() {
    for (final c in [_nombre, _correo, _direccion, _telefono, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _elegirFoto() async {
    final img = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 80);
    if (img == null) return;
    final bytes = await img.readAsBytes();
    if (mounted) setState(() => _foto = bytes);
  }

  void _aviso(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  // ───────── Diálogo de Términos, Políticas y Condiciones ─────────
  void _mostrarTerminos() {
    const parrafo = TextStyle(fontSize: 14.5, height: 1.45, color: Colors.black87);
    const negrita = TextStyle(
        fontSize: 14.5, height: 1.45, color: Colors.black87, fontWeight: FontWeight.w700);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Términos, Políticas y Condiciones',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 14),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bienvenido a nuestra aplicación. Antes de crear tu cuenta, '
                        'lee y acepta lo siguiente:',
                        style: parrafo,
                      ),
                      const SizedBox(height: 14),
                      Text.rich(const TextSpan(children: [
                        TextSpan(text: '1. Protección de Datos: ', style: negrita),
                        TextSpan(
                          text: 'Al registrarte autorizas el tratamiento de tus datos '
                              'personales (nombre, correo, teléfono, dirección y foto) '
                              'para fines informativos y de gestión de tu cuenta y tus pedidos.',
                          style: parrafo,
                        ),
                      ])),
                      const SizedBox(height: 14),
                      Text.rich(const TextSpan(children: [
                        TextSpan(text: '2. Uso de la Información: ', style: negrita),
                        TextSpan(
                          text: 'Tus datos de contacto se mantendrán seguros bajo '
                              'los protocolos de almacenamiento y no serán compartidos '
                              'con terceros sin tu consentimiento.',
                          style: parrafo,
                        ),
                      ])),
                      const SizedBox(height: 14),
                      Text.rich(const TextSpan(children: [
                        TextSpan(text: '3. Compromiso del Usuario: ', style: negrita),
                        TextSpan(
                          text: 'Te comprometes a hacer un uso adecuado de la '
                              'plataforma y a respetar las normas de la aplicación.',
                          style: parrafo,
                        ),
                      ])),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Cerrar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _crearCuenta() async {
    final nombre = _nombre.text.trim();
    final correo = _correo.text.trim();
    final direccion = _direccion.text.trim();
    final telefono = _telefono.text.trim();
    final password = _password.text;

    if (nombre.isEmpty ||
        correo.isEmpty ||
        direccion.isEmpty ||
        telefono.isEmpty ||
        password.isEmpty) {
      _aviso('Completa todos los campos');
      return;
    }

    if (!_aceptaTerminos) {
      _aviso('Debes aceptar los Términos, Políticas y Condiciones para registrarte');
      return;
    }

    setState(() => _cargando = true);
    final r = await AuthService.registrar(
      nombre: nombre,
      correo: correo,
      telefono: telefono,
      direccion: direccion,
      password: password,
      foto: _foto,
    );
    if (!mounted) return;
    setState(() => _cargando = false);

    _aviso(r.mensaje);
    if (!r.exito) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => VerificarCuenta(correo: correo)),
    );
  }

  Widget _campo(String etiqueta, IconData icono, TextEditingController c,
      {bool password = false, TextInputType tipo = TextInputType.text, Widget? prefijo}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CampoTexto(
        etiqueta: etiqueta,
        icono: icono,
        prefijo: prefijo,
        controller: c,
        esPassword: password,
        tipoTeclado: tipo,
        bordeColor: AppColors.primaryColor,
        colorIcono: Colors.black,
      ),
    );
  }

  // Checkbox + texto subrayado que abre el diálogo
  Widget _checkTerminos() => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: _aceptaTerminos,
            activeColor: AppColors.primaryColor,
            checkColor: Colors.white,
            side: BorderSide(color: AppColors.primaryColor, width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            onChanged: (v) => setState(() => _aceptaTerminos = v ?? false),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _mostrarTerminos,
              child: Text(
                'Acepto los Términos, Políticas y Condiciones de tratamiento de datos.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.primaryColor,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primaryColor,
                ),
              ),
            ),
          ),
        ],
      );

  Widget _tarjeta() => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 24, offset: const Offset(0, 12))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
              color: Colors.white.withOpacity(0.85),
              child: Column(children: [
                Text('Registrarse', style: Estilostextos.estilosTitulo),
                const SizedBox(height: 4),
                const Text('Crea tu cuenta para comenzar',
                    style: TextStyle(fontSize: 13.5, color: Colors.black54)),
                const SizedBox(height: 18),
                _campo('Nombre', Icons.person_outline, _nombre),
                _campo('Correo', Icons.email, _correo,
                    tipo: TextInputType.emailAddress,
                    prefijo: Image.asset('assets/images/gmail2.webp', width: 20)),
                _campo('Dirección', Icons.home_outlined, _direccion),
                _campo('Teléfono', Icons.phone_outlined, _telefono, tipo: TextInputType.phone),
                _campo('Contraseña', Icons.lock, _password,
                    password: true, prefijo: const SizedBox(width: 16)),
                _checkTerminos(),
                const SizedBox(height: 8),
                BotonDegradado(texto: 'Crear cuenta', cargando: _cargando, onPressed: _crearCuenta),
                const SizedBox(height: 14),
                Text('¿Ya tienes una cuenta?', style: Estilostextos.estilosLetra),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Inicia sesion')),
              ]),
            ),
          ),
        ),
      );

  Widget _formulario() => Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Padding(padding: const EdgeInsets.only(top: 59), child: _tarjeta()),
          MedallonLogo(
            icono: Icons.person_add_alt_1_rounded,
            insignia: Icons.photo_camera_rounded,
            imagen: _foto == null ? null : MemoryImage(_foto!),
            onInsignia: _elegirFoto,
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: FondoCurvo(
        child: SafeArea(
          child: Stack(children: [
            LayoutBuilder(
              builder: (_, c) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: c.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                      child: _formulario(),
                    ),
                  ),
                ),
              ),
            ),
            const Positioned(top: 8, left: 0, child: SubBarraInicio()),
          ]),
        ),
      ),
    );
  }
}