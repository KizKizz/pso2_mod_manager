import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_home/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';

class BackgroundSlideshow extends StatefulWidget {
  const BackgroundSlideshow({
    super.key,
    required this.isMini,
  });

  final bool isMini;

  @override
  State<BackgroundSlideshow> createState() => _BackgroundSlideshowState();
}

class _BackgroundSlideshowState extends State<BackgroundSlideshow> {
  FlutterCarouselController controller = FlutterCarouselController();
  int currentFileIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Refresh
    if (settingChangeStatus.watch(context) != settingChangeStatus.peek()) {
      setState(
        () {},
      );
    }
    if (!widget.isMini) {
      return FlutterCarousel(
          options: FlutterCarouselOptions(
              autoPlay: backgroundImageFiles.watch(context).length > 1 ? true : false,
              autoPlayInterval: Duration(seconds: backgroundImageSlideInterval.watch(context)),
              disableCenter: true,
              viewportFraction: 1.0,
              height: double.infinity,
              floatingIndicator: true,
              enableInfiniteScroll: backgroundImageFiles.watch(context).length > 1 ? true : false,
              indicatorMargin: 2,
              showIndicator: false,
              slideIndicator: CircularWaveSlideIndicator(
                  slideIndicatorOptions: SlideIndicatorOptions(
                      itemSpacing: 10, indicatorRadius: 4, currentIndicatorColor: Theme.of(context).colorScheme.primary, indicatorBackgroundColor: Theme.of(context).hintColor.withAlpha(150)))),
          items: backgroundImageFiles
              .watch(context)
              .map((e) => Image.file(
                    e,
                    width: double.infinity,
                    height: double.infinity,
                    filterQuality: FilterQuality.medium,
                    fit: BoxFit.cover,
                  ))
              .toList());
    } else {
      return Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
          child: Card(
              shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(0))),
              color: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
              margin: EdgeInsets.zero,
              elevation: 5,
              child: Visibility(
                visible: backgroundImageFiles.watch(context).isNotEmpty,
                child: Column(
                  spacing: 5,
                  children: [
                    Stack(
                      alignment: AlignmentDirectional.bottomEnd,
                      children: [
                        FlutterCarousel(
                          options: FlutterCarouselOptions(
                            controller: controller,
                            autoPlay: false,
                            autoPlayInterval: const Duration(seconds: 2),
                            disableCenter: true,
                            viewportFraction: 1.0,
                            height: MediaQuery.of(context).size.height * 0.3,
                            floatingIndicator: true,
                            enableInfiniteScroll: backgroundImageFiles.watch(context).length > 1 ? true : false,
                            indicatorMargin: 2,
                            slideIndicator: CircularWaveSlideIndicator(
                                slideIndicatorOptions: SlideIndicatorOptions(
                                    itemSpacing: 10,
                                    indicatorRadius: 4,
                                    currentIndicatorColor: Theme.of(context).colorScheme.primary,
                                    indicatorBackgroundColor: Theme.of(context).hintColor.withAlpha(200))),
                            onPageChanged: (index, reason) => currentFileIndex = index,
                          ),
                          items: backgroundImageFiles
                              .watch(context)
                              .map((e) => Image.file(
                                    e,
                                    fit: BoxFit.cover,
                                  ))
                              .toList(),
                        ),
                        Visibility(
                            visible: backgroundImageFiles.watch(context).isNotEmpty,
                            child: Padding(
                              padding: const EdgeInsets.all(3),
                              child: OutlinedButton.icon(
                                onLongPress: () async {
                                  await backgroundImageFiles.value[currentFileIndex].delete();
                                  backgroundImageFiles.value = backgroundImageFetch();
                                },
                                icon: const Icon(
                                  Icons.delete_forever,
                                  color: Colors.red,
                                ),
                                onPressed: () {},
                                label: Text(appText.remove, style: const TextStyle(color: Colors.red)),
                                style: ButtonStyle(visualDensity: VisualDensity.compact, backgroundColor: WidgetStateProperty.all(Colors.black.withAlpha(150))),
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
              )),
        ),
        Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Column(
              spacing: 5,
              children: [
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                        onPressed: backgroundImageFiles.watch(context).length > 1
                            ? () {
                                controller.previousPage();
                              }
                            : null,
                        child: const Icon(Icons.arrow_back_ios_rounded)),
                    OutlinedButton(
                        onPressed: backgroundImageFiles.watch(context).length > 1
                            ? () {
                                controller.nextPage();
                              }
                            : null,
                        child: const Icon(Icons.arrow_forward_ios_rounded)),
                    OutlinedButton(
                        onPressed: () {
                          backgroundImageFiles.value = backgroundImageFetch();
                        },
                        child: Text(appText.refresh)),
                    OutlinedButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          if (hideAppBackgroundSlides.value) {
                            hideAppBackgroundSlides.value = false;
                          } else {
                            hideAppBackgroundSlides.value = true;
                          }
                          prefs.setBool('hideAppBackgroundSlides', hideAppBackgroundSlides.value);
                        },
                        child: Text(hideAppBackgroundSlides.watch(context) ? appText.show : appText.hide)),
                  ],
                ),
                Row(
                  spacing: 5,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 5),
                    Text(appText.interval, style: Theme.of(context).textTheme.labelMedium),
                    Expanded(
                      child: SliderTheme(
                          data: SliderThemeData(overlayShape: SliderComponentShape.noOverlay, showValueIndicator: ShowValueIndicator.always),
                          child: Slider(
                            value: backgroundImageSlideInterval.watch(context).toDouble(),
                            min: 1,
                            max: 120,
                            label: appText.dText(appText.intervalNumSecond, backgroundImageSlideInterval.value.toString()),
                            onChanged: (value) async {
                              final prefs = await SharedPreferences.getInstance();
                              backgroundImageSlideInterval.value = value.round();
                              prefs.setInt('backgroundImageSlideInterval', backgroundImageSlideInterval.value);
                            },
                          )),
                    ),
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                      onPressed: () async {
                        const XTypeGroup jpgsTypeGroup = XTypeGroup(
                          label: 'Images',
                          extensions: <String>['jpg', 'jpeg', 'png'],
                        );
                        final List<XFile> selectedFiles = await openFiles(acceptedTypeGroups: <XTypeGroup>[jpgsTypeGroup]);
                        if (selectedFiles.isNotEmpty) {
                          for (var file in selectedFiles) {
                            await File(file.path).copy(backgroundDirPath + p.separator + p.basename(file.path));
                            backgroundImageFiles.value = backgroundImageFetch();
                          }
                        }
                      },
                      child: Text(appText.addImages)),
                )
              ],
            ))
      ]);
    }
  }
}

List<File> backgroundImageFetch() {
  if (Directory(backgroundDirPath).existsSync() &&
      Directory(backgroundDirPath).listSync(recursive: true).whereType<File>().where((e) => p.extension(e.path) == '.png' || p.extension(e.path) == '.jpg').isNotEmpty) {
    return Directory(backgroundDirPath).listSync(recursive: true).whereType<File>().where((e) => p.extension(e.path) == '.png' || p.extension(e.path) == '.jpg').toList();
  }
  return [];
}
