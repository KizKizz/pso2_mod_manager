import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';

class HelpPageGrid extends StatefulWidget {
  const HelpPageGrid({super.key});

  @override
  State<HelpPageGrid> createState() => _HelpPageGridState();
}

class _HelpPageGridState extends State<HelpPageGrid> {
  double fadeInOpacity = 0;
  final Player videoPlayer = Player();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 50), () {
      fadeInOpacity = 1;
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    videoPlayer.dispose();
    super.dispose();
  }

  void playVideo(String videoUrl) {
    videoPlayer.open(Media(Uri.parse(videoUrl).toString()));
    videoPlayer.setVolume(0);
    videoPlayer.play();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
        opacity: fadeInOpacity,
        duration: const Duration(milliseconds: 100),
        child: Expanded(
            child: Row(
          spacing: 5,
          children: [
            CardOverlay(
                paddingValue: 5,
                child: SingleChildScrollView(
                  child: Column(
                    spacing: 5,
                    children: [OutlinedButton(onPressed: () => setState(() {
                      
                    }), child: Text('data'))],
                  ),
                )),
            Expanded(
                child: CardOverlay(
              paddingValue: 5,
              child: Video(controller: VideoController(videoPlayer)),
            ))
          ],
        )));
  }
}
