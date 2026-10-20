import 'package:flutter/services.dart';

/// Convierte "$2.000" o "2000 pesos" en 2000 (solo toma los dígitos).
int numeroDe(String texto) =>
    int.tryParse(texto.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

/// Convierte el texto con viñetas en una lista de líneas sin viñeta:
/// "• Marca Norma\n• 100 hojas"  ->  ['Marca Norma', '100 hojas']
List<String> lineasDeLista(String texto) => texto
    .split('\n')
    .map((l) => l.replaceFirst('•', '').trim())
    .where((l) => l.isNotEmpty)
    .toList();

/// Hace que el campo funcione como una lista con viñetas, como en Word:
/// cada línea empieza con "• " y al presionar Enter aparece una nueva viñeta.
class FormatoVinetas extends TextInputFormatter {
  static const String vineta = '• ';

  /// Texto con el que debe empezar el campo (la primera viñeta).
  static const String inicial = vineta;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue anterior,
    TextEditingValue nuevo,
  ) {
    final cursor = nuevo.selection.baseOffset;
    if (nuevo.text.isEmpty || cursor < 0) return nuevo;
    final lineas = nuevo.text.split('\n');

    // Borrando: si una línea quedó solo con la viñeta, se quita entera
    if (nuevo.text.length < anterior.text.length) {
      final idx = '\n'.allMatches(nuevo.text.substring(0, cursor)).length;
      if (lineas[idx].trim() != '•') return nuevo;
      lineas.removeAt(idx);
      final posicion =
          idx == 0 ? 0 : lineas.sublist(0, idx).join('\n').length;
      return TextEditingValue(
        text: lineas.join('\n'),
        selection: TextSelection.collapsed(offset: posicion),
      );
    }

    // Escribiendo o pegando: toda línea sin viñeta recibe una
    var inicioLinea = 0;
    var agregado = 0;
    final salida = <String>[];
    for (final linea in lineas) {
      if (linea.startsWith('•')) {
        salida.add(linea);
      } else {
        salida.add('$vineta$linea');
        if (cursor >= inicioLinea) agregado += vineta.length;
      }
      inicioLinea += linea.length + 1;
    }
    return TextEditingValue(
      text: salida.join('\n'),
      selection: TextSelection.collapsed(offset: cursor + agregado),
    );
  }
}