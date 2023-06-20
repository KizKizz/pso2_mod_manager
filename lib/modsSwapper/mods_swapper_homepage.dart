import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/csv_ice_file_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_data_loader.dart';
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_popup.dart';
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_swappage.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

TextEditingController swapperSearchTextController = TextEditingController();
List<CsvIceFile> toItemSearchResults = [];
CsvIceFile? selectedFromCsvFile;
CsvIceFile? selectedToCsvFile;
List<String> fromItemIds = [];
List<String> toItemIds = [];
List<String> fromItemAvailableIces = [];
List<String> toItemAvailableIces = [];

class ModsSwapperHomePage extends StatefulWidget {
  const ModsSwapperHomePage({super.key, required this.fromItem, required this.fromSubmod});

  final Item fromItem;
  final SubMod fromSubmod;

  @override
  State<ModsSwapperHomePage> createState() => _ModsSwapperHomePageState();
}

class _ModsSwapperHomePageState extends State<ModsSwapperHomePage> {
  @override
  void initState() {
    //clear
    if (Directory(modManSwapperFromItemDirPath).existsSync()) {
      Directory(modManSwapperFromItemDirPath).deleteSync(recursive: true);
    }
    if (Directory(modManSwapperToItemDirPath).existsSync()) {
      Directory(modManSwapperToItemDirPath).deleteSync(recursive: true);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //create temp dirs
    Directory(modManSwapperDirPath).createSync(recursive: true);

    //create
    Directory(modManSwapperOutputDirPath).createSync(recursive: true);

    //fetch
    final iceNamesFromSubmod = widget.fromSubmod.getModFileNames();
    final fromItemCsvData = csvData
        .where((element) =>
            iceNamesFromSubmod.contains(element.hqIceName) ||
            iceNamesFromSubmod.contains(element.nqIceName) ||
            iceNamesFromSubmod.contains(element.nqLiIceName) ||
            iceNamesFromSubmod.contains(element.hqLiIceName))
        .toList();
    List<List<String>> csvInfos = [];
    bool includeHqLiIceOnly = false;
    bool includeNqLiIceOnly = false;
    for (var csvItemData in fromItemCsvData) {
      final data = csvItemData.getDetailedList().where((element) => element.split(': ').last.isNotEmpty).toList();
      final availableModFileData = data.where((element) => iceNamesFromSubmod.contains(element.split(': ').last)).toList();
      csvInfos.add(availableModFileData);
      //filter link inner items
      for (var line in availableModFileData) {
        if (!includeHqLiIceOnly && line.split(': ').first.contains('High Quality Linked Inner Ice')) {
          includeHqLiIceOnly = true;
        }
        if (!includeNqLiIceOnly && line.split(': ').first.contains('Normal Quality Linked Inner Ice')) {
          includeNqLiIceOnly = true;
        }
        if (includeHqLiIceOnly && includeNqLiIceOnly) {
          break;
        }
      }
    }

    if (includeHqLiIceOnly) {
      availableItemsCsvData = availableItemsCsvData.where((element) => element.hqLiIceName.isNotEmpty).toList();
    }
    if (includeNqLiIceOnly) {
      availableItemsCsvData = availableItemsCsvData.where((element) => element.nqLiIceName.isNotEmpty).toList();
    }

    return Scaffold(
        backgroundColor: Colors.transparent,
        body: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
          return Row(
            children: [
              RotatedBox(
                  quarterTurns: -1,
                  child: Text(
                    'MODS SWAP',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: constraints.maxHeight / 12),
                  )),
              VerticalDivider(
                width: 10,
                thickness: 2,
                indent: 5,
                endIndent: 5,
                color: Theme.of(context).textTheme.bodySmall!.color,
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //from
                          Expanded(
                              child: Column(
                            children: [
                              Card(
                                shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                color: Colors.transparent,
                                child: ListTile(
                                  title: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2, bottom: 2, right: 10),
                                        child: Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(3),
                                              border: Border.all(color: Theme.of(context).hintColor, width: 1),
                                            ),
                                            child: widget.fromItem.icons.first.contains('assets/img/placeholdersquare.png')
                                                ? Image.asset(
                                                    'assets/img/placeholdersquare.png',
                                                    filterQuality: FilterQuality.none,
                                                    fit: BoxFit.fitWidth,
                                                  )
                                                : Image.file(
                                                    File(widget.fromItem.icons.first),
                                                    filterQuality: FilterQuality.none,
                                                    fit: BoxFit.fitWidth,
                                                  )),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.fromItem.category,
                                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                            ),
                                            Text(widget.fromItem.itemName, style: const TextStyle(fontWeight: FontWeight.w500)),
                                            Text('${widget.fromSubmod.modName} > ${widget.fromSubmod.submodName}'),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              const Divider(
                                height: 5,
                                thickness: 1,
                                indent: 5,
                                endIndent: 5,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                      child: Text(curLangText!.uiChooseAVariantFoundBellow),
                                    ),
                                    Expanded(
                                      child: Card(
                                        shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                        color: Colors.transparent,
                                        child: ScrollbarTheme(
                                          data: ScrollbarThemeData(
                                            thumbColor: MaterialStateProperty.resolveWith((states) {
                                              if (states.contains(MaterialState.hovered)) {
                                                return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.7);
                                              }
                                              return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5);
                                            }),
                                          ),
                                          child: ListView.builder(
                                              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                                              shrinkWrap: true,
                                              physics: const PageScrollPhysics(),
                                              itemCount: fromItemCsvData.length,
                                              itemBuilder: (context, i) {
                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                                  child: RadioListTile(
                                                    shape:
                                                        RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                    value: fromItemCsvData[i],
                                                    groupValue: selectedFromCsvFile,
                                                    title: Text(fromItemCsvData[i].enName),
                                                    subtitle: Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [for (int line = 0; line < csvInfos[i].length; line++) Text(csvInfos[i][line])],
                                                    ),
                                                    onChanged: (CsvIceFile? currentItem) {
                                                      //print("Current ${moddedItemsList[i].groupName}");
                                                      selectedFromCsvFile = currentItem!;
                                                      fromItemAvailableIces = csvInfos[i];
                                                      fromItemIds = [selectedFromCsvFile!.id.toString(), selectedFromCsvFile!.adjustedId.toString()];
                                                      //set infos
                                                      if (selectedToCsvFile != null) {
                                                        toItemAvailableIces.clear();
                                                        List<String> selectedToItemIceList = selectedToCsvFile!.getDetailedList();
                                                        for (var line in selectedToItemIceList) {
                                                          if (fromItemAvailableIces.where((element) => element.split(': ').first == line.split(': ').first).isNotEmpty) {
                                                            toItemAvailableIces.add(line);
                                                          }
                                                        }
                                                      }

                                                      setState(
                                                        () {},
                                                      );
                                                    },
                                                  ),
                                                );
                                              }),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 0),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 25,
                            ),
                          ),
                          //to
                          Expanded(
                              child: Column(
                            children: [
                              Card(
                                shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                color: Colors.transparent,
                                child: SizedBox(
                                    height: 90,
                                    child: ListTile(
                                      minVerticalPadding: 15,
                                      title: Text(curLangText!.uiChooseAnItemBellowToSwap),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: SizedBox(
                                          height: 30,
                                          width: double.infinity,
                                          child: TextField(
                                            controller: swapperSearchTextController,
                                            maxLines: 1,
                                            textAlignVertical: TextAlignVertical.center,
                                            decoration: InputDecoration(
                                                hintText: curLangText!.uiSearchSwapItems,
                                                hintStyle: TextStyle(color: Theme.of(context).hintColor),
                                                isCollapsed: true,
                                                isDense: true,
                                                contentPadding: const EdgeInsets.only(left: 5, right: 5, bottom: 2),
                                                suffixIconConstraints: const BoxConstraints(minWidth: 20, minHeight: 28),
                                                suffixIcon: InkWell(
                                                  onTap: swapperSearchTextController.text.isEmpty
                                                      ? null
                                                      : () {
                                                          swapperSearchTextController.clear();
                                                          setState(() {});
                                                        },
                                                  child: Icon(
                                                    swapperSearchTextController.text.isEmpty ? Icons.search : Icons.close,
                                                    color: Theme.of(context).hintColor,
                                                  ),
                                                ),
                                                constraints: BoxConstraints.tight(const Size.fromHeight(26)),
                                                // Set border for enabled state (default)
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(width: 1, color: Theme.of(context).hintColor),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                // Set border for focused state
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.primary),
                                                  borderRadius: BorderRadius.circular(10),
                                                )),
                                            onChanged: (value) async {
                                              toItemSearchResults = availableItemsCsvData
                                                  .where((element) => curActiveLang == 'JP'
                                                      ? element.jpName.toLowerCase().contains(swapperSearchTextController.text.toLowerCase())
                                                      : element.enName.toLowerCase().contains(swapperSearchTextController.text.toLowerCase()))
                                                  .toList();
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                      ),
                                    )),
                              ),
                              const Divider(
                                height: 5,
                                thickness: 1,
                                indent: 5,
                                endIndent: 5,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      runAlignment: WrapAlignment.center,
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      spacing: 5,
                                      children: [
                                        Checkbox(
                                          splashRadius: 2,
                                          value: isReplacingNQWithHQ,
                                          onChanged: (value) async {
                                            final prefs = await SharedPreferences.getInstance();
                                            isReplacingNQWithHQ = value!;
                                            prefs.setBool('modsSwapperIsReplacingNQWithHQ', isReplacingNQWithHQ);
                                            setState(() {});
                                          },
                                        ),
                                        Text(curLangText!.uiReplaceNQwithHQ),
                                        // Container(width: 2, height: 20, color: Theme.of(context).primaryColorLight),
                                        // Checkbox(
                                        //   splashRadius: 2,
                                        //   value: isCopyAll,
                                        //   onChanged: (value) async {
                                        //     final prefs = await SharedPreferences.getInstance();
                                        //     isCopyAll = value!;
                                        //     prefs.setBool('modsSwapperIsCopyAll', isCopyAll);
                                        //     setState(() {});
                                        //   },
                                        // ),
                                        // Text(curLangText!.uiSwapAllFilesInsideIce),
                                        // Container(width: 2, height: 20, color: Theme.of(context).primaryColorLight),
                                        // Checkbox(
                                        //   splashRadius: 2,
                                        //   value: isRemoveExtras,
                                        //   onChanged: (value) async {
                                        //     final prefs = await SharedPreferences.getInstance();
                                        //     isRemoveExtras = value!;
                                        //     prefs.setBool('modsSwapperIsRemoveExtras', isRemoveExtras);
                                        //     setState(() {});
                                        //   },
                                        // ),
                                        // Text(curLangText!.uiRemoveUnmatchingFiles),
                                      ],
                                    ),
                                    Expanded(
                                      child: Card(
                                          shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                          color: Colors.transparent,
                                          child: ScrollbarTheme(
                                              data: ScrollbarThemeData(
                                                thumbColor: MaterialStateProperty.resolveWith((states) {
                                                  if (states.contains(MaterialState.hovered)) {
                                                    return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.7);
                                                  }
                                                  return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5);
                                                }),
                                              ),
                                              child: ListView.builder(
                                                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                                  shrinkWrap: true,
                                                  //physics: const BouncingScrollPhysics(),
                                                  itemCount: swapperSearchTextController.text.isEmpty ? availableItemsCsvData.length : toItemSearchResults.length,
                                                  itemBuilder: (context, i) {
                                                    return RadioListTile(
                                                      shape: RoundedRectangleBorder(
                                                          side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                      value: swapperSearchTextController.text.isEmpty ? availableItemsCsvData[i] : toItemSearchResults[i],
                                                      groupValue: selectedToCsvFile,
                                                      title: curActiveLang == 'JP'
                                                          ? swapperSearchTextController.text.isEmpty
                                                              ? Text(availableItemsCsvData[i].jpName)
                                                              : Text(toItemSearchResults[i].jpName)
                                                          : swapperSearchTextController.text.isEmpty
                                                              ? Text(availableItemsCsvData[i].enName)
                                                              : Text(toItemSearchResults[i].enName),
                                                      onChanged: (CsvIceFile? currentItem) {
                                                        //print("Current ${moddedItemsList[i].groupName}");
                                                        selectedToCsvFile = currentItem!;
                                                        toItemName = curActiveLang == 'JP' ? selectedToCsvFile!.jpName : selectedToCsvFile!.enName;
                                                        toItemIds = [selectedToCsvFile!.id.toString(), selectedToCsvFile!.adjustedId.toString()];
                                                        if (fromItemAvailableIces.isNotEmpty) {
                                                          toItemAvailableIces.clear();
                                                          List<String> selectedToItemIceList = selectedToCsvFile!.getDetailedList();
                                                          for (var line in selectedToItemIceList) {
                                                            if (fromItemAvailableIces.where((element) => element.split(': ').first == line.split(': ').first).isNotEmpty) {
                                                              toItemAvailableIces.add(line);
                                                            }

                                                            if (isReplacingNQWithHQ && line.split(': ').first.contains('Normal Quality')) {
                                                              toItemAvailableIces.add(line);
                                                            }
                                                          }
                                                        }
                                                        setState(
                                                          () {},
                                                        );
                                                      },
                                                    );
                                                  }))),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Note: Some items might work right after swapping, some might not, some might require cmx editing'),
                          Wrap(
                            runAlignment: WrapAlignment.center,
                            alignment: WrapAlignment.center,
                            spacing: 5,
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    swapperSearchTextController.clear();
                                    selectedFromCsvFile = null;
                                    selectedToCsvFile = null;
                                    availableItemsCsvData.clear();
                                    fromItemIds.clear();
                                    toItemIds.clear();
                                    fromItemAvailableIces.clear();
                                    toItemAvailableIces.clear();
                                    csvData.clear();
                                    availableItemsCsvData.clear();
                                    Navigator.pop(context);
                                  },
                                  child: Text(curLangText!.uiClose)),
                              ElevatedButton(
                                  onPressed: selectedFromCsvFile == null || selectedToCsvFile == null
                                      ? null
                                      : () {
                                          if (selectedFromCsvFile != null && selectedToCsvFile != null) {
                                            swapperConfirmDialog(context, widget.fromSubmod, fromItemIds, fromItemAvailableIces, toItemIds, toItemAvailableIces);
                                          }
                                        },
                                  child: Text(curLangText!.uiNext))
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          );
        }));
  }
}

Future<void> swapperConfirmDialog(context, SubMod fromSubmod, List<String> fromItemIds, List<String> fromItemAvailableIces, List<String> toItemIds, List<String> toItemAvailableIces) async {
  await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                titlePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(flex: 1, child: Center(child: Text(fromSubmod.itemName, style: const TextStyle(fontWeight: FontWeight.w700)))),
                    Expanded(flex: 1, child: Center(child: Text(toItemName, style: const TextStyle(fontWeight: FontWeight.w700)))),
                  ],
                ),
                contentPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Card(
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                            color: Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Item ID: ${fromItemIds[0]}'),
                                  Text('Adjusted ID: ${fromItemIds[1]}'),
                                  for (int i = 0; i < fromItemAvailableIces.length; i++) Text(fromItemAvailableIces[i])
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Icon(Icons.arrow_forward_ios_rounded),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Card(
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                            color: Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [Text('Item ID: ${toItemIds[0]}'), Text('Adjusted ID: ${toItemIds[1]}'), for (int i = 0; i < toItemAvailableIces.length; i++) Text(toItemAvailableIces[i])],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                actions: <Widget>[
                  ElevatedButton(
                      child: Text(curLangText!.uiReturn),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        swapperSwappingDialog(context, fromSubmod);
                      },
                      child: Text(curLangText!.uiSwap))
                ]);
          }));
}
