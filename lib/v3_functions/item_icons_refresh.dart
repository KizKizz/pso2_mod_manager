import 'dart:io';

import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:signals/signals_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

Future<bool> itemIconsRefresh(Signal<String> status) async {
  await Future.delayed(const Duration(microseconds: 100));
  for (var cateType in masterModList) {
    for (var category in cateType.categories.where((e) => markIconCategoryDirs.contains(e.categoryName))) {
      for (var item in category.items.where((e) => e.icons.isEmpty)) {
        status.value = '${appText.categoryName(category.categoryName)} > ${item.itemName}';
        await Future.delayed(const Duration(microseconds: 10));
        final modFileNames = item.getDistinctModFilePaths().map((e) => p.basenameWithoutExtension(e)).toList();
        final matchingItemData = pItemData.where((e) => e.containsIceFiles(modFileNames));
        for (var data in matchingItemData) {
          if (data.iconImagePath.isNotEmpty) {
            status.value = '${appText.categoryName(category.categoryName)} > ${item.itemName}: ${p.basename(data.iconImagePath)}';
            final response = await http.get(Uri.parse('https://raw.githubusercontent.com/KizKizz/pso2ngs_file_downloader/main${data.iconImagePath}'));
            if (response.statusCode == 200) {
              File newIconImageFile = File(item.location + p.separator + p.basename(data.iconImagePath));
              await newIconImageFile.writeAsBytes(response.bodyBytes);
              if (await newIconImageFile.exists() && !item.icons.contains(newIconImageFile.path)) item.icons.add(newIconImageFile.path);
            }
          }
        }
      }
    }
  }
  return true;
}
