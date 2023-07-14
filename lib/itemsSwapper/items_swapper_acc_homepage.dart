import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/csv_ice_file_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/itemsSwapper/items_swapper_data_loader.dart';
import 'package:pso2_mod_manager/itemsSwapper/items_swapper_popup.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_acc_swappage.dart' as msas;
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

TextEditingController swapperSearchTextController = TextEditingController();
TextEditingController swapperFromItemsSearchTextController = TextEditingController();
List<CsvAccessoryIceFile> fromItemSearchResults = [];
List<CsvAccessoryIceFile> toAccSearchResults = [];
CsvAccessoryIceFile? selectedFromAccCsvFile;
CsvAccessoryIceFile? selectedToAccCsvFile;
String fromAccItemId = '';
String toAccItemId = '';
List<String> fromAccItemAvailableIces = [];
List<String> toAccItemAvailableIces = [];

class ItemsSwapperAccHomePage extends StatefulWidget {
  const ItemsSwapperAccHomePage({super.key});

  @override
  State<ItemsSwapperAccHomePage> createState() => _ItemsSwapperAccHomePageState();
}

class _ItemsSwapperAccHomePageState extends State<ItemsSwapperAccHomePage> {
  @override
  void initState() {
    //clear
    if (Directory(modManSwapperFromItemDirPath).existsSync()) {
      Directory(modManSwapperFromItemDirPath).deleteSync(recursive: true);
    }
    if (Directory(modManSwapperToItemDirPath).existsSync()) {
      Directory(modManSwapperToItemDirPath).deleteSync(recursive: true);
    }
    if (Directory(modManSwapperOutputDirPath).existsSync()) {
      Directory(modManSwapperOutputDirPath).deleteSync(recursive: true);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //create temp dirs
    Directory(modManSwapperDirPath).createSync(recursive: true);

    //create
    Directory(modManSwapperOutputDirPath).createSync(recursive: true);

    //fetch icons
    List<CsvAccessoryIceFile> fromItemCsvData =
        csvAccData.where((element) => element.jpName.isNotEmpty && element.enName.isNotEmpty && (element.hqIceName.isNotEmpty || element.nqIceName.isNotEmpty)).toList();
    if (curActiveLang == 'JP') {
      fromItemCsvData.sort((a, b) => a.jpName.compareTo(b.jpName));
    } else {
      fromItemCsvData.sort((a, b) => a.enName.compareTo(b.enName));
    }
    //availableAccCsvData = availableAccCsvData.where((element) => element.id.toString().length == itemIdLength).toList();

    return Scaffold(
        backgroundColor: Colors.transparent,
        body: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
          return Row(
            children: [
              RotatedBox(
                  quarterTurns: -1,
                  child: Text(
                    'ITEMS SWAP',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: constraints.maxHeight / 14),
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
                                child: SizedBox(
                                  height: 92,
                                  child: ListTile(
                                    title: const Text('Choose an item below:'),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: SizedBox(
                                        height: 30,
                                        width: double.infinity,
                                        child: TextField(
                                          controller: swapperFromItemsSearchTextController,
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
                                                onTap: swapperFromItemsSearchTextController.text.isEmpty
                                                    ? null
                                                    : () {
                                                        swapperFromItemsSearchTextController.clear();
                                                        setState(() {});
                                                      },
                                                child: Icon(
                                                  swapperFromItemsSearchTextController.text.isEmpty ? Icons.search : Icons.close,
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
                                            fromItemSearchResults = fromItemCsvData
                                                .where((element) => curActiveLang == 'JP'
                                                    ? element.jpName.toLowerCase().contains(swapperFromItemsSearchTextController.text.toLowerCase())
                                                    : element.enName.toLowerCase().contains(swapperFromItemsSearchTextController.text.toLowerCase()))
                                                .toList();
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                    ),
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
                                      padding: const EdgeInsets.all(5),
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
                                              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                                              shrinkWrap: true,
                                              //physics: const PageScrollPhysics(),
                                              itemCount: swapperFromItemsSearchTextController.text.isEmpty ? fromItemCsvData.length : fromItemSearchResults.length,
                                              itemBuilder: (context, i) {
                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                                  child: RadioListTile(
                                                    shape:
                                                        RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                    value: swapperFromItemsSearchTextController.text.isEmpty ? fromItemCsvData[i] : fromItemSearchResults[i],
                                                    groupValue: selectedFromAccCsvFile,
                                                    title: curActiveLang == 'JP'
                                                        ? swapperFromItemsSearchTextController.text.isEmpty
                                                            ? Text(fromItemCsvData[i].jpName)
                                                            : Text(fromItemSearchResults[i].jpName)
                                                        : swapperFromItemsSearchTextController.text.isEmpty
                                                            ? Text(fromItemCsvData[i].enName)
                                                            : Text(fromItemSearchResults[i].enName),
                                                    subtitle: swapperFromItemsSearchTextController.text.isEmpty
                                                        ? selectedFromAccCsvFile == fromItemCsvData[i]
                                                            ? Column(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  for (int line = 0;
                                                                      line < selectedFromAccCsvFile!.getDetailedListIceInfosOnly().where((element) => element.split(': ').last.isNotEmpty).length;
                                                                      line++)
                                                                    Text(selectedFromAccCsvFile!.getDetailedListIceInfosOnly().where((element) => element.split(': ').last.isNotEmpty).toList()[line])
                                                                ],
                                                              )
                                                            : null
                                                        : selectedFromAccCsvFile == fromItemSearchResults[i]
                                                            ? Column(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  for (int line = 0;
                                                                      line < selectedFromAccCsvFile!.getDetailedListIceInfosOnly().where((element) => element.split(': ').last.isNotEmpty).length;
                                                                      line++)
                                                                    Text(selectedFromAccCsvFile!.getDetailedListIceInfosOnly().where((element) => element.split(': ').last.isNotEmpty).toList()[line])
                                                                ],
                                                              )
                                                            : null,
                                                    onChanged: (CsvAccessoryIceFile? currentItem) {
                                                      //print("Current ${moddedItemsList[i].groupName}");
                                                      selectedFromAccCsvFile = currentItem!;
                                                      fromAccItemAvailableIces = selectedFromAccCsvFile!.getDetailedListIceInfosOnly().where((element) => element.split(': ').last.isNotEmpty).toList();
                                                      fromItemName = curActiveLang == 'JP' ? selectedFromAccCsvFile!.jpName : selectedFromAccCsvFile!.enName;
                                                      fromAccItemId = selectedFromAccCsvFile!.id.toString();
                                                      //set infos
                                                      if (selectedToAccCsvFile != null) {
                                                        toAccItemAvailableIces.clear();
                                                        List<String> selectedToItemIceList = selectedToAccCsvFile!.getDetailedList();
                                                        for (var line in selectedToItemIceList) {
                                                          if (fromAccItemAvailableIces.where((element) => element.split(': ').first == line.split(': ').first).isNotEmpty) {
                                                            toAccItemAvailableIces.add(line);
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
                                    height: 92,
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
                                              toAccSearchResults = availableAccCsvData
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
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          MaterialButton(
                                            height: 29,
                                            padding: EdgeInsets.zero,
                                            onPressed: () async {
                                              final prefs = await SharedPreferences.getInstance();
                                              isReplacingNQWithHQ ? isReplacingNQWithHQ = false : isReplacingNQWithHQ = true;
                                              prefs.setBool('modsSwapperIsReplacingNQWithHQ', isReplacingNQWithHQ);
                                              setState(() {});
                                            },
                                            child: Wrap(
                                              alignment: WrapAlignment.center,
                                              runAlignment: WrapAlignment.center,
                                              crossAxisAlignment: WrapCrossAlignment.center,
                                              spacing: 5,
                                              children: [Icon(isReplacingNQWithHQ ? Icons.check_box_outlined : Icons.check_box_outline_blank), Text(curLangText!.uiReplaceNQwithHQ)],
                                            ),
                                          ),
                                          // MaterialButton(
                                          //   height: 29,
                                          //   padding: EdgeInsets.zero,
                                          //   onPressed: () async {
                                          //     final prefs = await SharedPreferences.getInstance();
                                          //     isCopyAll ? isCopyAll = false : isCopyAll = true;
                                          //     prefs.setBool('modsSwapperIsCopyAll', isCopyAll);
                                          //     setState(() {});
                                          //   },
                                          //   child: Wrap(
                                          //     alignment: WrapAlignment.center,
                                          //     runAlignment: WrapAlignment.center,
                                          //     crossAxisAlignment: WrapCrossAlignment.center,
                                          //     spacing: 5,
                                          //     children: [Icon(isCopyAll ? Icons.check_box_outlined : Icons.check_box_outline_blank), Text(curLangText!.uiSwapAllFilesInsideIce)],
                                          //   ),
                                          // ),
                                          MaterialButton(
                                            height: 29,
                                            padding: EdgeInsets.zero,
                                            onPressed: () async {
                                              final prefs = await SharedPreferences.getInstance();
                                              isRemoveExtras ? isRemoveExtras = false : isRemoveExtras = true;
                                              prefs.setBool('modsSwapperIsRemoveExtras', isRemoveExtras);
                                              setState(() {});
                                            },
                                            child: Wrap(
                                              alignment: WrapAlignment.center,
                                              runAlignment: WrapAlignment.center,
                                              crossAxisAlignment: WrapCrossAlignment.center,
                                              spacing: 5,
                                              children: [Icon(isRemoveExtras ? Icons.check_box_outlined : Icons.check_box_outline_blank), Text(curLangText!.uiRemoveUnmatchingFiles)],
                                            ),
                                          ),
                                        ],
                                      ),
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
                                                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                                                  shrinkWrap: true,
                                                  //physics: const BouncingScrollPhysics(),
                                                  itemCount: swapperSearchTextController.text.isEmpty ? availableAccCsvData.length : toAccSearchResults.length,
                                                  itemBuilder: (context, i) {
                                                    return Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                                      child: RadioListTile(
                                                        shape: RoundedRectangleBorder(
                                                            side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                        value: swapperSearchTextController.text.isEmpty ? availableAccCsvData[i] : toAccSearchResults[i],
                                                        groupValue: selectedToAccCsvFile,
                                                        title: curActiveLang == 'JP'
                                                            ? swapperSearchTextController.text.isEmpty
                                                                ? Text(availableAccCsvData[i].jpName)
                                                                : Text(toAccSearchResults[i].jpName)
                                                            : swapperSearchTextController.text.isEmpty
                                                                ? Text(availableAccCsvData[i].enName)
                                                                : Text(toAccSearchResults[i].enName),
                                                        onChanged: (CsvAccessoryIceFile? currentItem) {
                                                          //print("Current ${moddedItemsList[i].groupName}");
                                                          selectedToAccCsvFile = currentItem!;
                                                          toItemName = curActiveLang == 'JP' ? selectedToAccCsvFile!.jpName : selectedToAccCsvFile!.enName;
                                                          toAccItemId = selectedToAccCsvFile!.id.toString();
                                                          if (fromAccItemAvailableIces.isNotEmpty) {
                                                            toAccItemAvailableIces.clear();
                                                            List<String> selectedToItemIceList = selectedToAccCsvFile!.getDetailedList();
                                                            for (var line in selectedToItemIceList) {
                                                              if (fromAccItemAvailableIces.where((element) => element.split(': ').first == line.split(': ').first).isNotEmpty) {
                                                                toAccItemAvailableIces.add(line);
                                                              }

                                                              if (isReplacingNQWithHQ && line.split(': ').first.contains('Normal Quality')) {
                                                                toAccItemAvailableIces.add(line);
                                                              }
                                                            }
                                                          }
                                                          setState(
                                                            () {},
                                                          );
                                                        },
                                                      ),
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
                          Text(curLangText!.uiNoteModsMightNotWokAfterSwapping),
                          Wrap(
                            runAlignment: WrapAlignment.center,
                            alignment: WrapAlignment.center,
                            spacing: 5,
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    swapperSearchTextController.clear();
                                    swapperFromItemsSearchTextController.clear();
                                    selectedFromAccCsvFile = null;
                                    selectedToAccCsvFile = null;
                                    availableAccCsvData.clear();
                                    fromAccItemId = '';
                                    toAccItemId = '';
                                    fromAccItemAvailableIces.clear();
                                    toAccItemAvailableIces.clear();
                                    csvAccData.clear();
                                    availableAccCsvData.clear();
                                    Navigator.pop(context);
                                  },
                                  child: Text(curLangText!.uiClose)),
                              ElevatedButton(
                                  onPressed: selectedFromAccCsvFile == null || selectedToAccCsvFile == null
                                      ? null
                                      : () {
                                          if (selectedFromAccCsvFile != null && selectedToAccCsvFile != null) {
                                            swapperConfirmDialog(context, fromItemSubmodGet(fromAccItemAvailableIces), fromAccItemId, fromAccItemAvailableIces, toAccItemId, toAccItemAvailableIces);
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

Future<void> swapperConfirmDialog(context, SubMod fromSubmod, String fromAccItemId, List<String> fromAccItemAvailableIces, String toAccItemId, List<String> toAccItemAvailableIces) async {
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
                                children: [Text('${curLangText!.uiItemID}: $fromAccItemId'), for (int i = 0; i < fromAccItemAvailableIces.length; i++) Text(fromAccItemAvailableIces[i])],
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
                                children: [Text('${curLangText!.uiItemID}: $toAccItemId'), for (int i = 0; i < toAccItemAvailableIces.length; i++) Text(toAccItemAvailableIces[i])],
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
                        msas.swapperAccSwappingDialog(context, fromSubmod, fromAccItemAvailableIces, toAccItemAvailableIces, toItemName);
                      },
                      child: Text(curLangText!.uiSwap))
                ]);
          }));
}
