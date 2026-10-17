import 'package:flutter/material.dart';
import 'package:papelerias/screens/contactenos.dart';
import 'package:papelerias/screens/perfil_admin.dart';
import '../theme/colores.dart';
import '../theme/estilostextos.dart';
import '../widgets/fondodegradado.dart';
import '../widgets/BarraInferior.dart';
import '../widgets/menu_lateral_admin.dart';
import '../widgets/carrusel_fotos.dart';
import '../widgets/ServiciosRapidos.dart';
import '../widgets/BannerTemporada.dart';
import '../components/chat_papeleria_modal.dart';

/// Pantalla principal del administrador (después de iniciar sesión como admin)
class PrincipalAdmin extends StatelessWidget {
  const PrincipalAdmin({super.key});

  void _abrirChatPapeleria(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ChatPapeleriaModal(),
    );
  }

  // Lleva a la pantalla del perfil del administrador
  void _abrirPerfil(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PerfilAdmin()),
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
    return Scaffold(
      backgroundColor: AppColors.fondo,
      drawer: const MenuLateralAdmin(),
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
              const CarruselFotos(),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: ServiciosRapidos(),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: BannerTemporada(
                  onTap: () => _abrirContactenos(context),
                ),
              ),
              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
      floatingActionButton: Tooltip(
        message: 'Chatbot',
        preferBelow: false,
        verticalOffset: 36,
        waitDuration: const Duration(milliseconds: 200),
        showDuration: const Duration(seconds: 2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 235, 96, 140),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
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
                backgroundColor: Color.fromARGB(255, 252, 203, 5),
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
      // Barra inferior del administrador: solo Perfil
      bottomNavigationBar: BarraInferior(
        onPerfil: () => _abrirPerfil(context),
      ),
    );
  }

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
        const SizedBox(width: 40),
      ],
    );
  }
}