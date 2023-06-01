import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:pso2_mod_manager/global_variables.dart';

class PreviewVideoStack extends StatelessWidget {
  const PreviewVideoStack({Key? key, required this.videoPath, required this.overlayText}) : super(key: key);

  final String videoPath;
  final String overlayText;

  @override
  Widget build(BuildContext context) {
    videoPlayer.open(Media(videoPath));
    videoPlayer.setVolume(0);
    //videoPlayer.pause();
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Video(controller: vidPlayercontroller),
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
                child: Text(overlayText, style: const TextStyle(fontSize: 17)),
              ))),
        )
      ],
    );
  }
}
