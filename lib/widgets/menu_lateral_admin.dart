import 'package:flutter/material.dart';
import '../models/categoria_app.dart';
import '../screens/ingresar_productos.dart';
import '../screens/inventario_screen.dart';
import '../screens/productos_stock.dart';
import '../services/categoria_service.dart';
import '../theme/colores.dart';
import '../theme/estilostextos.dart';
import 'categoria_desplegable_admin.dart';
import 'dialogo_nueva_categoria.dart';

/// Una opción del menú del administrador.
/// [destino] es la pantalla a la que lleva. Si es null, muestra "próximamente".
class OpcionAdmin {
  final String nombre;
  final IconData icono;
  final WidgetBuilder? destino;

  const OpcionAdmin(this.nombre, this.icono, {this.destino});
}

/// ÚNICO lugar donde se definen las opciones del menú del administrador.
final List<OpcionAdmin> opcionesAdmin = [
  OpcionAdmin(
    'Inventario',
    Icons.inventory_2_outlined,
    destino: (_) => const PantallaInventario(),
  ),
  OpcionAdmin(
    'Ingresar productos',
    Icons.add_box_outlined,
    destino: (_) => const PantallaIngresarProductos(),
  ),
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
/// Si estás viendo una categoría del inventario, pasa también su id:
///   MenuLateralAdmin(opcionActiva: 'Inventario', categoriaActiva: 3)
class MenuLateralAdmin extends StatefulWidget {
  final String? opcionActiva;
  final int? categoriaActiva;

  const MenuLateralAdmin({super.key, this.opcionActiva, this.categoriaActiva});

  @override
  State<MenuLateralAdmin> createState() => _MenuLateralAdminState();
}

class _MenuLateralAdminState extends State<MenuLateralAdmin> {
  late bool _inventarioAbierto;

  @override
  void initState() {
    super.initState();
    // Si ya estás en el inventario, el menú arranca con las categorías abiertas
    _inventarioAbierto = widget.opcionActiva == 'Inventario';
    CategoriaService.cargar(); // refresca las categorías desde la base de datos
  }

  void _abrirOpcion(BuildContext context, OpcionAdmin opcion) {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    navigator.pop(); // cierra el menú

    // Si ya estás en esa opción, solo se cierra el menú
    if (opcion.nombre == widget.opcionActiva) return;

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

  // Abre el inventario completo (categoria == null) o el de una categoría
  void _abrirInventario(BuildContext context, {CategoriaApp? categoria}) {
    final navigator = Navigator.of(context);
    navigator.pop(); // cierra el menú

    final yaEstoyAhi = widget.opcionActiva == 'Inventario' &&
        widget.categoriaActiva == categoria?.id;
    if (yaEstoyAhi) return;

    final ruta = MaterialPageRoute(
      builder: (_) => PantallaInventario(
        idCategoria: categoria?.id,
        nombreCategoria: categoria?.nombre,
      ),
    );

    // Si ya estás en una pantalla de inventario, se reemplaza para no apilarlas
    if (widget.opcionActiva == 'Inventario') {
      navigator.pushReplacement(ruta);
    } else {
      navigator.push(ruta);
    }
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
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final opcion in opcionesAdmin) ..._bloqueOpcion(context, opcion),
              ],
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

  // Cada opción del menú. "Inventario" lleva debajo la lista desplegable.
  List<Widget> _bloqueOpcion(BuildContext context, OpcionAdmin opcion) {
    final activa = opcion.nombre == widget.opcionActiva;

    if (opcion.nombre != 'Inventario') {
      return [
        _tarjeta(
          opcion,
          activa: activa,
          onTap: () => _abrirOpcion(context, opcion),
        ),
      ];
    }

    return [
      _tarjeta(
        opcion,
        activa: activa,
        onTap: () => setState(() => _inventarioAbierto = !_inventarioAbierto),
        flecha: AnimatedRotation(
          turns: _inventarioAbierto ? 0.25 : 0,
          duration: const Duration(milliseconds: 200),
          child: Icon(
            Icons.chevron_right_rounded,
            color: activa ? const Color(0xFFB03A5B) : Colors.grey.shade400,
          ),
        ),
      ),
      AnimatedSize(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.topCenter,
        child: _inventarioAbierto
            ? CategoriasDesplegablesAdmin(
                categoriaActiva: widget.categoriaActiva,
                todosActivo:
                    widget.opcionActiva == 'Inventario' && widget.categoriaActiva == null,
                onTodos: () => _abrirInventario(context),
                onCategoria: (c) => _abrirInventario(context, categoria: c),
                onNueva: () => mostrarDialogoNuevaCategoria(context),
              )
            : const SizedBox(width: double.infinity, height: 0),
      ),
    ];
  }

  Widget _tarjeta(
    OpcionAdmin opcion, {
    required bool activa,
    required VoidCallback onTap,
    Widget? flecha,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: activa ? const Color(0xFFFFE0E8) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE0E8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(opcion.icono, color: const Color(0xFFB03A5B)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(opcion.nombre, style: Estilostextos.estilosLetra),
                ),
                flecha ??
                    Icon(
                      Icons.chevron_right_rounded,
                      color: activa ? const Color(0xFFB03A5B) : Colors.grey.shade400,
                    ),
              ],
            ),
          ),
        ),
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