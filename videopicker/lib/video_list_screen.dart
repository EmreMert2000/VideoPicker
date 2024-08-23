import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:videopicker/Screens/video_player_screen.dart';

class VideoListScreen extends StatefulWidget {
  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  List<String> _videoPaths = [];
  int? _editingIndex;
  TextEditingController _editingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    final directory = await getApplicationDocumentsDirectory();
    final videoDir = Directory('${directory.path}/videos');
    if (await videoDir.exists()) {
      setState(() {
        _videoPaths = videoDir.listSync().map((item) => item.path).toList();
      });
    }
  }

  Future<void> _addVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null) {
      final file = File(result.files.single.path!);
      final directory = await getApplicationDocumentsDirectory();
      final videoDir = Directory('${directory.path}/videos');
      if (!await videoDir.exists()) {
        await videoDir.create();
      }
      final newPath = '${videoDir.path}/${result.files.single.name}';
      await file.copy(newPath);
      setState(() {
        _videoPaths.add(newPath);
      });
    }
  }

  Future<void> _deleteVideo(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
      setState(() {
        _videoPaths.remove(path);
      });
    }
  }

  Future<void> _renameVideo(String oldPath, String newName) async {
    final directory = await getApplicationDocumentsDirectory();
    final videoDir = Directory('${directory.path}/videos');
    final newPath = '${videoDir.path}/$newName';
    final file = File(oldPath);
    if (await file.exists()) {
      await file.rename(newPath);
      setState(() {
        final index = _videoPaths.indexOf(oldPath);
        if (index != -1) {
          _videoPaths[index] = newPath;
        }
        _editingIndex = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Yöneticisi'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addVideo,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "KAYDETTİĞİM VİDEOLAR",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _videoPaths.length,
              itemBuilder: (context, index) {
                final videoPath = _videoPaths[index];
                final videoName = videoPath.split('/').last;
                return ListTile(
                  title: _editingIndex == index
                      ? TextField(
                          controller: _editingController,
                          autofocus: true,
                          onSubmitted: (newName) async {
                            if (newName.isNotEmpty) {
                              await _renameVideo(videoPath, newName);
                            }
                          },
                        )
                      : Text(videoName),
                  leading: IconButton(
                    icon: Icon(Icons.play_arrow),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoPlayerScreen(
                            videoPath: videoPath,
                            videoTitle: videoName,
                          ),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    if (_editingIndex == null) {
                      setState(() {
                        _editingIndex = index;
                        _editingController.text = videoName;
                      });
                    }
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteVideo(videoPath),
                  ),
                );
              },
            ),
          ),
          if (_editingIndex != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final newName = _editingController.text;
                        if (newName.isNotEmpty) {
                          await _renameVideo(
                              _videoPaths[_editingIndex!], newName);
                        }
                      },
                      child: Text('Save'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _editingIndex = null;
                        });
                      },
                      child: Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
