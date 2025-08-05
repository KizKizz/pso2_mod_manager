import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:signals/signals_flutter.dart';
import 'package:path/path.dart' as p;

class MultiChoiceSelectButton extends StatefulWidget {
  const MultiChoiceSelectButton(
      {super.key,
      required this.width,
      required this.height,
      required this.label,
      required this.selectPopupLabel,
      required this.availableItemList,
      required this.availableItemLabels,
      required this.selectedItemsLabel,
      required this.selectedItems,
      required this.extraWidgets,
      required this.savePref});

  final double width;
  final double height;
  final String label;
  final String selectPopupLabel;
  final List<String> availableItemList;
  final List<String> availableItemLabels;
  final List<String> selectedItemsLabel;
  final Signal<List<String>> selectedItems;
  final List<Widget> extraWidgets;
  final Function savePref;

  @override
  State<MultiChoiceSelectButton> createState() => _MultiChoiceSelectButtonState();
}

class _MultiChoiceSelectButtonState extends State<MultiChoiceSelectButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: OutlinedButton(
          style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context))),
              side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5)),
              padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 10))),
          onPressed: () async {
            await _multiChoiceSelectPopup(context, widget.selectPopupLabel, widget.availableItemList, widget.availableItemLabels, widget.selectedItems, widget.extraWidgets);
            setState(() {});
            widget.savePref();
          },
          child: Row(
            spacing: 2.5,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsetsGeometry.only(top: 1.2),
                child: Text(
                  widget.label,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.5),
                child: Text(
                    widget.selectedItems.watch(context).length == widget.availableItemList.length || widget.selectedItems.value.contains('All')
                        ? appText.all
                        : widget.selectedItems.watch(context).length == 1
                            ? widget.selectedItemsLabel.first
                            : widget.selectedItems.watch(context).isEmpty
                                ? appText.select
                                : '${widget.selectedItemsLabel.first} +${widget.selectedItemsLabel.length - 1}',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge),
              )
            ],
          )),
    );
  }
}

Future<void> _multiChoiceSelectPopup(
    context, String selectPopupLabel, List<String> availableItemList, List<String> availableItemLabels, Signal<List<String>> selectedItems, List<Widget> extraWidgets) async {
  if (selectedItems.value.contains('All')) {
    selectedItems.value.retainWhere((e) => e == 'All');
    selectedItems.value.addAll(availableItemList);
  }
  return await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
              shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline), borderRadius: const BorderRadius.all(Radius.circular(5))),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiDialogBackgroundColorAlpha.watch(context)),
              insetPadding: const EdgeInsets.all(5),
              titlePadding: const EdgeInsets.only(top: 5),
              title: Column(children: [
                Text(
                  selectPopupLabel,
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
                const HoriDivider()
              ]),
              contentPadding: const EdgeInsets.only(top: 5, bottom: 0, left: 10, right: 10),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: availableItemList
                      .map((e) => CheckboxListTile(
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
                            selected: selectedItems.value.contains(e),
                            value: selectedItems.value.contains(e),
                            onChanged: (value) {
                              selectedItems.value.removeWhere((e) => e == 'All');
                              selectedItems.value.contains(e) ? selectedItems.value.remove(e) : selectedItems.value.add(e);
                              setState(
                                () {},
                              );
                              mainGridStatus.value = '[${DateTime.now()}] Selection: ${selectedItems.value.join(', ')}';
                            },
                          ))
                      .toList(),
                ),
              ),
              actionsPadding: const EdgeInsets.only(top: 0, bottom: 10, left: 10, right: 10),
              actions: [
                const HoriDivider(),
                OverflowBar(
                  spacing: 5,
                  overflowSpacing: 5,
                  alignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                        onPressed: () {
                          selectedItems.value.clear();
                          selectedItems.value.add('All');
                          selectedItems.value.addAll(availableItemList);
                          setState(
                            () {},
                          );
                          mainGridStatus.value = '[${DateTime.now()}] Selection: ${selectedItems.value.join(', ')}';
                        },
                        child: Text(appText.selectAll)),
                    OutlinedButton(
                        onPressed: () {
                          selectedItems.value.clear();
                          selectedItems.value.add('All');
                          setState(
                            () {},
                          );
                          mainGridStatus.value = '[${DateTime.now()}] Selection: ${selectedItems.value.join(', ')}';
                        },
                        child: Text(appText.deselectAll))
                  ],
                )
              ]);
        });
      });
}

class SingleChoiceSelectButton extends StatefulWidget {
  const SingleChoiceSelectButton(
      {super.key,
      required this.width,
      required this.height,
      required this.label,
      required this.selectPopupLabel,
      required this.availableItemList,
      required this.availableItemLabels,
      required this.selectedItemsLabel,
      required this.selectedItem,
      required this.extraWidgets,
      required this.savePref});

  final double width;
  final double height;
  final String label;
  final String selectPopupLabel;
  final List<String> availableItemList;
  final List<String> availableItemLabels;
  final List<String> selectedItemsLabel;
  final Signal<String> selectedItem;
  final List<Widget> extraWidgets;
  final Function savePref;

  @override
  State<SingleChoiceSelectButton> createState() => _SingleChoiceSelectButtonState();
}

class _SingleChoiceSelectButtonState extends State<SingleChoiceSelectButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: OutlinedButton(
          style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context))),
              side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5)),
              padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 10))),
          onPressed: () async {
            await _singleChoiceSelectPopup(context, widget.selectPopupLabel, widget.availableItemList, widget.availableItemLabels, widget.selectedItem, widget.extraWidgets);
            setState(() {});
            widget.savePref();
          },
          child: Row(
            spacing: 2.5,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsetsGeometry.only(top: 1.2),
                child: Text(
                  widget.label,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.5),
                child: Text(
                    FileSystemEntity.isFileSync(widget.selectedItem.value)
                        ? p.basename(widget.selectedItem.value)
                        : widget.availableItemList.contains(widget.selectedItem.value)
                            ? widget.selectedItemsLabel[widget.availableItemList.indexOf(widget.selectedItem.value)]
                            : appText.select,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: Theme.of(context).textTheme.bodyLarge),
              )
            ],
          )),
    );
  }
}

Future<void> _singleChoiceSelectPopup(
    context, String selectPopupLabel, List<String> availableItemList, List<String> availableItemLabels, Signal<String> selectedItem, List<Widget> extraWidgets) async {
  return await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline), borderRadius: const BorderRadius.all(Radius.circular(5))),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiDialogBackgroundColorAlpha.watch(context)),
            insetPadding: const EdgeInsets.all(5),
            titlePadding: const EdgeInsets.only(top: 5),
            title: Column(children: [
              Text(
                selectPopupLabel,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              const HoriDivider()
            ]),
            contentPadding: const EdgeInsets.only(top: 5, bottom: 10, left: 10, right: 10),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: availableItemList
                    .map((e) => RadioListTile(
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
                          groupValue: selectedItem.value,
                          onChanged: (value) {
                            selectedItem.value = e;
                            setState(
                              () {},
                            );
                            mainGridStatus.value = '[${DateTime.now()}] Selection: $e';
                          },
                        ))
                    .toList(),
              ),
            ),
          );
        });
      });
}
