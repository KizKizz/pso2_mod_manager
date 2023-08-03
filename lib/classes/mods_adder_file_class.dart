class ModsAdderFile {
  ModsAdderFile(this.category, this.itemName, this.modName, this.submodName, this.itemIconPath, this.filePaths, this.filesToAddPaths, this.isUnknown);

  String category;
  String itemName;
  String modName;
  String submodName;
  String itemIconPath;
  List<String> filePaths;
  List<String> filesToAddPaths;
  bool isUnknown;
}
