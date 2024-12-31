import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:path/path.dart' as p;
import 'package:signals/signals_flutter.dart';

class BackgroundSlideshowBox extends StatefulWidget {
  const BackgroundSlideshowBox({super.key});

  @override
  State<BackgroundSlideshowBox> createState() => _BackgroundSlideshowBoxState();
}

class _BackgroundSlideshowBoxState extends State<BackgroundSlideshowBox> {
  late List<File> imageFiles;
  FlutterCarouselController controller = FlutterCarouselController();
  int currentFileIndex = 0;

  @override
  void initState() {
    imageFiles = Directory(backgroundDirPath).listSync(recursive: true).whereType<File>().where((e) => p.extension(e.path) == '.png' || p.extension(e.path) == '.jpg').toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(
        height: 220,
        child: Card(
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(0))),
            color: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
            margin: EdgeInsets.zero,
            elevation: 5,
            child: Visibility(
              visible: imageFiles.isNotEmpty,
              child: Column(
                spacing: 5,
                children: [
                  Stack(
                    alignment: AlignmentDirectional.bottomEnd,
                    children: [
                      FlutterCarousel(
                        options: FlutterCarouselOptions(
                          controller: controller,
                          autoPlay: false,
                          autoPlayInterval: const Duration(seconds: 2),
                          disableCenter: true,
                          viewportFraction: 1.0,
                          height: 220,
                          floatingIndicator: true,
                          enableInfiniteScroll: imageFiles.length > 1 ? true : false,
                          indicatorMargin: 2,
                          slideIndicator: CircularWaveSlideIndicator(
                              slideIndicatorOptions: SlideIndicatorOptions(
                                  itemSpacing: 10,
                                  indicatorRadius: 4,
                                  currentIndicatorColor: Theme.of(context).colorScheme.primary,
                                  indicatorBackgroundColor: Theme.of(context).hintColor.withAlpha(200))),
                          onPageChanged: (index, reason) => currentFileIndex = index,
                        ),
                        items: imageFiles
                            .map((e) => Image.file(
                                  e,
                                  fit: BoxFit.cover,
                                ))
                            .toList(),
                      ),
                      Visibility(
                          visible: imageFiles.isNotEmpty,
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: IconButton(
                                onPressed: () async {
                                  await imageFiles[currentFileIndex].delete();
                                  imageFiles.removeAt(currentFileIndex);
                                  setState(() {});
                                },
                                icon: const Icon(
                                  Icons.delete_forever,
                                  color: Colors.red,
                                )),
                          )),
                    ],
                  ),
                ],
              ),
            )),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Row(
          spacing: 5,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            OutlinedButton(
                onPressed: imageFiles.length > 1
                    ? () {
                        controller.previousPage();
                      }
                    : null,
                child: const Icon(Icons.arrow_back_ios_rounded)),
            OutlinedButton(
                onPressed: imageFiles.length > 1
                    ? () {
                        controller.nextPage();
                      }
                    : null,
                child: const Icon(Icons.arrow_forward_ios_rounded))
          ],
        ),
      )
    ]);
  }
}
