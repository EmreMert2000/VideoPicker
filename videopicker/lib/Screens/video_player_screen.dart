import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;
  final String videoTitle; // Video ismi ekleniyor

  VideoPlayerScreen({required this.videoPath, required this.videoTitle});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  double _volume = 1.0;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      _isPlaying = !_isPlaying;
    });
  }

  void _stopVideo() {
    _controller.pause();
    _controller.seekTo(Duration.zero);
    setState(() {
      _isPlaying = false;
    });
  }

  void _setVolume(double volume) {
    setState(() {
      _volume = volume;
      _controller.setVolume(_volume);
    });
  }

  void _setPlaybackSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed;
      _controller.setPlaybackSpeed(_playbackSpeed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.videoTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 1.0,
                    height: MediaQuery.of(context).size.width * 1.0,
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                  SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                        ),
                        onPressed: _togglePlayPause,
                      ),
                      IconButton(
                        icon: Icon(Icons.stop),
                        onPressed: _stopVideo,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Video Sesi: ${(_volume * 100).toInt()}%',
                    style: TextStyle(fontSize: 16),
                  ),
                  Slider(
                    value: _volume,
                    onChanged: _setVolume,
                    min: 0.0,
                    max: 1.0,
                    activeColor: Colors.blue,
                    inactiveColor: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Video Hızı: ${_playbackSpeed}x',
                    style: TextStyle(fontSize: 16),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.fast_rewind),
                        onPressed: () {
                          _setPlaybackSpeed(_playbackSpeed == 1.0 ? 2.0 : 1.0);
                        },
                        tooltip: 'Change speed',
                      ),
                      IconButton(
                        icon: Icon(Icons.fast_forward),
                        onPressed: () {
                          if (_playbackSpeed == 1.0) {
                            _setPlaybackSpeed(2.0);
                          } else if (_playbackSpeed == 2.0) {
                            _setPlaybackSpeed(3.0);
                          } else {
                            _setPlaybackSpeed(1.0);
                          }
                        },
                        tooltip: 'Change speed',
                      ),
                    ],
                  ),
                ],
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}
