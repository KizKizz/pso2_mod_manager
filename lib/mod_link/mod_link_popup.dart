import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_link/mod_link_functions.dart';
import 'package:signals/signals_flutter.dart';

Future<void> modLinkPopup(context) async {
  Map? connectionOffer;
  return await showDialog(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).colorScheme.outline),
              borderRadius: const BorderRadius.all(Radius.circular(5)),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiDialogBackgroundColorAlpha.watch(context)),
            scrollable: true,
            insetPadding: const EdgeInsets.all(5),
            contentPadding: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
            content: Column(
              spacing: 5,
              children: [
                Text('success'),
                Visibility(visible: connectionOffer != null, child: Text(connectionOffer.toString())),
                ElevatedButton(
                  onPressed: () async {
                    final peerConnection = await createPeerConnection(iceServerConfigs);
                    connectionOffer = (await peerConnection.createOffer()).toMap();

                    debugPrint(connectionOffer.toString());
                    setState(() {});
                  },
                  child: Text('Generate'),
                ),
              ],
            ),

            actionsPadding: const EdgeInsets.only(top: 0, bottom: 10, left: 10, right: 10),
            actions: [],
          );
        },
      );
    },
  );
}
