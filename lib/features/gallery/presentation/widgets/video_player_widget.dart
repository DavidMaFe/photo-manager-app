import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';


class VideoPlayerWidget extends StatefulWidget {

  final String videoUrl;
  final ValueChanged<bool>? onControlsVisibilityChanged;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    required this.onControlsVisibilityChanged
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}


class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {

  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {

    try {

      final token = _getToken();
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        httpHeaders: {
          'Authorization': 'Bearer $token'
        }
      );

      await _controller.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }

      // Update video progress
      _controller.addListener(() {
        if (mounted){
          setState(() {});
        }
      });

    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  String _getToken() {
    try {
      final prefs = GetIt.instance<SharedPreferences>();
      return prefs.getString("AUTH_TOKEN") ?? '';
    } catch(e) {
      return '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
        _startHideControlsTimer();
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      widget.onControlsVisibilityChanged?.call(_showControls);

      if (_showControls && _controller.value.isPlaying) {
        _startHideControlsTimer();
      } else {
        _hideControlsTimer?.cancel();
      }
    });
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _controller.value.isPlaying) {
        setState(() {
          _showControls = false;
          widget.onControlsVisibilityChanged?.call(false);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    if (_hasError) {
      final l10n = AppLocalizations.of(context)!;
      return _buildError(l10n);
    }

    if (!_isInitialized) {
      return _buildLoading();
    }

    return GestureDetector(
      onTap: _toggleControls,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),
          if (_showControls) _buildControls()
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            context.palette.media.withValues(alpha: 0.3),
            context.palette.media.withValues(alpha: 0),
            context.palette.media.withValues(alpha: 0),
            context.palette.media.withValues(alpha: 0.5)
          ],
          stops: const [0.0, 0.15, 0.75, 1.0]
        )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 40),
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: context.palette.media.withValues(alpha: 0.5),
                shape: BoxShape.circle
              ),
              child: IconButton(
                onPressed: _togglePlayPause,
                icon: Icon(
                    _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 64,
                    color: context.palette.onMedia
                ),
              ),
            )
          ),
          _buildBottomControls()
        ],
      ),
    );
  }

  Widget _buildBottomControls() {

    final position = _controller.value.position;
    final duration = _controller.value.duration;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          VideoProgressIndicator(
            _controller,
            allowScrubbing: true,
            colors: VideoProgressColors(
              playedColor: context.palette.onMedia,
              bufferedColor: context.palette.onMedia.withValues(alpha: 0.38),
              backgroundColor: context.palette.onMedia.withValues(alpha: 0.24)
            )
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(position),
                style: TextStyle(color: context.palette.onMedia, fontSize: 12),
              ),
              Text(
                _formatDuration(duration),
                style: TextStyle(color: context.palette.onMedia, fontSize: 12),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      color: context.palette.media,
      child: Center(
        child: CircularProgressIndicator(
          color: context.palette.onMedia
        ),
      ),
    );
  }

  Widget _buildError(AppLocalizations l10n) {
    return Container(
      color: context.palette.media,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: context.palette.onMedia.withValues(alpha: 0.70),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.loadingVideoError,
              style: TextStyle(color: context.palette.onMedia.withValues(alpha: 0.70), fontSize: 16),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: context.palette.onMedia.withValues(alpha: 0.54), fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}


