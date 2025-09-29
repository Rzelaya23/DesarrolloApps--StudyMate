// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

/// Paleta de colores disponible
const List<Color> colorList = [
  Color(0xFF7B61FF),
  Colors.blue,
  Colors.green,
  Colors.orange,
  Colors.red,
];

/// Estado de tema unificado (oscuro/claro + color semilla)
class AppTheme {
  final bool isDarkmode;
  final int selectedColor;

  AppTheme({
    this.isDarkmode = false,
    this.selectedColor = 0, // por defecto morado claro
  }) : assert(selectedColor >= 0 && selectedColor < colorList.length);

  AppTheme copyWith({bool? isDarkmode, int? selectedColor}) {
    return AppTheme(
      isDarkmode: isDarkmode ?? this.isDarkmode,
      selectedColor: (selectedColor != null &&
          selectedColor >= 0 &&
          selectedColor < colorList.length)
          ? selectedColor
          : this.selectedColor,
    );
  }

  /// Genera ThemeData Material 3 con color semilla y brillo
  ThemeData toThemeData() {
    final seed = colorList[selectedColor];

    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: seed, // semilla principal -> moradito claro
      brightness: isDarkmode ? Brightness.dark : Brightness.light,
      appBarTheme: const AppBarTheme(centerTitle: false),
      cardTheme: const CardThemeData(
        clipBehavior: Clip.hardEdge,
      ),
    );
  }
}

