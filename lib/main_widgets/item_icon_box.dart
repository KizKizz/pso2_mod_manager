import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:signals/signals_flutter.dart';

class ItemIconBox extends StatefulWidget {
  const ItemIconBox({super.key, required this.item, required this.showSubCategory});

  final Item item;
  final bool showSubCategory;

  @override
  State<ItemIconBox> createState() => _ItemIconBoxState();
}

class _ItemIconBoxState extends State<ItemIconBox> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: AlignmentDirectional.topEnd,
        children: [
          Card(
              shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(0))),
              color: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
              margin: EdgeInsets.zero,
              elevation: 5,
              child: Stack(
                alignment: AlignmentDirectional.bottomCenter,
                fit: StackFit.expand,
                children: [
                  widget.item.icons.isNotEmpty
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
                          items: widget.item.icons
                              .where((e) => File(e).existsSync())
                              .map((e) => Image.file(
                                    File(e),
                                    filterQuality: FilterQuality.high,
                                    fit: BoxFit.cover,
                                  ))
                              .toList(),
                        )
                      : Image.asset(
                          'assets/img/placeholdersquare.png',
                          filterQuality: FilterQuality.medium,
                          fit: BoxFit.cover,
                        ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Visibility(
                        visible: widget.showSubCategory && !aqmInjectCategoryDirs.contains(widget.item.category) && widget.item.subCategory!.isNotEmpty,
                        child: Container(
                          color: Theme.of(context).scaffoldBackgroundColor.withAlpha(200),
                          height: 25,
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: AutoSizeText(
                              widget.item.category == defaultCategoryDirs[14]
                                  ? appText.motionTypeName(widget.item.subCategory!)
                                  : widget.item.category == defaultCategoryDirs[17]
                                      ? appText.weaponTypeName(widget.item.subCategory!.split('* ').last)
                                      : widget.item.subCategory!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              )),
          Row(
            spacing: 0.5,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (widget.item.isFavorite) Icon(Icons.favorite, color: Colors.redAccent),
              Spacer(),
              if (widget.item.isNew)
                Padding(
                  padding: const EdgeInsets.only(top: 1.5, right: 2),
                  child: Text(
                    appText.xnew,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, backgroundColor: Colors.redAccent),
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }
}
