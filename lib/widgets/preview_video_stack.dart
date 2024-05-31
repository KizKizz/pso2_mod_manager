import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class PreviewVideoStack extends StatefulWidget {
  const PreviewVideoStack({super.key, required this.videoPath, required this.overlayText});

  final String videoPath;
  final String overlayText;

  @override
  State<PreviewVideoStack> createState() => _PreviewVideoStackState();
}

class _PreviewVideoStackState extends State<PreviewVideoStack> {
  // final Player videoPlayer = Player();
  bool showPlayButton = false;
  final Player videoPlayer = Player();

  @override
  void dispose() {
    videoPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    videoPlayer.open(Media(widget.videoPath));
    videoPlayer.setVolume(0);
    videoPlayer.stream.completed.listen((event) {
      if (event) {
        //videoPlayer.pause();
        videoPlayer.play();
      }
    });
    //videoPlayer.pause();
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Video(controller: VideoController(videoPlayer)),
            // Visibility(
            //   visible: previewDialogModName.isNotEmpty && videoPlayer.state.completed,
            //   child: MaterialButton(
            //     onPressed: () {
            //       videoPlayer.play();
            //       setState(() {

            //       });
            //     },
            //     child: const Wrap(
            //       alignment: WrapAlignment.center,
            //       runAlignment: WrapAlignment.center,
            //       spacing: 2,
            //       children: [Icon(Icons.play_arrow), Text('Play')],
            //     ),
            //   ),
            // )
          ],
        ),
        FittedBox(
          fit: BoxFit.fitWidth,
          child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: Theme.of(context).hintColor),
              ),
              height: 25,
              child: Center(
                  child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Text(widget.overlayText, style: const TextStyle(fontSize: 17)),
              ))),
        )
      ],
    );
  }
}
