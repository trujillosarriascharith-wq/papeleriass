import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/categoria_service.dart';
import 'anexar_imagen.dart';

/// Abre el formulario flotante para crear una categoría.
Future<void> mostrarDialogoNuevaCategoria(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _DialogoNuevaCategoria(),
  );
}

class _DialogoNuevaCategoria extends StatefulWidget {
  const _DialogoNuevaCategoria();

  @override
  State<_DialogoNuevaCategoria> createState() => _DialogoNuevaCategoriaState();
}

class _DialogoNuevaCategoriaState extends State<_DialogoNuevaCategoria> {
  final _nombre = TextEditingController();
  final _descripcion = TextEditingController();
  Uint8List? _imagen;
  String _nombreImagen = 'categoria.jpg';
  bool _guardando = false;
  String? _error;

  @override
  void dispose() {
    _nombre.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final nombre = _nombre.text.trim();
    final descripcion = _descripcion.text.trim();

    if (_imagen == null) {
      setState(() => _error = 'Anexa una imagen de la categoría');
      return;
    }
    if (nombre.isEmpty) {
      setState(() => _error = 'Escribe el nombre de la categoría');
      return;
    }
    if (descripcion.isEmpty) {
      setState(() => _error = 'Escribe la descripción');
      return;
    }

    setState(() {
      _guardando = true;
      _error = null;
    });

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await CategoriaService.crear(
        nombre: nombre,
        descripcion: descripcion,
        imagen: _imagen!,
        nombreImagen: _nombreImagen,
      );
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text('Categoría "$nombre" creada')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva categoría'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnexarImagen(
              imagen: _imagen,
              onElegida: (bytes, nombre) => setState(() {
                _imagen = bytes;
                _nombreImagen = nombre;
                _error = null;
              }),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nombre,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Nombre de la categoría'),
            ),
            TextField(
              controller: _descripcion,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _guardando ? null : _guardar,
          child: _guardando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}