
import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:archive/archive_io.dart';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/main.dart';

bool _newModDragging = false;
final List<XFile> _newModDragDropList = [];
//List<String> _itemsDisplayList = [];

void modAddHandler(context) {
  showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Adding mods'),
            titlePadding: EdgeInsets.all(5),
            content: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return Row(
                  children: [
                    DropTarget(
                      //enable: true,
                      onDragDone: (detail) {
                        setState(() {
                          for (var element in detail.files) {
                            if (_newModDragDropList.indexWhere(
                                    (file) => file.path == element.path) ==
                                -1) {
                              _newModDragDropList.add(element);
                              if (p.extension(element.path) == '.zip') {
                                unzipPack(element.path, element.name);
                              }
                            }
                          }

                          // if (_itemsDisplayList.isNotEmpty) {
                          //   _itemsDisplayList.clear();
                          // }
                          // for (var item in _newModDragDropList) {
                          //   _itemsDisplayList.add(item.name);
                          // }

                          //debugPrint(_newModDragDropList.toString());
                          // detail.files
                          //     .sort(((a, b) => a.name.compareTo(b.name)));
                          // _newModDragDropList.addAll(detail.files);
                          // context
                          //     .read<StateProvider>()
                          //     .modsDropAdd(detail.files);
                          // for (var element in detail.files) {
                          //   if (!Directory(element.path).existsSync()) {
                          //     isModAddFolderOnly = false;
                          //     break;
                          //   }
                          // }
                        });
                      },
                      onDragEntered: (detail) {
                        setState(() {
                          _newModDragging = true;
                        });
                      },
                      onDragExited: (detail) {
                        setState(() {
                          _newModDragging = false;
                        });
                      },
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border:
                                Border.all(color: Theme.of(context).hintColor),
                            color: _newModDragging
                                ? Colors.blue.withOpacity(0.4)
                                : Colors.black26,
                          ),
                          height: constraints.maxHeight,
                          width: constraints.maxWidth * 0.3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_newModDragDropList.isEmpty)
                                const Center(
                                    child: Text('Drag zip files here')),
                              if (_newModDragDropList.isNotEmpty)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: SizedBox(
                                        width: constraints.maxWidth,
                                        height: constraints.maxHeight,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          child: ListView.builder(
                                              itemCount:
                                                  _newModDragDropList.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return ListTile(
                                                  dense: true,
                                                  // leading: const Icon(
                                                  //     Icons.list),
                                                  trailing: const Icon(
                                                      Icons.remove_circle),
                                                  title: Text(
                                                      _newModDragDropList[index]
                                                          .name),
                                                  subtitle: Text(
                                                    _newModDragDropList[index]
                                                        .path,
                                                    style: const TextStyle(
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                  ),
                                                );
                                              }),
                                        )),
                                  ),
                                )
                            ],
                          )),
                    ),
                    VerticalDivider(
                      width: 10,
                      thickness: 2,
                      indent: 5,
                      endIndent: 5,
                      color: Theme.of(context).textTheme.bodySmall!.color,
                    ),
                    Container(
                      width: constraints.maxWidth * 0.4,
                      height: constraints.maxHeight,
                      color: Colors.amber,
                    )
                  ],
                );
              }),
            ),
          );
        });
      });
}

void unzipPack(String filePath, String fileName) {
  // Use an InputFileStream to access the zip file without storing it in memory.
  final inputStream = InputFileStream(filePath);
  // Decode the zip from the InputFileStream. The archive will have the contents of the
  // zip, without having stored the data in memory.
  final archive = ZipDecoder().decodeBuffer(inputStream);
  // For all of the entries in the archive
  for (var file in archive.files) {
    // If it's a file and not a directory
    if (file.isFile) {
      // Write the file content to a directory called 'out'.
      // In practice, you should make sure file.name doesn't include '..' paths
      // that would put it outside of the extraction directory.
      // An OutputFileStream will write the data to disk.
      final outputStream = OutputFileStream('temp$s$fileName$s${file.name}');
      // The writeContent method will decompress the file content directly to disk without
      // storing the decompressed data in memory.
      file.writeContent(outputStream);
      // Make sure to close the output stream so the File is closed.
      outputStream.close();
    }
  }
}
