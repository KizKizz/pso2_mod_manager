import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';

class HelpPageGrid extends StatefulWidget {
  const HelpPageGrid({super.key});

  @override
  State<HelpPageGrid> createState() => _HelpPageGridState();
}

class _HelpPageGridState extends State<HelpPageGrid> {
  double fadeInOpacity = 0;
  final Player videoPlayer = Player();
  final helpVideos = <String, String>{
    appText.addModsToModManager: 'https://github.com/KizKizz/pso2_mod_manager/raw/refs/heads/main/help_data/add_mods.mp4',
    appText.applyRestoreMods: 'https://github.com/KizKizz/pso2_mod_manager/raw/refs/heads/main/help_data/apply_restore_mods.mp4',
    appText.swapModsToAnotherItem: 'https://github.com/KizKizz/pso2_mod_manager/raw/refs/heads/main/help_data/mod_swaps.mp4',
    appText.swapItemToAnotherItem: 'https://github.com/KizKizz/pso2_mod_manager/raw/refs/heads/main/help_data/item_swaps.mp4',
    appText.addModsToModSets: 'https://github.com/KizKizz/pso2_mod_manager/raw/refs/heads/main/help_data/mod_sets.mp4',
    appText.addCustomImagesToVitalGauge: 'https://github.com/KizKizz/pso2_mod_manager/raw/refs/heads/main/help_data/vital_gauge.mp4',
    appText.addCustomImagesToLineStrike: 'https://github.com/KizKizz/pso2_mod_manager/raw/refs/heads/main/help_data/line_strike.mp4'
  };

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
        child: Column(
          spacing: 5,
          children: [
            Expanded(
                child: CardOverlay(
              paddingValue: 5,
              child: Video(controller: VideoController(videoPlayer)),
            )),
            SizedBox(
              width: double.infinity,
              child: CardOverlay(
                paddingValue: 5,
                child: Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    alignment: WrapAlignment.center,
                    children: helpVideos.entries
                        .map((e) => OutlinedButton(
                            onPressed: () => setState(() {
                                  playVideo(e.value);
                                }),
                            child: Text(e.key)))
                        .toList()),
              ),
            ),
          ],
        ));
  }
}
