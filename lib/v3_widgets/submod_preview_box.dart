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

class SubmodPreviewBox extends StatefulWidget {
  const SubmodPreviewBox({super.key, required this.imageFilePaths, required this.videoFilePaths, required this.isNew});

  final List<String> imageFilePaths;
  final List<String> videoFilePaths;
  final bool isNew;

  @override
  State<SubmodPreviewBox> createState() => _SubmodPreviewBoxState();
}

class _SubmodPreviewBoxState extends State<SubmodPreviewBox> {
  bool showPlayButton = false;
  bool showVideoBox = false;

  @override
  void initState() {
    widget.videoFilePaths.isEmpty ? showPlayButton = false : showPlayButton = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (showVideoBox) {
      return Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          SubmodVideoBox(
            videoFilePaths: widget.videoFilePaths,
            isNew: widget.isNew,
            videoCompleted: (finished) {
              if (finished) {
                showVideoBox = false;
                setState(() {});
              }
            },
          ),
          Visibility(
            visible: widget.imageFilePaths.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: IconButton.outlined(
                  style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor.withAlpha(150))),
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                  onPressed: () {
                    showVideoBox = false;
                    showPlayButton = false;
                    setState(() {});
                  },
                  icon: const Icon(Icons.image)),
            ),
          )
        ],
      );
    }
    if (showPlayButton) {
      return Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          Container(
              foregroundDecoration: widget.isNew
                  ? RotatedCornerDecoration.withColor(
                      color: Colors.redAccent.withAlpha(220),
                      badgeSize: const Size(40, 55),
                      textSpan: TextSpan(
                        text: appText.xnew,
                        style: Theme.of(context).textTheme.labelLarge,
                      ))
                  : null,
              width: double.infinity,
              height: 200,
              child: Card(
                  shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(0))),
                  color: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
                  margin: EdgeInsets.zero,
                  elevation: 5,
                  child: InkWell(
                    onTap: () {
                      showVideoBox = true;
                      setState(() {});
                    },
                    child: const Icon(Icons.play_arrow, size: 50),
                  ))),
          Visibility(
            visible: widget.imageFilePaths.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: IconButton.outlined(
                  style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor.withAlpha(150))),
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                  onPressed: () {
                    showVideoBox = false;
                    showPlayButton = false;
                    setState(() {});
                  },
                  icon: const Icon(Icons.image)),
            ),
          )
        ],
      );
    } else {
      return Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          SubmodImageBox(imageFilePaths: widget.imageFilePaths, isNew: widget.isNew),
          Visibility(
            visible: widget.videoFilePaths.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 3, right: 46),
              child: IconButton.outlined(
                  style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor.withAlpha(150))),
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                  onPressed: () {
                    showPlayButton = true;
                    setState(() {});
                  },
                  icon: const Icon(Icons.video_camera_back_outlined)),
            ),
          )
        ],
      );
    }
  }
}

class SubmodVideoBox extends StatefulWidget {
  const SubmodVideoBox({super.key, required this.videoFilePaths, required this.isNew, required this.videoCompleted});

  final List<String> videoFilePaths;
  final bool isNew;
  final Function(bool finished) videoCompleted;

  @override
  State<SubmodVideoBox> createState() => _SubmodVideoBOxState();
}

class _SubmodVideoBOxState extends State<SubmodVideoBox> {
  late final Player videoPlayer;
  late final Playlist playlist;

  @override
  void initState() {
    videoPlayer = Player();
    List<String> videoPaths = [];
    for (var path in widget.videoFilePaths) {
      if (videoPaths.indexWhere((e) => p.basename(e) == p.basename(path)) == -1) videoPaths.add(path);
    }
    playlist = Playlist(videoPaths.map((e) => Media(e)).toList());
    super.initState();
  }

  @override
  void dispose() {
    videoPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if ((playlist.medias.isNotEmpty)) {
      videoPlayer.open(playlist);
      videoPlayer.setVolume(0);
      videoPlayer.play();
    }
    videoPlayer.stream.completed.listen((event) {
      if (event) {
        if (playlist.index == playlist.medias.indexOf(playlist.medias.last)) {
          widget.videoCompleted(true);
        }
      }
    });

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
        child: Video(controller: VideoController(videoPlayer)),
      ),
    );
  }
}

class SubmodImageBox extends StatefulWidget {
  const SubmodImageBox({
    super.key,
    required this.imageFilePaths,
    required this.isNew,
  });

  final List<String> imageFilePaths;
  final bool isNew;

  @override
  State<SubmodImageBox> createState() => _SubmodImageBoxState();
}

class _SubmodImageBoxState extends State<SubmodImageBox> {
  @override
  Widget build(BuildContext context) {
    List<String> imagePaths = [];
    for (var path in widget.imageFilePaths) {
      if (imagePaths.indexWhere((e) => p.basename(e) == p.basename(path)) == -1) imagePaths.add(path);
    }

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
                            itemSpacing: 10, indicatorRadius: 4, currentIndicatorColor: Theme.of(context).colorScheme.primary, indicatorBackgroundColor: Theme.of(context).hintColor.withAlpha(200)))),
                items: imagePaths.where((e) => File(e).existsSync()).map((e) => Image.file(File(e))).toList(),
              ),
              Visibility(
                  visible: imagePaths.isNotEmpty,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 3, right: 3),
                    child: IconButton.outlined(
                        visualDensity: VisualDensity.adaptivePlatformDensity,
                        style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor.withAlpha(150))),
                        onPressed: () {
                          modImagePreviewGalleryPopup(context, imagePaths);
                        },
                        icon: const Icon(Icons.zoom_in)),
                  )),
            ],
          )),
    );
  }
}
