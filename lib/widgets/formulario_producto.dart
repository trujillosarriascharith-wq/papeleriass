import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/producto_model.dart';
import '../services/crear_producto_service.dart';
import '../utils/texto_producto.dart';
import 'anexar_imagen.dart';
import 'boton_formulario.dart';
import 'campo_descripcion.dart';
import 'campo_etiquetado.dart';
import 'fila_valor_cantidad.dart';
import 'selector_categoria.dart';

/// Formulario completo para agregar un producto al inventario.
class FormularioProducto extends StatefulWidget {
  const FormularioProducto({super.key});

  @override
  State<FormularioProducto> createState() => _FormularioProductoState();
}

class _FormularioProductoState extends State<FormularioProducto> {
  final _nombre = TextEditingController();
  final _valor = TextEditingController();
  final _cantidad = TextEditingController();
  final _descripcion = TextEditingController(text: FormatoVinetas.inicial);
  int? _categoria;
  Uint8List? _imagen;
  String _nombreImagen = 'producto.jpg';
  bool _guardando = false;

  @override
  void dispose() {
    for (final c in [_nombre, _valor, _cantidad, _descripcion]) {
      c.dispose();
    }
    super.dispose();
  }

  void _aviso(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  // Devuelve el mensaje del primer problema, o null si todo está bien
  String? _validar() {
    if (_imagen == null) return 'Anexa una imagen del producto';
    if (_nombre.text.trim().isEmpty) return 'Escribe el nombre del producto';
    if (numeroDe(_valor.text) <= 0) return 'Escribe el valor (debe incluir números)';
    if (int.tryParse(_cantidad.text.trim()) == null) return 'Escribe la cantidad de unidades';
    if (_categoria == null) return 'Selecciona una categoría';
    if (lineasDeLista(_descripcion.text).isEmpty) return 'Escribe la descripción';
    return null;
  }

  Future<void> _agregar() async {
    final problema = _validar();
    if (problema != null) {
      _aviso(problema);
      return;
    }
    final producto = ProductoModel(
      idProducto: 0, // lo asigna la base de datos
      nombre: _nombre.text.trim(),
      imagen: '', // se llena con la URL cuando se sube la imagen
      descripcion: lineasDeLista(_descripcion.text),
      precio: numeroDe(_valor.text),
      cantidadStock: int.parse(_cantidad.text.trim()),
      idCategoria: _categoria!, // la categoría elegida en el formulario
    );
    final nombreCategoria =
        categoriasProducto.firstWhere((c) => c.id == _categoria).nombre;
    setState(() => _guardando = true);
    try {
      await CrearProductoService.crear(producto, _imagen!, _nombreImagen);
      if (!mounted) return;
      _limpiar();
      _aviso('Producto agregado a $nombreCategoria');
    } catch (e) {
      _aviso(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  // Deja el formulario vacío para agregar otro producto
  void _limpiar() {
    for (final c in [_nombre, _valor, _cantidad]) {
      c.clear();
    }
    _descripcion.text = FormatoVinetas.inicial;
    setState(() {
      _categoria = null;
      _imagen = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: AnexarImagen(
              imagen: _imagen,
              onElegida: (bytes, nombre) => setState(() {
                _imagen = bytes;
                _nombreImagen = nombre;
              }),
            ),
          ),
          const SizedBox(height: 18),
          CampoEtiquetado(etiqueta: 'Nombre del Producto', controller: _nombre),
          const SizedBox(height: 14),
          FilaValorCantidad(valor: _valor, cantidad: _cantidad),
          const SizedBox(height: 14),
          SelectorCategoria(
            valor: _categoria,
            onChanged: (v) => setState(() => _categoria = v),
          ),
          const SizedBox(height: 14),
          CampoDescripcion(controller: _descripcion),
          const SizedBox(height: 22),
          Center(
            child: BotonFormulario(
              texto: 'Agregar',
              cargando: _guardando,
              onPressed: _agregar,
            ),
          ),
        ],
      ),
    );
  }
}