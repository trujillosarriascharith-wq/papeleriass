/// Una categoría de la tienda, con el id real de la tabla "categorias".
class CategoriaApp {
  final int id;
  final String nombre;
  final String imagen;

  const CategoriaApp(this.id, this.nombre, this.imagen);
}

/// ÚNICO lugar donde se definen las categorías (las usan el menú lateral
/// del cliente y el formulario de ingresar productos).
const List<CategoriaApp> categoriasTienda = [
  CategoriaApp(1, 'Cuadernos', 'assets/images/cuadernos.png'),
  CategoriaApp(4, 'Colores', 'assets/images/colores.png'),
  CategoriaApp(6, 'Cartucheras', 'assets/images/cartucheras.png'),
  CategoriaApp(7, 'Temperas', 'assets/images/temperas.png'),
  CategoriaApp(8, 'Marcadores', 'assets/images/marcadores.jpg'),
  CategoriaApp(3, 'Pegamentos', 'assets/images/pegamentos.jpg'),
];