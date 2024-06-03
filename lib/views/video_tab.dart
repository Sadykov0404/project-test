import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:video_edit_player/views/video_edited_page.dart';

import 'package:video_edit_player/views/video_trimmer_page.dart';

class VideoTab extends StatefulWidget {
  const VideoTab({super.key});

  @override
  State<VideoTab> createState() => _VideoTabState();
}

class _VideoTabState extends State<VideoTab> {
  String? editedVideoPath;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.file_upload_outlined),
              SizedBox(width: 12),
              Text("LOAD VIDEO"),
            ],
          ),
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.video,
              allowCompression: false,
            );
            if (result != null) {
              File file = File(result.files.single.path!);
              final editedPath = await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return TrimmerView(file);
                }),
              );

              setState(() {
                editedVideoPath = editedPath;
              });
            }
          },
        ),
      ),
      floatingActionButton: editedVideoPath != null
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return VideoEditedPage(editedVideoPath!);
                  }),
                );
              },
              child: Icon(Icons.play_arrow),
            )
          : null,
    );
  }
}
