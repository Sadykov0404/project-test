import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:http/http.dart' as http;

class TrimmerView extends StatefulWidget {
  final File file;

  TrimmerView(this.file);

  @override
  _TrimmerViewState createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  final Trimmer _trimmer = Trimmer();

  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;
  bool _progressVisibility = false;

  Future<void> _openSavedVideo(String outputPath) async {
    final directory = Directory(outputPath);
    if (await directory.exists()) {
      final result = await FilePicker.platform.getDirectoryPath();
      if (result != null) {
        final filePath = '$result/${directory.uri.pathSegments.last}';
        if (await canLaunch(filePath)) {
          await launch(filePath);
          return;
        }
      }
    }

    // _showToast("Video Saved successfully");
    _showToast("Cannot open the saved video");
  }

  Future<String?> _saveVideo() async {
    setState(() {
      _progressVisibility = true;
    });

    final appDocDir = await getApplicationDocumentsDirectory();
    final outputPath = '${appDocDir.path}/trimmed_videos';

    final outputDir = Directory(outputPath);
    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }

    final uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
    final videoFilePath = '$outputPath/$uniqueFileName.mp4';
    print(videoFilePath);

    await _trimmer.saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
      onSave: (String? value) {
        setState(() {
          _progressVisibility = false;
          if (value != null) {
            Navigator.of(context).pop(value);
          }
        });
      },
    );
  }

  void _sendVideo() async {
    if (_endValue / 1000 - _startValue / 1000 > 120) {
      _showToast("It should be less than 120 seconds");
    } else if (_endValue / 1000 - _startValue / 1000 < 60) {
      _showToast("Must be at least 60 seconds");
    } else {
      final outputPath = await _saveVideo();
      if (outputPath != null) {
        _openSavedVideo(outputPath);
        sendVideo();
      }
    }
  }

  void _loadVideo() {
    _trimmer.loadVideo(videoFile: widget.file);
  }

  @override
  void initState() {
    super.initState();

    _loadVideo();
  }

  void _showToast(String message) {
    final snackBar = SnackBar(
      backgroundColor: Colors.red,
      dismissDirection: DismissDirection.up,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height - 150,
        left: 20,
        right: 20,
      ),
      content: Text(message),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future sendVideo() async {
    final url = Uri.parse(
        'https://faceai-dev-55cf5949db95.herokuapp.com/ping?crop_params=$_startValue:$_endValue');
    final request = http.MultipartRequest('GET', url);
    // request.files.add(
    //     await http.MultipartFile.fromPath('video', 'videoUrl'));

    // чтобы загрузить видео нам нужен upload file api
    final response = await request.send();
    if (response.statusCode == 200) {
      print('Video sent successfully');
    } else {
      print('Failed to send video');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Editor"),
      ),
      body: Builder(
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.black.withOpacity(0.8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Visibility(
                  visible: _progressVisibility,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.red,
                  ),
                ),
                Expanded(
                  child: VideoViewer(trimmer: _trimmer),
                ),
                Center(
                  child: TrimViewer(
                    showDuration: true,
                    trimmer: _trimmer,
                    viewerHeight: 50.0,
                    viewerWidth: MediaQuery.of(context).size.width,
                    maxVideoLength: const Duration(seconds: 120),
                    onChangeStart: (value) => _startValue = value,
                    onChangeEnd: (value) => _endValue = value,
                    onChangePlaybackState: (value) =>
                        setState(() => _isPlaying = value),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("CANCEL"),
                    ),
                    TextButton(
                      child: _isPlaying
                          ? const Icon(
                              Icons.pause,
                              size: 80.0,
                              color: Colors.white,
                            )
                          : const Icon(
                              Icons.play_arrow,
                              size: 80.0,
                              color: Colors.white,
                            ),
                      onPressed: () async {
                        bool playbackState =
                            await _trimmer.videoPlaybackControl(
                          startValue: _startValue,
                          endValue: _endValue,
                        );
                        setState(() {
                          _isPlaying = playbackState;
                        });
                      },
                    ),
                    ElevatedButton(
                      onPressed: _progressVisibility ? null : _sendVideo,
                      child: const Text("SAVE"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
