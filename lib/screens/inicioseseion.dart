import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:papelerias/screens/recuperarcontrase%C3%B1a.dart';
import 'package:papelerias/screens/registrarse.dart';
import '../theme/colores.dart';
import '../theme/estilostextos.dart';
import '../widgets/barrasuperior.dart';
import '../services/google_auth_service.dart';
import '../services/auth_service.dart';
import '../widgets/campodetexto.dart';
import '../widgets/fondocurvo.dart';
import '../widgets/fondodegradado.dart';
import '../widgets/botondegradado.dart';
import 'principal_clienet.dart';
import 'admin_home.dart';


class InicioSesion extends StatefulWidget {
  const InicioSesion({super.key});

  @override
  State<InicioSesion> createState() => _InicioSesionState();
}

class _InicioSesionState extends State<InicioSesion> {
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _password = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _password.dispose();
    super.dispose();
  }

  void _aviso(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _iniciarSesion() async {
    final nombre = _nombre.text.trim();
    final correo = _correo.text.trim();
    final password = _password.text;

    if (nombre.isEmpty || correo.isEmpty || password.isEmpty) {
      _aviso('Completa todos los campos');
      return;
    }

    setState(() => _cargando = true);
    final r = await AuthService.login(
      nombre: nombre,
      correo: correo,
      password: password,
    );
    if (!mounted) return;
    setState(() => _cargando = false);

    if (!r.exito) {
      _aviso(r.mensaje);
      return;
    }

    _irSegunRol(r.usuario?['rol']?.toString());
  }

  void _irSegunRol(String? rol) {
  debugPrint('ROL RECIBIDO: $rol');

  final esAdmin = (rol ?? '').toLowerCase().startsWith('admin');
  final Widget destino =
      esAdmin ? const AdminHomeScreen() : const PrincipalClient();

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => destino),
    (_) => false,
  );
}

  Future<void> _iniciarConGoogle() async {
    try {
      final cuenta = await GoogleAuthService.iniciarSesion();
      if (cuenta == null) return; // canceló
      final idToken = cuenta.authentication.idToken;
      // TODO: enviar idToken a tu backend para verificarlo
      debugPrint(idToken == null ? 'Sin idToken' : 'idToken recibido');
      _aviso('Hola ${cuenta.displayName ?? cuenta.email}');
    } catch (e) {
      debugPrint('Error Google Sign-In: $e');
      _aviso('No se pudo iniciar sesión con Google');
    }
  }

  Widget _campo(String etiqueta, IconData icono, TextEditingController c,
      {bool password = false, TextInputType tipo = TextInputType.text, Widget? prefijo}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
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

  // Sub-barra con el mismo degradado, esquinas redondeadas y sombra
  Widget _subBarra() => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: FondoDegradado(
            alto: 48,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: BarraSuperior(
              onInicio: () => Navigator.pop(context),

              colorIconos: Colors.black,
              compacto: true,
            ),
          ),
        ),
      );

  Widget _avatar() => Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4), //color del bode del icono de iniciar sesion
        ),
        child: const Icon(Icons.person, size: 90, color: Color.fromARGB(255, 240, 255, 247)), //color del icono de iniciarsesion
      );

  Widget _tarjeta() => ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white.withOpacity(0.85),
            child: Column(
              children: [
                Text('Inicia Sesión', style: Estilostextos.estilosTitulo),
                const SizedBox(height: 16),
                _campo('Nombre', Icons.person_outline, _nombre),
                _campo('Correo', Icons.email, _correo),
                _campo('Contraseña', Icons.lock, _password, password: true),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RecuperarContrasena()),
                    );
                  },
                  child: Text('¿Olvidaste tu contraseña?', style: Estilostextos.estilosLetra),
                ),
                const SizedBox(height: 10),
                BotonDegradado(
                  texto: 'Iniciar Sesion',
                  cargando: _cargando,
                  onPressed: _iniciarSesion,
                ),
                const SizedBox(height: 16),
                Text('Inicia sesión con', style: Estilostextos.estilosLetra),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _iniciarConGoogle,
                  icon: Image.asset('assets/images/google.png', width: 50, height: 28),//icono de google
                  label: const Text('Google'),
                ),
                const SizedBox(height: 16),
                Text('¿No tienes cuenta aún?', style: Estilostextos.estilosLetra),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const Registrarse()),
                    );
                  },
                  child: const Text('Crear una cuenta'),
                ),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 237, 237), //fondo de la pagina
      body: FondoCurvo(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 8),
                _subBarra(),
                const SizedBox(height: 16),
                _avatar(),
                const SizedBox(height: 20),
                _tarjeta(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}