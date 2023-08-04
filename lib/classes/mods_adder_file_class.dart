import 'dart:io';

class ModsAdderItem {
  ModsAdderItem(this.category, this.itemName, this.itemDirPath, this.itemIconPath, this.isUnknown, this.toBeAdded, this.modList);

  String category;
  String itemName;
  String itemDirPath;
  String itemIconPath;
  bool isUnknown;
  bool toBeAdded;
  List<ModsAdderMod> modList;
}

class ModsAdderMod {
  ModsAdderMod(this.modName, this.modDirPath, this.toBeAdded, this.submodList, this.filesInMod);

  String modName;
  String modDirPath;
  bool toBeAdded;
  List<ModsAdderSubMod> submodList;
  List<File> filesInMod;
}

class ModsAdderSubMod {
  ModsAdderSubMod(this.submodName, this.submodDirPath, this.toBeAdded, this.files);

  String submodName;
  String submodDirPath;
  bool toBeAdded;
  List<File> files;
}
