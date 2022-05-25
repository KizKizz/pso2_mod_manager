// ignore_for_file: unused_import
import 'dart:io';

import 'package:pso2_mod_manager/main.dart';
import 'package:path/path.dart' as p;

List<FileSystemEntity> mainDataList = [];

class ModCategory {
  ModCategory(
    this.categoryName,
    this.path,
    this.itemNames,
    this.imageIcons,
    this.numOfItems,
    this.numOfMods,
    this.categorySubList,
  );

  String categoryName;
  String path;
  List<String> itemNames;
  List<List<File>> imageIcons;
  int numOfItems;
  List<int> numOfMods;
  List<FileSystemEntity> categorySubList;
}

class ModFile extends ModCategory {
  ModFile(
    this.path,
    this.modName,
    this.iceName,
    this.parentName,
    this.parentPath,
    this.category,
    this.images,
    this.isApplied,
    this.isSFW,
  ) : super('', '', [], [], 0, [], []);

  String path;
  String modName;
  String iceName;
  String parentName;
  String parentPath;
  String category;
  List<File> images;
  bool isApplied;
  bool isSFW;

  fromJson(Map<String, dynamic> json) {
    path = json['path'];
    modName = json['modName'];
    iceName = json['iceName'];
    parentPath = json['parent'];
    category = json['category'];
    isApplied = json['isApplied'];
    isSFW = json['isSFW'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['path'] = path;
    data['modName'] = modName;
    data['iceName'] = iceName;
    data['parent'] = parentPath;
    data['category'] = category;
    data['isApplied'] = isApplied;
    data['isSFW'] = isSFW;

    return data;
  }
}

//Helper functions
List<ModCategory> categoryAdder(List<FileSystemEntity> mainData) {
  List<ModCategory> cateList = [];
  for (var element in getCategoryList(mainData)) {
    List<Directory> tempDirsList = getSubDirsList(Directory(element.path));
    cateList.add(ModCategory(
        getDirHeader(element),
        element.path,
        getDirHeaderList(tempDirsList),
        getImageIconList(tempDirsList),
        tempDirsList.length,
        getModNum(tempDirsList),
        getDataFromModDirs(element.path)));
  }
  return cateList;
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

List<FileSystemEntity> getFilesFromPath(String path) {
  Directory curDir = Directory(path);
  List<FileSystemEntity> filesReturn = [];

  var itemsList = curDir.listSync(recursive: true);
  final Iterable<FileSystemEntity> files = itemsList.whereType<File>();
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
