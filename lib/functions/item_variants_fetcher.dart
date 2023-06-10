import 'package:pso2_mod_manager/classes/mod_class.dart';
import 'package:pso2_mod_manager/functions/csv_list_fetcher.dart';
import 'package:pso2_mod_manager/functions/item_icons_fetcher.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';

Future<List<String>> itemVariantsFetch(List<Mod> modList, String itemName) async {
  //load sheets
  if (itemIconRefSheetsList.isEmpty) {
    itemIconRefSheetsList = await itemCsvFetcher(modManRefSheetsDirPath);
  }

  List<String> modFileNamesFromMods = [];
  for (var element in modList) {
    modFileNamesFromMods.addAll(element.getModFileNames());
  }
  List<String> itemVariantCsvInfos = [];
  for (var modFileName in modFileNamesFromMods) {
    itemVariantCsvInfos.addAll(itemIconRefSheetsList.where((element) => !itemVariantCsvInfos.contains(element) && element.contains(modFileName)));
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
        itemVariantNames.add(lineSplit[2]);
      }
    }
  }
  //print(itemVariantNames);

  return itemVariantNames;
}
