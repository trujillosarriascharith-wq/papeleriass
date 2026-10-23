import 'package:flutter/material.dart';
import '../models/categoria_app.dart';
import '../screens/categoria_screen.dart';
import '../services/categoria_service.dart';
import '../theme/colores.dart';
import '../theme/estilostextos.dart';
import 'imagen_categoria.dart';

/// Menú lateral reutilizable. Úsalo en cualquier pantalla:
///   Scaffold(drawer: const MenuLateral(), ...)
/// Si estás dentro de una categoría, pásala para resaltarla:
///   const MenuLateral(categoriaActiva: 'Cuadernos')
/// Las categorías se leen de la base de datos (CategoriaService).
class MenuLateral extends StatefulWidget {
  final String? categoriaActiva;

  const MenuLateral({super.key, this.categoriaActiva});

  @override
  State<MenuLateral> createState() => _MenuLateralState();
}

class _MenuLateralState extends State<MenuLateral> {
  @override
  void initState() {
    super.initState();
    CategoriaService.cargar(); // refresca las categorías al abrir el menú
  }

  void _abrirCategoria(BuildContext context, CategoriaApp cat) {
    final navigator = Navigator.of(context);

    navigator.pop(); // cierra el menú

    // Si ya estás en esa categoría, solo se cierra el menú
    if (cat.nombre == widget.categoriaActiva) return;

    navigator.push(
      MaterialPageRoute(
        builder: (_) => PantallaCategoria(titulo: cat.nombre, idCategoria: cat.id),
      ),
    );
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
              child: Text('Categorías', style: Estilostextos.estilosTitulo),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<CategoriaApp>>(
              valueListenable: CategoriaService.categorias,
              builder: (context, lista, _) {
                if (lista.isEmpty) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: CategoriaService.cargando,
                    builder: (context, cargando, _) => Center(
                      child: cargando
                          ? const CircularProgressIndicator()
                          : Text(
                              'No se pudieron cargar las categorías',
                              style: Estilostextos.estilosLetra,
                            ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: lista.length,
                  itemBuilder: (context, i) => _tarjeta(context, lista[i]),
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

  Widget _tarjeta(BuildContext context, CategoriaApp cat) {
    final activa = cat.nombre == widget.categoriaActiva;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: activa ? const Color(0xFFFFE0E8) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _abrirCategoria(context, cat),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF1F1F1)),
                  ),
                  child: ImagenCategoria(imagen: cat.imagen),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(cat.nombre, style: Estilostextos.estilosLetra),
                ),
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