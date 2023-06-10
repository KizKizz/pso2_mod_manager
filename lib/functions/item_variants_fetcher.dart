import 'package:pso2_mod_manager/classes/mod_class.dart';
import 'package:pso2_mod_manager/functions/csv_list_fetcher.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';

Future<List<String>> itemVariantsFetch(List<Mod> modList, String category, String itemName) async {
  //load sheets
  if (csvInfosFromSheets.isEmpty) {
    csvInfosFromSheets = await itemCsvFetcher(modManRefSheetsDirPath);
  }

  List<String> partsToRemove = ['[Ba]', '[Se]', '[In]', '[Ou]', '[Fu]'];

  List<String> modFileNamesFromMods = [];
  for (var element in modList) {
    modFileNamesFromMods.addAll(element.getModFileNames());
  }
  List<String> itemVariantCsvInfos = [];
  for (var modFileName in modFileNamesFromMods) {
    int defaultCateIndex = defaultCateforyDirs.indexOf(category);
    if (defaultCateIndex != -1) {
      itemVariantCsvInfos.addAll(csvInfosFromSheets[defaultCateIndex].where((element) => !itemVariantCsvInfos.contains(element) && element.contains(modFileName)));
    }
  }
  List<String> itemVariantNames = [];
  for (var line in itemVariantCsvInfos) {
    final lineSplit = line.split(',');
    if (curActiveLang == 'JP') {
      if (itemName.replaceAll('_', '/') != lineSplit[1]) {
        itemVariantNames.add(lineSplit[1]);
      }
    } else {
      if (itemName.replaceAll('_', '/') != lineSplit[2]) {
        String itemNameNoAffix = itemName.replaceAll('_', '/');
        String itemToAdd = lineSplit[2];
        for (var affix in partsToRemove) {
          itemNameNoAffix = itemNameNoAffix.replaceAll(affix, '').trim();
          itemToAdd = itemToAdd.replaceAll(affix, '').trim();
        }
        itemToAdd = itemToAdd.replaceFirst(itemNameNoAffix, '').trim();
        itemVariantNames.add(itemToAdd);
      }
    }
  }
  //print(itemVariantNames);

  return itemVariantNames;
}
