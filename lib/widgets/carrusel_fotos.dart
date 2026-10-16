import 'dart:async';
import 'package:flutter/material.dart';

/// Carrusel de fotos con avance automático e indicadores.
/// Úsalo así:  const CarruselFotos()
/// o con tus propias fotos:  CarruselFotos(imagenes: ['assets/images/carrusel/a.jpg', ...])
class CarruselFotos extends StatefulWidget {
  final List<String> imagenes;
  final double alto;
  final Duration intervalo;

  const CarruselFotos({
    super.key,
    this.imagenes = const [
      'assets/images/carrusel/foto1.png',
      'assets/images/carrusel/foto2.png',
      'assets/images/carrusel/foto3.png',
      'assets/images/carrusel/foto4.png',
    ],
    this.alto = 200,
    this.intervalo = const Duration(seconds: 4),
  });

  @override
  State<CarruselFotos> createState() => _CarruselFotosState();
}

class _CarruselFotosState extends State<CarruselFotos> {
  final PageController _controller = PageController(viewportFraction: 0.92);
  Timer? _timer;
  int _actual = 0;

  @override
  void initState() {
    super.initState();
    if (widget.imagenes.length > 1) {
      _timer = Timer.periodic(widget.intervalo, (_) {
        if (!_controller.hasClients) return;
        final siguiente = (_actual + 1) % widget.imagenes.length;
        _controller.animateToPage(
          siguiente,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imagenes.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: widget.alto,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.imagenes.length,
            onPageChanged: (i) => setState(() => _actual = i),
            itemBuilder: (context, i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      widget.imagenes[i],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFFFE0E8),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          size: 40,
                          color: Color(0xFFB03A5B),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < widget.imagenes.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _actual ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == _actual
                      ? const Color(0xFFB03A5B)
                      : const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
      ],
    );
  }
}