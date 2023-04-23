import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:pso2_mod_manager/functions/item_icons_fetcher.dart';
import 'package:pso2_mod_manager/item_ref.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

List<String> _cateToIgnoreScan = ['Emotes', 'Motions'];

Future<bool> itemIconsLoader() async {
  itemRefSheetsList = await popSheetsList(modManRefSheetsDirPath);
  if (itemRefSheetsList.isNotEmpty) {
    for (var cateDir in Directory(modManModsDirPath).listSync(recursive: false)) {
      if (!_cateToIgnoreScan.contains(XFile(cateDir.path).name)) {
        for (var itemDir in Directory(cateDir.path).listSync(recursive: false)) {
          final filesInItemDir = Directory(itemDir.path).listSync(recursive: false).whereType<File>();
          final imgFilesInItemDir = filesInItemDir.where((element) => p.extension(element.path) == '.png' || p.extension(element.path) == '.jpg');
          if (filesInItemDir.isEmpty || imgFilesInItemDir.isEmpty) {
            final iceFile = Directory(itemDir.path).listSync(recursive: true).whereType<File>().firstWhere((element) => p.extension(element.path) == '');
            if (iceFile.path.isNotEmpty) {
              List<String> infoString = await findItemInCsv(XFile(iceFile.path));
              if (infoString.isNotEmpty && infoString[3].isNotEmpty) {
                await File(infoString[3]).copy(Uri.file('${itemDir.path}/${XFile(infoString[3]).name}').toFilePath());
              }
            } else {
              break;
            }
            //print(infoString);
          }
        }
      }
    }
    Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
      element.deleteSync(recursive: true);
    });
  }
  //setState(() {
  itemRefSheetsList.clear();
  //context.read<StateProvider>().listDataCheckTrue();
  //});

  return true;
}
