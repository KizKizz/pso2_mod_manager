// import 'dart:io';

// import 'package:file_picker/file_picker.dart';
// import 'package:file_selector/file_selector.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:pso2_mod_manager/global_vars.dart';
// import 'package:pso2_mod_manager/mod_sync/mod_sync_functions.dart';
// import 'package:pso2_mod_manager/mod_sync/mod_sync_variables.dart';
// import 'package:pso2_mod_manager/shared_prefs.dart';
// import 'package:signals/signals_flutter.dart';
// import 'package:url_launcher/url_launcher_string.dart';

// Future<void> modLinkPopup(context) async {
//   return await showDialog(
//     barrierDismissible: true,
//     context: context,
//     builder: (BuildContext context) {
//       return StatefulBuilder(
//         builder: (dialogContext, setState) {
//           return AlertDialog(
//             shape: RoundedRectangleBorder(
//               side: BorderSide(color: Theme.of(context).colorScheme.outline),
//               borderRadius: const BorderRadius.all(Radius.circular(5)),
//             ),
//             backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiDialogBackgroundColorAlpha.watch(context)),
//             scrollable: true,
//             insetPadding: const EdgeInsets.all(5),
//             contentPadding: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
//             content: Column(
//               spacing: 5,
//               children: [
//                 Text(modSyncConnection?.iceConnectionState?.name ?? 'null'),
//                 ElevatedButton(
//                   onPressed: modSyncConnection != null
//                       ? () async {
//                           if (modSyncConnection?.connectionState == null) {
//                             modSyncConnection = null;
//                             modSyncConnectionOffer = null;
//                           } else {
//                             await modSyncConnection!.close();
//                             if (modSyncConnection?.connectionState! == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
//                               modSyncConnection = null;
//                               modSyncConnectionOffer = null;
//                             }
//                           }
//                           await modSyncOfferFile.delete();
//                           setState(() {});
//                         }
//                       : null,
//                   child: Text('Close Connection'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () async {
//                     if (modSyncOfferFile.existsSync() && modSyncConnectionOffer != null) {
//                       launchUrlString(modSyncOfferFile.parent.path);
//                     } else {
//                       await modSyncGenerateOffer();
//                     }
//                     setState(() {});
//                   },
//                   child: Text(modSyncOfferFile.existsSync() && modSyncConnectionOffer != null ? 'Browse' : 'Generate Offer'),
//                 ),
//                 // Visibility(visible: modSyncConnectionOffer != null, child: Text(modSyncConnectionOffer.toString())),
//                 ElevatedButton(
//                   onPressed: () async {
//                     XFile? selectedFile;
//                     if (useAltFilePicker) {
//                       FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.custom, allowedExtensions: ['pmmo']);
//                       if (result != null) selectedFile = result.xFiles.single;
//                     } else {
//                       XTypeGroup fileTypeGroup = XTypeGroup(label: 'Offer File', extensions: ['pmmo']);
//                       selectedFile = await openFile(acceptedTypeGroups: <XTypeGroup>[fileTypeGroup]);
//                     }

//                     if (selectedFile != null) {
//                       modSyncGenerateReply(File(selectedFile.path));
//                       setState(() {});
//                     }
//                   },
//                   child: Text('Generate Reply'),
//                 ),
//               ],
//             ),

//             actionsPadding: const EdgeInsets.only(top: 0, bottom: 10, left: 10, right: 10),
//             actions: [],
//           );
//         },
//       );
//     },
//   );
// }
