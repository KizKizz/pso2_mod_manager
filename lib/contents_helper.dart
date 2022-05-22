// ignore_for_file: unused_import

import 'dart:io';

import 'package:pso2_mod_manager/main.dart';
import 'package:path/path.dart' as p;

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

List<List<Directory>> getDirsInParentDirs(List<Directory> parentDirs) {
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

List<String> getMoreParentHeadersFromFilesList(List<FileSystemEntity> paramList) {
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
