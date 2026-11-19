import 'package:flutter/material.dart';

abstract final class LembarMetrics {
  static const space4 = 4.0;
  static const space8 = 8.0;
  static const space12 = 12.0;
  static const space16 = 16.0;
  static const space20 = 20.0;
  static const space24 = 24.0;
  static const gutter = space20;
  static const signInArtworkWidth = 248.0;
  static const signInHeroHeight = 212.0;
  static const signInTitleWidth = 204.0;
  static const maxContent = 600.0;
  static const tap = 48.0;
  static const smallRadius = 8.0;
  static const mediumRadius = 12.0;
  static const mediaRadius = 16.0;
  static const cardRadius = 20.0;
}

@immutable
class LembarColors extends ThemeExtension<LembarColors> {
  const LembarColors({
    required this.surface,
    required this.ink,
    required this.muted,
    required this.action,
    required this.actionPressed,
    required this.selected,
    required this.slot,
    required this.divider,
    required this.error,
    required this.disabled,
    required this.videoPanel,
    required this.videoPoster,
    required this.videoControl,
    required this.onVideo,
    required this.onDark,
    required this.videoTrack,
  });

  static const light = LembarColors(
    surface: Color(0xFFF6F5F1),
    ink: Color(0xFF191B18),
    muted: Color(0xFF595D50),
    action: Color(0xFFD8F466),
    actionPressed: Color(0xFFBFD64E),
    selected: Color(0xFFEAEEDD),
    slot: Color(0xFFE9EBE1),
    divider: Color(0xFFDADCD2),
    error: Color(0xFF93372B),
    disabled: Color(0xFFE3E5DA),
    videoPanel: Color(0xFF232620),
    videoPoster: Color(0xFF3D4333),
    videoControl: Color(0xFF30342A),
    onVideo: Color(0xFFE1E4D8),
    onDark: Color(0xFFFFFFFF),
    videoTrack: Color(0xFF777E6D),
  );

  final Color surface;
  final Color ink;
  final Color muted;
  final Color action;
  final Color actionPressed;
  final Color selected;
  final Color slot;
  final Color divider;
  final Color error;
  final Color disabled;
  final Color videoPanel;
  final Color videoPoster;
  final Color videoControl;
  final Color onVideo;
  final Color onDark;
  final Color videoTrack;

  // The assessment ships one fixed light theme.
  @override
  LembarColors copyWith() => this;

  @override
  LembarColors lerp(covariant LembarColors? other, double t) =>
      t < 0.5 ? this : other ?? this;
}

extension LembarThemeContext on BuildContext {
  LembarColors get colors => Theme.of(this).extension<LembarColors>()!;
  TextTheme get type => Theme.of(this).textTheme;
}

ThemeData lembarTheme() {
  const colors = LembarColors.light;
  final scheme = ColorScheme.fromSeed(seedColor: colors.action).copyWith(
    surface: colors.surface,
    onSurface: colors.ink,
    onSurfaceVariant: colors.muted,
    primary: colors.action,
    onPrimary: colors.ink,
    error: colors.error,
    outlineVariant: colors.divider,
  );
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: colors.surface,
    dividerColor: colors.divider,
    fontFamily: 'Inter',
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colors.surface,
      indicatorColor: colors.selected,
      surfaceTintColor: colors.surface,
      height: 64,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.onDark,
      prefixIconColor: colors.muted,
      suffixIconColor: colors.muted,
      border: _inputBorder(colors.divider),
      enabledBorder: _inputBorder(colors.divider),
      focusedBorder: _inputBorder(colors.ink, width: 2),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.ink,
        minimumSize: const Size(LembarMetrics.tap, LembarMetrics.tap),
        side: BorderSide(color: colors.divider),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(LembarMetrics.mediumRadius),
          ),
        ),
      ),
    ),
    splashFactory: InkRipple.splashFactory,
    extensions: const [colors],
    textTheme: TextTheme(
      displayMedium: _heading(52, 55, -2),
      headlineLarge: _heading(40, 42, -2),
      headlineMedium: _heading(27, 29, -1.1),
      titleLarge: _heading(25, 27, -0.55),
      titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      bodyMedium: const TextStyle(fontSize: 14, height: 1.5),
      bodySmall: const TextStyle(fontSize: 12, height: 1.42),
      labelLarge: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      labelSmall: const TextStyle(
        fontFamily: 'IBM Plex Mono',
        fontSize: 11,
        height: 1.36,
        letterSpacing: 0.4,
        fontWeight: FontWeight.w500,
      ),
    ).apply(bodyColor: colors.ink, displayColor: colors.ink),
  );
}

TextStyle _heading(double size, double lineHeight, double spacing) => TextStyle(
  fontFamily: 'Space Grotesk',
  fontSize: size,
  height: lineHeight / size,
  letterSpacing: spacing,
  fontWeight: FontWeight.w700,
);

OutlineInputBorder _inputBorder(Color color, {double width = 1}) =>
    OutlineInputBorder(
      borderRadius: const BorderRadius.all(
        Radius.circular(LembarMetrics.mediumRadius),
      ),
      borderSide: BorderSide(color: color, width: width),
    );
