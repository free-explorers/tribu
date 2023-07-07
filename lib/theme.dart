import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/utils/color.dart';

const tribuBlue = Color(0xFF013d50);
const tribuOrange = Color(0xFFffb25f);

final lightThemeProvider = Provider((ref) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: tribuBlue,
    primary: tribuBlue,
    secondary: tribuOrange,
    onSecondary: tribuBlue,
    secondaryContainer: tribuOrange,
    onSecondaryContainer: tribuBlue,
    tertiary: tribuBlue.withOpacity(0.05),
    tertiaryContainer: tribuBlue.withOpacity(0.05),
  );

  final theme = overrideShapes(
    ThemeData.light().copyWith(
      useMaterial3: true,
      colorScheme: colorScheme,
    ),
  );

  return theme.copyWith(
    appBarTheme: theme.appBarTheme.copyWith(
      backgroundColor: colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      elevation: 4,
      shadowColor: theme.shadowColor,
      systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
    ),
    cardTheme: theme.cardTheme.copyWith(color: colorScheme.tertiaryContainer),
    floatingActionButtonTheme: theme.floatingActionButtonTheme.copyWith(
      backgroundColor: tribuOrange,
      foregroundColor: colorScheme.primary,
    ),
    primaryColor: colorScheme.primary,
    colorScheme: theme.colorScheme,
    textSelectionTheme: theme.textSelectionTheme
        .copyWith(selectionHandleColor: lighten(colorScheme.primary, 15)),
  );
});

final primaryThemeProvider = Provider((ref) {
  final theme = overrideShapes(
    ThemeData.dark().copyWith(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: tribuBlue,
        brightness: Brightness.dark,
        background: tribuBlue,
        surface: tribuBlue,
        primary: Colors.white,
        onPrimary: tribuBlue,
        secondary: tribuOrange,
        onSecondary: tribuBlue,
        error: Colors.red.shade300,
        primaryContainer: tribuBlue,
        secondaryContainer: tribuOrange,
        onSecondaryContainer: tribuBlue,
        tertiaryContainer: lighten(tribuBlue, 90).withOpacity(0.1),
        onTertiary: Colors.white,
      ),
    ),
  );
  final bottomSheetTheme =
      theme.bottomSheetTheme.copyWith(backgroundColor: tribuBlue);

  return theme.copyWith(
    bottomSheetTheme: bottomSheetTheme,
    scaffoldBackgroundColor: tribuBlue,
    drawerTheme: theme.drawerTheme.copyWith(backgroundColor: tribuBlue),
    popupMenuTheme: theme.popupMenuTheme.copyWith(color: lighten(tribuBlue)),
    canvasColor: tribuBlue,
    cardTheme: theme.cardTheme.copyWith(
      color: theme.colorScheme.tertiaryContainer,
    ),
    dialogTheme:
        theme.dialogTheme.copyWith(backgroundColor: tribuBlue, elevation: 0),
    toggleButtonsTheme: theme.toggleButtonsTheme
        .copyWith(fillColor: tribuOrange, selectedColor: tribuBlue),
    bottomAppBarTheme: theme.bottomAppBarTheme.copyWith(color: tribuBlue),
    textSelectionTheme: theme.textSelectionTheme.copyWith(
      cursorColor: tribuOrange,
      selectionColor: tribuOrange.withAlpha(125),
      selectionHandleColor: tribuOrange,
    ),
    floatingActionButtonTheme: theme.floatingActionButtonTheme
        .copyWith(backgroundColor: tribuOrange, foregroundColor: tribuBlue),
    inputDecorationTheme: theme.inputDecorationTheme.copyWith(
      fillColor: theme.colorScheme.tertiaryContainer,
    ),
  );
});

ThemeData overrideShapes(ThemeData theme) {
  const tribuRoundedShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(16)),
  );
  return theme.copyWith(
    floatingActionButtonTheme: theme.floatingActionButtonTheme.copyWith(
      shape: tribuRoundedShape,
    ),
    cardTheme: theme.cardTheme.copyWith(
      shape: tribuRoundedShape,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
    ),
    popupMenuTheme: theme.popupMenuTheme.copyWith(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    dialogTheme: theme.dialogTheme.copyWith(shape: tribuRoundedShape),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(shape: tribuRoundedShape),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(shape: tribuRoundedShape),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: tribuRoundedShape,
      ),
    ),
  );
}
