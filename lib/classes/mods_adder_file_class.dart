import 'dart:io';

class ModsAdderItem {
  ModsAdderItem(this.category, this.itemName, this.itemDirPath, this.itemIconPath, this.isUnknown, this.toBeAdded, this.isChildrenDuplicated, this.modList);

  String category;
  String itemName;
  String itemDirPath;
  String itemIconPath;
  bool isUnknown;
  bool toBeAdded;
  bool isChildrenDuplicated;
  List<ModsAdderMod> modList;

  void setNewParentPathToChildren(String newParentPath) {
    for (var mod in modList) {
      String oldModDirPath = mod.modDirPath;
      mod.modDirPath = mod.modDirPath.replaceFirst(itemDirPath, newParentPath);
      //files in mod
      mod.filesInMod = Directory(mod.modDirPath).listSync().whereType<File>().toList();
      //submods
      for (var submod in mod.submodList) {
        submod.submodDirPath = submod.submodDirPath.replaceFirst(oldModDirPath, mod.modDirPath);
        //files in submod
        submod.files = Directory(submod.submodDirPath).listSync(recursive: true).whereType<File>().toList();
      }
    }
  }
}

class ModsAdderMod {
  ModsAdderMod(this.modName, this.modDirPath, this.toBeAdded, this.isChildrenDuplicated, this.isDuplicated, this.submodList, this.filesInMod);

  String modName;
  String modDirPath;
  bool toBeAdded;
  bool isChildrenDuplicated;
  bool isDuplicated;
  List<ModsAdderSubMod> submodList;
  List<File> filesInMod;

  void setNewParentPathToChildren(String newParentPath) {
    filesInMod = Directory(newParentPath).listSync().whereType<File>().toList();
    for (var submod in submodList) {
      submod.submodDirPath = submod.submodDirPath.replaceFirst(modDirPath, newParentPath);
    }
  }
}

class ModsAdderSubMod {
  ModsAdderSubMod(this.submodName, this.submodDirPath, this.toBeAdded, this.isDuplicated, this.files);

  String submodName;
  String submodDirPath;
  bool toBeAdded;
  bool isDuplicated;
  List<File> files;
}
