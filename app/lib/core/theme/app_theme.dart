import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  /// Acento de marca (antes "brown"): un vino/berenjena apagado, más propio del contexto
  /// conmemorativo que el marrón original. Los tres tonos (base/oscuro/claro) se usan igual que
  /// antes: oscuro para texto sobre fondo claro, claro para bordes/fondos suaves.
  static const plum = Color(0xFF6B3F55);
  static const plumDark = Color(0xFF3B1F30);
  static const plumLight = Color(0xFFDCC7D3);
  static const black = Color(0xFF1A1420);
  static const white = Color(0xFFFFFFFF);
  static const offWhite = Color(0xFFF7F5F2);
  static const green = Color(0xFF2E7D32);
  static const greenLight = Color(0xFFA5D6A7);
  static const gray = Color(0xFF9E9E9E);
  static const grayLight = Color(0xFFE0E0E0);

  // Superficies de fondo para el tema oscuro: no son un simple "negativo" del claro, para que
  // las tarjetas y el fondo se distingan entre sí (ver cardTheme más abajo).
  static const darkBackground = Color(0xFF120E15);
  static const darkSurface = Color(0xFF1E1822);

  /// Color de texto de un chip de filtro según si está seleccionado o no: el fondo
  /// seleccionado es oscuro (ver [ChipThemeData.selectedColor]), así que el texto debe
  /// pasar a blanco para no perder contraste.
  static Color chipLabel(bool selected) => selected ? white : plumDark;
}

class AppTheme {
  /// Tipografía editorial (evoca la prensa/las esquelas impresas) para títulos y cabeceras;
  /// el cuerpo de texto se queda en la fuente del sistema por legibilidad — importante aquí,
  /// dado que la app ya ofrece tamaño de letra ajustable para un público mayor.
  static TextTheme _textTheme(TextTheme base, Color displayColor) {
    return base.copyWith(
      headlineMedium: GoogleFonts.playfairDisplay(
        textStyle: base.headlineMedium,
        fontWeight: FontWeight.w700,
        color: displayColor,
      ),
      headlineSmall: GoogleFonts.playfairDisplay(
        textStyle: base.headlineSmall,
        fontWeight: FontWeight.w700,
        color: displayColor,
      ),
      titleLarge: GoogleFonts.playfairDisplay(
        textStyle: base.titleLarge,
        fontWeight: FontWeight.w600,
        color: displayColor,
      ),
    );
  }

  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.black,
      onPrimary: AppColors.white,
      secondary: AppColors.plum,
      onSecondary: AppColors.white,
      error: Color(0xFFB3261E),
      onError: AppColors.white,
      errorContainer: Color(0xFFF9DEDC),
      onErrorContainer: Color(0xFF410E0B),
      surface: AppColors.white,
      onSurface: AppColors.black,
      surfaceContainerHighest: AppColors.plumLight,
      outline: Color(0xFF8D7385),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.white,
      textTheme: _textTheme(
        ThemeData(brightness: Brightness.light).textTheme,
        AppColors.black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
      ),
      // El AppBar es siempre negro (en los dos temas): sin esto, un TabBar dentro de un AppBar
      // (p. ej. el Dashboard) coge el color de texto por defecto de Material 3, que puede acabar
      // siendo prácticamente negro sobre negro. Mismo blanco/blanco-translúcido que ya usa el
      // AppBar para su propio texto.
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: AppColors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.black,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.black.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.black,
          side: const BorderSide(color: AppColors.black),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.plumDark),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: colorScheme.primary,
          selectedForegroundColor: colorScheme.onPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.plumLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.plumLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.black, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB3261E)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.plumLight.withValues(alpha: 0.4),
        selectedColor: AppColors.black,
        labelStyle: const TextStyle(
          color: AppColors.plumDark,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.plumLight),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.green
              : AppColors.gray,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.greenLight
              : AppColors.grayLight,
        ),
      ),
    );
  }

  static ThemeData dark() {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.white,
      onPrimary: AppColors.black,
      secondary: AppColors.plumLight,
      onSecondary: AppColors.plumDark,
      error: Color(0xFFF2B8B5),
      onError: Color(0xFF601410),
      errorContainer: Color(0xFF8C1D18),
      onErrorContainer: Color(0xFFF9DEDC),
      surface: AppColors.darkSurface,
      onSurface: AppColors.white,
      surfaceContainerHighest: Color(0xFF362A34),
      outline: Color(0xFFA6919F),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: _textTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
        AppColors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
      ),
      // El AppBar es siempre negro (en los dos temas): sin esto, un TabBar dentro de un AppBar
      // (p. ej. el Dashboard) coge el color de texto por defecto de Material 3, que puede acabar
      // siendo prácticamente negro sobre negro. Mismo blanco/blanco-translúcido que ya usa el
      // AppBar para su propio texto.
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: AppColors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.black,
          disabledBackgroundColor: AppColors.white.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.white,
          side: const BorderSide(color: AppColors.white),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.plumLight),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: colorScheme.primary,
          selectedForegroundColor: colorScheme.onPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4A3C48)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4A3C48)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.white, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFFF2B8B5)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF362A34),
        selectedColor: AppColors.white,
        labelStyle: const TextStyle(
          color: AppColors.plumLight,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF4A3C48)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.greenLight
              : AppColors.gray,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.green
              : const Color(0xFF362A34),
        ),
      ),
    );
  }
}
