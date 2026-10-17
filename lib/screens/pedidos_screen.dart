import 'package:flutter/material.dart';
import '../models/carrito_item.dart';
import '../services/carrito_service.dart';
import '../theme/colores.dart';
import '../theme/estilostextos.dart';
import '../widgets/fondodegradado.dart';

/// Pedido: muestra solo los productos que se seleccionaron en el carrito.
class PantallaPedidos extends StatelessWidget {
  const PantallaPedidos({super.key});

  @override
  Widget build(BuildContext context) {
    final carrito = CarritoService.instancia;
    final productos = carrito.seleccionados;

    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              FondoDegradado(
                alto: 64,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: Colors.white,
                    ),
                    Text('Mi pedido', style: Estilostextos.estilosBienvenida),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: productos.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_, i) {
                    final p = productos[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(p.nombre, style: Estilostextos.estilosLetra),
                      subtitle: Text('${p.cantidad} x ${formatearPrecio(p.precio)}'),
                      trailing: Text(
                        formatearPrecio(p.subtotal),
                        style: Estilostextos.estilosLetra,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
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
                        onPressed: () {
                          // TODO: enviar el pedido al backend y luego:
                          // CarritoService.instancia.quitarSeleccionados();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Pedido próximamente')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.botonAgregar,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: Text('CONFIRMAR PEDIDO',
                            style: Estilostextos.estilosLetra),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}