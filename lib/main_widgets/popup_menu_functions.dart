import 'dart:io';

import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_data/load_mods.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/v3_widgets/rename_popup.dart';
import 'package:path/path.dart' as p;
import 'package:io/io.dart' as io;

Future<void> submodRename(context, Mod mod, SubMod submod) async {
  String? newName = await renamePopup(context, p.dirname(submod.location), submod.submodName);
  if (newName != null) {
    if (p.isWithin(mod.location, submod.location)) {
      String newPath = p.dirname(submod.location) + p.separator + newName;
      await io.copyPath(submod.location, newPath);
      await Directory(submod.location).delete(recursive: true);
      submod.submodName = newName;
      for (var modFile in submod.modFiles) {
        modFile.submodName = newName;
        modFile.location = modFile.location.replaceFirst(submod.location, newPath);
      }
      submod.location = newPath;
    } else {
      String newPath = p.dirname(mod.location) + p.separator + newName;
      await io.copyPath(mod.location, newPath);
      await Directory(mod.location).delete(recursive: true);
      mod.modName = newName;
      submod.submodName = newName;
      for (var modFile in submod.modFiles) {
        modFile.submodName = newName;
        modFile.location = modFile.location.replaceFirst(submod.location, newPath);
      }
      for (var smod in mod.submods.where((e) => p.isWithin(mod.location, e.location))) {
        for (var modFile in smod.modFiles) {
          modFile.location = modFile.location.replaceFirst(mod.location, newPath);
        }
        smod.location = smod.location.replaceFirst(mod.location, newPath);
      }

      mod.location = newPath;
      submod.location = newPath;
    }
    saveMasterModListToJson();
    modPopupStatus.value = newName;
  }
}
