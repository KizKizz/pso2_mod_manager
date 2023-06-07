import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
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
            content: CarouselSlider(
              carouselController: previewDialogCarouselController,
              options: CarouselOptions(
                  enableInfiniteScroll: isAutoPlay,
                  aspectRatio: 2.0,
                  enlargeCenterPage: true,
                  enlargeStrategy: CenterPageEnlargeStrategy.scale,
                  autoPlay: isAutoPlay,
                  autoPlayInterval: const Duration(seconds: 1),
                  onPageChanged: (index, reason) {
                    setState(() {
                      currentImageIndex = index;
                    });
                  }),
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
                      child: const Text('Previous'),
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
                      child: const Text('Next'),
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
                    child: Text(isAutoPlay ? 'Stop Auto Play' : 'Auto Play'),
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
