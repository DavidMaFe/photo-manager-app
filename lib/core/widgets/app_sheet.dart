import 'package:flutter/material.dart';

/// Abre una hoja inferior con el tema de «Revelado» (asa, radio 28, fondo surface).
///
/// El contenido recibe padding `fromLTRB(20, 12, 20, 28)` y sube con el teclado.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool useRootNavigator = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    useRootNavigator: useRootNavigator,
    useSafeArea: true,
    builder: (sheetContext) => AppSheetBody(child: builder(sheetContext)),
  );
}

/// Padding estándar del contenido de una hoja, incluido el teclado.
class AppSheetBody extends StatelessWidget {
  final Widget child;

  const AppSheetBody({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 28 + keyboard),
      child: SingleChildScrollView(child: child),
    );
  }
}
