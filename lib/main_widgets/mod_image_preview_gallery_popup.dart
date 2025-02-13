import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:signals/signals_flutter.dart';

Future<void> modImagePreviewGalleryPopup(context, List<String> imagePaths) async {
  await showDialog(
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0))),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiDialogBackgroundColorAlpha.watch(context)),
            insetPadding: const EdgeInsets.only(top: 25),
            contentPadding: const EdgeInsets.only(top: 10, bottom: 0, left: 10, right: 10),
            content: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: FlutterCarousel(
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
            ),
            actionsPadding: const EdgeInsets.only(top: 0, bottom: 10, left: 10, right: 10),
            actions: [
              const HoriDivider(),
              OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(appText.returns))
            ],
          );
        });
      });
}
