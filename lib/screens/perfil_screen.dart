
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:papelerias/widgets/botondegradado.dart';
// import '../services/auth_service.dart';
// import '../services/carrito_service.dart';
// import '../services/sesion.dart';
// import '../theme/colores.dart';
// import '../theme/estilostextos.dart';
// import '../widgets/barrasuperior.dart';
// import '../widgets/fondodegradado.dart';
// import '../widgets/BarraInferior.dart';
// import '../widgets/formulario_perfil.dart';
// import '../widgets/foto_perfil_editable.dart';
// import 'carrito_screen.dart';
// import 'contactenos.dart';
// import 'home_screen.dart';
// import 'notificaciones.dart';

// /// Pantalla de Perfil del usuario
// class PerfilScreen extends StatefulWidget {
//   const PerfilScreen({super.key});

//   @override
//   State<PerfilScreen> createState() => _PerfilScreenState();
// }

// class _PerfilScreenState extends State<PerfilScreen> {
//   static const _rutaFoto = 'assets/images/perfil.webp';

//   String? _fotoUrl;
//   bool _subiendoFoto = false;

//   // Lo llama el formulario cada vez que carga los datos del usuario
//   void _usuarioCargado(Map<String, dynamic> u) {
//     if (!mounted) return;
//     final foto = (u['foto'] ?? '').toString();
//     setState(() => _fotoUrl = foto.isEmpty ? null : foto);
//   }

//   void _aviso(String mensaje) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context)
//       ..hideCurrentSnackBar()
//       ..showSnackBar(SnackBar(content: Text(mensaje)));
//   }

//   // Abre la galería, sube la foto y la deja guardada en la base de datos
//   Future<void> _cambiarFoto() async {
//     if (_subiendoFoto) return;
//     try {
//       final archivo = await ImagePicker().pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 1024,
//         imageQuality: 85,
//       );
//       if (archivo == null) return; // canceló

//       final bytes = await archivo.readAsBytes();
//       if (!mounted) return;
//       setState(() => _subiendoFoto = true);

//       final r = await AuthService.subirFotoPerfil(bytes);
//       if (!mounted) return;

//       setState(() {
//         _subiendoFoto = false;
//         if (r.exito) {
//           final f = (r.usuario?['foto'] ?? '').toString();
//           if (f.isNotEmpty) _fotoUrl = f;
//         }
//       });
//       _aviso(r.exito ? 'Foto actualizada' : r.mensaje);
//     } catch (_) {
//       if (!mounted) return;
//       setState(() => _subiendoFoto = false);
//       _aviso('No se pudo abrir la galería');
//     }
//   }

//   // Cierra la sesión, vacía el carrito que se ve en pantalla y vuelve al inicio.
//   // El carrito sigue guardado en la base de datos: al volver a iniciar sesión
//   // el usuario lo recupera.
//   Future<void> _cerrarSesion() async {
//     await AuthService.cerrarSesion();
//     CarritoService.instancia.limpiarLocal(); // el siguiente usuario no ve este carrito
//     BarraInferior.sesionIniciada = false; // cierra la sesión en la barra
//     if (!mounted) return;
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (_) => const HomeScreen()),
//       (_) => false,
//     );
//   }

//   // ---------- Navegación de la barra inferior ----------

//   void _irAlInicio() =>
//       Navigator.of(context).popUntil((ruta) => ruta.isFirst);

//   void _abrirNotificaciones() {
//     if (!Sesion.activa) return;
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => PantallaNotificaciones(token: Sesion.token!),
//       ),
//     );
//   }

//   void _abrirCarrito() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const PantallaCarrito()),
//     );
//   }

//   void _abrirContactenos() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const PantallaContactenos()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.fondo,
//       body: Stack(
//         fit: StackFit.expand, // el Stack ocupa toda la pantalla: el círculo queda al fondo
//         children: [
//           const CirculoDecorativo(degradado: true),
//           SingleChildScrollView(
//             child: Column(
//               children: [
//                 Stack(
//                   clipBehavior: Clip.none,
//                   children: [
//                     // Encabezado con degradado (ya sin la barra de iconos)
//                     FondoDegradado(
//                       alto: 170,
//                       padding: EdgeInsets.zero,
//                       child: const SizedBox.shrink(),
//                     ),
//                     Positioned(
//                       bottom: -60,
//                       left: 0,
//                       right: 0,
//                       child: Center(
//                         child: FotoPerfilEditable(
//                           fotoUrl: _fotoUrl,
//                           rutaPorDefecto: _rutaFoto,
//                           subiendo: _subiendoFoto,
//                           onEditar: _cambiarFoto,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 75),
//                 Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 20),
//                   padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
//                   decoration: BoxDecoration(
//                     color: const Color.fromARGB(255, 238, 232, 232).withOpacity(0.5), //fondo del cuadro de perfil
//                     borderRadius: BorderRadius.circular(28),
//                   ),
//                   child: Column(
//                     children: [
//                       Text(
//                         'Perfil',
//                         style: Estilostextos.estilosTitulo
//                             .copyWith(fontWeight: FontWeight.bold, fontFamily: 'serif'),
//                       ),
//                       const SizedBox(height: 16),
//                       FormularioPerfil(onUsuario: _usuarioCargado),
//                       const SizedBox(height: 10),
//                       SizedBox(
//                         width: 190,
//                         child: BotonDegradado(
//                           texto: 'Cerrar Sesión',
//                           icono: Icons.logout,
//                           onPressed: _cerrarSesion,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//               ],
//             ),
//           ),
//         ],
//       ),
//       // Barra inferior: Inicio (casita), Notificaciones, Carrito y Contáctenos
//       bottomNavigationBar: BarraInferior(
//         onInicio: _irAlInicio,
//         onNotificaciones: _abrirNotificaciones,
//         onCarrito: _abrirCarrito,
//         onContacto: _abrirContactenos,
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:papelerias/widgets/botondegradado.dart';
import '../services/auth_service.dart';
import '../services/carrito_service.dart';
import '../services/sesion.dart';
import '../theme/colores.dart';
import '../theme/estilostextos.dart';
import '../widgets/barrasuperior.dart';
import '../widgets/fondodegradado.dart';
import '../widgets/BarraInferior.dart';
import '../widgets/formulario_perfil.dart';
import '../widgets/foto_perfil_editable.dart';
import 'carrito_screen.dart';
import 'contactenos.dart';
import 'home_screen.dart';
import 'notificaciones.dart';

/// Pantalla de Perfil del usuario
class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  static const _rutaFoto = 'assets/images/perfil.webp';

  String? _fotoUrl;
  bool _subiendoFoto = false;

  // Lo llama el formulario cada vez que carga los datos del usuario
  void _usuarioCargado(Map<String, dynamic> u) {
    if (!mounted) return;
    // La foto propia ('foto') o, si no hay, la de la cuenta de Google ('avatar')
    final foto = (u['foto'] ?? u['avatar'] ?? '').toString();
    setState(() => _fotoUrl = foto.isEmpty ? null : foto);
  }

  void _aviso(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  // Abre la galería, sube la foto y la deja guardada en la base de datos
  Future<void> _cambiarFoto() async {
    if (_subiendoFoto) return;
    try {
      final archivo = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (archivo == null) return; // canceló

      final bytes = await archivo.readAsBytes();
      if (!mounted) return;
      setState(() => _subiendoFoto = true);

      final r = await AuthService.subirFotoPerfil(bytes);
      if (!mounted) return;

      setState(() {
        _subiendoFoto = false;
        if (r.exito) {
          final f = (r.usuario?['foto'] ?? '').toString();
          if (f.isNotEmpty) _fotoUrl = f;
        }
      });
      _aviso(r.exito ? 'Foto actualizada' : r.mensaje);
    } catch (_) {
      if (!mounted) return;
      setState(() => _subiendoFoto = false);
      _aviso('No se pudo abrir la galería');
    }
  }

  // Cierra la sesión, vacía el carrito que se ve en pantalla y vuelve al inicio.
  // El carrito sigue guardado en la base de datos: al volver a iniciar sesión
  // el usuario lo recupera.
  Future<void> _cerrarSesion() async {
    await AuthService.cerrarSesion();
    CarritoService.instancia.limpiarLocal(); // el siguiente usuario no ve este carrito
    BarraInferior.sesionIniciada = false; // cierra la sesión en la barra
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  // ---------- Navegación de la barra inferior ----------

  void _irAlInicio() =>
      Navigator.of(context).popUntil((ruta) => ruta.isFirst);

  void _abrirNotificaciones() {
    if (!Sesion.activa) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PantallaNotificaciones(token: Sesion.token!),
      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: Stack(
        fit: StackFit.expand, // el Stack ocupa toda la pantalla: el círculo queda al fondo
        children: [
          const CirculoDecorativo(degradado: true),
          SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Encabezado con degradado (ya sin la barra de iconos)
                    FondoDegradado(
                      alto: 170,
                      padding: EdgeInsets.zero,
                      child: const SizedBox.shrink(),
                    ),
                    Positioned(
                      bottom: -60,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: FotoPerfilEditable(
                          fotoUrl: _fotoUrl,
                          rutaPorDefecto: _rutaFoto,
                          subiendo: _subiendoFoto,
                          onEditar: _cambiarFoto,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 75),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 238, 232, 232).withOpacity(0.5), //fondo del cuadro de perfil
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Perfil',
                        style: Estilostextos.estilosTitulo
                            .copyWith(fontWeight: FontWeight.bold, fontFamily: 'serif'),
                      ),
                      const SizedBox(height: 16),
                      FormularioPerfil(onUsuario: _usuarioCargado),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 190,
                        child: BotonDegradado(
                          texto: 'Cerrar Sesión',
                          icono: Icons.logout,
                          onPressed: _cerrarSesion,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
      // Barra inferior: Inicio (casita), Notificaciones, Carrito y Contáctenos
      bottomNavigationBar: BarraInferior(
        onInicio: _irAlInicio,
        onNotificaciones: _abrirNotificaciones,
        onCarrito: _abrirCarrito,
        onContacto: _abrirContactenos,
      ),
    );
  }
}