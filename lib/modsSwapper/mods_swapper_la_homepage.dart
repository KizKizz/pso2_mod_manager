import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/csv_ice_file_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_data_loader.dart';
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_la_swappage.dart';
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_popup.dart';
import 'package:pso2_mod_manager/state_provider.dart';

TextEditingController swapperSearchTextController = TextEditingController();
List<CsvEmoteIceFile> toIEmotesSearchResults = [];
CsvEmoteIceFile? selectedFromEmotesCsvFile;
CsvEmoteIceFile? selectedToEmotesCsvFile;
List<String> fromEmotesAvailableIces = [];
List<String> toEmotesAvailableIces = [];
String selectedLaGender = '';
List<CsvEmoteIceFile> fromItemCsvData = [];

class ModsSwapperEmotesHomePage extends StatefulWidget {
  const ModsSwapperEmotesHomePage({super.key, required this.fromItem, required this.fromSubmod});

  final Item fromItem;
  final SubMod fromSubmod;

  @override
  State<ModsSwapperEmotesHomePage> createState() => _ModsSwapperEmotesHomePageState();
}

class _ModsSwapperEmotesHomePageState extends State<ModsSwapperEmotesHomePage> {
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

    //fetch
    final iceNamesFromSubmod = widget.fromSubmod.getModFileNames();
    if (!isEmotesToStandbyMotions || fromItemCsvData.isEmpty) {
      fromItemCsvData = csvEmotesData
          .where((element) =>
              iceNamesFromSubmod.contains(element.pso2HashIceName) ||
              iceNamesFromSubmod.contains(element.pso2VfxHashIceName) ||
              iceNamesFromSubmod.contains(element.rbCastFemaleHashIceName) ||
              iceNamesFromSubmod.contains(element.rbCastMaleHashIceName) ||
              iceNamesFromSubmod.contains(element.rbFigHashIceName) ||
              iceNamesFromSubmod.contains(element.rbHumanHashIceName) ||
              iceNamesFromSubmod.contains(element.rbVfxHashIceName))
          .toList();
    }
    List<List<String>> csvInfos = [];
    bool isPso2HashFound = false;
    bool isPso2VfxHashFound = false;
    String selectedMotionType = '';
    for (var csvItemData in fromItemCsvData) {
      final data = csvItemData.getDetailedList().where((element) => element.split(': ').last.isNotEmpty).toList();
      final availableModFileData = data.where((element) => iceNamesFromSubmod.contains(element.split(': ').last) || element.split(': ').first == 'Gender').toList();
      csvInfos.add(availableModFileData);
      if (selectedMotionType.isEmpty) {
        selectedMotionType = csvItemData.subCategory;
      }
      //filter pso2 only emotes
      for (var line in availableModFileData) {
        if (!isPso2HashFound && line.split(': ').first.contains('PSO2 Hash Ice')) {
          isPso2HashFound = true;
        }
        if (!isPso2VfxHashFound && line.split(': ').first.contains('PSO2 VFX Hash Ice')) {
          isPso2VfxHashFound = true;
        }
        if (isPso2HashFound && isPso2VfxHashFound) {
          break;
        }
      }
    }

    if (selectedMotionType.isNotEmpty) {
      availableEmotesCsvData = availableEmotesCsvData.where((element) => element.subCategory == selectedMotionType).toList();
    }

    if (isPso2HashFound) {
      availableEmotesCsvData = availableEmotesCsvData.where((element) => element.pso2HashIceName.isNotEmpty).toList();
    }
    if (isPso2VfxHashFound) {
      availableEmotesCsvData = availableEmotesCsvData.where((element) => element.pso2VfxHashIceName.isNotEmpty).toList();
    }

    if (isEmotesToStandbyMotions) {
      availableEmotesCsvData = availableEmotesCsvData.where((element) => element.subCategory == 'Standby Motion').toList();
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
                                                    groupValue: selectedFromEmotesCsvFile,
                                                    title: Text(fromItemCsvData[i].enName),
                                                    subtitle: Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [for (int line = 0; line < csvInfos[i].length; line++) Text(csvInfos[i][line])],
                                                    ),
                                                    onChanged: (CsvEmoteIceFile? currentItem) {
                                                      //print("Current ${moddedItemsList[i].groupName}");
                                                      selectedFromEmotesCsvFile = currentItem!;
                                                      fromEmotesAvailableIces = csvInfos[i];
                                                      //fromItemIds = [selectedFromEmotesCsvFile!.id.toString(), selectedFromEmotesCsvFile!.adjustedId.toString()];
                                                      //set infos
                                                      if (selectedToEmotesCsvFile != null) {
                                                        toEmotesAvailableIces.clear();
                                                        List<String> selectedToItemIceList = selectedToEmotesCsvFile!.getDetailedList();
                                                        for (var line in selectedToItemIceList) {
                                                          if (fromEmotesAvailableIces.where((element) => element.split(': ').first == line.split(': ').first).isNotEmpty) {
                                                            toEmotesAvailableIces.add(line);
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
                                              toIEmotesSearchResults = availableEmotesCsvData
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
                                          // MaterialButton(
                                          //   height: 29,
                                          //   padding: EdgeInsets.zero,
                                          //   onPressed: () async {
                                          //     final prefs = await SharedPreferences.getInstance();
                                          //     isReplacingNQWithHQ ? isReplacingNQWithHQ = false : isReplacingNQWithHQ = true;
                                          //     prefs.setBool('modsSwapperIsReplacingNQWithHQ', isReplacingNQWithHQ);
                                          //     setState(() {});
                                          //   },
                                          //   child: Wrap(
                                          //     alignment: WrapAlignment.center,
                                          //     runAlignment: WrapAlignment.center,
                                          //     crossAxisAlignment: WrapCrossAlignment.center,
                                          //     spacing: 5,
                                          //     children: [Icon(isReplacingNQWithHQ ? Icons.check_box_outlined : Icons.check_box_outline_blank), Text(curLangText!.uiReplaceNQwithHQ)],
                                          //   ),
                                          // ),
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
                                          // MaterialButton(
                                          //   height: 29,
                                          //   padding: EdgeInsets.zero,
                                          //   onPressed: () async {
                                          //     final prefs = await SharedPreferences.getInstance();
                                          //     isRemoveExtras ? isRemoveExtras = false : isRemoveExtras = true;
                                          //     prefs.setBool('modsSwapperIsRemoveExtras', isRemoveExtras);
                                          //     setState(() {});
                                          //   },
                                          //   child: Wrap(
                                          //     alignment: WrapAlignment.center,
                                          //     runAlignment: WrapAlignment.center,
                                          //     crossAxisAlignment: WrapCrossAlignment.center,
                                          //     spacing: 5,
                                          //     children: [Icon(isRemoveExtras ? Icons.check_box_outlined : Icons.check_box_outline_blank), Text(curLangText!.uiRemoveUnmatchingFiles)],
                                          //   ),
                                          // ),
                                          MaterialButton(
                                            height: 29,
                                            padding: EdgeInsets.zero,
                                            onPressed: selectedMotionType.isNotEmpty || swapperSearchTextController.text.isNotEmpty
                                                ? null
                                                : () async {
                                                    //final prefs = await SharedPreferences.getInstance();
                                                    //swapperSearchTextController.clear();
                                                    csvEmotesData.clear();
                                                    if (!isEmotesToStandbyMotions) {
                                                      isEmotesToStandbyMotions = true;
                                                      await sheetListFetchFromFiles(getCsvFiles(defaultCateforyDirs[14]));
                                                      availableEmotesCsvData = await getEmotesToMotionsSwapToCsvList(csvEmotesData, defaultCateforyDirs[14]);
                                                    } else {
                                                      isEmotesToStandbyMotions = false;
                                                      await sheetListFetchFromFiles(getCsvFiles(widget.fromItem.category));
                                                      availableEmotesCsvData = await getEmotesSwapToCsvList(csvEmotesData, widget.fromItem);
                                                      if (selectedMotionType.isNotEmpty) {
                                                        availableEmotesCsvData = availableEmotesCsvData.where((element) => element.subCategory == selectedMotionType).toList();
                                                      }
                                                      if (isPso2HashFound) {
                                                        availableEmotesCsvData = availableEmotesCsvData.where((element) => element.pso2HashIceName.isNotEmpty).toList();
                                                      }
                                                      if (isPso2VfxHashFound) {
                                                        availableEmotesCsvData = availableEmotesCsvData.where((element) => element.pso2VfxHashIceName.isNotEmpty).toList();
                                                      }
                                                    }
                                                    if (curActiveLang == 'JP') {
                                                      availableEmotesCsvData.sort(
                                                        (a, b) => a.jpName.compareTo(b.jpName),
                                                      );
                                                    } else {
                                                      availableEmotesCsvData.sort(
                                                        (a, b) => a.enName.compareTo(b.enName),
                                                      );
                                                    }
                                                    //prefs.setBool('isEmotesToStandbyMotions', isEmotesToStandbyMotions);
                                                    setState(() {});
                                                  },
                                            child: Wrap(
                                              alignment: WrapAlignment.center,
                                              runAlignment: WrapAlignment.center,
                                              crossAxisAlignment: WrapCrossAlignment.center,
                                              spacing: 5,
                                              children: [Icon(isEmotesToStandbyMotions ? Icons.check_box_outlined : Icons.check_box_outline_blank), Text(curLangText!.uiSwapToIdleMotion)],
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
                                                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                                  shrinkWrap: true,
                                                  //physics: const BouncingScrollPhysics(),
                                                  itemCount: swapperSearchTextController.text.isEmpty ? availableEmotesCsvData.length : toIEmotesSearchResults.length,
                                                  itemBuilder: (context, i) {
                                                    return RadioListTile(
                                                      shape: RoundedRectangleBorder(
                                                          side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                      value: swapperSearchTextController.text.isEmpty ? availableEmotesCsvData[i] : toIEmotesSearchResults[i],
                                                      groupValue: selectedToEmotesCsvFile,
                                                      title: curActiveLang == 'JP'
                                                          ? swapperSearchTextController.text.isEmpty
                                                              ? Text(availableEmotesCsvData[i].jpName)
                                                              : Text(toIEmotesSearchResults[i].jpName)
                                                          : swapperSearchTextController.text.isEmpty
                                                              ? Text(availableEmotesCsvData[i].enName)
                                                              : Text(toIEmotesSearchResults[i].enName),
                                                      subtitle: isEmotesToStandbyMotions
                                                          ? null
                                                          : swapperSearchTextController.text.isEmpty
                                                              ? Text(availableEmotesCsvData[i].gender)
                                                              : Text(toIEmotesSearchResults[i].gender),
                                                      onChanged: (CsvEmoteIceFile? currentItem) {
                                                        //print("Current ${moddedItemsList[i].groupName}");
                                                        selectedToEmotesCsvFile = currentItem!;
                                                        toItemName = curActiveLang == 'JP' ? selectedToEmotesCsvFile!.jpName : selectedToEmotesCsvFile!.enName;
                                                        //toItemIds = [selectedToEmotesCsvFile!.id.toString(), selectedToEmotesCsvFile!.adjustedId.toString()];
                                                        if (fromEmotesAvailableIces.isNotEmpty) {
                                                          toEmotesAvailableIces.clear();
                                                          List<String> selectedToItemIceList = selectedToEmotesCsvFile!.getDetailedList();
                                                          for (var line in selectedToItemIceList) {
                                                            if (fromEmotesAvailableIces.where((element) => element.split(': ').first == line.split(': ').first).isNotEmpty) {
                                                              toEmotesAvailableIces.add(line);
                                                            }

                                                            // if (isReplacingNQWithHQ && line.split(': ').first.contains('Normal Quality')) {
                                                            //   toEmotesAvailableIces.add(line);
                                                            // }
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
                          Text(curLangText!.uiNoteModsMightNotWokAfterSwapping),
                          Wrap(
                            runAlignment: WrapAlignment.center,
                            alignment: WrapAlignment.center,
                            spacing: 5,
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    swapperSearchTextController.clear();
                                    selectedFromEmotesCsvFile = null;
                                    selectedToEmotesCsvFile = null;
                                    availableEmotesCsvData.clear();
                                    fromEmotesAvailableIces.clear();
                                    toEmotesAvailableIces.clear();
                                    csvEmotesData.clear();
                                    availableEmotesCsvData.clear();
                                    isEmotesToStandbyMotions = false;
                                    Navigator.pop(context);
                                  },
                                  child: Text(curLangText!.uiClose)),
                              ElevatedButton(
                                  onPressed: selectedFromEmotesCsvFile == null || selectedToEmotesCsvFile == null
                                      ? null
                                      : () {
                                          if (selectedFromEmotesCsvFile != null && selectedToEmotesCsvFile != null) {
                                            swapperConfirmDialog(context, widget.fromSubmod, fromEmotesAvailableIces, toEmotesAvailableIces);
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

Future<void> swapperConfirmDialog(context, SubMod fromSubmod, List<String> fromEmotesAvailableIces, List<String> toEmotesAvailableIces) async {
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
                                children: [for (int i = 0; i < fromEmotesAvailableIces.length; i++) Text(fromEmotesAvailableIces[i])],
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
                                children: [
                                  for (int i = 0; i < toEmotesAvailableIces.length; i++)
                                    if (toEmotesAvailableIces[i].split(': ').last.isNotEmpty) Text(toEmotesAvailableIces[i])
                                ],
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
                        swapperLaSwappingDialog(context, fromSubmod);
                      },
                      child: Text(curLangText!.uiSwap))
                ]);
          }));
}
