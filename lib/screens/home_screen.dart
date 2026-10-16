import 'package:flutter/material.dart';
import 'package:papelerias/screens/inicioseseion.dart';
import 'package:papelerias/screens/perfil_screen.dart';
import 'package:papelerias/screens/notificaciones.dart';
import 'package:papelerias/screens/contactenos.dart';
import '../theme/colores.dart';
import '../theme/estilostextos.dart';
import '../widgets/fondodegradado.dart';
import '../widgets/BarraInferior.dart';
import '../widgets/menu_lateral.dart';
import '../widgets/carrusel_fotos.dart';
import '../widgets/ServiciosRapidos.dart';
import '../widgets/BannerTemporada.dart';
import '../components/chat_papeleria_modal.dart';
import '../services/sesion.dart';

/// Pantalla principal - Papelería y Variedades Juan José
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _abrirChatPapeleria(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ChatPapeleriaModal(),
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

  // Lleva a la pantalla de inicio de sesión
  void _abrirInicioSesion(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const InicioSesion()),
    );
  }

  // Lleva a la pantalla de Contáctenos
  void _abrirContactenos(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PantallaContactenos()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      // Menú lateral reutilizable (se abre con el icono de las rayitas)
      drawer: const MenuLateral(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              FondoDegradado(
                alto: 120,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                child: _encabezado(context),
              ),
              const SizedBox(height: 20),
              Text('Novedades', style: Estilostextos.estilosTitulo),
              const SizedBox(height: 16),
              // Carrusel de fotos (reemplaza la cuadrícula de categorías)
              const CarruselFotos(),
              const SizedBox(height: 24),

              // Servicios rápidos: solo informativos (no llevan a ninguna parte)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: ServiciosRapidos(),
              ),
              const SizedBox(height: 24),

              // Banner de temporada (cambia textos / icono / colores según la fecha)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: BannerTemporada(
                  onTap: () => _abrirContactenos(context),
                ),
              ),

              // Espacio al final para que el robot del chatbot no tape el banner
              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
      // Botón del chatbot con letrero "Chatbot" al pasar el mouse
      // (en el celular aparece al mantener presionado)
      floatingActionButton: Tooltip(
        message: 'Chatbot', // texto que aparece (cámbialo si quieres otro)
        preferBelow: false, // aparece ARRIBA del botón para que no lo tape la barra
        verticalOffset: 36,
        waitDuration: const Duration(milliseconds: 200),
        showDuration: const Duration(seconds: 2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 235, 96, 140), // fondo del letrero
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        textStyle: const TextStyle(
          color: Colors.white, // color de la letra del letrero
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        child: MouseRegion(
          cursor: SystemMouseCursors.click, // manita al pasar el mouse
          child: GestureDetector(
            onTap: () => _abrirChatPapeleria(context),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF8FAB).withAlpha(100),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 30,
                backgroundColor: Color.fromARGB(255, 252, 203, 5), // círculo del chatbot
                child: CircleAvatar(
                  radius: 28,
                  backgroundImage: AssetImage('assets/images/robot.jpg'),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // Barra inferior: Iniciar sesión y Contáctenos
      bottomNavigationBar: BarraInferior(
        onInicioSesion: () => _abrirInicioSesion(context),
        onContacto: () => _abrirContactenos(context),
      ),
    );
  }

  // Encabezado: [menú] [logo] [texto]
  Widget _encabezado(BuildContext context) {
    const iconConstraints = BoxConstraints(minWidth: 40, minHeight: 40);

    return Row(
      children: [
        // Icono de las rayitas: abre el menú lateral
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
          radius: 32, // tamaño del logo
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
        // Espacio vacío para que el texto siga centrado
        // (el icono de iniciar sesión ahora está en la barra inferior)
        const SizedBox(width: 40),
      ],
    );
  }
}