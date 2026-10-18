import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Layout of the viewers: the [media] (the page view of photos and videos), the [top] chrome and the [bottom] panel.
///
/// With the chrome visible the media fits the space between [top] and [bottom], so nothing covers it. When the chrome
/// hides, [top] slides up and [bottom] slides down while they fade out, and the media grows to the full screen at the
/// same time; showing the chrome does the opposite. The status bar hides with the chrome (full screen) and comes back
/// with it and when the viewer closes.
class MediaViewerLayout extends StatefulWidget {
  static const Duration duration = Duration(milliseconds: 250);
  static const Curve curve = Curves.easeInOutCubic;

  final bool chromeVisible;
  final Widget media;
  final Widget top;
  final Widget bottom;

  const MediaViewerLayout({
    super.key,
    required this.chromeVisible,
    required this.media,
    required this.top,
    required this.bottom,
  });

  @override
  State<MediaViewerLayout> createState() => _MediaViewerLayoutState();
}

class _MediaViewerLayoutState extends State<MediaViewerLayout> {
  double _topHeight = 0;
  double _bottomHeight = 0;

  /// Off until the chrome is measured for the first time: the media takes its space at once when the viewer opens.
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    if (!widget.chromeVisible) _setStatusBarVisible(false);
  }

  @override
  void didUpdateWidget(covariant MediaViewerLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chromeVisible != widget.chromeVisible) _setStatusBarVisible(widget.chromeVisible);
  }

  @override
  void dispose() {
    _setStatusBarVisible(true);
    super.dispose();
  }

  /// Hidden: no system bar at all. Visible: the mode of the rest of the app (the navigation bar stays hidden).
  static void _setStatusBarVisible(bool visible) {
    SystemChrome.setEnabledSystemUIMode(
      visible ? SystemUiMode.immersiveSticky : SystemUiMode.manual,
      overlays: visible ? null : const [],
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = widget.chromeVisible;
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedPadding(
            duration: _animate ? MediaViewerLayout.duration : Duration.zero,
            curve: MediaViewerLayout.curve,
            padding: visible ? EdgeInsets.only(top: _topHeight, bottom: _bottomHeight) : EdgeInsets.zero,
            child: widget.media,
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _chrome(
            hiddenOffset: const Offset(0, -1),
            child: _SizeReporter(
              onSize: (size) => _onSize(top: size.height),
              child: widget.top,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _chrome(
            hiddenOffset: const Offset(0, 1),
            child: _SizeReporter(
              onSize: (size) => _onSize(bottom: size.height),
              child: widget.bottom,
            ),
          ),
        ),
      ],
    );
  }

  /// Slides out by its own height towards its edge and fades out; taps go through it while it is hidden.
  Widget _chrome({required Offset hiddenOffset, required Widget child}) {
    final visible = widget.chromeVisible;
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedSlide(
        duration: MediaViewerLayout.duration,
        curve: MediaViewerLayout.curve,
        offset: visible ? Offset.zero : hiddenOffset,
        child: AnimatedOpacity(
          duration: MediaViewerLayout.duration,
          curve: MediaViewerLayout.curve,
          opacity: visible ? 1 : 0,
          child: child,
        ),
      ),
    );
  }

  // Measured during layout; applied after the frame (the top and the panel may both report in the same frame)
  double? _measuredTop;
  double? _measuredBottom;
  bool _applyScheduled = false;

  void _onSize({double? top, double? bottom}) {
    if (top != null) _measuredTop = top;
    if (bottom != null) _measuredBottom = bottom;
    if (_applyScheduled) return;
    _applyScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyScheduled = false;
      if (!mounted) return;
      final newTop = _measuredTop ?? _topHeight;
      final newBottom = _measuredBottom ?? _bottomHeight;
      if (newTop != _topHeight || newBottom != _bottomHeight) {
        setState(() {
          _topHeight = newTop;
          _bottomHeight = newBottom;
        });
      }
      if (!_animate) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_animate) setState(() => _animate = true);
        });
      }
    });
  }
}

/// Reports the size of its child after every layout in which it changes.
class _SizeReporter extends SingleChildRenderObjectWidget {
  final ValueChanged<Size> onSize;

  const _SizeReporter({required this.onSize, required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderSizeReporter(onSize);

  @override
  void updateRenderObject(BuildContext context, _RenderSizeReporter renderObject) => renderObject.onSize = onSize;
}

class _RenderSizeReporter extends RenderProxyBox {
  ValueChanged<Size> onSize;
  Size? _reported;

  _RenderSizeReporter(this.onSize);

  @override
  void performLayout() {
    super.performLayout();
    if (size != _reported) {
      _reported = size;
      onSize(size);
    }
  }
}
