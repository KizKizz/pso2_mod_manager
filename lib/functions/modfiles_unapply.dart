import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/functions/unapply_mods.dart';

Future<List<ModFile>> modFilesUnapply(context, List<ModFile> modFiles) async {
  //apply mods
  List<ModFile> unappliedModFiles = [];
  for (var modFile in modFiles) {
    modFile = await modFileUnapply(modFile);
    modFile.ogMd5s.clear();
    modFile.bkLocations.clear();
    modFile.ogLocations.clear();
    modFile.applyDate = DateTime(0);
    modFile.applyStatus = false;
    unappliedModFiles.add(modFile);
  }

  return unappliedModFiles;
}


