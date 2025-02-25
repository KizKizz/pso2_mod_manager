import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/main_widgets/item_icon_box.dart';
import 'package:pso2_mod_manager/main_widgets/item_more_functions_menu.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/info_box.dart';
import 'package:signals/signals_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PopupItemInfo extends StatefulWidget {
  const PopupItemInfo({super.key, required this.item, required this.showModInfo});

  final Item item;
  final bool showModInfo;

  @override
  State<PopupItemInfo> createState() => _PopupItemInfoState();
}

class _PopupItemInfoState extends State<PopupItemInfo> {
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 5,
      children: [
        ItemIconBox(item: widget.item),
        Text(
          appText.categoryName(widget.item.category),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          widget.item.getDisplayName(),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Row(
          spacing: 5,
          children: [
            Visibility(
              visible: widget.showModInfo,
              child: Expanded(
                child: InfoBox(
                  info: appText.dText(widget.item.mods.length > 1 ? appText.numMods : appText.numMod, widget.item.mods.length.toString()),
                  borderHighlight: false,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: InfoBox(
                info: appText.dText(appText.numCurrentlyApplied, widget.item.getNumOfAppliedMods().toString()),
                borderHighlight: widget.item.applyStatus,
              ),
            ),
          ],
        ),
        Row(
          spacing: 5,
          children: [
            Expanded(
                child: OutlinedButton(
                    style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)))),
                    onPressed: () => launchUrlString(widget.item.location),
                    child: Text(appText.openInFileExplorer))),
            ItemMoreFunctionsMenu(item: widget.item, isInsidePopup: true,)
          ],
        ),
      ],
    );
  }
}
