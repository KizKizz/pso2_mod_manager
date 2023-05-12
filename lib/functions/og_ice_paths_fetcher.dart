import 'package:pso2_mod_manager/global_variables.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

List<String> ogIcePathsFetcher(String iceName) {
  List<String> ogPaths = [];
  int win32PathIndex = ogWin32FilePaths.indexWhere((element) => p.basename(element) == iceName);
  int win32NAPathIndex = ogWin32NAFilePaths.indexWhere((element) => p.basename(element) == iceName);
  List<String> win32RebootPaths = ogWin32RebootFilePaths.where((element) => p.basename(element) == iceName).toList();
  List<String> win32RebootNAPaths = ogWin32RebootNAFilePaths.where((element) => p.basename(element) == iceName).toList();
  if (win32PathIndex != -1) {
    ogPaths.add(ogWin32FilePaths[win32PathIndex]);
  }
  if (win32NAPathIndex != -1) {
    ogPaths.add(ogWin32NAFilePaths[win32NAPathIndex]);
  }
  if (win32RebootPaths.isNotEmpty) {
    ogPaths.addAll(win32RebootPaths);
  }
  if (win32RebootNAPaths.isNotEmpty) {
    ogPaths.addAll(win32RebootNAPaths);
  }

  return ogPaths;
}
