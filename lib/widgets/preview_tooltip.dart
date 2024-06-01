import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:info_popup/info_popup.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/state_provider.dart';

class ModManPreviewTooltip extends StatefulWidget {
  const ModManPreviewTooltip({super.key, required this.child});

  final Widget child;

  @override
  State<ModManPreviewTooltip> createState() => _ModManPreviewTooltipState();
}

class _ModManPreviewTooltipState extends State<ModManPreviewTooltip> {

  @override
  Widget build(BuildContext context) {
    return InfoPopupWidget(
        arrowTheme: const InfoPopupArrowTheme(
          arrowSize: Size.zero
        ),
        customContent: () => previewImages.isNotEmpty && !context.watch<StateProvider>().showPreviewPanel
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
                    autoPlayInterval: previewImages.length > 1 && previewImages.where((element) => element.toString() == ('PreviewVideoStack')).length == previewImages.length
                        ? 7000
                        : previewImages.length > 1 && previewImages.where((element) => element.toString() == ('PreviewImageStack')).length == previewImages.length
                            ? 1000
                            : 0,
                    isLoop: true,
                    children: previewImages,
                  ),
                ),
              )
            : null,
        child: widget.child);
  }
}
