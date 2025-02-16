import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';
import 'package:signals/signals_flutter.dart';

class ItemIconBox extends StatefulWidget {
  const ItemIconBox({super.key, required this.item});

  final Item item;

  @override
  State<ItemIconBox> createState() => _ItemIconBoxState();
}

class _ItemIconBoxState extends State<ItemIconBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      foregroundDecoration: widget.item.isNew
          ? RotatedCornerDecoration.withColor(
              color: Colors.redAccent.withAlpha(220),
              badgeSize: const Size(40, 55),
              textSpan: TextSpan(
                text: appText.xnew,
                style: Theme.of(context).textTheme.labelLarge,
              ))
          : null,
      width: 140,
      height: 140,
      child: Card(
          shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(0))),
          color: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
          margin: EdgeInsets.zero,
          elevation: 5,
          child: widget.item.icons.isNotEmpty
              ? FlutterCarousel(
                  options: FlutterCarouselOptions(
                      autoPlay: widget.item.icons.length > 1 && itemIconSlides.watch(context) ? true : false,
                      autoPlayInterval: const Duration(seconds: 2),
                      disableCenter: true,
                      viewportFraction: 1.0,
                      height: double.infinity,
                      floatingIndicator: true,
                      enableInfiniteScroll: widget.item.icons.length > 1 && itemIconSlides.watch(context) ? true : false,
                      indicatorMargin: 2,
                      slideIndicator: CircularWaveSlideIndicator(
                          slideIndicatorOptions: SlideIndicatorOptions(
                              itemSpacing: 10,
                              indicatorRadius: 4,
                              currentIndicatorColor: Theme.of(context).colorScheme.primary,
                              indicatorBackgroundColor: Theme.of(context).hintColor.withAlpha(200)))),
                  items: widget.item.icons.where((e) => File(e).existsSync())
                      .map((e) => Image.file(
                            File(e),
                            filterQuality: FilterQuality.high,
                            fit: BoxFit.cover,
                          ))
                      .toList(),
                )
              : Image.asset(
                  'assets/img/placeholdersquare.png',
                  filterQuality: FilterQuality.high,
                  fit: BoxFit.cover,
                )),
    );
  }
}
