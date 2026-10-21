// import 'package:flutter/material.dart';
// import 'package:papelerias/screens/perfil_admin.dart';
// import '../models/producto_model.dart';
// import '../theme/colores.dart';
// import '../theme/estilostextos.dart';
// import '../widgets/BarraInferior.dart';
// import '../widgets/fondodegradado.dart';
// import '../widgets/menu_lateral_admin.dart';
// import '../widgets/tarjetainventario.dart';

// /// Inventario completo. Los productos aparecen aquí cuando el administrador
// /// los agrega en la pantalla de "Ingresar productos".
// class PantallaInventario extends StatefulWidget {
//   const PantallaInventario({super.key});

//   @override
//   State<PantallaInventario> createState() => _PantallaInventarioState();
// }

// class _PantallaInventarioState extends State<PantallaInventario> {
//   final _busqueda = TextEditingController();
//   List<ProductoModel> _productos = [];
//   bool _cargando = true;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _cargar();
//   }

//   @override
//   void dispose() {
//     _busqueda.dispose();
//     super.dispose();
//   }

//   /// Trae todos los productos del inventario.
//   Future<List<ProductoModel>> _pedirProductos() async {
//     // TODO: pedir al backend todos los productos del inventario,
//     // por ejemplo con tu producto_service.dart.
//     return [];
//   }

//   Future<void> _cargar() async {
//     setState(() {
//       _cargando = true;
//       _error = null;
//     });
//     try {
//       final datos = await _pedirProductos();
//       if (mounted) setState(() => _productos = datos);
//     } catch (e) {
//       if (mounted) {
//         setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
//       }
//     } finally {
//       if (mounted) setState(() => _cargando = false);
//     }
//   }

//   // Productos que coinciden con lo escrito en la barra de búsqueda
//   List<ProductoModel> get _filtrados {
//     final texto = _busqueda.text.trim().toLowerCase();
//     if (texto.isEmpty) return _productos;
//     return _productos.where((p) => p.nombre.toLowerCase().contains(texto)).toList();
//   }

//   // ---------- Navegación ----------

//   // Vuelve a la pantalla principal del administrador
//   void _irAlInicio() {
//     Navigator.popUntil(context, (ruta) => ruta.isFirst);
//   }

//   void _abrirPerfil() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const PerfilAdmin()),
//     );
//   }

//   // Abre "Ingresar productos" usando la pantalla conectada en el menú del
//   // administrador (menu_lateral_admin.dart). Al volver, recarga la lista para
//   // que aparezcan los productos recién agregados.
//   Future<void> _abrirIngresarProductos() async {
//     WidgetBuilder? destino;
//     for (final o in opcionesAdmin) {
//       if (o.nombre == 'Ingresar productos') destino = o.destino;
//     }

//     if (destino == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Ingresar productos próximamente'),
//           backgroundColor: Color(0xFFFF8FAB),
//         ),
//       );
//       return;
//     }

//     await Navigator.push(context, MaterialPageRoute(builder: destino));
//     if (mounted) _cargar();
//   }

//   // ---------- Widgets ----------

//   // Barra de búsqueda sobre fondo con degradado
//   Widget _barraBusqueda() {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(16),
//       child: FondoDegradado(
//         alto: 60,
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//         child: TextField(
//           controller: _busqueda,
//           onChanged: (_) => setState(() {}),
//           style: Estilostextos.estilosLetra,
//           decoration: InputDecoration(
//             hintText: 'Buscar Producto',
//             hintStyle: Estilostextos.estilosLetra.copyWith(
//               fontWeight: FontWeight.w400,
//               color: Colors.black54,
//             ),
//             prefixIcon: const Icon(Icons.search, color: Colors.black),
//             filled: true,
//             fillColor: Colors.white,
//             isDense: true,
//             contentPadding: const EdgeInsets.symmetric(vertical: 10),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(22),
//               borderSide: BorderSide.none,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _contenido() {
//     if (_cargando) return const Center(child: CircularProgressIndicator());

//     if (_error != null) {
//       return Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(_error!, textAlign: TextAlign.center),
//             TextButton(onPressed: _cargar, child: const Text('Reintentar')),
//           ],
//         ),
//       );
//     }

//     // Aún no hay productos en el inventario: no se muestra nada
//     if (_productos.isEmpty) return const SizedBox.shrink();

//     final lista = _filtrados;

//     // Hay productos, pero ninguno coincide con la búsqueda
//     if (lista.isEmpty) {
//       return Center(
//         child: Text('No se encontraron productos',
//             style: Estilostextos.estilosLetra),
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: _cargar,
//       child: ListView.builder(
//         physics: const AlwaysScrollableScrollPhysics(),
//         padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
//         itemCount: lista.length,
//         itemBuilder: (_, i) => TarjetaInventario(
//           key: ValueKey(lista[i].idProducto),
//           producto: lista[i],
//         ),
//       ),
//     );
//   }

//   // Círculo negro con "+" para agregar un producto
//   Widget _botonAgregar() {
//     return Tooltip(
//       message: 'Agregar producto',
//       preferBelow: false,
//       waitDuration: const Duration(milliseconds: 200),
//       showDuration: const Duration(seconds: 2),
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//       decoration: BoxDecoration(
//         color: const Color.fromARGB(255, 235, 96, 140),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       textStyle: const TextStyle(
//         color: Colors.white,
//         fontSize: 14,
//         fontWeight: FontWeight.w600,
//       ),
//       child: Material(
//         color: Colors.black,
//         shape: const CircleBorder(),
//         child: InkWell(
//           customBorder: const CircleBorder(),
//           onTap: _abrirIngresarProductos,
//           child: const SizedBox(
//             width: 52,
//             height: 52,
//             child: Icon(Icons.add_rounded, color: Colors.white, size: 38),
//           ),
//         ),
//       ),
//     );
//   }

//   // Panel gris con la lista y el botón de agregar
//   Widget _panel() {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(12, 12, 12, 12),
//       decoration: BoxDecoration(
//         color: const Color(0xFFE4E4E4),
//         borderRadius: BorderRadius.circular(28),
//       ),
//       child: Column(
//         children: [
//           Expanded(child: _contenido()),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 4, 20, 14),
//             child: Align(
//               alignment: Alignment.centerRight,
//               child: _botonAgregar(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.fondo,
//       drawer: const MenuLateralAdmin(opcionActiva: 'Inventario'),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(5),
//           child: Column(
//             children: [
//               FondoDegradado(
//                 alto: 100,
//                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
//                 child: _encabezado(),
//               ),
//               const SizedBox(height: 8),
//               _barraBusqueda(),
//               Expanded(child: _panel()),
//             ],
//           ),
//         ),
//       ),
//       // Barra inferior del administrador: Inicio y Perfil
//       bottomNavigationBar: BarraInferior(
//         onInicio: _irAlInicio,
//         onPerfil: _abrirPerfil,
//       ),
//     );
//   }

//   // Encabezado: [menú] [logo] [texto]
//   Widget _encabezado() {
//     const iconConstraints = BoxConstraints(minWidth: 40, minHeight: 40);

//     return Row(
//       children: [
//         Builder(
//           builder: (ctx) => IconButton(
//             onPressed: () => Scaffold.of(ctx).openDrawer(),
//             icon: const Icon(Icons.menu_rounded),
//             iconSize: 30,
//             color: Colors.white,
//             tooltip: 'Menú',
//             padding: EdgeInsets.zero,
//             constraints: iconConstraints,
//           ),
//         ),
//         const SizedBox(width: 4),
//         const CircleAvatar(
//           radius: 30,
//           backgroundColor: Colors.white,
//           backgroundImage: AssetImage('assets/images/logo2.png'),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: FittedBox(
//             fit: BoxFit.scaleDown,
//             child: Text(
//               'Papelería y Variedades\nJuan José',
//               textAlign: TextAlign.center,
//               style: Estilostextos.estilosBienvenida,
//             ),
//           ),
//         ),
//         // Mismo ancho que el icono del menú para que el texto quede centrado
//         const SizedBox(width: 40),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:papelerias/screens/perfil_admin.dart';
import '../models/producto_model.dart';
import '../services/producto_service.dart';
import '../theme/colores.dart';
import '../theme/estilostextos.dart';
import '../widgets/BarraInferior.dart';
import '../widgets/fondodegradado.dart';
import '../widgets/menu_lateral_admin.dart';
import '../widgets/tarjetainventario.dart';

/// Inventario completo. Los productos aparecen aquí cuando el administrador
/// los agrega en la pantalla de "Ingresar productos".
class PantallaInventario extends StatefulWidget {
  const PantallaInventario({super.key});

  @override
  State<PantallaInventario> createState() => _PantallaInventarioState();
}

class _PantallaInventarioState extends State<PantallaInventario> {
  final _busqueda = TextEditingController();
  List<ProductoModel> _productos = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  /// Trae todos los productos del inventario.
  Future<List<ProductoModel>> _pedirProductos() async {
    final todos = await ProductoService.listar();
    todos.sort((a, b) => b.idProducto.compareTo(a.idProducto)); // los nuevos primero
    return todos;
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final datos = await _pedirProductos();
      if (mounted) setState(() => _productos = datos);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  // Productos que coinciden con lo escrito en la barra de búsqueda
  List<ProductoModel> get _filtrados {
    final texto = _busqueda.text.trim().toLowerCase();
    if (texto.isEmpty) return _productos;
    return _productos.where((p) => p.nombre.toLowerCase().contains(texto)).toList();
  }

  // ---------- Navegación ----------

  // Vuelve a la pantalla principal del administrador
  void _irAlInicio() {
    Navigator.popUntil(context, (ruta) => ruta.isFirst);
  }

  void _abrirPerfil() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PerfilAdmin()),
    );
  }

  // Abre "Ingresar productos" usando la pantalla conectada en el menú del
  // administrador (menu_lateral_admin.dart). Al volver, recarga la lista para
  // que aparezcan los productos recién agregados.
  Future<void> _abrirIngresarProductos() async {
    WidgetBuilder? destino;
    for (final o in opcionesAdmin) {
      if (o.nombre == 'Ingresar productos') destino = o.destino;
    }

    if (destino == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresar productos próximamente'),
          backgroundColor: Color(0xFFFF8FAB),
        ),
      );
      return;
    }

    await Navigator.push(context, MaterialPageRoute(builder: destino));
    if (mounted) _cargar();
  }

  // ---------- Widgets ----------

  // Barra de búsqueda sobre fondo con degradado
  Widget _barraBusqueda() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: FondoDegradado(
        alto: 60,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: TextField(
          controller: _busqueda,
          onChanged: (_) => setState(() {}),
          style: Estilostextos.estilosLetra,
          decoration: InputDecoration(
            hintText: 'Buscar Producto',
            hintStyle: Estilostextos.estilosLetra.copyWith(
              fontWeight: FontWeight.w400,
              color: Colors.black54,
            ),
            prefixIcon: const Icon(Icons.search, color: Colors.black),
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _contenido() {
    if (_cargando) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            TextButton(onPressed: _cargar, child: const Text('Reintentar')),
          ],
        ),
      );
    }

    // Aún no hay productos en el inventario: no se muestra nada
    if (_productos.isEmpty) return const SizedBox.shrink();

    final lista = _filtrados;

    // Hay productos, pero ninguno coincide con la búsqueda
    if (lista.isEmpty) {
      return Center(
        child: Text('No se encontraron productos',
            style: Estilostextos.estilosLetra),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        itemCount: lista.length,
        itemBuilder: (_, i) => TarjetaInventario(
          key: ValueKey(lista[i].idProducto),
          producto: lista[i],
        ),
      ),
    );
  }

  // Círculo negro con "+" para agregar un producto
  Widget _botonAgregar() {
    return Tooltip(
      message: 'Agregar producto',
      preferBelow: false,
      waitDuration: const Duration(milliseconds: 200),
      showDuration: const Duration(seconds: 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 235, 96, 140),
        borderRadius: BorderRadius.circular(14),
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      child: Material(
        color: Colors.black,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: _abrirIngresarProductos,
          child: const SizedBox(
            width: 52,
            height: 52,
            child: Icon(Icons.add_rounded, color: Colors.white, size: 38),
          ),
        ),
      ),
    );
  }

  // Panel gris con la lista y el botón de agregar
  Widget _panel() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE4E4E4),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Expanded(child: _contenido()),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 20, 14),
            child: Align(
              alignment: Alignment.centerRight,
              child: _botonAgregar(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      drawer: const MenuLateralAdmin(opcionActiva: 'Inventario'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              FondoDegradado(
                alto: 100,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                child: _encabezado(),
              ),
              const SizedBox(height: 8),
              _barraBusqueda(),
              Expanded(child: _panel()),
            ],
          ),
        ),
      ),
      // Barra inferior del administrador: Inicio y Perfil
      bottomNavigationBar: BarraInferior(
        onInicio: _irAlInicio,
        onPerfil: _abrirPerfil,
      ),
    );
  }

  // Encabezado: [menú] [logo] [texto]
  Widget _encabezado() {
    const iconConstraints = BoxConstraints(minWidth: 40, minHeight: 40);

    return Row(
      children: [
        Builder(
          builder: (ctx) => IconButton(
            onPressed: () => Scaffold.of(ctx).openDrawer(),
            icon: const Icon(Icons.menu_rounded),
            iconSize: 30,
            color: Colors.white,
            tooltip: 'Menú',
            padding: EdgeInsets.zero,
            constraints: iconConstraints,
          ),
        ),
        const SizedBox(width: 4),
        const CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white,
          backgroundImage: AssetImage('assets/images/logo2.png'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Papelería y Variedades\nJuan José',
              textAlign: TextAlign.center,
              style: Estilostextos.estilosBienvenida,
            ),
          ),
        ),
        // Mismo ancho que el icono del menú para que el texto quede centrado
        const SizedBox(width: 40),
      ],
    );
  }
}