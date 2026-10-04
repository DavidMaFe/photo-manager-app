import 'package:flutter/widgets.dart';

/// Shared "selection mode is active" flag: [MainShell] hides the navigation
/// bar while a page shows its selection action bar instead.
class ShellSelectionMode extends InheritedNotifier<ValueNotifier<bool>> {
  const ShellSelectionMode({super.key, required ValueNotifier<bool> notifier, required super.child})
      : super(notifier: notifier);

  /// The shell's notifier, or `null` outside the shell (e.g. in tests).
  static ValueNotifier<bool>? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<ShellSelectionMode>()?.notifier;
}

/// Reports [active] to the enclosing [ShellSelectionMode] and clears it when
/// removed.
class ReportSelectionMode extends StatefulWidget {
  final bool active;
  final Widget child;

  const ReportSelectionMode({super.key, required this.active, required this.child});

  @override
  State<ReportSelectionMode> createState() => _ReportSelectionModeState();
}

class _ReportSelectionModeState extends State<ReportSelectionMode> {
  ValueNotifier<bool>? _notifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notifier = ShellSelectionMode.maybeOf(context);
    _report(widget.active);
  }

  @override
  void didUpdateWidget(covariant ReportSelectionMode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) _report(widget.active);
  }

  @override
  void dispose() {
    final notifier = _notifier;
    if (notifier != null && widget.active) {
      // Leaving the page while selecting: show the navigation bar again.
      WidgetsBinding.instance.addPostFrameCallback((_) => notifier.value = false);
    }
    super.dispose();
  }

  void _report(bool active) {
    final notifier = _notifier;
    if (notifier == null || notifier.value == active) return;
    // Not during build: the shell rebuilds when the value changes.
    WidgetsBinding.instance.addPostFrameCallback((_) => notifier.value = active);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
