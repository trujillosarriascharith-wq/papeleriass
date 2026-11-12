import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../theme/colores.dart';

/// Pantalla de Ayuda: muestra el Manual de Usuario (PDF guardado en assets).
/// La usan tanto el cliente como el administrador desde su menú lateral.
class PantallaAyuda extends StatefulWidget {
  const PantallaAyuda({super.key});

  @override
  State<PantallaAyuda> createState() => _PantallaAyudaState();
}

class _PantallaAyudaState extends State<PantallaAyuda> {
  static const String _rutaManual = 'assets/manual/manual_usuario.pdf';

  final PdfViewerController _controller = PdfViewerController();

  int _paginaActual = 1;
  int _totalPaginas = 0;
  bool _cargando = true;
  bool _error = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Ayuda',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF9627F), Color(0xFFA33550)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        actions: [
          if (_totalPaginas > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '$_paginaActual / $_totalPaginas',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
        ],
      ),
      body: _error
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No se pudo abrir el manual de usuario.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          : Stack(
              children: [
                SfPdfViewer.asset(
                  _rutaManual,
                  controller: _controller,
                  canShowScrollHead: true,
                  enableDoubleTapZooming: true,
                  onDocumentLoaded: (details) {
                    setState(() {
                      _totalPaginas = details.document.pages.count;
                      _cargando = false;
                    });
                  },
                  onDocumentLoadFailed: (details) {
                    setState(() {
                      _error = true;
                      _cargando = false;
                    });
                  },
                  onPageChanged: (details) {
                    setState(() => _paginaActual = details.newPageNumber);
                  },
                ),
                if (_cargando) const Center(child: CircularProgressIndicator()),
              ],
            ),
    );
  }
}