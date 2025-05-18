import 'dart:convert';
import 'dart:io';

import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/cml/cml_class.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_add/item_data_class.dart';
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/mod_apply/item_icon_mark.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';

File makerIceFile = File('$pso2DataDirPath${p.separator}win32${p.separator}1c5f7a7fbcdd873336048eaf6e26cd87');

Future<List<Cml>> cmlItemsLoad() async {
  File jsonFile = File(mainCmlItemListJsonPath);
  if (!jsonFile.existsSync()) await jsonFile.create();

  List<Cml> cmlList = [];
  String dataFromJson = await jsonFile.readAsString();
  if (dataFromJson.isNotEmpty) {
    var jsonData = await jsonDecode(dataFromJson);
    for (var item in jsonData) {
      cmlList.add(Cml.fromJson(item));
    }
  }

  List<ItemData> newItemList = pItemData.where((e) => e.category == defaultCategoryDirs[1] && (e.getName().contains('[To]'))).toList();
  newItemList.removeWhere((e) => cmlList.indexWhere((i) => i.id == e.getItemID() && i.aId == e.getItemAdjustedID()) != -1);
  for (var data in newItemList) {
    cmlList.add(Cml().fromItemData(data));
  }

  return cmlList;
}

void saveMasterCmlItemListToJson() {
  //Save to json
  masterCMLItemList.map((item) => item.toJson()).toList();
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  File(mainCmlItemListJsonPath).writeAsStringSync(encoder.convert(masterCMLItemList));
}

Future<bool> cmlFileReplacement(Cml cmlItem, File cmlReplacementFile) async {
  if (Directory('$modCMLReplaceTempDirPath${p.separator}replace').existsSync()) Directory('$modCMLReplaceTempDirPath${p.separator}replace').deleteSync(recursive: true);
  await Directory('$modCMLReplaceTempDirPath${p.separator}replace').create(recursive: true);
  if (makerIceFile.existsSync()) {
    await Process.run('$zamboniExePath -outdir "$modCMLReplaceTempDirPath${p.separator}replace"', [makerIceFile.path]);
    final extractedIcePath = '$modCMLReplaceTempDirPath${p.separator}replace${p.separator}${p.basenameWithoutExtension(makerIceFile.path)}_ext${p.separator}group1';
    if (Directory(extractedIcePath).existsSync()) {
      File cmlFile = File('$extractedIcePath${p.separator}pl_cp_${cmlItem.aId}.cml');
      if (cmlFile.existsSync()) await cmlFile.delete();
      File copiedFile = await cmlReplacementFile.copy(p.dirname(cmlFile.path) + p.separator + p.basename(cmlReplacementFile.path));
      File renamedFile = await copiedFile.rename(cmlFile.path);
      if (renamedFile.existsSync()) {
        // pack
        await Process.run('$zamboniExePath -c -pack -outdir "$modCMLReplaceTempDirPath${p.separator}replace"',
            ['$modCMLReplaceTempDirPath${p.separator}replace${p.separator}${p.basenameWithoutExtension(makerIceFile.path)}_ext']);
        File packedIceFile = File('$modCMLReplaceTempDirPath${p.separator}replace${p.separator}${p.basenameWithoutExtension(makerIceFile.path)}_ext.ice');
        if (packedIceFile.existsSync()) {
          File renamedIceFile = await packedIceFile.rename('$modCMLReplaceTempDirPath${p.separator}replace${p.separator}${p.basenameWithoutExtension(makerIceFile.path)}');
          renamedIceFile.copy(makerIceFile.path);
          if (replaceItemIconOnApplied && !cmlItem.itemIconReplaced) {
            cmlItem.itemIconReplaced = await markedAqmItemIconApply(cmlItem.itemIconWebPath);
          }
        }

        return true;
      }
    }
  }

  return false;
}
