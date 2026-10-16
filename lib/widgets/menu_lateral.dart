import 'package:flutter/material.dart';
import '../theme/colores.dart';
import '../theme/estilostextos.dart';

/// Una categoría del menú.
/// [destino] es la pantalla a la que lleva. Si es null, muestra "próximamente".
class CategoriaMenu {
  final String nombre;
  final String imagen;
  final WidgetBuilder? destino;

  const CategoriaMenu(this.nombre, this.imagen, {this.destino});
}

/// ÚNICO lugar donde se definen las categorías y a dónde lleva cada una.
/// Para conectar una pantalla, agrega el parámetro destino, por ejemplo:
///   CategoriaMenu('Cuadernos', 'assets/images/cuadernos.png',
///       destino: (_) => const PantallaCuadernos()),
/// (no olvides importar la pantalla arriba en este archivo)
final List<CategoriaMenu> categoriasApp = [
  CategoriaMenu('Cuadernos', 'assets/images/cuadernos.png'),
  CategoriaMenu('Colores', 'assets/images/colores.png'),
  CategoriaMenu('Cartucheras', 'assets/images/cartucheras.png'),
  CategoriaMenu('Temperas', 'assets/images/temperas.png'),
  CategoriaMenu('Marcadores', 'assets/images/marcadores.jpg'),
  CategoriaMenu('Pegamentos', 'assets/images/pegamentos.jpg'),
];

/// Menú lateral reutilizable. Úsalo en cualquier pantalla:
///   Scaffold(drawer: const MenuLateral(), ...)
/// Si estás dentro de una categoría, pásala para resaltarla:
///   const MenuLateral(categoriaActiva: 'Cuadernos')
class MenuLateral extends StatelessWidget {
  final String? categoriaActiva;

  const MenuLateral({super.key, this.categoriaActiva});

  void _abrirCategoria(BuildContext context, CategoriaMenu cat) {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    navigator.pop(); // cierra el menú

    // Si ya estás en esa categoría, solo se cierra el menú
    if (cat.nombre == categoriaActiva) return;

    if (cat.destino == null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Categoría ${cat.nombre} próximamente'),
          backgroundColor: const Color(0xFFFF8FAB),
        ),
      );
      return;
    }
    navigator.push(MaterialPageRoute(builder: cat.destino!));
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
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categoriasApp.length,
              itemBuilder: (context, i) {
                final cat = categoriasApp[i];
                final activa = cat.nombre == categoriaActiva;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Material(
                    color: activa ? const Color(0xFFFFE0E8) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _abrirCategoria(context, cat),
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
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFF1F1F1),
                                ),
                              ),
                              child: Image.asset(
                                cat.imagen,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                cat.nombre,
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
