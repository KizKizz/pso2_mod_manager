import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:pso2_mod_manager/global_variables.dart';

class PreviewVideoStack extends StatefulWidget {
  const PreviewVideoStack({super.key, required this.videoPath, required this.overlayText});

  final String videoPath;
  final String overlayText;

  @override
  State<PreviewVideoStack> createState() => _PreviewVideoStackState();
}

class _PreviewVideoStackState extends State<PreviewVideoStack> {
  final Player videoPlayer = Player();
  bool showPlayButton = false;

  @override
  void dispose() {
    videoPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final VideoController vidPlayercontroller = VideoController(videoPlayer);
    videoPlayer.open(Media(widget.videoPath));
    videoPlayer.setVolume(0);
    videoPlayer.streams.completed.listen((event) {
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
            Video(controller: vidPlayercontroller),
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

// class PreviewVideoStack extends StatelessWidget {
//   const PreviewVideoStack({Key? key, required this.videoPath, required this.overlayText}) : super(key: key);

//   final String videoPath;
//   final String overlayText;


//   @override
//   Widget build(BuildContext context) {
//     final Player videoPlayer = Player();
//     final VideoController vidPlayercontroller = VideoController(videoPlayer);
//     videoPlayer.open(Media(videoPath));
//     videoPlayer.setVolume(0);
//     //videoPlayer.pause();
//     return Stack(
//       alignment: Alignment.bottomCenter,
//       children: [
//         Video(controller: vidPlayercontroller),
//         FittedBox(
//           fit: BoxFit.fitWidth,
//           child: Container(
//               decoration: BoxDecoration(
//                 color: Theme.of(context).canvasColor.withOpacity(0.5),
//                 borderRadius: BorderRadius.circular(3),
//                 border: Border.all(color: Theme.of(context).hintColor),
//               ),
//               height: 25,
//               child: Center(
//                   child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 5),
//                 child: Text(overlayText, style: const TextStyle(fontSize: 17)),
//               ))),
//         )
//       ],
//     );
//   }
// }
