import 'package:flutter/material.dart';
import '../screens/inventario_screen.dart';
import '../screens/productos_stock.dart';
import '../theme/colores.dart';
import '../theme/estilostextos.dart';

/// Una opción del menú del administrador.
/// [destino] es la pantalla a la que lleva. Si es null, muestra "próximamente".
class OpcionAdmin {
  final String nombre;
  final IconData icono;
  final WidgetBuilder? destino;

  const OpcionAdmin(this.nombre, this.icono, {this.destino});
}

/// ÚNICO lugar donde se definen las opciones del menú del administrador.
/// Para conectar una pantalla, agrega el parámetro destino, por ejemplo:
///   OpcionAdmin('Ingresar productos', Icons.add_box_outlined,
///       destino: (_) => const PantallaIngresarProductos()),
/// (no olvides importar la pantalla arriba en este archivo)
final List<OpcionAdmin> opcionesAdmin = [
  OpcionAdmin(
    'Inventario',
    Icons.inventory_2_outlined,
    destino: (_) => const PantallaInventario(),
  ),
  OpcionAdmin('Ingresar productos', Icons.add_box_outlined),
  OpcionAdmin(
    'Productos en stock',
    Icons.list_alt_rounded,
    destino: (_) => const PantallaProductosStock(),
  ),
];

/// Menú lateral del administrador. Úsalo en las pantallas de administrador:
///   Scaffold(drawer: const MenuLateralAdmin(), ...)
/// Si estás dentro de una opción, pásala para resaltarla:
///   const MenuLateralAdmin(opcionActiva: 'Inventario')
class MenuLateralAdmin extends StatelessWidget {
  final String? opcionActiva;

  const MenuLateralAdmin({super.key, this.opcionActiva});

  void _abrirOpcion(BuildContext context, OpcionAdmin opcion) {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    navigator.pop(); // cierra el menú

    // Si ya estás en esa opción, solo se cierra el menú
    if (opcion.nombre == opcionActiva) return;

    if (opcion.destino == null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('${opcion.nombre} próximamente'),
          backgroundColor: const Color(0xFFFF8FAB),
        ),
      );
      return;
    }
    navigator.push(MaterialPageRoute(builder: opcion.destino!));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.fondo,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _encabezado(context),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Gestión de inventario', style: Estilostextos.estilosTitulo),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: opcionesAdmin.length,
              itemBuilder: (context, i) {
                final opcion = opcionesAdmin[i];
                final activa = opcion.nombre == opcionActiva;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Material(
                    color: activa ? const Color(0xFFFFE0E8) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _abrirOpcion(context, opcion),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE0E8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                opcion.icono,
                                color: const Color(0xFFB03A5B),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                opcion.nombre,
                                style: Estilostextos.estilosLetra,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: activa
                                  ? const Color(0xFFB03A5B)
                                  : Colors.grey.shade400,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Papelería y Variedades Juan José',
                style: Estilostextos.estilosContacto,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _encabezado(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 20,
        20,
        20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF9627F), Color(0xFFA33550)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.only(topRight: Radius.circular(24)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage('assets/images/logo2.png'),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Papelería y Variedades\nJuan José',
              style: Estilostextos.estilosBienvenida,
            ),
          ),
        ],
      ),
    );
  }
}