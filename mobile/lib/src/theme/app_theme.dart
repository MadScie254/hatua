import 'package:flutter/material.dart';

/// HATUA's colours beyond the Material scheme.
///
/// Forest green (#087F66) is the brand and every primary action. A deeper pine carries the one
/// bold element, the "talk to someone now" band. Ochre is reserved for time: deadlines only, so
/// it never competes with actions. Emergency copy keeps Material's error colours.
@immutable
class HatuaColors extends ThemeExtension<HatuaColors> {
  const HatuaColors({required this.band, required this.onBand, required this.time, required this.onTime});

  final Color band;
  final Color onBand;
  final Color time;
  final Color onTime;

  static const light = HatuaColors(
    band: Color(0xFF0B4F41),
    onBand: Color(0xFFFFFFFF),
    time: Color(0xFFF6E2B8),
    onTime: Color(0xFF5A3B00),
  );
  static const dark = HatuaColors(
    band: Color(0xFF1C6B58),
    onBand: Color(0xFFFFFFFF),
    time: Color(0xFF5A4216),
    onTime: Color(0xFFFBE3B5),
  );

  static HatuaColors of(BuildContext context) => Theme.of(context).extension<HatuaColors>() ?? light;

  @override
  HatuaColors copyWith({Color? band, Color? onBand, Color? time, Color? onTime}) => HatuaColors(
        band: band ?? this.band,
        onBand: onBand ?? this.onBand,
        time: time ?? this.time,
        onTime: onTime ?? this.onTime,
      );

  @override
  HatuaColors lerp(HatuaColors? other, double t) => other == null
      ? this
      : HatuaColors(
          band: Color.lerp(band, other.band, t)!,
          onBand: Color.lerp(onBand, other.onBand, t)!,
          time: Color.lerp(time, other.time, t)!,
          onTime: Color.lerp(onTime, other.onTime, t)!,
        );
}

class AppTheme {
  static const _seed = Color(0xFF087F66);

  /// Widest a column of text and cards gets on tablets and desktop browsers.
  static const maxContentWidth = 720.0;

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
    final base = ThemeData(useMaterial3: true, colorScheme: colorScheme);
    // Roboto only (already on Android and bundled in the web build): no extra font download.
    // Hierarchy comes from weight and size, not from more typefaces.
    final text = base.textTheme.copyWith(
      headlineMedium: base.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
      headlineSmall: base.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.3),
      titleLarge: base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium: base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, height: 1.3),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(height: 1.45),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.45),
    );
    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    return base.copyWith(
      textTheme: text,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: text.titleLarge?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 5),
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size(48, 48), shape: buttonShape),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48), shape: buttonShape),
      ),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(minimumSize: const Size(48, 48))),
      listTileTheme: const ListTileThemeData(minVerticalPadding: 10),
      extensions: [brightness == Brightness.dark ? HatuaColors.dark : HatuaColors.light],
    );
  }
}
