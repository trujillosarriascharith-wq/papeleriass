// /// Una categoría de la tienda, con el id real de la tabla "categorias".
// class CategoriaApp {
//   final int id;
//   final String nombre;
//   final String imagen;

//   const CategoriaApp(this.id, this.nombre, this.imagen);
// }

// /// ÚNICO lugar donde se definen las categorías (las usan el menú lateral
// /// del cliente y el formulario de ingresar productos).
// const List<CategoriaApp> categoriasTienda = [
//   CategoriaApp(1, 'Cuadernos', 'assets/images/cuadernos.png'),
//   CategoriaApp(4, 'Colores', 'assets/images/colores.png'),
//   CategoriaApp(6, 'Cartucheras', 'assets/images/cartucheras.png'),
//   CategoriaApp(7, 'Temperas', 'assets/images/temperas.png'),
//   CategoriaApp(8, 'Marcadores', 'assets/images/marcadores.jpg'),
//   CategoriaApp(3, 'Pegamentos', 'assets/images/pegamentos.jpg'),
// ];
/// Una categoría de la tienda, con el id real de la tabla "categorias".
class CategoriaApp {
  final int id;
  final String nombre;
  final String imagen; // URL (o asset local) de la foto

  const CategoriaApp(this.id, this.nombre, this.imagen);

  /// Construye la categoría desde la respuesta del backend.
  factory CategoriaApp.fromJson(Map<String, dynamic> json) {
    return CategoriaApp(
      int.tryParse('${json['id_categoria'] ?? json['id']}') ?? 0,
      (json['nombre'] ?? '').toString(),
      (json['imagen'] ?? '').toString(),
    );
  }
}

/// Lista de respaldo con las categorías iniciales. Ya NO se usa en las pantallas:
/// las categorías ahora se leen de la base de datos con CategoriaService.
/// Se deja aquí solo para que nada que la importe deje de compilar.
const List<CategoriaApp> categoriasTienda = [
  CategoriaApp(1, 'Cuadernos', 'assets/images/cuadernos.png'),
  CategoriaApp(4, 'Colores', 'assets/images/colores.png'),
  CategoriaApp(6, 'Cartucheras', 'assets/images/cartucheras.png'),
  CategoriaApp(7, 'Temperas', 'assets/images/temperas.png'),
  CategoriaApp(8, 'Marcadores', 'assets/images/marcadores.jpg'),
  CategoriaApp(3, 'Pegamentos', 'assets/images/pegamentos.jpg'),
];