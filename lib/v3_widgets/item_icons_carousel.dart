import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

class ItemIconsCarousel extends StatelessWidget {
  const ItemIconsCarousel({
    super.key,
    required this.iconPaths,
  });

  final List<String> iconPaths;

  @override
  Widget build(BuildContext context) {
    List<Widget> imgWidgetList = [];
    for (var path in iconPaths) {
      imgWidgetList.add(Image.file(
        File(path),
        filterQuality: FilterQuality.none,
        fit: BoxFit.cover,
      ));
    }

    return FlutterCarousel(
      options: FlutterCarouselOptions(
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 2),
          disableCenter: true,
          viewportFraction: 1.0,
          height: double.infinity,
          floatingIndicator: true,
          enableInfiniteScroll: true,
          indicatorMargin: 2,
          slideIndicator: CircularWaveSlideIndicator(slideIndicatorOptions: SlideIndicatorOptions(itemSpacing: 10, indicatorRadius: 4, currentIndicatorColor: Theme.of(context).colorScheme.primary, indicatorBackgroundColor: Theme.of(context).hintColor.withOpacity(0.3)))),
      items: imgWidgetList,
    );
  }
}
