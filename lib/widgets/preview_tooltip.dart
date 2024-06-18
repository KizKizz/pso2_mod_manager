import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:info_popup/info_popup.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/pages/home_page.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:pso2_mod_manager/widgets/preview_image_stack.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/widgets/preview_video_stack.dart';

Offset previewTooltipDyOffset = const Offset(427, 0);

// class ModManPreviewTooltip extends StatefulWidget {
//   final Offset contentPositionOffSet;
//   final List<String> images;
//   final List<String> videos;
//   final String separateString;
//   final bool isModPreview;
//   final bool isSubmodPrevew;
//   final bool isModFilePreview;
//   final bool isAppliedListPreview;
//   final bool isSetItemPreview;
//   final Widget child;

//   const ModManPreviewTooltip(
//       {super.key,
//       required this.images,
//       required this.videos,
//       required this.separateString,
//       required this.isModPreview,
//       required this.isSubmodPrevew,
//       required this.isModFilePreview,
//       required this.isAppliedListPreview,
//       required this.isSetItemPreview,
//       required this.child,
//       required this.contentPositionOffSet});

//   @override
//   State<ModManPreviewTooltip> createState() => _ModManPreviewTooltipState();
// }

// class _ModManPreviewTooltipState extends State<ModManPreviewTooltip> {

//   @override
//   Widget build(BuildContext context) {
//     List<Widget> pWidgets = [];
//     if (widget.images.isNotEmpty) {
//       pWidgets.addAll(widget.images.toSet().map((path) => PreviewImageStack(imagePath: path, overlayText: p.basenameWithoutExtension(p.dirname(path)))));
//     }
//     if (widget.videos.isNotEmpty) {
//       pWidgets.addAll(widget.images.toSet().map((path) => PreviewVideoStack(videoPath: path, overlayText: p.basenameWithoutExtension(p.dirname(path)))));
//     }
//     return InfoPopupWidget(
//         contentOffset: widget.contentPositionOffSet,
//         dismissTriggerBehavior: PopupDismissTriggerBehavior.anyWhere,
//         popupClickTriggerBehavior: PopupClickTriggerBehavior.none,
//         onControllerCreated: (controller) {
//           if (controller.customContent == null) {
//             controller.dismissInfoPopup();
//           }
//         },
//         arrowTheme: const InfoPopupArrowTheme(arrowSize: Size.zero),
//         customContent: () => (widget.isModPreview && !hoveringOnSubmod && !hoveringOnModFile ||
//                     widget.isSubmodPrevew && hoveringOnSubmod ||
//                     widget.isModFilePreview && hoveringOnModFile ||
//                     widget.isAppliedListPreview ||
//                     widget.isSetItemPreview) &&
//                 pWidgets.isNotEmpty
//             ? ConstrainedBox(
//                 constraints: BoxConstraints(minWidth: appWindow.size.width / 5, minHeight: appWindow.size.height / 5, maxWidth: appWindow.size.width / 3, maxHeight: appWindow.size.height / 3),
//                 child: Container(
//                   decoration: BoxDecoration(
//                       color: Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8),
//                       border: Border.all(color: Theme.of(context).primaryColorLight),
//                       borderRadius: const BorderRadius.all(Radius.circular(2))),
//                   child: ImageSlideshow(
//                     height: double.infinity,
//                     initialPage: 0,
//                     indicatorColor: Colors.transparent,
//                     indicatorBackgroundColor: Colors.transparent,
//                     autoPlayInterval: pWidgets.length > 1 && pWidgets.where((element) => element.toString() == ('PreviewVideoStack')).length == pWidgets.length
//                         ? 7000
//                         : pWidgets.length > 1 && pWidgets.where((element) => element.toString() == ('PreviewImageStack')).length == pWidgets.length
//                             ? 1000
//                             : 0,
//                     isLoop: true,
//                     children: pWidgets,
//                   ),
//                 ),
//               )
//             : null,
//         child: widget.child);
//   }
// }

class ModManPreviewTooltip extends StatelessWidget {
  const ModManPreviewTooltip(
      {super.key,
      required this.contentPositionOffSet,
      required this.images,
      required this.videos,
      required this.separateString,
      required this.isModPreview,
      required this.isSubmodPrevew,
      required this.isModFilePreview,
      required this.isAppliedListPreview,
      required this.isSetItemPreview,
      required this.child});

  final Offset contentPositionOffSet;
  final List<String> images;
  final List<String> videos;
  final String separateString;
  final bool isModPreview;
  final bool isSubmodPrevew;
  final bool isModFilePreview;
  final bool isAppliedListPreview;
  final bool isSetItemPreview;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    List<Widget> pWidgets = [];
    if (images.isNotEmpty) {
      pWidgets.addAll(images.toSet().map((path) => PreviewImageStack(imagePath: path, overlayText: p.basenameWithoutExtension(p.dirname(path)))));
    }
    if (videos.isNotEmpty) {
      pWidgets.addAll(images.toSet().map((path) => PreviewVideoStack(videoPath: path, overlayText: p.basenameWithoutExtension(p.dirname(path)))));
    }
    return InfoPopupWidget(
        contentOffset: contentPositionOffSet,
        dismissTriggerBehavior: PopupDismissTriggerBehavior.anyWhere,
        popupClickTriggerBehavior: PopupClickTriggerBehavior.none,
        onControllerCreated: (controller) {
          if (controller.customContent == null) {
            controller.dismissInfoPopup();
          }
        },
        arrowTheme: const InfoPopupArrowTheme(arrowSize: Size.zero),
        customContent: () =>
            (isModPreview && !hoveringOnSubmod && !hoveringOnModFile || isSubmodPrevew && hoveringOnSubmod || isModFilePreview && hoveringOnModFile || isAppliedListPreview || isSetItemPreview) && pWidgets.isNotEmpty
                ? ConstrainedBox(
                    constraints: BoxConstraints(minWidth: appWindow.size.width / 5, minHeight: appWindow.size.height / 5, maxWidth: appWindow.size.width / 3, maxHeight: appWindow.size.height / 3),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8),
                          border: Border.all(color: Theme.of(context).primaryColorLight),
                          borderRadius: const BorderRadius.all(Radius.circular(2))),
                      child: ImageSlideshow(
                        height: double.infinity,
                        initialPage: 0,
                        indicatorColor: Colors.transparent,
                        indicatorBackgroundColor: Colors.transparent,
                        autoPlayInterval: pWidgets.length > 1 && pWidgets.where((element) => element.toString() == ('PreviewVideoStack')).length == pWidgets.length
                            ? 7000
                            : pWidgets.length > 1 && pWidgets.where((element) => element.toString() == ('PreviewImageStack')).length == pWidgets.length
                                ? 1000
                                : 0,
                        isLoop: true,
                        children: pWidgets,
                      ),
                    ),
                  )
                : null,
        child: child);
  }
}

// class ModManPreviewTooltip extends StatelessWidget {
//   const ModManPreviewTooltip({super.key, required this.contentPositionOffSet, required this.submods, required this.watchTrigger, required this.appliedListTrigger, required this.child});

//   final Offset contentPositionOffSet;
//   final List<SubMod> submods;
//   final bool watchTrigger;
//   final bool appliedListTrigger;
//   final Widget child;

//   @override
//   Widget build(BuildContext context) {
//     List<Widget> pWidgets = [];
//     for (var element in submods) {
//       pWidgets.addAll(element.previewImages.toSet().map((path) => PreviewImageStack(imagePath: path, overlayText: p.basenameWithoutExtension(p.dirname(path)))));
//     }
//     for (var element in submods) {
//       pWidgets.addAll(element.previewVideos.toSet().map((path) => PreviewVideoStack(videoPath: path, overlayText: p.basenameWithoutExtension(p.dirname(path)))));
//     }
//     return InfoPopupWidget(
//         contentOffset: contentPositionOffSet,
//         dismissTriggerBehavior: PopupDismissTriggerBehavior.anyWhere,
//         popupClickTriggerBehavior: PopupClickTriggerBehavior.none,
//         onControllerCreated: (controller) {
//           if (controller.customContent == null) {
//             controller.dismissInfoPopup();
//           }
//         },
//         arrowTheme: const InfoPopupArrowTheme(arrowSize: Size.zero),
//         customContent: () => watchTrigger
//             ? (submods.where((element) => element.previewImages.isNotEmpty).isNotEmpty || submods.where((element) => element.previewVideos.isNotEmpty).isNotEmpty) &&
//                     pWidgets.isNotEmpty &&
//                     !context.watch<StateProvider>().showPreviewPanel &&
//                     !context.watch<StateProvider>().mouseHoveringSubmods
//                 ? ConstrainedBox(
//                     constraints: BoxConstraints(minWidth: appWindow.size.width / 5, minHeight: appWindow.size.height / 5, maxWidth: appWindow.size.width / 3, maxHeight: appWindow.size.height / 3),
//                     child: Container(
//                       decoration: BoxDecoration(
//                           color: Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8),
//                           border: Border.all(color: Theme.of(context).primaryColorLight),
//                           borderRadius: const BorderRadius.all(Radius.circular(2))),
//                       child: ImageSlideshow(
//                         height: double.infinity,
//                         initialPage: 0,
//                         indicatorColor: Colors.transparent,
//                         indicatorBackgroundColor: Colors.transparent,
//                         autoPlayInterval: pWidgets.length > 1 && pWidgets.where((element) => element.toString() == ('PreviewVideoStack')).length == pWidgets.length
//                             ? 7000
//                             : pWidgets.length > 1 && pWidgets.where((element) => element.toString() == ('PreviewImageStack')).length == pWidgets.length
//                                 ? 1000
//                                 : 0,
//                         isLoop: true,
//                         children: pWidgets,
//                       ),
//                     ),
//                   )
//                 : null
//             : appliedListTrigger
//                 ? context.watch<StateProvider>().isCursorInAppliedList &&
//                         (submods.where((element) => element.previewImages.isNotEmpty).isNotEmpty || submods.where((element) => element.previewVideos.isNotEmpty).isNotEmpty) &&
//                         pWidgets.isNotEmpty &&
//                         !context.watch<StateProvider>().showPreviewPanel
//                     ? ConstrainedBox(
//                         constraints: BoxConstraints(minWidth: appWindow.size.width / 5, minHeight: appWindow.size.height / 5, maxWidth: appWindow.size.width / 3, maxHeight: appWindow.size.height / 3),
//                         child: Container(
//                           decoration: BoxDecoration(
//                               color: Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8),
//                               border: Border.all(color: Theme.of(context).primaryColorLight),
//                               borderRadius: const BorderRadius.all(Radius.circular(2))),
//                           child: ImageSlideshow(
//                             height: double.infinity,
//                             initialPage: 0,
//                             indicatorColor: Colors.transparent,
//                             indicatorBackgroundColor: Colors.transparent,
//                             autoPlayInterval: pWidgets.length > 1 && pWidgets.where((element) => element.toString() == ('PreviewVideoStack')).length == pWidgets.length
//                                 ? 7000
//                                 : pWidgets.length > 1 && pWidgets.where((element) => element.toString() == ('PreviewImageStack')).length == pWidgets.length
//                                     ? 1000
//                                     : 0,
//                             isLoop: true,
//                             children: pWidgets,
//                           ),
//                         ),
//                       )
//                     : null
//                 : (submods.where((element) => element.previewImages.isNotEmpty).isNotEmpty || submods.where((element) => element.previewVideos.isNotEmpty).isNotEmpty) &&
//                         pWidgets.isNotEmpty &&
//                         !context.watch<StateProvider>().showPreviewPanel
//                     ? ConstrainedBox(
//                         constraints: BoxConstraints(minWidth: appWindow.size.width / 5, minHeight: appWindow.size.height / 5, maxWidth: appWindow.size.width / 3, maxHeight: appWindow.size.height / 3),
//                         child: Container(
//                           decoration: BoxDecoration(
//                               color: Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8),
//                               border: Border.all(color: Theme.of(context).primaryColorLight),
//                               borderRadius: const BorderRadius.all(Radius.circular(2))),
//                           child: ImageSlideshow(
//                             height: double.infinity,
//                             initialPage: 0,
//                             indicatorColor: Colors.transparent,
//                             indicatorBackgroundColor: Colors.transparent,
//                             autoPlayInterval: pWidgets.length > 1 && pWidgets.where((element) => element.toString() == ('PreviewVideoStack')).length == pWidgets.length
//                                 ? 7000
//                                 : pWidgets.length > 1 && pWidgets.where((element) => element.toString() == ('PreviewImageStack')).length == pWidgets.length
//                                     ? 1000
//                                     : 0,
//                             isLoop: true,
//                             children: pWidgets,
//                           ),
//                         ),
//                       )
//                     : null,
//         child: child);
//   }
// }