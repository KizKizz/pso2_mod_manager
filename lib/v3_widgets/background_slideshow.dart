import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:path/path.dart' as p;

class BackgroundSlideshow extends StatefulWidget {
  const BackgroundSlideshow({super.key, required this.dirPath});

  final String dirPath;

  @override
  State<BackgroundSlideshow> createState() => _BackgroundSlideshowState();
}

class _BackgroundSlideshowState extends State<BackgroundSlideshow> {
  @override
  Widget build(BuildContext context) {
    List<Widget> imgWidgetList = [];
    List<File> imageFiles = Directory(widget.dirPath).listSync(recursive: true).whereType<File>().where((e) => p.extension(e.path) == '.png' || p.extension(e.path) == '.jpg').toList();
    for (var file in imageFiles) {
      imgWidgetList.add(Image.file(
        file,
        width: double.infinity,
        height: double.infinity,
        filterQuality: FilterQuality.medium,
        fit: BoxFit.cover,
      ));
    }

    return FlutterCarousel(
      options: FlutterCarouselOptions(
          autoPlay: imgWidgetList.length > 1 ? true : false,
          autoPlayInterval: const Duration(seconds: 10),
          disableCenter: true,
          viewportFraction: 1.0,
          height: double.infinity,
          floatingIndicator: true,
          enableInfiniteScroll: true,
          indicatorMargin: 2,
          showIndicator: false),
      // slideIndicator: CircularWaveSlideIndicator(
      //     slideIndicatorOptions: SlideIndicatorOptions(
      //         itemSpacing: 10, indicatorRadius: 4, currentIndicatorColor: Theme.of(context).colorScheme.primary, indicatorBackgroundColor: Theme.of(context).hintColor.withOpacity(0.3)))),
      items: imgWidgetList,
    );
  }
}
