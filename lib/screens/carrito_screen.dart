import 'package:flutter/material.dart';
import 'package:papelerias/screens/notificaciones.dart';
import 'package:papelerias/screens/contactenos.dart';
import 'package:papelerias/screens/perfil_screen.dart';
import '../models/carrito_item.dart';
import '../services/carrito_service.dart';
import '../services/sesion.dart';
import '../theme/colores.dart';
import '../theme/estilostextos.dart';
import '../widgets/BarraInferior.dart';
import '../widgets/encabezado_tienda.dart';
import '../widgets/menu_lateral.dart';
import '../widgets/tarjetascarrito.dart';
import 'pedidos_screen.dart';

class PantallaCarrito extends StatefulWidget {
  const PantallaCarrito({super.key});

  @override
  State<PantallaCarrito> createState() => _PantallaCarritoState();
}

class _PantallaCarritoState extends State<PantallaCarrito> {
  @override
  void initState() {
    super.initState();
    // Trae el carrito guardado en la base de datos
    CarritoService.instancia.cargar();
  }

  // Muestra un aviso si la operación devolvió un mensaje de error
  void _avisar(String? mensaje) {
    if (mensaje == null || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // INICIAR COMPRA: abre la pantalla de Pedido con los productos marcados
  void _iniciarCompra(BuildContext context) {
    if (CarritoService.instancia.seleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un producto')),
      );
      return;
    }
    if (!Sesion.activa) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para hacer tu pedido')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PantallaPedidos()),
    );
  }

  // Lleva a la pantalla del perfil del usuario
  void _abrirPerfil(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PerfilScreen()),
    );
  }

  // Abre las notificaciones solo si hay sesión iniciada (necesita el token)
  void _abrirNotificaciones(BuildContext context) {
    if (!Sesion.activa) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para ver tus notificaciones')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PantallaNotificaciones(token: Sesion.token!),
      ),
    );
  }

  void _abrirContactenos(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PantallaContactenos()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final carrito = CarritoService.instancia;

    return Scaffold(
      backgroundColor: AppColors.fondo,
      drawer: const MenuLateral(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              EncabezadoTienda(onInicio: () => Navigator.pop(context)),
              const SizedBox(height: 16),
              Text('Carrito de compras', style: Estilostextos.estilosTitulo),
              const SizedBox(height: 8),
              // Se redibuja solo cada vez que cambia el carrito
              Expanded(
                child: ListenableBuilder(
                  listenable: carrito,
                  builder: (context, _) {
                    final items = carrito.items;

                    if (items.isEmpty) {
                      return Center(
                        child: carrito.cargando
                            ? const CircularProgressIndicator()
                            : Text('Tu carrito está vacío',
                                style: Estilostextos.estilosLetra),
                      );
                    }

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            itemCount: items.length,
                            itemBuilder: (_, i) {
                              final item = items[i];
                              return TarjetaCarrito(
                                key: ValueKey(item.id),
                                item: item,
                                onSeleccionar: (v) async =>
                                    _avisar(await carrito.seleccionar(item, v)),
                                onEliminar: () async =>
                                    _avisar(await carrito.eliminar(item)),
                                onSumar: () async =>
                                    _avisar(await carrito.sumar(item)),
                                onRestar: () async =>
                                    _avisar(await carrito.restar(item)),
                              );
                            },
                          ),
                        ),
                        _pie(context, carrito),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // Barra inferior: Perfil, Notificaciones, Carrito y Contáctenos
      bottomNavigationBar: BarraInferior(
        onPerfil: () => _abrirPerfil(context),
        onNotificaciones: () => _abrirNotificaciones(context),
        onCarrito: () {}, // ya estás en el carrito, no hace nada
        onContacto: () => _abrirContactenos(context),
      ),
    );
  }

  // Total + botón INICIAR COMPRA
  Widget _pie(BuildContext context, CarritoService carrito) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total:', style: Estilostextos.estilosTitulo),
              Text(formatearPrecio(carrito.total),
                  style: Estilostextos.estilosTitulo),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 220,
            height: 44,
            child: ElevatedButton(
              onPressed: () => _iniciarCompra(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.botonAgregar,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: Text('INICIAR COMPRA', style: Estilostextos.estilosLetra),
            ),
          ),
        ],
      ),
    );
  }
}