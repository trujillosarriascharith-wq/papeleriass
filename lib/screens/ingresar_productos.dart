import 'package:flutter/material.dart';
import 'package:papelerias/screens/perfil_admin.dart';
import '../theme/colores.dart';
import '../widgets/BarraInferior.dart';
import '../widgets/encabezado_admin.dart';
import '../widgets/fondodegradado.dart';
import '../widgets/formulario_producto.dart';
import '../widgets/menu_lateral_admin.dart';
import '../widgets/panel_gris.dart';

/// Pantalla para agregar un producto al inventario.
class PantallaIngresarProductos extends StatelessWidget {
  const PantallaIngresarProductos({super.key});

  // Vuelve a la pantalla principal del administrador
  void _irAlInicio(BuildContext context) {
    Navigator.popUntil(context, (ruta) => ruta.isFirst);
  }

  void _abrirPerfil(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PerfilAdmin()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      drawer: const MenuLateralAdmin(opcionActiva: 'Ingresar productos'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              FondoDegradado(
                alto: 100,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                child: const EncabezadoAdmin(),
              ),
              const Expanded(
                child: PanelGris(child: FormularioProducto()),
              ),
            ],
          ),
        ),
      ),
      // Barra inferior del administrador: Inicio y Perfil
      bottomNavigationBar: BarraInferior(
        onInicio: () => _irAlInicio(context),
        onPerfil: () => _abrirPerfil(context),
      ),
    );
  }
}