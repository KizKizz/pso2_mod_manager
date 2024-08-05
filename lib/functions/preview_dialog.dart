import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';

CarouselController previewDialogCarouselController = CarouselController();
bool isAutoPlay = false;
int currentImageIndex = 0;

void previewDialog(context) async {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
            backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
            titlePadding: EdgeInsets.zero,
            title: Column(
              children: [
                Text(previewDialogModName),
                const Divider(
                  indent: 5,
                  endIndent: 5,
                  thickness: 1,
                  height: 5,
                )
              ],
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            content: FlutterCarousel(
              options: CarouselOptions(
                  controller: previewDialogCarouselController,
                  autoPlay: isAutoPlay,
                  autoPlayInterval: previewDialogImages.length > 1 && previewDialogImages.where((element) => element.toString() == ('PreviewVideoStack')).length == previewDialogImages.length
                      ? const Duration(seconds: 5)
                      : previewDialogImages.length > 1 && previewDialogImages.where((element) => element.toString() == ('previewDialogImagestack')).length == previewDialogImages.length
                          ? const Duration(seconds: 1)
                          : const Duration(seconds: 2),
                  disableCenter: true,
                  viewportFraction: 1.0,
                  aspectRatio: 2.0,
                  floatingIndicator: false,
                  enableInfiniteScroll: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      currentImageIndex = index;
                    });
                  },
                  indicatorMargin: 4,
                  slideIndicator: CircularWaveSlideIndicator(slideIndicatorOptions: SlideIndicatorOptions(itemSpacing: 10, indicatorRadius: 4, currentIndicatorColor: Theme.of(context).colorScheme.primary, indicatorBackgroundColor: Theme.of(context).hintColor.withOpacity(0.3)))),
              items: previewDialogImages,
            ),
           
            actionsOverflowButtonSpacing: 5,
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: <Widget>[
              Wrap(
                runAlignment: WrapAlignment.center,
                alignment: WrapAlignment.center,
                spacing: 5,
                children: [
                  SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: previewDialogImages.length < 2 || currentImageIndex < 1 || isAutoPlay
                          ? null
                          : () {
                              previewDialogCarouselController.previousPage();
                              setState(
                                () {},
                              );
                            },
                      child: Text(curLangText!.uiPrevious),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: previewDialogImages.length < 2 || currentImageIndex >= previewDialogImages.length - 1 || isAutoPlay
                          ? null
                          : () {
                              previewDialogCarouselController.nextPage();
                              setState(
                                () {},
                              );
                            },
                      child: Text(curLangText!.uiNext),
                    ),
                  ),
                  const VerticalDivider(
                    thickness: 2,
                  ),
                  Text('${currentImageIndex + 1}/${previewDialogImages.length}'),
                  const VerticalDivider(
                    thickness: 2,
                  ),
                  ElevatedButton(
                    onPressed: previewDialogImages.length < 2
                        ? null
                        : () {
                            if (isAutoPlay) {
                              previewDialogCarouselController.stopAutoPlay();
                              isAutoPlay = false;
                            } else {
                              previewDialogCarouselController.startAutoPlay();
                              isAutoPlay = true;
                            }
                            setState(
                              () {},
                            );
                          },
                    child: Text(isAutoPlay ? curLangText!.uiStopAutoPlay : curLangText!.uiAutoPlay),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  previewDialogImages.clear();
                  previewDialogModName = '';
                  currentImageIndex = 0;
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
