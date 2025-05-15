import 'package:flutter/material.dart';

class AppTheme {
  final TextTheme textTheme;

  const AppTheme(this.textTheme);

  static ColorScheme customScheme(Color surfaceColor, Color textColor) {
    return ColorScheme(
      brightness: Brightness.light,
      primary: Color(4289316863),
      surface: surfaceColor,  // Dynamic accent color
      onPrimary: Colors.white,
      onSurface: textColor,
      secondary: Color(4283785073),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4292535033),
      onSecondaryContainer: Color(4279376939),
      tertiary: Color(4285486453),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4294564093),
      onTertiaryContainer: Color(4280816431),
      error: Colors.red,
      onError: Colors.white,
      onSurfaceVariant: Colors.black,
      outline: Colors.grey,
      outlineVariant: Colors.grey,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Colors.black,
      inversePrimary: Colors.white,
      primaryFixed: Colors.blue,
      onPrimaryFixed: Colors.white,
      primaryFixedDim: Colors.blueGrey,
      onPrimaryFixedVariant: Colors.white,
      secondaryFixed: Colors.green,
      onSecondaryFixed: Colors.white,
      secondaryFixedDim: Colors.greenAccent,
      onSecondaryFixedVariant: Colors.white,
      surfaceDim: Colors.grey,
      surfaceBright: Colors.white,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: Colors.white,
      surfaceContainer: Colors.white,
      surfaceContainerHigh: Colors.white,
      surfaceContainerHighest: Colors.white,
    );
  }

  ThemeData custom(Color surfaceColor, Color textColor) {
    return theme(customScheme(surfaceColor, textColor));
  }

// method to build ThemeData
  ThemeData theme(ColorScheme colorScheme) {
    return ThemeData(
      colorScheme: colorScheme,
      textTheme: textTheme,
      // Customize other theme properties if needed
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(4289316863),
      surfaceTint: Color(4289316863),
      onPrimary: Color(4278726751),
      primaryContainer: Color(4280764279),
      onPrimaryContainer: Color(4292273151),
      secondary: Color(4290627548),
      onSecondary: Color(4280824129),
      secondaryContainer: Color(4282271576),
      onSecondaryContainer: Color(4292535033),
      tertiary: Color(4292656353),
      onTertiary: Color(4282329157),
      tertiaryContainer: Color(4283842140),
      onTertiaryContainer: Color(4294564093),
      error: Color(4294948011),
      onError: Color(4285071365),
      errorContainer: Color(4287823882),
      onErrorContainer: Color(4294957782),
      surface: Color(4279309080),
      onSurface: Color(4293059305),
      onSurfaceVariant: Color(4291086031),
      outline: Color(4287533209),
      outlineVariant: Color(4282664782),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293059305),
      inversePrimary: Color(4282408848),
      primaryFixed: Color(4292273151),
      onPrimaryFixed: Color(4278197053),
      primaryFixedDim: Color(4289316863),
      onPrimaryFixedVariant: Color(4280764279),
      secondaryFixed: Color(4292535033),
      onSecondaryFixed: Color(4279376939),
      secondaryFixedDim: Color(4290627548),
      onSecondaryFixedVariant: Color(4282271576),
      tertiaryFixed: Color(4294564093),
      onTertiaryFixed: Color(4280816431),
      tertiaryFixedDim: Color(4292656353),
      onTertiaryFixedVariant: Color(4283842140),
      surfaceDim: Color(4279309080),
      surfaceBright: Color(4281809214),
      surfaceContainerLowest: Color(4278980115),
      surfaceContainerLow: Color(4279835680),
      surfaceContainer: Color(4280098852),
      surfaceContainerHigh: Color(4280822319),
      surfaceContainerHighest: Color(4281546042)
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(4282408848),
      surfaceTint: Color(4282408848),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4292273151),
      onPrimaryContainer: Color(4278197053),
      secondary: Color(4283785073),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4292535033),
      onSecondaryContainer: Color(4279376939),
      tertiary: Color(4285486453),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4294564093),
      onTertiaryContainer: Color(4280816431),
      error: Color(4290386458),
      onError: Color(4294967295),
      errorContainer: Color(4294957782),
      onErrorContainer: Color(4282449922),
      surface: Color(4294572543),
      onSurface: Color(4279835680),
      onSurfaceVariant: Color(4282664782),
      outline: Color(4285822847),
      outlineVariant: Color(4291086031),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281217078),
      inversePrimary: Color(4289316863),
      primaryFixed: Color(4292273151),
      onPrimaryFixed: Color(4278197053),
      primaryFixedDim: Color(4289316863),
      onPrimaryFixedVariant: Color(4280764279),
      secondaryFixed: Color(4292535033),
      onSecondaryFixed: Color(4279376939),
      secondaryFixedDim: Color(4290627548),
      onSecondaryFixedVariant: Color(4282271576),
      tertiaryFixed: Color(4294564093),
      onTertiaryFixed: Color(4280816431),
      tertiaryFixedDim: Color(4292656353),
      onTertiaryFixedVariant: Color(4283842140),
      surfaceDim: Color(4292467168),
      surfaceBright: Color(4294572543),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294177786),
      surfaceContainer: Color(4293783028),
      surfaceContainerHigh: Color(4293388526),
      surfaceContainerHighest: Color(4293059305),
    );
  }
}

