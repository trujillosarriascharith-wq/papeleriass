// //correcto hoy 23 /11
// import 'package:flutter/material.dart';
// import 'package:image_picker_android/image_picker_android.dart';
// import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
// import 'package:papelerias/screens/home_screen.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Android: usar el Photo Picker moderno, que muestra todas las imágenes del
//   // dispositivo (incluidas las de Descargas, donde llegan las fotos arrastradas al emulador)[cite: 18]
//   final ImagePickerPlatform picker = ImagePickerPlatform.instance;
//   if (picker is ImagePickerAndroid) {
//     picker.useAndroidPhotoPicker = true;
//   }

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Papeleria Juan Jose',
//       home: HomeScreen(),
//     );
//   }
// }
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:papelerias/screens/home_screen.dart';
import 'package:papelerias/screens/principal_admin.dart';
import 'package:papelerias/screens/principal_clienet.dart';
import 'package:papelerias/services/sesion.dart';
import 'package:papelerias/widgets/BarraInferior.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Android: usar el Photo Picker moderno, que muestra todas las imágenes del
  // dispositivo (incluidas las de Descargas, donde llegan las fotos arrastradas al emulador)
  final ImagePickerPlatform picker = ImagePickerPlatform.instance;
  if (picker is ImagePickerAndroid) {
    picker.useAndroidPhotoPicker = true;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Papeleria Juan Jose',
      home: const _PuertaDeSesion(),
    );
  }
}

/// Pantalla de arranque: revisa si ya hay una sesión guardada en el teléfono.
/// - Si hay sesión válida  -> entra directo a la pantalla de cliente o admin.
/// - Si no hay o expiró    -> muestra el HomeScreen normal.
class _PuertaDeSesion extends StatefulWidget {
  const _PuertaDeSesion();

  @override
  State<_PuertaDeSesion> createState() => _PuertaDeSesionState();
}

class _PuertaDeSesionState extends State<_PuertaDeSesion> {
  late final Future<Widget> _destino = _decidirPantalla();

  /// Revisa en el propio token (JWT) si todavía no ha vencido
  bool _tokenVigente(String token) {
    try {
      final partes = token.split('.');
      if (partes.length != 3) return false;

      final cuerpo =
          utf8.decode(base64Url.decode(base64Url.normalize(partes[1])));
      final datos = jsonDecode(cuerpo) as Map<String, dynamic>;

      final exp = datos['exp'];
      if (exp is! num) return true; // token sin vencimiento

      final ahora = DateTime.now().millisecondsSinceEpoch / 1000;
      return ahora < exp - 60; // margen de 1 minuto
    } catch (_) {
      return false;
    }
  }

  Future<Widget> _decidirPantalla() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final usuarioTexto = prefs.getString('usuario');

      if (token == null || token.isEmpty || usuarioTexto == null) {
        return const HomeScreen();
      }

      // Token vencido: se limpia y se pide iniciar sesión de nuevo
      if (!_tokenVigente(token)) {
        await prefs.remove('token');
        await prefs.remove('usuario');
        return const HomeScreen();
      }

      final usuario = jsonDecode(usuarioTexto) as Map<String, dynamic>;
      final rol = (usuario['rol'] ?? '').toString().toLowerCase();

      // Se restaura la sesión en memoria
      Sesion.token = token;
      BarraInferior.sesionIniciada = true;

      return rol.startsWith('admin')
          ? const PrincipalAdmin()
          : const PrincipalClient();
    } catch (_) {
      return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _destino,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data ?? const HomeScreen();
      },
    );
  }
}
