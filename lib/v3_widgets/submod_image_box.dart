import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';
import 'package:signals/signals_flutter.dart';
import 'package:path/path.dart' as p;

class SubmodImageBox extends StatefulWidget {
  const SubmodImageBox({
    super.key,
    required this.filePaths,
    required this.isNew,
  });

  final List<String> filePaths;
  final bool isNew;

  @override
  State<SubmodImageBox> createState() => _SubmodImageBoxState();
}

class _SubmodImageBoxState extends State<SubmodImageBox> {
  List<String> paths = [];

  @override
  void initState() {
    for (var path in widget.filePaths) {
      if (paths.indexWhere((e) => p.basename(e) == p.basename(path)) == -1) paths.add(path);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                    autoPlay: paths.length > 1 ? true : false,
                    autoPlayInterval: const Duration(seconds: 2),
                    disableCenter: true,
                    viewportFraction: 1.0,
                    height: double.infinity,
                    floatingIndicator: true,
                    enableInfiniteScroll: paths.length > 1 ? true : false,
                    indicatorMargin: 2,
                    slideIndicator: CircularWaveSlideIndicator(
                        slideIndicatorOptions: SlideIndicatorOptions(
                            itemSpacing: 10, indicatorRadius: 4, currentIndicatorColor: Theme.of(context).colorScheme.primary, indicatorBackgroundColor: Theme.of(context).hintColor.withAlpha(200)))),
                items: paths.map((e) => Image.file(File(e))).toList(),
              ),
              Visibility(
                  visible: paths.isNotEmpty,
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: IconButton(onPressed: () {}, icon: const Icon(Icons.zoom_in)),
                  )),
            ],
          )),
    );
  }
}
