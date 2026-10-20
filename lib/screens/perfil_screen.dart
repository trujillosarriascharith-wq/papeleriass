import 'package:flutter/material.dart';
import 'package:papelerias/widgets/botondegradado.dart';
import '../services/auth_service.dart';
import '../theme/colores.dart';
import '../theme/estilostextos.dart';
import '../widgets/barrasuperior.dart';
import '../widgets/fondodegradado.dart';
import '../widgets/campodetexto.dart';
import '../widgets/BarraInferior.dart';
import 'home_screen.dart';

/// Pantalla de Perfil del usuario
class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  static const _rutaFoto = 'assets/images/perfil.webp';
  static const _rutaGmail = 'assets/icons/gmail.webp';

  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _direccion = TextEditingController();
  final _telefono = TextEditingController();
  String? _fotoUrl;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final u = await AuthService.usuarioGuardado();
    if (u == null || !mounted) return;
    setState(() {
      _nombre.text = u['nombre']?.toString() ?? '';
      _correo.text = u['email']?.toString() ?? '';
      _direccion.text = u['direccion']?.toString() ?? '';
      _telefono.text = u['telefono']?.toString() ?? '';
      final f = u['foto']?.toString() ?? '';
      _fotoUrl = f.isEmpty ? null : f;
    });
  }

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _direccion.dispose();
    _telefono.dispose();
    super.dispose();
  }

  Widget _campo(String etiqueta, IconData icono, TextEditingController c,
      {TextInputType tipo = TextInputType.text, Widget? prefijo}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: CampoTexto(
        etiqueta: etiqueta,
        icono: icono,
        prefijo: prefijo,
        bordeColor: AppColors.primaryColor, //borde de los campos
        colorIcono: Colors.black,
        controller: c,
        tipoTeclado: tipo,
        iconoFinal: Icons.edit_outlined,
        onTapIconoFinal: () {},
      ),
    );
  }

  Widget _fotoPerfil() {
    final ImageProvider imagen = _fotoUrl != null
        ? NetworkImage(_fotoUrl!)
        : const AssetImage(_rutaFoto);

    return Stack(
      children: [
        CircleAvatar(
          radius: 58,
          backgroundColor: Colors.white, //borde de la foto
          child: CircleAvatar(radius: 54, backgroundImage: imagen),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {},
            child: const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Icon(Icons.camera_alt, size: 18, color: Colors.black),
            ),
          ),
        ),
      ],
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
                    FondoDegradado(
                      alto: 170,
                      padding: const EdgeInsets.fromLTRB(12, 40, 12, 0),
                      // Sub-barra con degradado y sombra encima del degradado grande
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: FondoDegradado(
                            alto: 34,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: BarraSuperior(
                              colorIconos: Colors.black,
                              compacto: true,
                              iconoInicio: Icons.home_outlined,
                              iconoPerfil: Icons.person_outline,
                              iconoCarrito: Icons.shopping_cart_outlined,
                              iconoNotificaciones: Icons.notifications_outlined,
                              onInicio: () =>
                                  Navigator.of(context).popUntil((r) => r.isFirst),
                              onCarrito: () {},
                              onNotificaciones: () {},
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -60,
                      left: 0,
                      right: 0,
                      child: Center(child: _fotoPerfil()),
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
                      _campo('Nombre', Icons.person_outline, _nombre),
                      _campo('Correo', Icons.email_outlined, _correo,
                          tipo: TextInputType.emailAddress,
                          prefijo: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Image.asset(_rutaGmail, width: 22, height: 22),
                          )),
                      _campo('Dirección', Icons.home_outlined, _direccion),
                      _campo('Teléfono', Icons.phone_outlined, _telefono,
                          tipo: TextInputType.phone),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 190,
                        child: BotonDegradado(
                          texto: 'Cerrar Sesión',
                          icono: Icons.logout,
                          onPressed: () async {
                            await AuthService.cerrarSesion();
                            BarraInferior.sesionIniciada = false; // cierra la sesión en la barra
                            if (!context.mounted) return;
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const HomeScreen()),
                              (_) => false,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }
}