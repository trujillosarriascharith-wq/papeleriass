
import 'package:flutter/material.dart';
import '../models/categoria_app.dart';
import '../services/categoria_service.dart';
import '../theme/colores.dart';
import 'campo_etiquetado.dart';

/// Categorías cargadas de la base de datos (las mismas de los menús).
/// Se deja con este nombre para que formulario_producto.dart siga funcionando igual.
List<CategoriaApp> get categoriasProducto => CategoriaService.categorias.value;

/// Lista desplegable para elegir la categoría del producto.
/// Tiene el mismo estilo que [CampoTexto] (borde rosado y esquinas redondeadas).
class SelectorCategoria extends StatefulWidget {
  final int? valor;
  final ValueChanged<int?> onChanged;

  const SelectorCategoria({super.key, required this.valor, required this.onChanged});

  @override
  State<SelectorCategoria> createState() => _SelectorCategoriaState();
}

class _SelectorCategoriaState extends State<SelectorCategoria> {
  @override
  void initState() {
    super.initState();
    CategoriaService.cargar(); // así aparecen las categorías recién creadas
  }

  InputDecoration _decoracion() {
    final borde = OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
    );
    return InputDecoration(
      filled: true,
      fillColor: AppColors.fondoComponente,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: borde,
      enabledBorder: borde,
      focusedBorder: borde,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<CategoriaApp>>(
      valueListenable: CategoriaService.categorias,
      builder: (context, lista, _) {
        // Si el valor elegido ya no está en la lista, se deja vacío
        final valor = lista.any((c) => c.id == widget.valor) ? widget.valor : null;
        return CampoConEtiqueta(
          etiqueta: 'Categoría',
          campo: DropdownButtonFormField<int>(
            value: valor,
            isExpanded: true,
            hint: const Text('Selecciona una categoría'),
            decoration: _decoracion(),
            borderRadius: BorderRadius.circular(16),
            items: [
              for (final c in lista)
                DropdownMenuItem(value: c.id, child: Text(c.nombre)),
            ],
            onChanged: widget.onChanged,
          ),
        );
      },
    );
  }
}