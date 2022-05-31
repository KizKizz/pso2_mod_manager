// ignore_for_file: unused_import
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:pso2_mod_manager/main.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

import 'home_page.dart';

List<FileSystemEntity> mainDataList = [];

class ModCategory {
  ModCategory(
    this.categoryName,
    this.categoryPath,
    this.itemNames,
    this.imageIcons,
    this.numOfItems,
    this.numOfMods,
    this.numOfApplied,
    this.categorySubList,
  );

  String categoryName;
  String categoryPath;
  List<String> itemNames;
  List<List<File>> imageIcons;
  int numOfItems;
  List<int> numOfMods;
  List<int> numOfApplied;
  List<FileSystemEntity> categorySubList;
}

class ModFile extends ModCategory {
  ModFile(
    this.numOfSubItems,
    this.modPath, //mod folder path
    this.modName, //mod folder name,
    this.icePath,
    this.iceName,
    this.iceParent,
    this.originalIcePath,
    this.backupIcePath,
    this.images,
    this.isApplied,
    this.isSFW,
  ) : super('', '', [], [], 0, [], [], []);

  int numOfSubItems;
  String modPath;
  String modName;
  String icePath;
  String iceName;
  String iceParent;
  String originalIcePath;
  String backupIcePath;
  Future? images;
  bool isApplied;
  bool isSFW;

  fromJson(Map<String, dynamic> json) {
    categoryName = json['categoryName'];
    categoryPath = json['categoryPath'];
    modPath = json['modPath'];
    modName = json['modName'];
    icePath = json['icePath'];
    iceName = json['iceName'];
    iceParent = json['iceParent'];
    originalIcePath = json['originalIcePath'];
    backupIcePath = json['backupIcePath'];
    isApplied = json['isApplied'];
    isSFW = json['isSFW'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['categoryPath'] = categoryPath;
    data['categoryName'] = categoryName;
    data['modPath'] = modPath;
    data['modName'] = modName;
    data['iceName'] = iceName;
    data['icePath'] = icePath;
    data['iceParent'] = iceParent;
    data['originalIcePath'] = originalIcePath;
    data['backupIcePath'] = backupIcePath;
    data['isApplied'] = isApplied;
    data['isSFW'] = isSFW;

    return data;
  }
}

//Helper functions
List<ModCategory> categoryAdder(List<FileSystemEntity> mainData) {
  List<ModCategory> cateList = [];
  List<ModFile> modFilesListFromJson = [];

  //JSON Helper
  void convertData(var jsonResponse) {
    for (var b in jsonResponse) {
      ModFile mod = ModFile(
          0,
          b['modPath'],
          b['modName'],
          b['icePath'],
          b['iceName'],
          b['iceParent'],
          b['originalIcePath'],
          b['backupIcePath'],
          null,
          b['isApplied'],
          b['isSFW']);
      mod.categoryPath = b['categoryPath'];
      mod.categoryName = b['categoryName'];
      modFilesListFromJson.add(mod);
    }
  }

  if (modFilesListFromJson.isEmpty &&
      File(modSettingsPath).readAsStringSync().isNotEmpty) {
    convertData(jsonDecode(File(modSettingsPath).readAsStringSync()));
  }

  //print(modFilesListFromJson.length);

  for (var element in getCategoryList(mainData)) {
    List<Directory> tempDirsList = getSubDirsList(Directory(element.path));
    ModCategory newCategory = ModCategory(
        getDirHeader(element),
        element.path,
        getDirHeaderList(tempDirsList),
        getImageIconList(tempDirsList),
        tempDirsList.length,
        getModNum(tempDirsList),
        [],
        getDataFromModDirs(element.path));

    for (var modName in newCategory.itemNames) {
      int count = 0;
      final filesInJson =
          modFilesListFromJson.where((e) => e.modName == modName);
      for (var file in filesInJson) {
        if (file.isApplied) {
          count++;
        }
      }
      newCategory.numOfApplied.add(count);
    }

    cateList.add(newCategory);
  }
  return cateList;
}

// Future<List<ModFile>> modFileAdder(
//     ModCategory curCategory, String modName, int numOfSubItems) async {
//   List<ModFile> modListsList = [];
//   List<File> imgList = [];
//   final filesList = curCategory.categorySubList.whereType<File>();
//   final curModPath = '${curCategory.categoryPath}\\$modName';
//   List<String> icePaths = [];
//   for (var curFile in filesList) {
//     final fileExtension = p.extension(curFile.path);
//     if (fileExtension == '' &&
//         getRootParentDirPath(curFile, curCategory.categoryName)
//                 .split('\\')
//                 .last ==
//             modName) {
//       icePaths.add(curFile.path);
//     } else if (fileExtension == '.jpg' || fileExtension == '.png') {
//       imgList.add(curFile);
//     }
//   }
// //Add files
//   for (var icePath in icePaths) {
//     ModFile newMod = ModFile(
//         icePaths.length,
//         curModPath,
//         modName,
//         icePath,
//         icePath.split('\\').last,
//         File(icePath).parent.path.split('\\').last,
//         imgList,
//         false,
//         true);
//     newMod.categoryPath = curCategory.categoryPath;
//     newMod.categoryName = curCategory.categoryName;
//     newMod.numOfItems = curCategory.numOfItems;
//     modListsList.add(newMod);
//   }

//   return modListsList;
// }

Future<List<List<ModFile>>> modFileAdder(
    ModCategory curCategory, String modName, int numOfSubItems) async {
  List<ModFile> modListsList = [];
  List<List<ModFile>> sortedModsList = [];
  List<File> tempImgs = [];
  List<String> allModParents = [];
  List<ModFile> modFilesListFromJson = [];
  Future? imgList;
  final filesList = curCategory.categorySubList.whereType<File>();
  final curModPath = '${curCategory.categoryPath}\\$modName';

//JSON Helper
  void convertData(var jsonResponse) {
    for (var b in jsonResponse) {
      ModFile mod = ModFile(
          numOfSubItems,
          b['modPath'],
          b['modName'],
          b['icePath'],
          b['iceName'],
          b['iceParent'],
          b['originalIcePath'],
          b['backupIcePath'],
          imgList,
          b['isApplied'],
          b['isSFW']);
      mod.categoryPath = b['categoryPath'];
      mod.categoryName = b['categoryName'];
      modFilesListFromJson.add(mod);
    }
  }

  if (modFilesListFromJson.isEmpty &&
      File(modSettingsPath).readAsStringSync().isNotEmpty) {
    convertData(jsonDecode(await File(modSettingsPath).readAsString()));
  }

  List<String> icePaths = [];
  for (var curFile in filesList) {
    final fileExtension = p.extension(curFile.path);
    if (fileExtension == '' &&
        getRootParentDirPath(curFile, curCategory.categoryName)
                .split('\\')
                .last ==
            modName) {
      icePaths.add(curFile.path);
    } else if (fileExtension == '.jpg' || fileExtension == '.png') {
      tempImgs.add(curFile);
    }
  }

//Add files
  for (var icePath in icePaths) {
    List<File> previewImgs = [];
    for (var img in tempImgs) {
      if (img.parent.path == File(icePath).parent.path &&
          !previewImgs.contains(img)) {
        previewImgs.add(img);
      }
    }
    imgList = getImagesList(previewImgs);

    String parentPath = File(icePath)
        .parent
        .path
        .replaceFirst(curModPath, '')
        .replaceFirst('\\', '')
        .replaceAll('\\', ' > ');
    if (parentPath == '') {
      parentPath = modName;
    }

    ModFile newMod = ModFile(icePaths.length, curModPath, modName, icePath,
        icePath.split('\\').last, parentPath, '', '', imgList, false, true);
    newMod.categoryPath = curCategory.categoryPath;
    newMod.categoryName = curCategory.categoryName;
    newMod.numOfItems = curCategory.numOfItems;

    for (var mod in modFilesListFromJson) {
      if (mod.iceName == newMod.iceName) {
        newMod.isApplied = mod.isApplied;
        newMod.isSFW = mod.isSFW;
        newMod.originalIcePath = mod.originalIcePath;
        newMod.backupIcePath = mod.backupIcePath;
      }
    }

    modListsList.add(newMod);
  }

  for (var mod in modListsList) {
    allModParents.add(mod.iceParent);
  }
  allModParents = allModParents.toSet().toList();
  String tempFirst = allModParents.firstWhere(
    (element) => element == modName,
    orElse: () {
      return '';
    },
  );
  if (allModParents.length > 1 && tempFirst != '') {
    allModParents.removeAt(0);
    allModParents.sort();
    allModParents.insert(0, tempFirst);
  }

  for (var parent in allModParents) {
    List<ModFile> temp =
        modListsList.where((element) => element.iceParent == parent).toList();
    sortedModsList.add(temp);
  }

  return sortedModsList;
}

Future<List<File>> getImagesList(List<File> imgFile) async {
  return imgFile.toList();
}

Future<List<FileSystemEntity>> getDataFromModDirsFuture(String path) async {
  Directory tempDir = Directory(path);

  return tempDir.listSync(recursive: true);
}

List<FileSystemEntity> getDataFromModDirs(String path) {
  Directory tempDir = Directory(path);

  return tempDir.listSync(recursive: true);
}

List<Directory> getCategoryList(List<FileSystemEntity> dataList) {
  final Iterable<Directory> dirs = dataList.whereType<Directory>();

  return dirs.where((e) => e.parent.path == modsDirPath).toList();
}

List<Directory> getSubDirsList(Directory mainDir) {
  final Iterable<Directory> dirs =
      mainDir.listSync(recursive: false).whereType<Directory>();

  return dirs.toList();
}

List<List<File>> getImageIconList(List<Directory> dirsList) {
  List<List<File>> tempReturn = [];
  File defaultIcon = File('assets/img/placeholder-square.jpg');
  for (var dir in dirsList) {
    var subDirs = dir.listSync(recursive: false);
    final Iterable<File> files = subDirs.whereType<File>();

    List<File> temp = [];
    for (var file in files) {
      final fileExtension = p.extension(file.path);
      if (fileExtension == '.jpg' || fileExtension == '.png') {
        temp.add(file);
      }
    }
    if (temp.isEmpty) {
      temp.add(defaultIcon);
    }
    tempReturn.add(temp);
  }
  //print(tempReturn);
  return tempReturn;
}

List<List<Directory>> getSubDirsListFromList(List<Directory> parentDirs) {
  var tempDirsList = [];
  List<List<Directory>> returnList = [];
  for (var parentDir in parentDirs) {
    tempDirsList.add(parentDir.listSync(recursive: false));
  }
  for (var list in tempDirsList) {
    final Iterable<Directory> dirsList = list.whereType<Directory>();
    returnList.add(dirsList.toList());
  }

  return returnList;
}

String getRootParentDirPath(File file, String category) {
  List<String> pathSplit = file.path.split(category);
  List<String> temp = pathSplit.last.split('\\');
  //print('${pathSplit.first}$category\\${temp.first}${temp[1]}');
  return '${pathSplit.first}$category\\${temp.first}${temp[1]}';
}

List<String> getDirHeaderList(List<Directory> dirList) {
  List<String> temp = [];
  for (var element in dirList) {
    temp.add(element.path.split('\\').last);
  }
  return temp;
}

String getDirHeader(Directory dir) {
  return dir.path.split('\\').last;
}

String getFileName(File file) {
  return file.path.split('\\').last;
}

List<int> getModNum(List<Directory> dirsList) {
  List<int> tempReturn = [];

  for (var dirs in dirsList) {
    final subDirs = getSubDirsList(dirs);
    final Iterable<Directory> subDirsList = subDirs.whereType<Directory>();
    tempReturn.add(subDirsList.length);
  }

  return tempReturn;
}

List<File> getIceFilesFromPath(String path) {
  Directory curDir = Directory(path);
  List<File> filesReturn = [];

  var itemsList = curDir.listSync(recursive: true);
  final Iterable<File> files = itemsList.whereType<File>();
  if (files.isNotEmpty) {
    for (var file in files) {
      final fileExtension = p.extension(file.path);
      if (fileExtension == '') {
        filesReturn.add(file);
      }
    }
  }

  filesReturn
      .sort((a, b) => a.parent.toString().compareTo(b.parent.toString()));

  return filesReturn;
}

//==============================================================================

List<Directory> getDirsInParentDir(Directory parentDir) {
  var itemsList = parentDir.listSync(recursive: false);
  final Iterable<Directory> dirs = itemsList.whereType<Directory>();

  return dirs.toList();
}

Future<List<Directory>> futureGetDirsInParentDir(Directory parentDir) async {
  var itemsList = parentDir.listSync(recursive: false);
  final Iterable<Directory> dirs = itemsList.whereType<Directory>();

  return dirs.toList();
}

Future<List<File>> futureGetImgInDir(Directory parentDir) async {
  var imgList = parentDir.listSync(recursive: false);
  List<File> temp = [];
  final Iterable<File> files = imgList.whereType<File>();
  if (files.isNotEmpty) {
    for (var file in files) {
      final fileExtension = p.extension(file.path);
      if (fileExtension == '.jpg' || fileExtension == '.png') {
        temp.add(file);
      }
    }
  }

  return temp.toList();
}

List<String> getHeadersFromList(List<Directory> paramList) {
  List<String> headers = [];
  for (var element in paramList) {
    headers.add(element.path.split('\\').last);
  }

  // for (var element in headers) {
  //   print(element);
  // }

  return headers;
}

String getHeaderFromDir(Directory dir) {
  return dir.path.split('\\').last;
}

File itemsDirListIcon(String path) {
  Directory itemsDir = Directory(path);

  var itemsList = itemsDir.listSync(recursive: false);
  final Iterable<File> files = itemsList.whereType<File>();
  File iconFile = File('assets/img/placeholder-square.jpg');
  if (files.isNotEmpty) {
    for (var file in files) {
      final fileExtension = p.extension(file.path);
      if (fileExtension == '.jpg') {
        iconFile = file;
        return iconFile;
      }
    }
  }

  return iconFile;
}

List<String> getFileHeadersFromList(List<FileSystemEntity> paramList) {
  List<String> headers = [];
  for (var element in paramList) {
    headers.add(element.path.split('\\').last);
  }

  // for (var element in headers) {
  //   print(element);
  // }

  return headers;
}

List<String> getParentHeadersFromFilesList(List<FileSystemEntity> paramList) {
  List<String> headers = [];
  for (var element in paramList) {
    var temp = element.path.split('\\');
    headers.add(temp[temp.length - 2]);
  }

  // for (var element in headers) {
  //   print(element);
  // }

  return headers;
}

List<String> getMoreParentHeadersFromFilesList(
    List<FileSystemEntity> paramList) {
  List<String> headers = [];
  for (var element in paramList) {
    var temp = element.path.split('\\');
    headers.add(temp[temp.length - 3]);
  }

  // for (var element in headers) {
  //   print(element);
  // }

  return headers;
}

String getParentHeaderFromFile(FileSystemEntity paramList) {
  var temp = paramList.path.split('\\');
  return (temp[temp.length - 2]);
}
