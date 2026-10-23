import 'package:flutter/material.dart';
import '../models/categoria_app.dart';
import '../services/categoria_service.dart';
import '../theme/estilostextos.dart';
import 'imagen_categoria.dart';

/// Lista que se despliega bajo "Inventario" en el menú del administrador:
/// "Todos los productos", cada categoría y "Agregar nueva categoría".
class CategoriasDesplegablesAdmin extends StatelessWidget {
  final int? categoriaActiva; // id de la categoría que se está viendo
  final bool todosActivo; // true si se está viendo el inventario completo
  final VoidCallback onTodos;
  final ValueChanged<CategoriaApp> onCategoria;
  final VoidCallback onNueva;

  const CategoriasDesplegablesAdmin({
    super.key,
    required this.categoriaActiva,
    required this.todosActivo,
    required this.onTodos,
    required this.onCategoria,
    required this.onNueva,
  });

  static const _rosa = Color(0xFFB03A5B);

  Widget _fila({
    required Widget icono,
    required String texto,
    required bool activa,
    required VoidCallback onTap,
    bool destacada = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Material(
        color: activa ? const Color(0xFFFFE0E8) : const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                SizedBox(width: 40, height: 40, child: icono),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    texto,
                    style: Estilostextos.estilosLetra.copyWith(
                      color: destacada ? _rosa : null,
                      fontWeight: destacada ? FontWeight.w600 : null,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: activa ? _rosa : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconoRosa(IconData icono) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFE0E8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icono, color: _rosa, size: 22),
    );
  }

  Widget _iconoCategoria(CategoriaApp c) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF1F1F1)),
      ),
      child: ImagenCategoria(imagen: c.imagen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, bottom: 4),
      child: Column(
        children: [
          _fila(
            icono: _iconoRosa(Icons.inventory_2_outlined),
            texto: 'Todos los productos',
            activa: todosActivo,
            onTap: onTodos,
          ),
          ValueListenableBuilder<List<CategoriaApp>>(
            valueListenable: CategoriaService.categorias,
            builder: (context, lista, _) {
              if (lista.isEmpty) {
                return ValueListenableBuilder<bool>(
                  valueListenable: CategoriaService.cargando,
                  builder: (context, cargando, _) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: cargando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text('No hay categorías', style: Estilostextos.estilosLetra),
                  ),
                );
              }
              return Column(
                children: [
                  for (final c in lista)
                    _fila(
                      icono: _iconoCategoria(c),
                      texto: c.nombre,
                      activa: c.id == categoriaActiva,
                      onTap: () => onCategoria(c),
                    ),
                ],
              );
            },
          ),
          _fila(
            icono: _iconoRosa(Icons.add_rounded),
            texto: 'Agregar nueva categoría',
            activa: false,
            destacada: true,
            onTap: onNueva,
          ),
        ],
      ),
    );
  }
}