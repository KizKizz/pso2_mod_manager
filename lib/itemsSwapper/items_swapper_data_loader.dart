
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/classes/csv_ice_file_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/itemsSwapper/items_swapper_acc_homepage.dart';
import 'package:pso2_mod_manager/itemsSwapper/items_swapper_homepage.dart';
import 'package:pso2_mod_manager/itemsSwapper/items_swapper_la_homepage.dart';
import 'package:pso2_mod_manager/itemsSwapper/items_swapper_popup.dart';
import 'package:pso2_mod_manager/itemsSwapper/items_swapper_wp_homepage.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_data_loader.dart' as ms;

SubMod fromItemSubmodGet(List<String> iceFileNames) {
  List<ModFile> modFileList = [];
  String fromItemNameSwap = modManCurActiveItemNameLanguage == 'JP' ? '${fromItemName.replaceAll('/', '_')}_${curLangText!.uiSwap}' : '${fromItemName.replaceAll('/', '_')}_${curLangText!.uiSwap}';
  for (var iceNameWithType in iceFileNames) {
    String iceName = iceNameWithType.split(': ').last;

    //look in backupDir first
    // final iceFileInBackupDir =
    //     Directory(Uri.file(modManBackupsDirPath).toFilePath()).listSync(recursive: true).whereType<File>().firstWhere((element) => p.extension(element.path) == '', orElse: () => File(''));
    // if (p.basename(iceFileInBackupDir.path) == iceName) {
    //   modFileList
    //       .add(ModFile(iceName, fromItemNameSwap, fromItemNameSwap, fromItemNameSwap, selectedCategoryF!, '', [], iceFileInBackupDir.path, false, DateTime(0), 0, false, false, false, [], [], []));
    // } else {
    for (var type in ogDataFilePaths) {
      String icePathFromOgData = type.firstWhere(
        (element) => p.basename(element) == iceName,
        orElse: () => '',
      );
      if (p.basename(icePathFromOgData) == iceName) {
        modFileList.add(ModFile(iceName, fromItemNameSwap, fromItemNameSwap, fromItemNameSwap, selectedCategoryF!, '', [], icePathFromOgData, false, DateTime(0), 0, false, false, false, [], [], [], []));
      }
    }
    //}
  }

  return SubMod(fromItemNameSwap, fromItemNameSwap, fromItemName, selectedCategoryF!, '', false, DateTime(0), 0, false, false, false, false, false, -1, -1, '', [], [], [], [], [], modFileList);
}

Future<List<CsvAccessoryIceFile>> getAccSwapToCsvList(List<CsvAccessoryIceFile> cvsAccDataInput, String category) async {
  return cvsAccDataInput.where((element) => element.category == category && element.enName.isNotEmpty && element.jpName.isNotEmpty).toList();
}

Future<List<CsvEmoteIceFile>> getEmotesSwapToCsvList(List<CsvEmoteIceFile> cvsEmoteDataInput, String category) async {
  return cvsEmoteDataInput.where((element) => element.category == category && element.enName.isNotEmpty && element.jpName.isNotEmpty).toList();
}

Future<List<CsvEmoteIceFile>> getEmotesToMotionsSwapToCsvList(List<CsvEmoteIceFile> cvsEmoteDataInput, String itemCategory) async {
  return cvsEmoteDataInput.where((element) => element.category == itemCategory).toList();
}

Future<List<CsvWeaponIceFile>> getWeaponsSwapToCsvList(List<CsvWeaponIceFile> cvsWeaponDataInput, String swapFromItemCategory) async {
  return cvsWeaponDataInput.where((element) => element.category == swapFromItemCategory).toList();
}

class ItemsSwapperDataLoader extends StatefulWidget {
  const ItemsSwapperDataLoader({super.key});

  @override
  State<ItemsSwapperDataLoader> createState() => _ItemsSwapperDataLoaderState();
}

class _ItemsSwapperDataLoaderState extends State<ItemsSwapperDataLoader> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: csvData.isEmpty && csvAccData.isEmpty && csvEmotesData.isEmpty && csvWeaponsData.isEmpty ? ms.sheetListFetchFromFiles(context, selectedCategoryF!, []) : null,
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
              Item fromItem = Item('', [], [], '', '', '', false, selectedCategoryF!, '', false, DateTime(0), 0, false, false, false, [], []);
              return FutureBuilder(
                  future: availableItemsCsvData.isEmpty && csvData.isNotEmpty
                      ? ms.getSwapToCsvList(csvData, fromItem.category)
                      : availableAccCsvData.isEmpty && csvAccData.isNotEmpty
                          ? getAccSwapToCsvList(csvAccData, selectedCategoryF!)
                          : availableEmotesCsvData.isEmpty && csvEmotesData.isNotEmpty
                              ? getEmotesSwapToCsvList(csvEmotesData, selectedCategoryF!)
                              : availableWeaponCsvData.isEmpty && csvWeaponsData.isNotEmpty
                                  ? getWeaponsSwapToCsvList(csvWeaponsData, selectedCategoryF!)
                                  : null,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting && (availableItemsCsvData.isEmpty || availableAccCsvData.isEmpty)) {
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
                          return const ItemsSwapperAccHomePage();
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
                          return const ItemsSwapperEmotesHomePage();
                        } else if (csvWeaponsData.isNotEmpty) {
                          availableWeaponCsvData = snapshot.data;
                          // if (modManCurActiveItemNameLanguage == 'JP') {
                          //   availableWeaponCsvData.sort(
                          //     (a, b) => a.jpName.compareTo(b.jpName),
                          //   );
                          // } else {
                          //   availableWeaponCsvData.sort(
                          //     (a, b) => a.enName.compareTo(b.enName),
                          //   );
                          // }
                          return const ItemsSwapperWeaponHomePage(
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
                          return const ItemsSwapperHomePage();
                        }
                      }
                    }
                  });
            }
          }
        });
  }
}
