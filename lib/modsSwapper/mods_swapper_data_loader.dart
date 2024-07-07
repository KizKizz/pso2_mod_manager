import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/csv_ice_file_class.dart';
import 'package:pso2_mod_manager/classes/csv_item_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/functions/player_item_data.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_acc_homepage.dart';
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_homepage.dart';
// ignore: depend_on_referenced_packages
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_la_homepage.dart';
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_popup.dart';
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_wp_homepage.dart';
import 'package:pso2_mod_manager/state_provider.dart';

List<String> itemCateList = defaultCategoryDirs.toList();

Future<bool> sheetListFetchFromFiles(context, String itemCategory, List<String> modFilePaths) async {
  // List<CsvItem> playerItemData = await playerItemDataGet();
  if (playerItemData.isEmpty) playerItemDataGet(context);
  List<CsvItem> selectedPlayerItemData = playerItemData.where((element) => element.category == itemCategory).toList();
  if (itemCategory == defaultCategoryDirs[11]) {
    selectedPlayerItemData.addAll(playerItemData.where((element) => element.category == defaultCategoryDirs[2]));
  } else if (itemCategory == defaultCategoryDirs[2]) {
    selectedPlayerItemData.addAll(playerItemData.where((element) => element.category == defaultCategoryDirs[11]));
  } else if (itemCategory == defaultCategoryDirs[16]) {
    selectedPlayerItemData.addAll(playerItemData.where((element) => element.category == defaultCategoryDirs[1]));
  }
  for (var item in selectedPlayerItemData) {
    if (itemCategory == defaultCategoryDirs[0]) {
      csvAccData.add(CsvAccessoryIceFile.fromList(item.getInfos()));
    } else if (itemCategory == defaultCategoryDirs[7]) {
      if (item.getInfos().length != 16 && item.getInfos().length != 20) {
        debugPrint('${item.getInfos()[2]} _ ${item.getInfos().length}');
        //
      }
      if (item.getInfos().length == 16) {
        csvEmotesData.add(CsvEmoteIceFile.fromListNgs(item.getInfos()));
      } else if (item.getInfos().length == 20) {
        csvEmotesData.add(CsvEmoteIceFile.fromListPso2(item.getInfos()));
      }
    } else if (itemCategory == defaultCategoryDirs[14]) {
      if (item.getInfos().length == 12) {
        csvEmotesData.add(CsvEmoteIceFile.fromListMotion(item.getInfos()));
      }
    } else if (itemCategory == defaultCategoryDirs[10]) {
      csvData.add(CsvIceFile.fromListHairs(item.getInfos()));
    } else if (itemCategory == defaultCategoryDirs[12]) {
      // if (item.getInfos()[1] == 'Debug') {
      //   List<String> itemSplit = item.getInfos();
      //   itemSplit.insert(1, '');
      //   item = itemSplit.join(',');
      // }
      csvData.add(CsvIceFile.fromListMags(item.getInfos()));
    } else if (itemCategory == defaultCategoryDirs[17]) {
      csvWeaponsData.add(CsvWeaponIceFile.fromList(item.getInfoForWeapons()));
    } else if (itemCategory == defaultCategoryDirs[13]) {
      if (item.getInfos().length > 18) csvData.add(CsvIceFile.fromList(item.getInfos()));
    } else {
      csvData.add(CsvIceFile.fromList(item.getInfos()));
    }
  }

  return true;
}

Future<List<CsvIceFile>> getSwapToCsvList(List<CsvIceFile> cvsDataInput, String swapFromItemCategory) async {
  String categorySymbol = '';
  // if (swapFromItem.category == 'Basewears') {
  //   categorySymbol = '[Ba]';
  // } else if (swapFromItem.category == 'Setwears') {
  //   categorySymbol = '[Se]';
  // } else
  if (swapFromItemCategory == defaultCategoryDirs[11]) {
    categorySymbol = '[In]';
  }
  if (swapFromItemCategory == defaultCategoryDirs[12]) {
    return cvsDataInput.where((element) => element.category == swapFromItemCategory).toList();
  }
  // if (swapFromItem.category == 'Setwears') {
  //   return cvsDataInput.where((element) => element.enName.contains(categorySymbol)).toList();
  // }
  if (swapFromItemCategory == defaultCategoryDirs[16] || swapFromItemCategory == defaultCategoryDirs[1]) {
    return cvsDataInput
        .where((element) => element.enName.isNotEmpty && element.jpName.isNotEmpty && (element.enName.contains('[Ba]') || element.enName.contains('[Se]') || element.enName.contains('[Fu]')))
        .toList();
  }
  if (swapFromItemCategory == defaultCategoryDirs[11]) {
    return cvsDataInput.where((element) => element.category == swapFromItemCategory || element.category == defaultCategoryDirs[2]).toList();
  }
  if (swapFromItemCategory == defaultCategoryDirs[2]) {
    return cvsDataInput.where((element) => element.category == swapFromItemCategory || element.category == defaultCategoryDirs[11]).toList();
  }
  if (swapFromItemCategory == defaultCategoryDirs[13]) {
    return cvsDataInput.where((element) => element.category == swapFromItemCategory).toList();
  }
  if (categorySymbol.isNotEmpty) {
    return cvsDataInput.where((element) => element.category == swapFromItemCategory && element.enName.contains(categorySymbol) && element.enName.isNotEmpty && element.jpName.isNotEmpty).toList();
  } else {
    return cvsDataInput.where((element) => element.category == swapFromItemCategory && element.enName.isNotEmpty && element.jpName.isNotEmpty).toList();
  }
}

Future<List<CsvAccessoryIceFile>> getAccSwapToCsvList(List<CsvAccessoryIceFile> cvsAccDataInput, String swapFromItemCategory) async {
  return cvsAccDataInput.where((element) => element.category == swapFromItemCategory && element.enName.isNotEmpty && element.jpName.isNotEmpty).toList();
}

Future<List<CsvEmoteIceFile>> getEmotesSwapToCsvList(List<CsvEmoteIceFile> cvsEmoteDataInput, String swapFromItemCategory) async {
  return cvsEmoteDataInput.where((element) => element.category == swapFromItemCategory && element.enName.isNotEmpty && element.jpName.isNotEmpty).toList();
}

Future<List<CsvEmoteIceFile>> getEmotesToMotionsSwapToCsvList(List<CsvEmoteIceFile> cvsEmoteDataInput, String itemCategory) async {
  return cvsEmoteDataInput.where((element) => element.category == itemCategory).toList();
}

Future<List<CsvWeaponIceFile>> getWeaponsSwapToCsvList(List<CsvWeaponIceFile> cvsWeaponDataInput, String swapFromItemCategory) async {
  return cvsWeaponDataInput.where((element) => element.category == swapFromItemCategory).toList();
}

class ModsSwapperDataLoader extends StatefulWidget {
  const ModsSwapperDataLoader({super.key, required this.fromItem, required this.fromSubmod});

  final Item fromItem;
  final SubMod fromSubmod;

  @override
  State<ModsSwapperDataLoader> createState() => _ModsSwapperDataLoaderState();
}

class _ModsSwapperDataLoaderState extends State<ModsSwapperDataLoader> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: csvData.isEmpty && csvAccData.isEmpty && csvEmotesData.isEmpty && csvWeaponsData.isEmpty
            ? sheetListFetchFromFiles(context, !defaultCategoryDirs.contains(widget.fromItem.category) ? fromItemCategory : widget.fromItem.category, widget.fromSubmod.getDistinctModFilePaths())
            : null,
        builder: (
          BuildContext context,
          AsyncSnapshot snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    curLangText!.uiLoadingItemRefSheetsData,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const CircularProgressIndicator(),
                ],
              ),
            );
          } else {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      curLangText!.uiErrorWhenLoadingItemRefSheets,
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
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      curLangText!.uiLoadingItemRefSheetsData,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const CircularProgressIndicator(),
                  ],
                ),
              );
            } else {
              return FutureBuilder(
                  future: availableItemsCsvData.isEmpty && csvData.isNotEmpty
                      ? getSwapToCsvList(csvData, !defaultCategoryDirs.contains(widget.fromItem.category) ? fromItemCategory : widget.fromItem.category)
                      : availableAccCsvData.isEmpty && csvAccData.isNotEmpty
                          ? getAccSwapToCsvList(csvAccData, !defaultCategoryDirs.contains(widget.fromItem.category) ? fromItemCategory : widget.fromItem.category)
                          : availableEmotesCsvData.isEmpty && csvEmotesData.isNotEmpty
                              ? getEmotesSwapToCsvList(csvEmotesData, !defaultCategoryDirs.contains(widget.fromItem.category) ? fromItemCategory : widget.fromItem.category)
                              : availableWeaponCsvData.isEmpty && csvWeaponsData.isNotEmpty
                                  ? getWeaponsSwapToCsvList(csvWeaponsData, !defaultCategoryDirs.contains(widget.fromItem.category) ? fromItemCategory : widget.fromItem.category)
                                  : null,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting && (availableItemsCsvData.isEmpty || availableAccCsvData.isEmpty || availableWeaponCsvData.isEmpty)) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              curLangText!.uiFetchingItemInfo,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const CircularProgressIndicator(),
                          ],
                        ),
                      );
                    } else {
                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                curLangText!.uiErrorWhenFetchingItemInfo,
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
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                curLangText!.uiFetchingItemInfo,
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const CircularProgressIndicator(),
                            ],
                          ),
                        );
                      } else {
                        // swap To item list
                        if (csvAccData.isNotEmpty) {
                          availableAccCsvData = snapshot.data;
                          if (modManCurActiveItemNameLanguage == 'JP') {
                            availableAccCsvData.sort(
                              (a, b) => a.jpName.compareTo(b.jpName),
                            );
                          } else {
                            availableAccCsvData.sort(
                              (a, b) => a.enName.compareTo(b.enName),
                            );
                          }
                          return ModsSwapperAccHomePage(
                            fromItem: widget.fromItem,
                            fromSubmod: widget.fromSubmod,
                          );
                        } else if (csvEmotesData.isNotEmpty) {
                          availableEmotesCsvData = snapshot.data;
                          if (modManCurActiveItemNameLanguage == 'JP') {
                            availableEmotesCsvData.sort(
                              (a, b) => a.jpName.compareTo(b.jpName),
                            );
                          } else {
                            availableEmotesCsvData.sort(
                              (a, b) => a.enName.compareTo(b.enName),
                            );
                          }
                          return ModsSwapperEmotesHomePage(
                            fromItem: widget.fromItem,
                            fromSubmod: widget.fromSubmod,
                          );
                        } else if (csvWeaponsData.isNotEmpty) {
                          availableWeaponCsvData = snapshot.data;
                          if (modManCurActiveItemNameLanguage == 'JP') {
                            availableWeaponCsvData.sort(
                              (a, b) => a.jpName.compareTo(b.jpName),
                            );
                          } else {
                            availableWeaponCsvData.sort(
                              (a, b) => a.enName.compareTo(b.enName),
                            );
                          }
                          return ModsSwapperWeaponHomePage(
                            fromItem: widget.fromItem,
                            fromSubmod: widget.fromSubmod,
                          );
                        } else {
                          availableItemsCsvData = snapshot.data;
                          if (modManCurActiveItemNameLanguage == 'JP') {
                            availableItemsCsvData.sort(
                              (a, b) => a.jpName.compareTo(b.jpName),
                            );
                          } else {
                            availableItemsCsvData.sort(
                              (a, b) => a.enName.compareTo(b.enName),
                            );
                          }
                          return ModsSwapperHomePage(
                            fromItem: widget.fromItem,
                            fromSubmod: widget.fromSubmod,
                          );
                        }
                      }
                    }
                  });
            }
          }
        });
  }
}

Future<String> modsSwapperCategorySelect(context) async {
  String? selectedItemCategory;
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                titlePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
                title: Text(curLangText!.uiSelectACategory, style: const TextStyle(fontWeight: FontWeight.w700)),
                contentPadding: const EdgeInsets.only(left: 16, right: 16),
                content: SizedBox(
                  width: 200,
                  child: DropdownButtonHideUnderline(
                      child: DropdownButton2(
                    hint: Text(curLangText!.uiItemCategories),
                    buttonStyleData: ButtonStyleData(
                      height: 30,
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
                    items: itemCateList
                        .map((item) => DropdownMenuItem<String>(
                            value: item,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                if (curActiveLang != 'JP')
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
                                  ),
                                if (curActiveLang != 'EN')
                                  Container(
                                    padding: const EdgeInsets.only(bottom: 3),
                                    child: Text(
                                      defaultCategoryNames[itemCateList.indexOf(item)],
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
                    value: selectedItemCategory,
                    onChanged: (value) async {
                      selectedItemCategory = value.toString();

                      setState(() {});
                    },
                  )),
                ),
                actions: <Widget>[
                  ElevatedButton(
                      child: Text(curLangText!.uiReturn),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  ElevatedButton(
                      onPressed: selectedItemCategory == null
                          ? null
                          : () {
                              Navigator.pop(context, selectedItemCategory);
                            },
                      child: Text(curLangText!.uiNext))
                ]);
          }));
}
