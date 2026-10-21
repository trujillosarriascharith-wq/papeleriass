import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/carrito_item.dart';
import '../models/producto_model.dart';
import '../screens/productos_stock.dart';
import '../services/producto_service.dart';
import '../theme/colores.dart';
import '../theme/estilostextos.dart';

/// Tarjeta de un producto del inventario:
/// foto, nombre, precio, unidades y acciones de editar y eliminar.
class TarjetaInventario extends StatelessWidget {
  final ProductoModel producto;
  final VoidCallback? onActualizado; // Para refrescar la lista en la pantalla padre

  const TarjetaInventario({
    super.key,
    required this.producto,
    this.onActualizado,
  });

  // Pocas unidades = rojo (mismo límite que la pantalla de stock)
  bool get _stockBajo =>
      producto.cantidadStock <= PantallaProductosStock.umbralStockBajo;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryColor, width: 1),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _foto(),
          const SizedBox(width: 12),
          Expanded(child: _informacion()),
          const SizedBox(width: 8),
          _unidadesYAcciones(context),
        ],
      ),
    );
  }

  Widget _foto() {
    const tamano = 66.0;
    final img = producto.imagen;
    final error = Container(
      width: tamano,
      height: tamano,
      color: AppColors.fondoComponente,
      child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: img.startsWith('http')
          ? Image.network(img,
              width: tamano, height: tamano, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => error)
          : img.isEmpty
              ? error
              : Image.asset(img,
                  width: tamano, height: tamano, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => error),
    );
  }

  // Nombre arriba y precio debajo
  Widget _informacion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          producto.nombre,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: Estilostextos.estilosLetra.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          formatearPrecio(producto.precio),
          style: Estilostextos.estilosLetra.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: 'serif',
          ),
        ),
      ],
    );
  }

  // Unidades y botones de Editar (lápiz) / Eliminar
  Widget _unidadesYAcciones(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${producto.cantidadStock}',
          style: TextStyle(
            color: _stockBajo ? const Color(0xFFD50000) : const Color(0xFF00D26A),
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text('UD', style: Estilostextos.estilosLetra.copyWith(fontSize: 14)),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón Editar (Lápiz)
            InkWell(
              onTap: () => _mostrarDialogoEditar(context),
              borderRadius: BorderRadius.circular(15),
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(Icons.edit, size: 20, color: Colors.blueAccent),
              ),
            ),
            const SizedBox(width: 8),
            // Botón Eliminar (Papelera)
            InkWell(
              onTap: () => _confirmarEliminar(context),
              borderRadius: BorderRadius.circular(15),
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(Icons.delete, size: 20, color: Colors.redAccent),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Diálogo para editar la información del producto
  void _mostrarDialogoEditar(BuildContext context) {
    final nombreController = TextEditingController(text: producto.nombre);
    final descripcionController = TextEditingController(
      text: producto.descripcion.join(', '),
    );
    final precioController = TextEditingController(text: producto.precio.toString());
    final stockController = TextEditingController(text: producto.cantidadStock.toString());
    
    XFile? nuevaImagenXFile;
    Uint8List? imagenBytes;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Modificar Producto'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Vista previa de la imagen actual o nueva seleccionada
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          final bytes = await pickedFile.readAsBytes();
                          setStateDialog(() {
                            nuevaImagenXFile = pickedFile;
                            imagenBytes = bytes;
                          });
                        }
                      },
                      child: Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: imagenBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(imagenBytes!, fit: BoxFit.cover),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: producto.imagen.startsWith('http')
                                    ? Image.network(producto.imagen, fit: BoxFit.cover)
                                    : const Icon(Icons.camera_alt, color: Colors.grey),
                              ),
                      ),
                    ),
                    const Text('Toca la imagen para cambiarla', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nombreController,
                      decoration: const InputDecoration(labelText: 'Nombre del producto'),
                    ),
                    TextField(
                      controller: descripcionController,
                      decoration: const InputDecoration(labelText: 'Descripción (separada por comas)'),
                    ),
                    TextField(
                      controller: precioController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Precio'),
                    ),
                    TextField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Cantidad en Stock'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      // Construimos el modelo actualizado con los datos del formulario
                      final productoActualizado = ProductoModel(
                        idProducto: producto.idProducto,
                        nombre: nombreController.text,
                        imagen: producto.imagen, // Se mantiene o el backend gestiona la nueva
                        descripcion: descripcionController.text
                            .split(',')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList(),
                        precio: int.tryParse(precioController.text) ?? producto.precio,
                        cantidadStock: int.tryParse(stockController.text) ?? producto.cantidadStock,
                        idCategoria: producto.idCategoria,
                        estado: producto.estado,
                      );

                      // Llamada al método correcto en el servicio
                      await ProductoService.actualizar(
                        id: producto.idProducto,
                        producto: productoActualizado,
                        imagenBytes: imagenBytes,
                        nombreImagen: nuevaImagenXFile?.name,
                      );

                      if (context.mounted) {
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Producto actualizado con éxito')),
                        );
                        if (onActualizado != null) onActualizado!();
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al actualizar: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Diálogo de confirmación para eliminar
  void _confirmarEliminar(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text('¿Estás seguro de eliminar "${producto.nombre}" de la base de datos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                // Llamada al método correcto en el servicio
                await ProductoService.eliminar(producto.idProducto);
                if (context.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Producto eliminado correctamente')),
                  );
                  if (onActualizado != null) onActualizado!();
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al eliminar: $e')),
                  );
                }
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}