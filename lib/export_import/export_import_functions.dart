import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/export_import/new_set_name_popup.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:signals/signals_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:io/io.dart' as io;

Signal<String> exportStatus = Signal('');

Future<File?> singleModExportSequence(context, String categoryName, Item item, Mod mod, SubMod submod) async {
  String exportFileName = await exportModNamePopup(context);
  return await modExportFunction(exportFileName, categoryName, item, mod, submod);
}

Future<File?> modExportFunction(String exportFileName, String categoryName, Item item, Mod mod, SubMod submod) async {
  String exportedPath = exportedModsDirPath +
      p.separator +
      exportFileName +
      p.separator +
      categoryName +
      p.separator +
      p.basenameWithoutExtension(item.location) +
      p.separator +
      p.basenameWithoutExtension(mod.location) +
      p.separator +
      p.basenameWithoutExtension(submod.location);

  await io.copyPath(submod.location, exportedPath);
  if (Directory(exportedPath).existsSync()) {
    //zip
    var encoder = ZipFileEncoder();
    await encoder.zipDirectory(Directory('$exportedModsDirPath${p.separator}$exportFileName'));
    String zipFilePath = '$exportedModsDirPath${p.separator}$exportFileName.zip';
    if (File(zipFilePath).existsSync()) {
      Directory('$exportedModsDirPath${p.separator}$exportFileName').deleteSync(recursive: true);
      File renamedFile = await File(zipFilePath).rename('${p.withoutExtension(zipFilePath)}.pmm');
      return renamedFile;
    }
  }

  return null;
}
