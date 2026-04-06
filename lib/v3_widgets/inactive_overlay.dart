import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_title_bar.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/background_slideshow.dart';
import 'package:signals/signals_flutter.dart';

Future<void> inactiveOverlay(context) async {
  bool isHovering = false;
  await showDialog(
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0))),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
            insetPadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.zero,
            content: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Scaffold(
                appBar: const PreferredSize(preferredSize: Size(double.maxFinite, 25), child: AppTitleBar()),
                body: InkWell(
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    mouseCursor: MouseCursor.defer,
                    onTap: () => Navigator.of(context).pop(),
                    onSecondaryTap: () => Navigator.of(context).pop(),
                    onHover: (value) => setState(() => value ? isHovering = true : isHovering = false),
                    child: Stack(
                      alignment: AlignmentDirectional.bottomEnd,
                      children: [
                        const BackgroundSlideshow(isMini: false),
                        Visibility(
                          visible: showMessageOnInactiveOverlay.watch(context) || isHovering,
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Card(
                                shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(5))),
                                color: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
                                margin: EdgeInsets.zero,
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                                  child: Text(
                                    appText.tapToReturn,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.headlineSmall,
                                  ),
                                )),
                          ),
                        )
                      ],
                    )),
              ),
            ),
          );
        });
      });
}
