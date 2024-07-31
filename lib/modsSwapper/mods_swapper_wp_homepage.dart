import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/csv_ice_file_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/functions/weapons_swapper_sort.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/modsAdder/mods_adder_homepage.dart';
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_popup.dart';
import 'package:pso2_mod_manager/state_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:url_launcher/url_launcher.dart';

TextEditingController swapperSearchTextController = TextEditingController();
List<CsvWeaponIceFile> toItemSearchResults = [];
CsvWeaponIceFile? selectedFromCsvFile;
CsvWeaponIceFile? selectedToCsvFile;
String fromItemAvailableIce = '';
String toItemAvailableIce = '';
String fromItemIconLink = '';
String toItemIconLink = '';
List<String> weaponTypes = [
  curLangText!.uiAll,
  curLangText!.uiSwords,
  curLangText!.uiWiredLances,
  curLangText!.uiPartisans,
  curLangText!.uiTwinDaggers,
  curLangText!.uiDoubleSabers,
  curLangText!.uiKnuckles,
  curLangText!.uiKatanas,
  curLangText!.uiSoaringBlades,
  curLangText!.uiAssualtRifles,
  curLangText!.uiLaunchers,
  curLangText!.uiTwinMachineGuns,
  curLangText!.uiBows,
  curLangText!.uiGunblades,
  curLangText!.uiRods,
  curLangText!.uiTalises,
  curLangText!.uiWands,
  curLangText!.uiJetBoots,
  curLangText!.uiHarmonizers,
  curLangText!.uiUnknownWeapons
];
String dropDownSelectedWeaponType = weaponTypes.first;
List<String> itemTypes = [curLangText!.uiAll, curLangText!.uiPSO2, curLangText!.uiNGS];
String dropDownSelectedItemType = itemTypes.first;
List<String> itemVars = [curLangText!.uiAll, curLangText!.uiWeapons, curLangText!.uiCamos];
String dropDownSelectedItemVar = itemTypes.first;

class ModsSwapperWeaponHomePage extends StatefulWidget {
  const ModsSwapperWeaponHomePage({super.key, required this.fromItem, required this.fromSubmod});

  final Item fromItem;
  final SubMod fromSubmod;

  @override
  State<ModsSwapperWeaponHomePage> createState() => _ModsSwapperWeaponHomePageState();
}

class _ModsSwapperWeaponHomePageState extends State<ModsSwapperWeaponHomePage> {
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
    final fromItemCsvData = csvWeaponsData.where((element) => iceNamesFromSubmod.contains(element.iceName)).toList();
    List<List<String>> csvInfos = [];
    for (var csvItemData in fromItemCsvData) {
      final data = csvItemData.getDetailedList().where((element) => element.split(': ').last.isNotEmpty).toList();
      // final availableModFileData = data.where((element) => iceNamesFromSubmod.contains(element.split(': ').last)).toList();

      csvInfos.add(data);
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
                                color: MyApp.themeNotifier.value == ThemeMode.light ? Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.7) : Colors.transparent,
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
                                            child: widget.fromItem.icons.first.contains('assets/img/placeholdersquare.png') || widget.fromItem.icons.isEmpty
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
                                            Text(widget.fromItem.itemName.characters.first == '_' ? widget.fromItem.itemName.replaceFirst('_', '*') : widget.fromItem.itemName,
                                                style: const TextStyle(fontWeight: FontWeight.w500)),
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
                                      child: Text(curLangText!.uiSelectAWeaponBelow),
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
                                          child: SuperListView.builder(
                                              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                                              // shrinkWrap: true,
                                              physics: const RangeMaintainingScrollPhysics(),
                                              itemCount: fromItemCsvData.length,
                                              itemBuilder: (context, i) {
                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                                  child: RadioListTile(
                                                    shape:
                                                        RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                    value: fromItemCsvData[i],
                                                    groupValue: selectedFromCsvFile,
                                                    title: Row(children: [
                                                      if (fromItemCsvData.length > 1)
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 2, bottom: 2, right: 10),
                                                          child: Container(
                                                              width: 80,
                                                              height: 80,
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(3),
                                                                border: Border.all(color: Theme.of(context).hintColor, width: 1),
                                                              ),
                                                              child: Image.network(
                                                                '$modManMAIconDatabaseLink${fromItemCsvData[i].iconImageWebPath.replaceAll('\\', '/').replaceAll(' ', '%20')}',
                                                                errorBuilder: (context, error, stackTrace) => Image.asset(
                                                                  'assets/img/placeholdersquare.png',
                                                                  filterQuality: FilterQuality.none,
                                                                  fit: BoxFit.fitWidth,
                                                                ),
                                                                filterQuality: FilterQuality.none,
                                                                fit: BoxFit.fitWidth,
                                                              )),
                                                        ),
                                                      Text(modManCurActiveItemNameLanguage == 'JP'
                                                          ? fromItemCsvData[i].jpName.isNotEmpty
                                                              ? fromItemCsvData[i].jpName
                                                              : p.basenameWithoutExtension(fromItemCsvData[i].icePath)
                                                          : fromItemCsvData[i].enName.isNotEmpty
                                                              ? fromItemCsvData[i].enName
                                                              : p.basenameWithoutExtension(fromItemCsvData[i].icePath))
                                                    ]),
                                                    subtitle: Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [for (int line = 0; line < csvInfos[i].length; line++) Text(csvInfos[i][line])],
                                                    ),
                                                    onChanged: (CsvWeaponIceFile? currentItem) {
                                                      //print("Current ${moddedItemsList[i].groupName}");
                                                      selectedFromCsvFile = currentItem!;
                                                      fromItemAvailableIce = currentItem.iceName;
                                                      // fromItemIds = [selectedFromCsvFile!.id.toString(), selectedFromCsvFile!.adjustedId.toString()];
                                                      //set infos
                                                      if (selectedToCsvFile != null) {
                                                        toItemAvailableIce = '';
                                                        // List<String> selectedToItemIceList = selectedToCsvFile!.getDetailedList();
                                                        // for (var line in selectedToItemIceList) {
                                                        // if (fromItemAvailableIce.where((element) => element.split(': ').first == line.split(': ').first).isNotEmpty) {
                                                        toItemAvailableIce = selectedToCsvFile!.iceName;
                                                        // }
                                                        // }
                                                      }

                                                      //confirm icon set
                                                      fromItemIconLink = '$modManMAIconDatabaseLink${currentItem.iconImageWebPath.replaceAll('\\', '/').replaceAll(' ', '%20')}';

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
                                              toItemSearchResults = availableWeaponCsvData
                                                  .where((element) => modManCurActiveItemNameLanguage == 'JP'
                                                      ? element.jpName.toLowerCase().contains(swapperSearchTextController.text.toLowerCase()) ||
                                                          element.iceName.toLowerCase().contains(swapperSearchTextController.text.toLowerCase()) ||
                                                          element.icePath.toLowerCase().contains(swapperSearchTextController.text.toLowerCase())
                                                      : element.enName.toLowerCase().contains(swapperSearchTextController.text.toLowerCase()) ||
                                                          element.iceName.toLowerCase().contains(swapperSearchTextController.text.toLowerCase()) ||
                                                          element.icePath.toLowerCase().contains(swapperSearchTextController.text.toLowerCase()))
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
                                        children: [
                                          //weapon types
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
                                                items: weaponTypes
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
                                                value: dropDownSelectedWeaponType,
                                                onChanged: (value) async {
                                                  dropDownSelectedWeaponType = value.toString();
                                                  selectedToCsvFile = null;
                                                  if (swapperSearchTextController.text.isNotEmpty) {
                                                    toItemSearchResults =
                                                        wpSwapperDropDownItemSort(swapperSearchTextController.text, dropDownSelectedWeaponType, dropDownSelectedItemType, dropDownSelectedItemVar);
                                                  } else {
                                                    availableWeaponCsvData =
                                                        wpSwapperDropDownItemSort(swapperSearchTextController.text, dropDownSelectedWeaponType, dropDownSelectedItemType, dropDownSelectedItemVar);
                                                  }
                                                  setState(() {});
                                                },
                                              )),
                                            ),
                                          ),
                                          //camo
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                                            child: SizedBox(
                                              width: 100,
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
                                                items: itemVars
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
                                                value: dropDownSelectedItemVar,
                                                onChanged: (value) async {
                                                  dropDownSelectedItemVar = value.toString();
                                                  selectedToCsvFile = null;
                                                  if (swapperSearchTextController.text.isNotEmpty) {
                                                    toItemSearchResults =
                                                        wpSwapperDropDownItemSort(swapperSearchTextController.text, dropDownSelectedWeaponType, dropDownSelectedItemType, dropDownSelectedItemVar);
                                                  } else {
                                                    availableWeaponCsvData =
                                                        wpSwapperDropDownItemSort(swapperSearchTextController.text, dropDownSelectedWeaponType, dropDownSelectedItemType, dropDownSelectedItemVar);
                                                  }
                                                  setState(() {});
                                                },
                                              )),
                                            ),
                                          ),
                                          // item type
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                                            child: SizedBox(
                                              width: 100,
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
                                                items: itemTypes
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
                                                value: dropDownSelectedItemType,
                                                onChanged: (value) async {
                                                  dropDownSelectedItemType = value.toString();
                                                  selectedToCsvFile = null;
                                                  if (swapperSearchTextController.text.isNotEmpty) {
                                                    toItemSearchResults =
                                                        wpSwapperDropDownItemSort(swapperSearchTextController.text, dropDownSelectedWeaponType, dropDownSelectedItemType, dropDownSelectedItemVar);
                                                  } else {
                                                    availableWeaponCsvData =
                                                        wpSwapperDropDownItemSort(swapperSearchTextController.text, dropDownSelectedWeaponType, dropDownSelectedItemType, dropDownSelectedItemVar);
                                                  }
                                                  setState(() {});
                                                },
                                              )),
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
                                              child: SuperListView.builder(
                                                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                                  // shrinkWrap: true,
                                                  physics: const RangeMaintainingScrollPhysics(),
                                                  itemCount: swapperSearchTextController.text.isEmpty ? availableWeaponCsvData.length : toItemSearchResults.length,
                                                  itemBuilder: (context, i) {
                                                    // String cate = availableWeaponCsvData[i].itemType;
                                                    // debugPrint(cate);
                                                    return Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                                      child: RadioListTile(
                                                        shape: RoundedRectangleBorder(
                                                            side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                        value: swapperSearchTextController.text.isEmpty ? availableWeaponCsvData[i] : toItemSearchResults[i],
                                                        groupValue: selectedToCsvFile,
                                                        title: Row(children: [
                                                          //icon
                                                          Padding(
                                                            padding: const EdgeInsets.only(top: 2, bottom: 2, right: 10),
                                                            child: Container(
                                                              width: 80,
                                                              height: 80,
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(3),
                                                                border: Border.all(color: Theme.of(context).hintColor, width: 1),
                                                              ),
                                                              child: swapperSearchTextController.text.isEmpty && availableWeaponCsvData[i].iconImageWebPath.isNotEmpty
                                                                  ? Image.network(
                                                                      '$modManMAIconDatabaseLink${availableWeaponCsvData[i].iconImageWebPath.replaceAll('\\', '/').replaceAll(' ', '%20')}',
                                                                      errorBuilder: (context, error, stackTrace) => Image.asset(
                                                                        'assets/img/placeholdersquare.png',
                                                                        filterQuality: FilterQuality.none,
                                                                        fit: BoxFit.fitWidth,
                                                                      ),
                                                                      filterQuality: FilterQuality.none,
                                                                      fit: BoxFit.fitWidth,
                                                                    )
                                                                  : swapperSearchTextController.text.isNotEmpty && toItemSearchResults[i].iconImageWebPath.isNotEmpty
                                                                      ? Image.network(
                                                                          '$modManMAIconDatabaseLink${toItemSearchResults[i].iconImageWebPath.replaceAll('\\', '/').replaceAll(' ', '%20')}',
                                                                          errorBuilder: (context, error, stackTrace) => Image.asset(
                                                                            'assets/img/placeholdersquare.png',
                                                                            filterQuality: FilterQuality.none,
                                                                            fit: BoxFit.fitWidth,
                                                                          ),
                                                                          filterQuality: FilterQuality.none,
                                                                          fit: BoxFit.fitWidth,
                                                                        )
                                                                      : Image.asset(
                                                                          'assets/img/placeholdersquare.png',
                                                                          filterQuality: FilterQuality.none,
                                                                          fit: BoxFit.fitWidth,
                                                                        ),
                                                            ),
                                                          ),
                                                          //name
                                                          modManCurActiveItemNameLanguage == 'JP'
                                                              ? swapperSearchTextController.text.isEmpty
                                                                  ? Text(availableWeaponCsvData[i].jpName.isNotEmpty
                                                                      ? availableWeaponCsvData[i].jpName.trim()
                                                                      : p.basenameWithoutExtension(availableWeaponCsvData[i].icePath))
                                                                  : Text(toItemSearchResults[i].jpName.isNotEmpty
                                                                      ? toItemSearchResults[i].jpName.trim()
                                                                      : p.basenameWithoutExtension(toItemSearchResults[i].icePath))
                                                              : swapperSearchTextController.text.isEmpty
                                                                  ? Text(availableWeaponCsvData[i].enName.isNotEmpty
                                                                      ? availableWeaponCsvData[i].enName.trim()
                                                                      : p.basenameWithoutExtension(availableWeaponCsvData[i].icePath))
                                                                  : Text(toItemSearchResults[i].enName.isNotEmpty
                                                                      ? toItemSearchResults[i].enName.trim()
                                                                      : p.basenameWithoutExtension(toItemSearchResults[i].icePath)),
                                                        ]),
                                                        subtitle: swapperSearchTextController.text.isEmpty
                                                            ? Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  for (int j = 0; j < availableWeaponCsvData[i].getDetailedList().length; j++) Text(availableWeaponCsvData[i].getDetailedList()[j])
                                                                ],
                                                              )
                                                            : Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [for (int j = 0; j < toItemSearchResults[i].getDetailedList().length; j++) Text(toItemSearchResults[i].getDetailedList()[j])],
                                                              ),
                                                        onChanged: (CsvWeaponIceFile? currentItem) {
                                                          //print("Current ${moddedItemsList[i].groupName}");
                                                          selectedToCsvFile = currentItem!;
                                                          toItemName = modManCurActiveItemNameLanguage == 'JP' ? selectedToCsvFile!.jpName : selectedToCsvFile!.enName;
                                                          if (toItemName.isEmpty) toItemName = p.basenameWithoutExtension(selectedToCsvFile!.icePath);
                                                          // toItemIds = [selectedToCsvFile!.id.toString(), selectedToCsvFile!.adjustedId.toString()];
                                                          if (fromItemAvailableIce.isNotEmpty) {
                                                            toItemAvailableIce = '';
                                                            // List<String> selectedToItemIceList = selectedToCsvFile!.getDetailedList();
                                                            // for (var line in selectedToItemIceList) {
                                                            //   if (fromItemAvailableIce.where((element) => element.split(': ').first == line.split(': ').first).isNotEmpty) {
                                                            //     toItemAvailableIce.add(line);
                                                            //   }

                                                            //   if (isReplacingNQWithHQ && line.split(': ').first.contains('Normal Quality')) {
                                                            //     toItemAvailableIce.add(line);
                                                            //   }
                                                            // }
                                                            toItemAvailableIce = currentItem.iceName;
                                                          }
                                                          //confirm icon set
                                                          toItemIconLink = '$modManMAIconDatabaseLink${currentItem.iconImageWebPath.replaceAll('\\', '/').replaceAll(' ', '%20')}';

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
                                    selectedFromCsvFile = null;
                                    selectedToCsvFile = null;
                                    fromItemAvailableIce = '';
                                    toItemAvailableIce = '';
                                    csvWeaponsData.clear();
                                    availableWeaponCsvData.clear();
                                    toItemSearchResults.clear();
                                    dropDownSelectedWeaponType = weaponTypes.first;
                                    dropDownSelectedItemType = itemTypes.first;
                                    dropDownSelectedItemVar = itemVars.first;
                                    Navigator.pop(context);
                                  },
                                  child: Text(curLangText!.uiClose)),
                              ElevatedButton(
                                  onPressed: selectedFromCsvFile == null || selectedToCsvFile == null
                                      ? null
                                      : () {
                                          if (selectedFromCsvFile != null && selectedToCsvFile != null) {
                                            swapperConfirmDialog(context, widget.fromSubmod, fromItemAvailableIce, toItemAvailableIce);
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

Future<void> swapperConfirmDialog(context, SubMod fromSubmod, String fromItemAvailableIce, String toItemAvailableIce) async {
  await showDialog(
      barrierDismissible: true,
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
                    Expanded(
                        flex: 1,
                        child: Center(
                            child: Column(children: [
                          Text(fromSubmod.itemName.characters.first == '_' ? fromSubmod.itemName.replaceFirst('_', '*') : fromSubmod.itemName, style: const TextStyle(fontWeight: FontWeight.w700)),
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(color: Theme.of(context).hintColor, width: 1),
                                ),
                                child: Image.network(
                                  fromItemIconLink,
                                  errorBuilder: (context, error, stackTrace) => Image.asset(
                                    'assets/img/placeholdersquare.png',
                                    filterQuality: FilterQuality.none,
                                    fit: BoxFit.fitWidth,
                                  ),
                                  filterQuality: FilterQuality.none,
                                  fit: BoxFit.fitWidth,
                                )),
                          ),
                        ]))),
                    Expanded(
                        flex: 1,
                        child: Center(
                            child: Column(children: [
                          Text(toItemName, style: const TextStyle(fontWeight: FontWeight.w700)),
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(color: Theme.of(context).hintColor, width: 1),
                                ),
                                child: Image.network(
                                  toItemIconLink,
                                  errorBuilder: (context, error, stackTrace) => Image.asset(
                                    'assets/img/placeholdersquare.png',
                                    filterQuality: FilterQuality.none,
                                    fit: BoxFit.fitWidth,
                                  ),
                                  filterQuality: FilterQuality.none,
                                  fit: BoxFit.fitWidth,
                                )),
                          ),
                        ]))),
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
                            child: Padding(padding: const EdgeInsets.all(5.0), child: Text(fromItemAvailableIce)),
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
                            child: Padding(padding: const EdgeInsets.all(5.0), child: Text(toItemAvailableIce)),
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
                        swapperWpSwappingDialog(context, fromSubmod, fromItemAvailableIce, toItemAvailableIce, toItemName);
                      },
                      child: Text(curLangText!.uiSwap))
                ]);
          }));
}

Future<void> swapperWpSwappingDialog(context, SubMod fromSubmod, String fromItemAvailableIce, String toItemAvailableIce, String toItemName) async {
  String swappedModPath = '';
  await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                contentPadding: const EdgeInsets.all(16),
                content: FutureBuilder(
                    future: swappedModPath.isEmpty ? modsSwapperWpSwap(context, fromSubmod, fromItemAvailableIce, toItemAvailableIce, toItemName) : null,
                    builder: (
                      BuildContext context,
                      AsyncSnapshot snapshot,
                    ) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          width: 250,
                          height: 250,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  curLangText!.uiSwappingItem,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const CircularProgressIndicator(),
                              ],
                            ),
                          ),
                        );
                      } else {
                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  curLangText!.uiErrorWhenSwapping,
                                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                  child: Text(snapshot.error.toString(), softWrap: true, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15)),
                                ),
                                ElevatedButton(
                                    child: Text(curLangText!.uiReturn),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    }),
                              ],
                            ),
                          );
                        } else if (!snapshot.hasData) {
                          return SizedBox(
                            width: 250,
                            height: 250,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    curLangText!.uiSwappingItem,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  const CircularProgressIndicator(),
                                ],
                              ),
                            ),
                          );
                        } else {
                          swappedModPath = snapshot.data;
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    swappedModPath.contains(modManSwapperOutputDirPath) ? curLangText!.uiSuccessfullySwapped : curLangText!.uiFailedToSwap,
                                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                child: swappedModPath.contains(modManSwapperOutputDirPath)
                                    ? Row(
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
                                                    Text(
                                                      fromSubmod.itemName,
                                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                                    ),
                                                    if (!fromSubmod.modName.contains('_${curLangText!.uiSwap}') && !fromSubmod.submodName.contains('_${curLangText!.uiSwap}'))
                                                      Text('${fromSubmod.modName} > ${fromSubmod.submodName}'),
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
                                                  children: [
                                                    Text(
                                                      toItemName,
                                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                                    ),
                                                    Text('${fromSubmod.modName} > ${fromSubmod.submodName}'),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    : ScrollbarTheme(
                                        data: ScrollbarThemeData(
                                          thumbColor: WidgetStateProperty.resolveWith((states) {
                                            if (states.contains(WidgetState.hovered)) {
                                              return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.7);
                                            }
                                            return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5);
                                          }),
                                        ),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 10),
                                                child: Text(
                                                  curLangText!.uiUnableToSwapTheseFilesBelow,
                                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              Text(swappedModPath)
                                            ],
                                          ),
                                        ),
                                      ),
                              ),
                              Container(
                                constraints: const BoxConstraints(minWidth: 450),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Wrap(
                                      runAlignment: WrapAlignment.center,
                                      alignment: WrapAlignment.center,
                                      spacing: 5,
                                      children: [
                                        ElevatedButton(
                                            child: Text(curLangText!.uiReturn),
                                            onPressed: () {
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
                                              Navigator.pop(context);
                                            }),
                                        ElevatedButton(
                                            onPressed: !swappedModPath.contains(modManSwapperOutputDirPath)
                                                ? null
                                                : () async {
                                                    await launchUrl(Uri.file(swappedModPath));
                                                  },
                                            child: Text('${curLangText!.uiOpen} ${curLangText!.uiInFileExplorer}')),
                                        ElevatedButton(
                                            onPressed: !swappedModPath.contains(modManSwapperOutputDirPath)
                                                ? null
                                                : () {
                                                    // newModDragDropList.add(XFile(Uri.file('$swappedModPath/${fromSubmod.modName}').toFilePath()));
                                                    // newModMainFolderList.add(XFile(Uri.file('$swappedModPath/${fromSubmod.modName}').toFilePath()));
                                                    // modAddHandler(context);
                                                    modAdderDragDropFiles
                                                        .add(XFile(Uri.file('$swappedModPath/${fromSubmod.modName.replaceAll(RegExp(charToReplaceWithoutSeparators), '_')}').toFilePath()));
                                                    modsAdderHomePage(context);
                                                  },
                                            child: Text(curLangText!.uiAddToModManager))
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          );
                        }
                      }
                    }));
          }));
}

Future<String> modsSwapperWpSwap(context, SubMod fromSubmod, String fromItemAvailableIce, String toItemAvailableIce, String toItemName) async {
  //clean
  if (Directory(modManSwapperOutputDirPath).existsSync()) {
    Directory(modManSwapperOutputDirPath).deleteSync(recursive: true);
  }
  //create
  Directory(modManSwapperFromItemDirPath).createSync(recursive: true);
  Directory(modManSwapperToItemDirPath).createSync(recursive: true);
  Directory(modManSwapperOutputDirPath).createSync(recursive: true);
  String renamedItemPath = Uri.file('$modManSwapperOutputDirPath/$toItemName').toFilePath();
  for (var modFile in fromSubmod.modFiles) {
    File curFile = File(modFile.location);
    if (fromItemAvailableIce == modFile.modFileName && curFile.existsSync()) {
      toItemName = toItemName.replaceAll(RegExp(charToReplace), '_').trim();
      String packDirPath = '';
      if (fromSubmod.modName == fromSubmod.submodName) {
        packDirPath = Uri.file('$modManSwapperOutputDirPath/$toItemName/${fromSubmod.modName.replaceAll(RegExp(charToReplace), '_')}').toFilePath();
      } else {
        packDirPath = Uri.file('$modManSwapperOutputDirPath/$toItemName/${fromSubmod.modName}/${fromSubmod.submodName.replaceAll(' > ', '/').replaceAll(RegExp(charToReplaceWithoutSeparators), '_')}')
            .toFilePath();
      }
      Directory(packDirPath).createSync(recursive: true);
      await curFile.copy(Uri.file('$packDirPath/$toItemAvailableIce').toFilePath());

      //image
      for (var imagePath in fromSubmod.previewImages) {
        if (Directory(packDirPath).listSync().whereType<File>().where((element) => p.basename(element.path) == p.basename(imagePath)).isEmpty) {
          File(imagePath).copySync(Uri.file('$packDirPath/${p.basename(imagePath)}').toFilePath());
        }
      }
      //video
      for (var videoPath in fromSubmod.previewVideos) {
        if (Directory(packDirPath).listSync().whereType<File>().where((element) => p.basename(element.path) == p.basename(videoPath)).isEmpty) {
          File(videoPath).copySync(Uri.file('$packDirPath/${p.basename(videoPath)}').toFilePath());
        }
      }
    }
  }

  return renamedItemPath;
}
