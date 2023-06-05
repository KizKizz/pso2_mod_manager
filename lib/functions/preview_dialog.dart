import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';

CarouselController previewDialogCarouselController = CarouselController();

void previewDialog(context) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            title: Text(previewModName),
            content: SizedBox(
              width: windowsWidth * 0.8,
              height: windowsHeight * 0.8,
              child: CarouselSlider(
                carouselController: previewDialogCarouselController,
                options: CarouselOptions(
                  enableInfiniteScroll: false,
                  enlargeCenterPage: true,
                  enlargeStrategy: CenterPageEnlargeStrategy.scale,
                ),
                items: previewDialogImages,
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  previewDialogImages.clear();
                  Navigator.pop(context);
                },
                child: Text(curLangText!.uiClose),
              ),
            ],
          );
        },
      );
    },
  );
}
