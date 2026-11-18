import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../services/auth_service.dart';
import 'BarraInferior.dart';

/// Pantalla pequeña de confirmación. Devuelve true si el usuario acepta.
Future<bool> _confirmarEliminar(BuildContext context) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Eliminar perfil'),
      content: const Text(
        '¿Está seguro de realizar esta acción? '
        'Se eliminará su perfil de forma permanente.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Aceptar', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
  return r ?? false;
}

/// Flujo completo: confirmar -> eliminar en la BD -> cerrar sesión -> inicio.
Future<void> eliminarPerfil(
  BuildContext context, {
  VoidCallback? alEliminar,
}) async {
  if (!await _confirmarEliminar(context)) return;
  if (!context.mounted) return;

  final r = await AuthService.eliminarCuenta();
  if (!context.mounted) return;

  if (!r.exito) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(r.mensaje)));
    return;
  }

  await AuthService.cerrarSesion();
  alEliminar?.call(); // por ejemplo, vaciar el carrito local
  BarraInferior.sesionIniciada = false;
  if (!context.mounted) return;

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const HomeScreen()),
    (_) => false,
  );
}