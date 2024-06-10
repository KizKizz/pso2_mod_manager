import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:info_popup/info_popup.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:pso2_mod_manager/widgets/preview_image_stack.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/widgets/preview_video_stack.dart';

Offset previewTooltipDyOffset = const Offset(427, 0);

class ModManPreviewTooltip extends StatefulWidget {
  const ModManPreviewTooltip({super.key, required this.contentPositionOffSet, required this.submods, required this.watchTrigger, required this.appliedListTrigger, required this.child});

  final Offset contentPositionOffSet;
  final List<SubMod> submods;
  final bool watchTrigger;
  final bool appliedListTrigger;
  final Widget child;

  @override
  State<ModManPreviewTooltip> createState() => _ModManPreviewTooltipState();
}

class _ModManPreviewTooltipState extends State<ModManPreviewTooltip> {
  List<Widget> pWidgets = [];

  @override
  void dispose() {
    pWidgets.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    pWidgets.clear();
    for (var element in widget.submods) {
      pWidgets.addAll(element.previewImages.toSet().map((path) => PreviewImageStack(imagePath: path, overlayText: p.basenameWithoutExtension(p.dirname(path)))));
    }
    for (var element in widget.submods) {
      pWidgets.addAll(element.previewVideos.toSet().map((path) => PreviewVideoStack(videoPath: path, overlayText: p.basenameWithoutExtension(p.dirname(path)))));
    }
    return InfoPopupWidget(
        contentOffset: widget.contentPositionOffSet,
        dismissTriggerBehavior: PopupDismissTriggerBehavior.anyWhere,
        popupClickTriggerBehavior: PopupClickTriggerBehavior.none,
        onControllerCreated: (controller) {
          if (controller.customContent == null) {
            controller.dismissInfoPopup();
          }
        },
        arrowTheme: const InfoPopupArrowTheme(arrowSize: Size.zero),
        customContent: () => widget.watchTrigger
            ? (widget.submods.where((element) => element.previewImages.isNotEmpty).isNotEmpty || widget.submods.where((element) => element.previewVideos.isNotEmpty).isNotEmpty) &&
                    pWidgets.isNotEmpty &&
                    !context.watch<StateProvider>().showPreviewPanel &&
                    !context.watch<StateProvider>().mouseHoveringSubmods
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
                : null
            : widget.appliedListTrigger
                ? context.watch<StateProvider>().isCursorInAppliedList &&
                        (widget.submods.where((element) => element.previewImages.isNotEmpty).isNotEmpty || widget.submods.where((element) => element.previewVideos.isNotEmpty).isNotEmpty) &&
                        pWidgets.isNotEmpty &&
                        !context.watch<StateProvider>().showPreviewPanel
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
                    : null
                : (widget.submods.where((element) => element.previewImages.isNotEmpty).isNotEmpty || widget.submods.where((element) => element.previewVideos.isNotEmpty).isNotEmpty) &&
                        pWidgets.isNotEmpty &&
                        !context.watch<StateProvider>().showPreviewPanel
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
        child: widget.child);
  }
}
