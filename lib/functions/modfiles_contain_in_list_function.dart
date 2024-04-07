import 'package:pso2_mod_manager/classes/mod_file_class.dart';

bool modFilesInList(List<ModFile> list, List<ModFile> modFiles) {
  if (list.isEmpty || modFiles.isEmpty) {
    return false;
  }
  for (var modFile in modFiles) {
    if (list.where((element) => element.location == modFile.location).isNotEmpty) {
      return true;
    }
  }

  return false;
}
