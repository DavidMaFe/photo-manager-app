import 'package:flutter/widgets.dart';
import 'package:photo_manager_app/core/services/secure_screen.dart';

/// Protects [child] with [SecureScreen] while it is on screen.
class SecureScreenGuard extends StatefulWidget {
  final Widget child;
  final SecureScreen? secureScreen;

  const SecureScreenGuard({super.key, required this.child, this.secureScreen});

  @override
  State<SecureScreenGuard> createState() => _SecureScreenGuardState();
}

class _SecureScreenGuardState extends State<SecureScreenGuard> {
  late final SecureScreen _secureScreen = widget.secureScreen ?? SecureScreen();

  @override
  void initState() {
    super.initState();
    _secureScreen.enable();
  }

  @override
  void dispose() {
    _secureScreen.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
