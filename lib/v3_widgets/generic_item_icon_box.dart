import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:signals/signals_flutter.dart';

class GenericItemIconBox extends StatefulWidget {
  const GenericItemIconBox({super.key, required this.iconImagePaths, required this.boxSize, required this.isNetwork});

  final List<String> iconImagePaths;
  final Size boxSize;
  final bool isNetwork;

  @override
  State<GenericItemIconBox> createState() => _GenericItemIconBoxState();
}

class _GenericItemIconBoxState extends State<GenericItemIconBox> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.boxSize.width,
      height: widget.boxSize.height,
      child: Card(
          shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(0))),
          color: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
          margin: EdgeInsets.zero,
          elevation: 5,
          child: FlutterCarousel(
              options: FlutterCarouselOptions(
                  autoPlay: widget.iconImagePaths.length > 1 && itemIconSlides.watch(context) ? true : false,
                  autoPlayInterval: const Duration(seconds: 2),
                  disableCenter: true,
                  viewportFraction: 1.0,
                  height: double.infinity,
                  floatingIndicator: true,
                  enableInfiniteScroll: widget.iconImagePaths.length > 1 && itemIconSlides.watch(context) ? true : false,
                  indicatorMargin: 2,
                  showIndicator: widget.iconImagePaths.length > 1,
                  slideIndicator: CircularWaveSlideIndicator(
                      slideIndicatorOptions: SlideIndicatorOptions(
                          itemSpacing: 10, indicatorRadius: 4, currentIndicatorColor: Theme.of(context).colorScheme.primary, indicatorBackgroundColor: Theme.of(context).hintColor.withAlpha(200)))),
              items: widget.iconImagePaths.isNotEmpty
                  ? widget.iconImagePaths
                      .map((e) => widget.isNetwork
                          ? Image.network('https://raw.githubusercontent.com/KizKizz/pso2ngs_file_downloader/main$e',
                              filterQuality: FilterQuality.high,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Image.asset(
                                    'assets/img/placeholdersquare.png',
                                    filterQuality: FilterQuality.high,
                                    fit: BoxFit.cover,
                                  ))
                          : Image.file(
                              File(e),
                              filterQuality: FilterQuality.high,
                              fit: BoxFit.cover,
                            ))
                      .toList()
                  : [
                      Image.asset(
                        'assets/img/placeholdersquare.png',
                        filterQuality: FilterQuality.high,
                        fit: BoxFit.cover,
                      )
                    ])),
    );
  }
}
