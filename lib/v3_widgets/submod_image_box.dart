import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/main_widgets/mod_image_preview_gallery_popup.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';
import 'package:signals/signals_flutter.dart';
import 'package:path/path.dart' as p;

bool showVideoPlayer = true;

class SubmodImageBox extends StatefulWidget {
  const SubmodImageBox({
    super.key,
    required this.imageFilePaths,
    required this.videoFilePaths,
    required this.isNew,
  });

  final List<String> imageFilePaths;
  final List<String> videoFilePaths;
  final bool isNew;

  @override
  State<SubmodImageBox> createState() => _SubmodImageBoxState();
}

class _SubmodImageBoxState extends State<SubmodImageBox> {
  late final Player videoPlayer;

  @override
  void initState() {
      videoPlayer = Player();
    super.initState();
  }

  @override
  void dispose() {
      videoPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> imagePaths = [];
    for (var path in widget.imageFilePaths) {
      if (imagePaths.indexWhere((e) => p.basename(e) == p.basename(path)) == -1) imagePaths.add(path);
    }
    List<String> videoPaths = [];
    for (var path in widget.videoFilePaths) {
      if (videoPaths.indexWhere((e) => p.basename(e) == p.basename(path)) == -1) videoPaths.add(path);
    }

    if ((imagePaths.isEmpty && videoPaths.isNotEmpty) || (imagePaths.isNotEmpty && videoPaths.isNotEmpty)) {
      videoPlayer.open(Playlist(videoPaths.map((e) => Media(e)).toList()));
      videoPlayer.setVolume(0);
      videoPlayer.stream.completed.listen((event) {
        if (event) {
          videoPlayer.play();
        }
      });
    }

    if (videoPaths.isNotEmpty) {
      return Container(
        foregroundDecoration: widget.isNew
            ? RotatedCornerDecoration.withColor(
                color: Colors.redAccent.withAlpha(220),
                badgeSize: const Size(40, 55),
                textSpan: TextSpan(
                  text: appText.xnew,
                  style: Theme.of(context).textTheme.labelLarge,
                ))
            : null,
        height: 200,
        child: Card(
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(0))),
            color: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
            margin: EdgeInsets.zero,
            elevation: 5,
            child: Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                // image
                Visibility(
                  visible: !showVideoPlayer || ((imagePaths.isNotEmpty && videoPaths.isEmpty) || (imagePaths.isEmpty && videoPaths.isEmpty)),
                  child: FlutterCarousel(
                    options: FlutterCarouselOptions(
                        autoPlay: imagePaths.length > 1 ? true : false,
                        autoPlayInterval: const Duration(seconds: 2),
                        disableCenter: true,
                        viewportFraction: 1.0,
                        height: double.infinity,
                        floatingIndicator: true,
                        enableInfiniteScroll: imagePaths.length > 1 ? true : false,
                        indicatorMargin: 2,
                        slideIndicator: CircularWaveSlideIndicator(
                            slideIndicatorOptions: SlideIndicatorOptions(
                                itemSpacing: 10,
                                indicatorRadius: 4,
                                currentIndicatorColor: Theme.of(context).colorScheme.primary,
                                indicatorBackgroundColor: Theme.of(context).hintColor.withAlpha(200)))),
                    items: imagePaths.where((e) => File(e).existsSync()).map((e) => Image.file(File(e))).toList(),
                  ),
                ),
                // video
                Visibility(
                  visible: showVideoPlayer && ((imagePaths.isEmpty && videoPaths.isNotEmpty) || (imagePaths.isNotEmpty && videoPaths.isNotEmpty)),
                  child: Video(controller: VideoController(videoPlayer)),
                ),

                Column(
                  spacing: 5,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Visibility(
                        visible: imagePaths.isNotEmpty && videoPaths.isNotEmpty,
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: IconButton(
                              onPressed: () {
                                showVideoPlayer ? showVideoPlayer = false : showVideoPlayer = true;
                                setState(() {});
                              },
                              icon: Icon(showVideoPlayer ? Icons.image : Icons.video_camera_back_outlined)),
                        )),
                    Visibility(
                        visible: !showVideoPlayer || imagePaths.isNotEmpty,
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: IconButton(
                              onPressed: () {
                                modImagePreviewGalleryPopup(context, imagePaths);
                              },
                              icon: const Icon(Icons.zoom_in)),
                        )),
                  ],
                )
              ],
            )),
      );
    } else {
      return Container(
        foregroundDecoration: widget.isNew
            ? RotatedCornerDecoration.withColor(
                color: Colors.redAccent.withAlpha(220),
                badgeSize: const Size(40, 55),
                textSpan: TextSpan(
                  text: appText.xnew,
                  style: Theme.of(context).textTheme.labelLarge,
                ))
            : null,
        height: 200,
        child: Card(
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(0))),
            color: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
            margin: EdgeInsets.zero,
            elevation: 5,
            child: Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                FlutterCarousel(
                  options: FlutterCarouselOptions(
                      autoPlay: imagePaths.length > 1 ? true : false,
                      autoPlayInterval: const Duration(seconds: 2),
                      disableCenter: true,
                      viewportFraction: 1.0,
                      height: double.infinity,
                      floatingIndicator: true,
                      enableInfiniteScroll: imagePaths.length > 1 ? true : false,
                      indicatorMargin: 2,
                      slideIndicator: CircularWaveSlideIndicator(
                          slideIndicatorOptions: SlideIndicatorOptions(
                              itemSpacing: 10,
                              indicatorRadius: 4,
                              currentIndicatorColor: Theme.of(context).colorScheme.primary,
                              indicatorBackgroundColor: Theme.of(context).hintColor.withAlpha(200)))),
                  items: imagePaths.where((e) => File(e).existsSync()).map((e) => Image.file(File(e))).toList(),
                ),
                Visibility(
                    visible: imagePaths.isNotEmpty,
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: IconButton(onPressed: () {}, icon: const Icon(Icons.zoom_in)),
                    )),
              ],
            )),
      );
    }
  }
}
