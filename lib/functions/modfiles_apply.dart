import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/functions/mod_file_restore.dart';
import 'package:pso2_mod_manager/global_variables.dart';

Future<List<ModFile>> modFilesApply(List<ModFile> modFiles) async {
  List<ModFile> alreadyAppliedModFiles = [];
  //check for applied file
  for (var modFile in modFiles) {
    if (!modFile.applyStatus) {
      ModFile? appliedFile = await modFileRestore(moddedItemsList, modFile);
      if (appliedFile != null) {
        alreadyAppliedModFiles.add(appliedFile);
      }
    }
  }
  if (alreadyAppliedModFiles.isNotEmpty) {}

  return modFiles;
}
