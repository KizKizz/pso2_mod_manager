import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:pso2_mod_manager/modsSwapper/mods_swapper_functions.dart';

// Future<void> testDialog(context) async {
//   return showDialog<void>(
//     context: context, // user must tap button!
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: const Center(child: Text('Test')),
//         content: SingleChildScrollView(child: Text(getByte())),
//         actions: <Widget>[
//           ElevatedButton(
//             child: const Text('Close'),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       );
//     },
//   );
// }

Future<bool> getByte() async {
  final fileGet = await openFile(); // File
  Uint8List aqpBytes = await File(fileGet!.path).readAsBytes(); // Uint8List
  //final byteData = bytes.buffer.asByteData(); // ByteData
  //print(byteData.buffer.asUint8List());
  // List<int> textBytes = utf8.encode('ABC');
  // print(textBytes);

  int firstMatchingIndex = aqpBytes.indexOfElements([243, 7, 204, 63]);
  print(aqpBytes[235]);
  print(firstMatchingIndex);

  return true;
}
