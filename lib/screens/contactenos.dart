import 'package:flutter/material.dart';
import '../theme/colores.dart';

/// Pantalla de Contáctenos - Papelería y Variedades Juan José
class PantallaContactenos extends StatelessWidget {
  const PantallaContactenos({super.key});

  // Cambia estos datos si algún día cambian en la papelería
  static const _telefono = '322 8793769';
  static const _correo = 'papeleriajuanjose2017@gmail.com';
  static const _direccion = 'Cra. 5# 8-36, Agrado, Huila';
    static const _propietaria = 'Magali Castro';


  // Foto de la papelería (guárdala en assets/images/ con este nombre)
  static const _foto = 'assets/images/papeleria.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: Column(
          children: [
            _encabezado(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Foto de la papelería
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        _foto,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                        // Si la foto aún no está en el proyecto, muestra un recuadro en vez de dar error
                        errorBuilder: (_, __, ___) => Container(
                          width: double.infinity,
                          height: 220,
                          color: AppColors.fondoComponente,
                          child: const Icon(
                            Icons.storefront_outlined,
                            size: 80,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Papelería y Variedades\nJuan José',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _tarjetaInfo(Icons.phone, 'Teléfono', _telefono),
                    const SizedBox(height: 12),
                    _tarjetaInfo(Icons.email, 'Correo', _correo),
                    const SizedBox(height: 12),
                    _tarjetaInfo(Icons.location_on, 'Dirección', _direccion),
                     const SizedBox(height: 12),
                    _tarjetaInfo(Icons.person, 'Propietaria', _propietaria),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Barra superior con la flecha para volver a la pantalla inicial
  Widget _encabezado(BuildContext context) {
    return Container(
      height: 56,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.primaryColor, AppColors.secondaryColor],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            tooltip: 'Volver',
          ),
          const SizedBox(width: 8),
          const Text(
            'Contáctenos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaInfo(IconData icono, String titulo, String valor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.fondoComponente,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent, width: 1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.fondoComponenteSeleccionado,
            child: Icon(icono, color: AppColors.secondaryColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}