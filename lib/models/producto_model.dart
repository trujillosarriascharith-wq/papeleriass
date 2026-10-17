class ProductoModel {
  final int idProducto; // en BD es int
  final String nombre;
  final String imagen;
  final List<String> descripcion; // lo mantenemos como lista para tu UI, pero en BD se guarda como text
  final int precio;
  final int cantidadStock;
  final int idCategoria; // en BD es int
  final String estado;

  ProductoModel({
    required this.idProducto,
    required this.nombre,
    required this.imagen,
    required this.descripcion,
    required this.precio,
    required this.cantidadStock,
    required this.idCategoria,
    this.estado = 'activo',
  });

  // === COMPATIBILIDAD CON LA GUÍA ===
  String get imagenUrl => imagen;
  int get id => idProducto;
  String get id_producto => idProducto.toString();
  String get id_categoria => idCategoria.toString();
  int get cantidad_stock => cantidadStock;

  // Mapear la respuesta que viene de Supabase - VERSIÓN ROBUSTA
  factory ProductoModel.fromJson(Map<String, dynamic> json) {

    // Imagen puede venir como imagen, imagenUrl
    final img = json['imagen']?? json['imagenUrl']?? json['imagen_url']?? '';

    // Descripción: en tu tabla es String, pero en tu app la usas como Lista
    List<String> descList = [];
    final rawDesc = json['descripcion'];
    if (rawDesc is List) {
      descList = List<String>.from(rawDesc.map((e) => e.toString()));
    } else if (rawDesc is String && rawDesc.isNotEmpty) {
      // "Marca Norma, Cuadriculado, 50 Hojas" -> ["Marca Norma", "Cuadriculado", "50 Hojas"]
      descList = rawDesc.split(', ').where((l) => l.trim().isNotEmpty).toList();
    }

    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      return int.tryParse(v.toString())?? 0;
    }

    return ProductoModel(
      // ACEPTA id_producto, id, Id - y si viene String lo convierte a int
      idProducto: parseInt(json['id_producto']?? json['id']?? json['Id']),
      nombre: json['nombre']?? '',
      imagen: img.toString(),
      descripcion: descList,
      precio: parseInt(json['precio']),
      cantidadStock: parseInt(json['cantidad_stock']?? json['cantidadStock']),
      idCategoria: parseInt(json['id_categoria']?? json['idCategoria']),
      estado: json['estado']?? 'activo',
    );
  }

  // Convertir a Map para enviar a Supabase - CON NOMBRES REALES DE TU TABLA
  Map<String, dynamic> toJson() {
    return {
      'id_categoria': idCategoria,
      'nombre': nombre,
      'descripcion': descripcion.join(', '), // Lista -> Texto para tu columna text
      'precio': precio,
      'cantidad_stock': cantidadStock,
      'imagen': imagen,
      'estado': estado,
    };
  }

  // Para UPDATE no mandamos id_producto
  Map<String, dynamic> toJsonForInsert() {
    return toJson();
  }
}