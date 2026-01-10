import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/main_widgets/popup_menu_functions.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:signals/signals_flutter.dart';

Future<void> modAqmSelectPopup(context, SubMod submod, List<String> availableItemList, List<String> availableItemLabels, Signal<String> selectedItem, List<Widget> extraWidgets) async {
  return await showDialog(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).colorScheme.outline),
              borderRadius: const BorderRadius.all(Radius.circular(5)),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiDialogBackgroundColorAlpha.watch(context)),
            insetPadding: const EdgeInsets.all(5),
            titlePadding: const EdgeInsets.only(top: 5, left: 10, right: 10),
            title: Column(
              children: [
                Text(appText.injectCustomAQM, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                const HoriDivider(),
              ],
            ),
            contentPadding: const EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 10),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: availableItemList
                    .map(
                      (e) => RadioGroup(
                        onChanged: (value) {
                          selectedItem.value = e;
                          setState(() {});
                          mainGridStatus.value = '[${DateTime.now()}] Selection: $e';
                        },
                        groupValue: selectedItem.value,
                        child: RadioListTile(
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Row(
                            spacing: 20,
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(availableItemLabels.isNotEmpty && availableItemLabels.length == availableItemList.length ? availableItemLabels[availableItemList.indexOf(e)] : e),
                              if (extraWidgets.length == availableItemList.length) extraWidgets[availableItemList.indexOf(e)],
                            ],
                          ),
                          selected: selectedItem.value == e,
                          value: e,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            actionsPadding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
            actions: [
              HoriDivider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(visible: submod.customAQMInjected!, child: Text(appText.dText(appText.injectedAQMFile, submod.customAQMFileName!))),
                  Row(
                    spacing: 5,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton(
                        onPressed: () async {
                          await submodAqmInject(context, submod);
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop();
                        },
                        child: Text(appText.injectAQM),
                      ),
                      OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: Text(appText.returns)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
}
