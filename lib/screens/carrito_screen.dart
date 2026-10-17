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
import '../widgets/fondodegradado.dart';
import '../widgets/menu_lateral.dart';
import '../widgets/tarjetascarrito.dart';
import 'pedidos_screen.dart';

class PantallaCarrito extends StatelessWidget {
  const PantallaCarrito({super.key});

  void _iniciarCompra(BuildContext context) {
    if (CarritoService.instancia.seleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un producto')),
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
              FondoDegradado(
                alto: 120,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                child: _encabezado(context),
              ),
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
                        child: Text('Tu carrito está vacío',
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
                                onSeleccionar: (v) => carrito.seleccionar(item, v),
                                onEliminar: () => carrito.eliminar(item),
                                onSumar: () => carrito.sumar(item),
                                onRestar: () => carrito.restar(item),
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

  // Mismo encabezado del home: [menú] [logo] [texto] [volver al inicio]
  Widget _encabezado(BuildContext context) {
    const iconConstraints = BoxConstraints(minWidth: 40, minHeight: 40);

    return Row(
      children: [
        Builder(
          builder: (ctx) => IconButton(
            onPressed: () => Scaffold.of(ctx).openDrawer(),
            icon: const Icon(Icons.menu_rounded),
            iconSize: 30,
            color: Colors.white,
            tooltip: 'Menú',
            padding: EdgeInsets.zero,
            constraints: iconConstraints,
          ),
        ),
        const SizedBox(width: 4),
        const CircleAvatar(
          radius: 32,
          backgroundColor: Colors.white,
          backgroundImage: AssetImage('assets/images/logo2.png'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Papelería y Variedades\nJuan José',
              textAlign: TextAlign.center,
              style: Estilostextos.estilosBienvenida,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.home_rounded),
          iconSize: 28,
          color: Colors.white,
          tooltip: 'Volver al inicio',
          padding: EdgeInsets.zero,
          constraints: iconConstraints,
        ),
      ],
    );
  }
}