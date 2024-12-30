import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';

class SubmodImageBox extends StatefulWidget {
  const SubmodImageBox({super.key, required this.submod});

  final SubMod submod;

  @override
  State<SubmodImageBox> createState() => _SubmodImageBoxState();
}

class _SubmodImageBoxState extends State<SubmodImageBox> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Card(
          shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(0))),
          color: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha),
          margin: EdgeInsets.zero,
          elevation: 5,
          child: Stack(
            alignment: AlignmentDirectional.bottomEnd,
            children: [
              FlutterCarousel(
                options: FlutterCarouselOptions(
                    autoPlay: widget.submod.previewImages.length > 1 ? true : false,
                    autoPlayInterval: const Duration(seconds: 2),
                    disableCenter: true,
                    viewportFraction: 1.0,
                    height: double.infinity,
                    floatingIndicator: true,
                    enableInfiniteScroll: widget.submod.previewImages.length > 1 ? true : false,
                    indicatorMargin: 2,
                    slideIndicator: CircularWaveSlideIndicator(
                        slideIndicatorOptions: SlideIndicatorOptions(
                            itemSpacing: 10, indicatorRadius: 4, currentIndicatorColor: Theme.of(context).colorScheme.primary, indicatorBackgroundColor: Theme.of(context).hintColor.withAlpha(200)))),
                items: widget.submod.previewImages.map((e) => Image.file(File(e))).toList(),
              ),
              Visibility(
                visible: widget.submod.previewImages.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: IconButton(onPressed: () {}, icon: const Icon(Icons.zoom_in)),
                )),
            ],
          )),
    );
  }
}
