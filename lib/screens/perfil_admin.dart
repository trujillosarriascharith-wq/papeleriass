
// import 'package:flutter/material.dart';
// import 'package:papelerias/widgets/botondegradado.dart';
// import '../services/auth_service.dart';
// import '../theme/colores.dart';
// import '../theme/estilostextos.dart';
// import '../widgets/barrasuperior.dart';
// import '../widgets/fondodegradado.dart';
// import '../widgets/BarraInferior.dart';
// import '../widgets/formulario_perfil.dart';
// import 'home_screen.dart';

// /// Pantalla de Perfil del administrador
// class PerfilAdmin extends StatelessWidget {
//   const PerfilAdmin({super.key});

//   // Icono de persona por defecto (sin foto)
//   Widget _iconoPerfil() {
//     return const CircleAvatar(
//       radius: 58,
//       backgroundColor: Colors.white, //borde del icono
//       child: CircleAvatar(
//         radius: 54,
//         backgroundColor: Color(0xFFFFE0E8),
//         child: Icon(Icons.person, size: 60, color: Color(0xFFB03A5B)),
//       ),
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
//                     FondoDegradado(
//                       alto: 170,
//                       padding: const EdgeInsets.fromLTRB(12, 40, 12, 0),
//                       // Sub-barra con degradado y sombra encima del degradado grande
//                       child: Container(
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.35),
//                               blurRadius: 8,
//                               offset: const Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(12),
//                           child: FondoDegradado(
//                             alto: 34,
//                             padding: const EdgeInsets.symmetric(horizontal: 4),
//                             // El administrador solo tiene el icono de inicio
//                             child: BarraSuperior(
//                               colorIconos: Colors.black,
//                               compacto: true,
//                               iconoInicio: Icons.home_outlined,
//                               onInicio: () =>
//                                   Navigator.of(context).popUntil((r) => r.isFirst),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       bottom: -60,
//                       left: 0,
//                       right: 0,
//                       child: Center(child: _iconoPerfil()),
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
//                       const FormularioPerfil(),
//                       const SizedBox(height: 10),
//                       SizedBox(
//                         width: 190,
//                         child: BotonDegradado(
//                           texto: 'Cerrar Sesión',
//                           icono: Icons.logout,
//                           onPressed: () async {
//                             await AuthService.cerrarSesion();
//                             BarraInferior.sesionIniciada = false; // cierra la sesión en la barra
//                             if (!context.mounted) return;
//                             Navigator.pushAndRemoveUntil(
//                               context,
//                               MaterialPageRoute(builder: (_) => const HomeScreen()),
//                               (_) => false,
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 120),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:papelerias/widgets/botondegradado.dart';
import '../services/auth_service.dart';
import '../theme/colores.dart';
import '../theme/estilostextos.dart';
import '../widgets/barrasuperior.dart';
import '../widgets/fondodegradado.dart';
import '../widgets/BarraInferior.dart';
import '../widgets/formulario_perfil.dart';
import '../widgets/dialogo_eliminar_perfil.dart';
import 'home_screen.dart';

/// Pantalla de Perfil del administrador
class PerfilAdmin extends StatelessWidget {
  const PerfilAdmin({super.key});

  // Icono de persona por defecto (sin foto)
  Widget _iconoPerfil() {
    return const CircleAvatar(
      radius: 58,
      backgroundColor: Colors.white, //borde del icono
      child: CircleAvatar(
        radius: 54,
        backgroundColor: Color(0xFFFFE0E8),
        child: Icon(Icons.person, size: 60, color: Color(0xFFB03A5B)),
      ),
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
                            // El administrador solo tiene el icono de inicio
                            child: BarraSuperior(
                              colorIconos: Colors.black,
                              compacto: true,
                              iconoInicio: Icons.home_outlined,
                              onInicio: () =>
                                  Navigator.of(context).popUntil((r) => r.isFirst),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -60,
                      left: 0,
                      right: 0,
                      child: Center(child: _iconoPerfil()),
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
                      const FormularioPerfil(),
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
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => eliminarPerfil(context),
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        label: const Text(
                          'Eliminar perfil',
                          style: TextStyle(color: Colors.red),
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