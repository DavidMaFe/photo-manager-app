import 'package:flutter/material.dart';

/// Cabecera de pestaña: título 30/w800 a la izquierda y acciones a la derecha.
class ScreenHeader extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final EdgeInsetsGeometry padding;

  const ScreenHeader({
    super.key,
    required this.title,
    this.actions = const [],
    this.padding = const EdgeInsets.fromLTRB(20, 20, 20, 0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          for (final action in actions) ...[const SizedBox(width: 8), action],
        ],
      ),
    );
  }
}
