import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/csv_ice_file_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/itemsSwapper/items_swapper_data_loader.dart';
import 'package:pso2_mod_manager/itemsSwapper/items_swapper_popup.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/modsAdder/mods_adder_homepage.dart';
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_data_loader.dart' as msdl;
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_la_swappage.dart' as msls;
import 'package:pso2_mod_manager/state_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

TextEditingController swapperSearchTextController = TextEditingController();
TextEditingController swapperFromItemsSearchTextController = TextEditingController();
List<CsvEmoteIceFile> fromItemSearchResults = [];
List<CsvEmoteIceFile> toIEmotesSearchResults = [];
CsvEmoteIceFile? selectedFromEmotesCsvFile;
CsvEmoteIceFile? selectedToEmotesCsvFile;
List<String> fromEmotesAvailableIces = [];
List<String> toEmotesAvailableIces = [];
String selectedLaGender = '';
List<CsvEmoteIceFile> fromItemCsvData = [];
String selectedMotionType = '';
List<CsvEmoteIceFile> queueFromEmoteCsvFiles = [];
List<CsvEmoteIceFile> queueToEmoteCsvFiles = [];
List<List<String>> queueFromEmotesAvailableIces = [];
List<List<String>> queueToEmotesAvailableIces = [];
List<String> queueSwappedLaPaths = [];
List<String> queueToItemNames = [];
List<String> motionTypes = ['All', 'Glide Motion', 'Jump Motion', 'Landing Motion', 'Dash Motion', 'Run Motion', 'Standby Motion', 'Swim Motion'];
String dropDownSelectedMotionType = motionTypes.first;

class ItemsSwapperEmotesHomePage extends StatefulWidget {
  const ItemsSwapperEmotesHomePage({super.key});

  @override
  State<ItemsSwapperEmotesHomePage> createState() => _ItemsSwapperEmotesHomePageState();
}

class _ItemsSwapperEmotesHomePageState extends State<ItemsSwapperEmotesHomePage> {
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
    if (!isEmotesToStandbyMotions || fromItemCsvData.isEmpty) {
      // fromItemCsvData = csvEmotesData
      //     .where((element) =>
      //         element.jpName.isNotEmpty &&
      //         element.enName.isNotEmpty &&
      //         (element.pso2HashIceName.isNotEmpty ||
      //             element.pso2VfxHashIceName.isNotEmpty ||
      //             element.rbCastFemaleHashIceName.isNotEmpty ||
      //             element.rbCastMaleHashIceName.isNotEmpty ||
      //             element.rbFigHashIceName.isNotEmpty ||
      //             element.rbHumanHashIceName.isNotEmpty ||
      //             element.rbVfxHashIceName.isNotEmpty))
      //     .toList();
      if (dropDownSelectedMotionType == motionTypes.first || selectedMotionType.isEmpty) {
        fromItemCsvData = csvEmotesData
            .where((element) =>
                // element.jpName.isNotEmpty &&
                // element.enName.isNotEmpty &&
                (element.pso2HashIceName.isNotEmpty ||
                    element.pso2VfxHashIceName.isNotEmpty ||
                    element.rbCastFemaleHashIceName.isNotEmpty ||
                    element.rbCastMaleHashIceName.isNotEmpty ||
                    element.rbFigHashIceName.isNotEmpty ||
                    element.rbHumanHashIceName.isNotEmpty ||
                    element.rbVfxHashIceName.isNotEmpty))
            .toList();
      } else {
        fromItemCsvData = csvEmotesData
            .where((element) =>
                // element.jpName.isNotEmpty &&
                // element.enName.isNotEmpty &&
                element.subCategory == dropDownSelectedMotionType &&
                (element.pso2HashIceName.isNotEmpty ||
                    element.pso2VfxHashIceName.isNotEmpty ||
                    element.rbCastFemaleHashIceName.isNotEmpty ||
                    element.rbCastMaleHashIceName.isNotEmpty ||
                    element.rbFigHashIceName.isNotEmpty ||
                    element.rbHumanHashIceName.isNotEmpty ||
                    element.rbVfxHashIceName.isNotEmpty))
            .toList();
      }
      if (modManCurActiveItemNameLanguage == 'JP') {
        fromItemCsvData.sort((a, b) => a.jpName.compareTo(b.jpName));
      } else {
        fromItemCsvData.sort((a, b) => a.enName.compareTo(b.enName));
      }
      for (var data in fromItemCsvData) {
        if (selectedMotionType.isEmpty && data.subCategory.isNotEmpty) {
          selectedMotionType = data.subCategory;
          break;
        }
      }
    }
    //List<List<String>> csvInfos = [];
    // bool isPso2HashFound = false;
    // bool isPso2VfxHashFound = false;
    // for (var csvItemData in fromItemCsvData) {
    //   final availableModFileData = csvItemData.getDetailedList().where((element) => element.split(': ').last.isNotEmpty).toList();
    //   // csvInfos.add(availableModFileData);
    //   // if (selectedMotionType.isEmpty) {
    //   //   selectedMotionType = csvItemData.subCategory;
    //   // }
    //   //filter pso2 only emotes
    //   // for (var line in availableModFileData) {
    //   //   if (!isPso2HashFound && line.split(': ').first.contains('PSO2 Hash Ice')) {
    //   //     isPso2HashFound = true;
    //   //   }
    //   //   if (!isPso2VfxHashFound && line.split(': ').first.contains('PSO2 VFX Hash Ice')) {
    //   //     isPso2VfxHashFound = true;
    //   //   }
    //   //   if (isPso2HashFound && isPso2VfxHashFound) {
    //   //     break;
    //   //   }
    //   // }
    // }

    // if (selectedMotionType.isNotEmpty && dropDownSelectedMotionType != motionTypes.first) {
    //   availableEmotesCsvData = availableEmotesCsvData.where((element) => element.subCategory == dropDownSelectedMotionType).toList();
    // }

    // if (isPso2HashFound) {
    //   availableEmotesCsvData = availableEmotesCsvData.where((element) => element.pso2HashIceName.isNotEmpty).toList();
    // }
    // if (isPso2VfxHashFound) {
    //   availableEmotesCsvData = availableEmotesCsvData.where((element) => element.pso2VfxHashIceName.isNotEmpty).toList();
    // }

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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Card(
                                shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                color: MyApp.themeNotifier.value == ThemeMode.light ? Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.7) : Colors.transparent,
                                child: SizedBox(
                                  height: 92,
                                  child: ListTile(
                                    minVerticalPadding: 15,
                                    title: Text(curLangText!.uiChooseAnItemBelow),
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
                                                .where((element) => modManCurActiveItemNameLanguage == 'JP'
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
                                      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                                      child: SizedBox(
                                        width: 200,
                                        child: DropdownButtonHideUnderline(
                                            child: DropdownButton2(
                                          buttonStyleData: ButtonStyleData(
                                            height: 28.5,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 1,
                                                color: Theme.of(context).hintColor,
                                              ),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          dropdownStyleData: DropdownStyleData(
                                            maxHeight: windowsHeight * 0.5,
                                            elevation: 3,
                                            padding: const EdgeInsets.symmetric(vertical: 2),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(3),
                                              color: Theme.of(context).cardColor,
                                            ),
                                          ),
                                          iconStyleData: const IconStyleData(iconSize: 15),
                                          menuItemStyleData: const MenuItemStyleData(
                                            height: 25,
                                            padding: EdgeInsets.symmetric(horizontal: 5),
                                          ),
                                          isDense: true,
                                          items: motionTypes
                                              .map((item) => DropdownMenuItem<String>(
                                                  value: item,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.only(bottom: 3),
                                                        child: Text(
                                                          item,
                                                          style: const TextStyle(
                                                              //fontSize: 14,
                                                              //fontWeight: FontWeight.bold,
                                                              //color: Colors.white,
                                                              ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      )
                                                    ],
                                                  )))
                                              .toList(),
                                          value: dropDownSelectedMotionType,
                                          onChanged: selectedMotionType.isEmpty
                                              ? null
                                              : (value) async {
                                                  dropDownSelectedMotionType = value.toString();
                                                  selectedFromEmotesCsvFile = null;
                                                  fromItemCsvData.clear();
                                                  if (dropDownSelectedMotionType == motionTypes.first) {
                                                    availableEmotesCsvData = csvEmotesData.where((element) => element.jpName.isNotEmpty && element.enName.isNotEmpty).toList();
                                                  } else {
                                                    availableEmotesCsvData = csvEmotesData.where((element) => element.subCategory == dropDownSelectedMotionType).toList();
                                                  }
                                                  if (modManCurActiveItemNameLanguage == 'JP') {
                                                    availableEmotesCsvData.sort((a, b) => a.jpName.compareTo(b.jpName));
                                                  } else {
                                                    availableEmotesCsvData.sort((a, b) => a.enName.compareTo(b.enName));
                                                  }
                                                  setState(() {});
                                                },
                                        )),
                                      ),
                                    ),
                                    Expanded(
                                      child: Card(
                                        shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                        color: MyApp.themeNotifier.value == ThemeMode.light ? Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.7) : Colors.transparent,
                                        child: ScrollbarTheme(
                                          data: ScrollbarThemeData(
                                            thumbColor: WidgetStateProperty.resolveWith((states) {
                                              if (states.contains(WidgetState.hovered)) {
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
                                                    groupValue: selectedFromEmotesCsvFile,
                                                    title: modManCurActiveItemNameLanguage == 'JP'
                                                        ? swapperFromItemsSearchTextController.text.isEmpty
                                                            ? Text(fromItemCsvData[i].jpName)
                                                            : Text(fromItemSearchResults[i].jpName)
                                                        : swapperFromItemsSearchTextController.text.isEmpty
                                                            ? Text(fromItemCsvData[i].enName)
                                                            : Text(fromItemSearchResults[i].enName),
                                                    subtitle: swapperFromItemsSearchTextController.text.isEmpty
                                                        ? selectedFromEmotesCsvFile == fromItemCsvData[i]
                                                            ? Column(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  for (int line = 0;
                                                                      line < selectedFromEmotesCsvFile!.getDetailedListIceInfosOnly().where((element) => element.split(': ').last.isNotEmpty).length;
                                                                      line++)
                                                                    Text(
                                                                        selectedFromEmotesCsvFile!.getDetailedListIceInfosOnly().where((element) => element.split(': ').last.isNotEmpty).toList()[line])
                                                                ],
                                                              )
                                                            : null
                                                        : selectedFromEmotesCsvFile == fromItemSearchResults[i]
                                                            ? Column(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  for (int line = 0;
                                                                      line < selectedFromEmotesCsvFile!.getDetailedListIceInfosOnly().where((element) => element.split(': ').last.isNotEmpty).length;
                                                                      line++)
                                                                    Text(
                                                                        selectedFromEmotesCsvFile!.getDetailedListIceInfosOnly().where((element) => element.split(': ').last.isNotEmpty).toList()[line])
                                                                ],
                                                              )
                                                            : null,
                                                    onChanged: queueFromEmoteCsvFiles.contains(fromItemCsvData[i])
                                                        ? null
                                                        : (CsvEmoteIceFile? currentItem) {
                                                            //print("Current ${moddedItemsList[i].groupName}");
                                                            selectedFromEmotesCsvFile = currentItem!;
                                                            fromItemName = modManCurActiveItemNameLanguage == 'JP' ? selectedFromEmotesCsvFile!.jpName : selectedFromEmotesCsvFile!.enName;
                                                            fromEmotesAvailableIces =
                                                                selectedFromEmotesCsvFile!.getDetailedListIceInfosOnly().where((element) => element.split(': ').last.isNotEmpty).toList();
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
                              Visibility(
                                  visible: queueFromEmoteCsvFiles.isNotEmpty,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 5),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          curLangText!.uiSwappingQueue,
                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                        ),
                                        ElevatedButton(
                                            onPressed: () {
                                              queueFromEmoteCsvFiles.clear();
                                              queueToEmoteCsvFiles.clear();
                                              queueFromEmotesAvailableIces.clear();
                                              queueToEmotesAvailableIces.clear();
                                              setState(() {});
                                            },
                                            child: Text(curLangText!.uiClearQueue))
                                      ],
                                    ),
                                  )),
                              //queue
                              Visibility(
                                visible: queueFromEmoteCsvFiles.isNotEmpty,
                                child: SizedBox(
                                    height: constraints.maxHeight * 0.35,
                                    width: double.infinity,
                                    child: Card(
                                        shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                        color: MyApp.themeNotifier.value == ThemeMode.light ? Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.7) : Colors.transparent,
                                        child: ScrollbarTheme(
                                            data: ScrollbarThemeData(
                                              thumbColor: WidgetStateProperty.resolveWith((states) {
                                                if (states.contains(WidgetState.hovered)) {
                                                  return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.7);
                                                }
                                                return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5);
                                              }),
                                            ),
                                            child: ListView.builder(
                                                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                                                shrinkWrap: true,
                                                //physics: const BouncingScrollPhysics(),
                                                itemCount: queueFromEmoteCsvFiles.length,
                                                itemBuilder: (context, i) {
                                                  return Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                                    child: ListTile(
                                                      shape: RoundedRectangleBorder(
                                                          side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                      tileColor: MyApp.themeNotifier.value == ThemeMode.light ? Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.7) : Colors.transparent,
                                                      title: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(queueFromEmoteCsvFiles[i].enName),
                                                              // for (int line = 0;
                                                              //     line < csvInfos.firstWhere((element) => queueFromEmoteCsvFiles[i].getDetailedList().contains(element.first)).length;
                                                              //     line++)
                                                              //   Text(csvInfos.firstWhere((element) => queueFromEmoteCsvFiles[i].getDetailedList().contains(element.first))[line].split(': ').last,
                                                              //       style: TextStyle(fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize, color: Theme.of(context).hintColor))
                                                              for (int line = 0; line < queueFromEmotesAvailableIces[i].length; line++)
                                                                Text(queueFromEmotesAvailableIces[i][line].split(': ').last,
                                                                    style: TextStyle(fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize, color: Theme.of(context).hintColor))
                                                            ],
                                                          ),
                                                          const Icon(Icons.arrow_forward_ios),
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.end,
                                                            children: [
                                                              Text(queueToEmoteCsvFiles[i].enName),
                                                              Text(queueToEmoteCsvFiles[i].gender,
                                                                  style: TextStyle(fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize, color: Theme.of(context).hintColor)),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      trailing: SizedBox(
                                                        width: 25,
                                                        child: MaterialButton(
                                                            visualDensity: VisualDensity.compact,
                                                            padding: EdgeInsets.zero,
                                                            onPressed: () {
                                                              queueFromEmoteCsvFiles.removeAt(i);
                                                              queueToEmoteCsvFiles.removeAt(i);
                                                              queueFromEmotesAvailableIces.removeAt(i);
                                                              queueToEmotesAvailableIces.removeAt(i);
                                                              setState(() {});
                                                            },
                                                            child: const SizedBox(width: 25, child: Icon(Icons.clear))),
                                                      ),
                                                    ),
                                                  );
                                                })))),
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
                                color: MyApp.themeNotifier.value == ThemeMode.light ? Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.7) : Colors.transparent,
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
                                                  .where((element) => modManCurActiveItemNameLanguage == 'JP'
                                                      ? element.jpName.toLowerCase().contains(swapperSearchTextController.text.toLowerCase()) ||
                                                          element.pso2HashIceName .toLowerCase().contains(swapperSearchTextController.text.toLowerCase()) ||
                                                          element.pso2VfxHashIceName.toLowerCase().contains(swapperSearchTextController.text.toLowerCase()) ||
                                                          element.rbCastFemaleHashIceName.toLowerCase().contains(swapperSearchTextController.text.toLowerCase())||
                                                          element.rbCastMaleHashIceName.toLowerCase().contains(swapperSearchTextController.text.toLowerCase())||
                                                          element.rbFigHashIceName.toLowerCase().contains(swapperSearchTextController.text.toLowerCase())||
                                                          element.rbHumanHashIceName.toLowerCase().contains(swapperSearchTextController.text.toLowerCase())||
                                                          element.rbVfxHashIceName.toLowerCase().contains(swapperSearchTextController.text.toLowerCase())
                                                      : element.enName.toLowerCase().contains(swapperSearchTextController.text.toLowerCase()) ||
                                                          element.pso2HashIceName .toLowerCase().contains(swapperSearchTextController.text.toLowerCase()) ||
                                                          element.pso2VfxHashIceName.toLowerCase().contains(swapperSearchTextController.text.toLowerCase()) ||
                                                          element.rbCastFemaleHashIceName.toLowerCase().contains(swapperSearchTextController.text.toLowerCase())||
                                                          element.rbCastMaleHashIceName.toLowerCase().contains(swapperSearchTextController.text.toLowerCase())||
                                                          element.rbFigHashIceName.toLowerCase().contains(swapperSearchTextController.text.toLowerCase())||
                                                          element.rbHumanHashIceName.toLowerCase().contains(swapperSearchTextController.text.toLowerCase())||
                                                          element.rbVfxHashIceName.toLowerCase().contains(swapperSearchTextController.text.toLowerCase()))
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
                                          //swap to idle motion
                                          MaterialButton(
                                            height: 29,
                                            padding: EdgeInsets.zero,
                                            onPressed:
                                                selectedMotionType.isNotEmpty || swapperSearchTextController.text.isNotEmpty || queueFromEmoteCsvFiles.isNotEmpty || queueToEmoteCsvFiles.isNotEmpty
                                                    ? null
                                                    : () async {
                                                        selectedFromEmotesCsvFile = null;
                                                        selectedToEmotesCsvFile = null;
                                                        csvEmotesData.clear();
                                                        if (!isEmotesToStandbyMotions) {
                                                          isEmotesToStandbyMotions = true;
                                                          await msdl.sheetListFetchFromFiles(context, defaultCategoryDirs[14], []);
                                                          availableEmotesCsvData = await msdl.getEmotesToMotionsSwapToCsvList(csvEmotesData, defaultCategoryDirs[14]);
                                                        } else {
                                                          isEmotesToStandbyMotions = false;
                                                          await msdl.sheetListFetchFromFiles(context, selectedCategoryF!, []);
                                                          //shell Item
                                                          Item tempItem = Item('', [], [], selectedCategoryF!, '', false, DateTime(0), 0, false, false, false, [], []);
                                                          availableEmotesCsvData = await msdl.getEmotesSwapToCsvList(csvEmotesData, tempItem.category);
                                                          if (selectedMotionType.isNotEmpty) {
                                                            availableEmotesCsvData = availableEmotesCsvData.where((element) => element.subCategory == selectedMotionType).toList();
                                                          }
                                                          // if (isPso2HashFound) {
                                                          //   availableEmotesCsvData = availableEmotesCsvData.where((element) => element.pso2HashIceName.isNotEmpty).toList();
                                                          // }
                                                          // if (isPso2VfxHashFound) {
                                                          //   availableEmotesCsvData = availableEmotesCsvData.where((element) => element.pso2VfxHashIceName.isNotEmpty).toList();
                                                          // }
                                                        }
                                                        if (modManCurActiveItemNameLanguage == 'JP') {
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
                                          color: MyApp.themeNotifier.value == ThemeMode.light ? Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.7) : Colors.transparent,
                                          child: ScrollbarTheme(
                                              data: ScrollbarThemeData(
                                                thumbColor: WidgetStateProperty.resolveWith((states) {
                                                  if (states.contains(WidgetState.hovered)) {
                                                    return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.7);
                                                  }
                                                  return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5);
                                                }),
                                              ),
                                              child: ListView.builder(
                                                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                                                  shrinkWrap: true,
                                                  //physics: const BouncingScrollPhysics(),
                                                  itemCount: swapperSearchTextController.text.isEmpty ? availableEmotesCsvData.length : toIEmotesSearchResults.length,
                                                  itemBuilder: (context, i) {
                                                    return Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                                      child: RadioListTile(
                                                        shape: RoundedRectangleBorder(
                                                            side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                        value: swapperSearchTextController.text.isEmpty ? availableEmotesCsvData[i] : toIEmotesSearchResults[i],
                                                        groupValue: selectedToEmotesCsvFile,
                                                        title: modManCurActiveItemNameLanguage == 'JP'
                                                            ? swapperSearchTextController.text.isEmpty
                                                                ? Text(availableEmotesCsvData[i].jpName)
                                                                : Text(toIEmotesSearchResults[i].jpName)
                                                            : swapperSearchTextController.text.isEmpty
                                                                ? Text(availableEmotesCsvData[i].enName)
                                                                : Text(toIEmotesSearchResults[i].enName),
                                                        subtitle: isEmotesToStandbyMotions ||
                                                                selectedMotionType.isNotEmpty ||
                                                                availableEmotesCsvData[i].gender.isEmpty ||
                                                                (toIEmotesSearchResults.isNotEmpty && toIEmotesSearchResults[i].gender.isEmpty)
                                                            ? null
                                                            : swapperSearchTextController.text.isEmpty
                                                                ? Text(availableEmotesCsvData[i].gender)
                                                                : Text(toIEmotesSearchResults[i].gender),
                                                        onChanged: (toIEmotesSearchResults.isNotEmpty && queueToEmoteCsvFiles.contains(toIEmotesSearchResults[i])) ||
                                                                (availableEmotesCsvData.isNotEmpty && queueToEmoteCsvFiles.contains(availableEmotesCsvData[i]))
                                                            ? null
                                                            : (CsvEmoteIceFile? currentItem) {
                                                                //print("Current ${moddedItemsList[i].groupName}");
                                                                selectedToEmotesCsvFile = currentItem!;
                                                                toItemName = modManCurActiveItemNameLanguage == 'JP' ? selectedToEmotesCsvFile!.jpName : selectedToEmotesCsvFile!.enName;
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
                                    selectedMotionType = '';
                                    selectedFromEmotesCsvFile = null;
                                    selectedToEmotesCsvFile = null;
                                    availableEmotesCsvData.clear();
                                    fromEmotesAvailableIces.clear();
                                    toEmotesAvailableIces.clear();
                                    csvEmotesData.clear();
                                    availableEmotesCsvData.clear();
                                    queueFromEmoteCsvFiles.clear();
                                    queueToEmoteCsvFiles.clear();
                                    isEmotesToStandbyMotions = false;
                                    dropDownSelectedMotionType = motionTypes.first;
                                    toIEmotesSearchResults.clear();
                                    fromItemSearchResults.clear();
                                    Navigator.pop(context);
                                  },
                                  child: Text(curLangText!.uiClose)),
                              ElevatedButton(
                                  onPressed:
                                      selectedFromEmotesCsvFile == null || selectedToEmotesCsvFile == null || selectedMotionType.isNotEmpty || isEmotesToStandbyMotions || fromItemCsvData.length < 2
                                          ? null
                                          : () {
                                              queueFromEmoteCsvFiles.add(selectedFromEmotesCsvFile!);
                                              queueToEmoteCsvFiles.add(selectedToEmotesCsvFile!);
                                              queueToItemNames.add(toItemName.toString());
                                              if (fromEmotesAvailableIces.isNotEmpty) {
                                                queueFromEmotesAvailableIces.add(fromEmotesAvailableIces);
                                              }
                                              if (toEmotesAvailableIces.isNotEmpty) {
                                                queueToEmotesAvailableIces.add(toEmotesAvailableIces.toList());
                                              }
                                              selectedFromEmotesCsvFile = null;
                                              selectedToEmotesCsvFile = null;
                                              setState(() {});
                                            },
                                  child: Text(curLangText!.uiAddToQueue)),
                              ElevatedButton(
                                  onPressed: (selectedFromEmotesCsvFile == null || selectedToEmotesCsvFile == null) && queueFromEmoteCsvFiles.isEmpty
                                      ? null
                                      : () async {
                                          if (queueFromEmoteCsvFiles.isEmpty) {
                                            if (selectedFromEmotesCsvFile != null && selectedToEmotesCsvFile != null) {
                                              swapperLaConfirmDialog(context, fromItemSubmodGet(fromEmotesAvailableIces), fromEmotesAvailableIces, toEmotesAvailableIces, toItemName);
                                            }
                                          } else {
                                            await swapperLaQueueConfirmDialog(
                                                context, fromItemSubmodGet(fromEmotesAvailableIces), queueFromEmotesAvailableIces, queueToEmotesAvailableIces, queueToItemNames);
                                            setState(() {});
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

Future<void> swapperLaConfirmDialog(context, SubMod fromSubmod, List<String> fromEmotesAvailableIces, List<String> toEmotesAvailableIces, String toSelectedItemName) async {
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
                    Expanded(flex: 1, child: Center(child: Text(fromItemName, style: const TextStyle(fontWeight: FontWeight.w700)))),
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
                            color: MyApp.themeNotifier.value == ThemeMode.light ? Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.7) : Colors.transparent,
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
                            color: MyApp.themeNotifier.value == ThemeMode.light ? Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.7) : Colors.transparent,
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
                        msls.swapperLaSwappingDialog(context, true, fromSubmod, toItemName, fromEmotesAvailableIces, toEmotesAvailableIces, queueSwappedLaPaths);
                      },
                      child: Text(curLangText!.uiSwap))
                ]);
          }));
}

Future<void> swapperLaQueueConfirmDialog(
    context, SubMod fromSubmod, List<List<String>> queueFromEmotesAvailableIceList, List<List<String>> queueToEmotesAvailableIceList, List<String> queueToItemNameList) async {
  await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                titlePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
                title: Text(curLangText!.uiItemsToSwap),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                content: ScrollbarTheme(
                  data: ScrollbarThemeData(
                    thumbColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.hovered)) {
                        return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.7);
                      }
                      return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5);
                    }),
                  ),
                  child: SingleChildScrollView(
                    physics: const PageScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < queueFromEmoteCsvFiles.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                          queueFromEmoteCsvFiles[i].enName,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        )),
                                    const SizedBox(
                                      width: 30,
                                    ),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                          queueToEmoteCsvFiles[i].enName,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        )),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Card(
                                        margin: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                                        color: MyApp.themeNotifier.value == ThemeMode.light ? Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.7) : Colors.transparent,
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [for (int line = 0; line < queueFromEmotesAvailableIceList[i].length; line++) Text(queueFromEmotesAvailableIceList[i][line])],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5),
                                      child: Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: queueSwappedLaPaths.length - 1 >= i &&
                                                Directory(queueSwappedLaPaths[i]).existsSync() &&
                                                Directory(queueSwappedLaPaths[i])
                                                    .listSync(recursive: true)
                                                    .whereType<File>()
                                                    .where((element) => queueToEmotesAvailableIceList[i].where((line) => line.contains(p.basenameWithoutExtension(element.path))).isNotEmpty)
                                                    .isNotEmpty
                                            ? Colors.green
                                            : null,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Card(
                                        margin: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                                        color: MyApp.themeNotifier.value == ThemeMode.light ? Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.7) : Colors.transparent,
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              for (int line = 0; line < queueToEmotesAvailableIceList[i].length; line++) Text(queueToEmotesAvailableIceList[i][line])
                                              //if (queueToEmotesAvailableIceList[i][line].split(': ').last.isNotEmpty) Text(queueToEmotesAvailableIceList[i][line])
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                //actionsPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
                actions: <Widget>[
                  ElevatedButton(
                      child: Text(curLangText!.uiReturn),
                      onPressed: () {
                        if (queueSwappedLaPaths.isNotEmpty) {
                          queueToItemNames.clear();
                          queueFromEmotesAvailableIceList.clear();
                          queueToEmotesAvailableIceList.clear();
                          queueToItemNameList.clear();
                          queueToEmoteCsvFiles.clear();
                          queueFromEmoteCsvFiles.clear();
                          queueSwappedLaPaths.clear();
                          setState(
                            () {},
                          );
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
                        }

                        Navigator.pop(context);
                      }),
                  ElevatedButton(
                      onPressed: queueSwappedLaPaths.isEmpty
                          ? null
                          : () async {
                              if (queueSwappedLaPaths.length == 1) {
                                await launchUrl(Uri.file(queueSwappedLaPaths.first));
                              } else {
                                await launchUrl(Uri.file(p.dirname(queueSwappedLaPaths.first)));
                              }
                            },
                      child: Text('${curLangText!.uiOpen} ${curLangText!.uiInFileExplorer}')),
                  ElevatedButton(
                      onPressed: queueSwappedLaPaths.isEmpty
                          ? null
                          : () {
                              for (var swappedModPath in queueSwappedLaPaths) {
                                //newModDragDropList.add(XFile(Uri.file('$swappedModPath/${fromSubmod.modName}').toFilePath()));
                                modAdderDragDropFiles.add(XFile(Uri.file('$swappedModPath/${fromSubmod.modName}').toFilePath()));
                              }
                              modsAdderHomePage(context);
                            },
                      child: Text(curLangText!.uiAddToModManager)),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ElevatedButton(
                        onPressed: () async {
                          for (int i = 0; i < queueFromEmotesAvailableIceList.length; i++) {
                            fromEmotesAvailableIces = queueFromEmotesAvailableIceList[i].toList();
                            toEmotesAvailableIces = queueToEmotesAvailableIceList[i].toList();
                            await msls.swapperLaQueueSwappingDialog(context, true, fromSubmod, queueToItemNameList[i], fromEmotesAvailableIces, toEmotesAvailableIces, queueSwappedLaPaths);
                            setState(
                              () {},
                            );
                          }
                        },
                        child: Text(curLangText!.uiSwap)),
                  )
                ]);
          }));
}
