import 'dart:io';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:pso2_mod_manager/mod_sync/mod_sync_variables.dart';

Map<String, dynamic> iceServerConfigs = {
  'iceServer': [
    {'url': 'stun:stun1.l.google.com:19302'},
  ],
};

Future<List<String>> modSyncDescFileToData(File inputFile) async {
  final offerString = await inputFile.readAsString();
  final codeUnits = [for (var n in offerString.split(', ')) int.parse(n)];
  return String.fromCharCodes(codeUnits).replaceAll('{', '').replaceAll('}', '').split(', ');
}

Future<File> modSyncGenerateOffer() async {
  modSyncConnection ??= await createPeerConnection(iceServerConfigs);
  modSyncConnectionOffer = (await modSyncConnection!.createOffer());
  // await modSyncConnection!.setLocalDescription(modSyncConnectionOffer!);
  if (await modSyncOfferFile.exists() == false) await modSyncOfferFile.create(recursive: true);
  final offerString = modSyncConnectionOffer!.toMap().toString().codeUnits.toString();
  return await modSyncOfferFile.writeAsString(offerString.substring(1, offerString.length - 1));
}

Future<File> modSyncGenerateReply(File offerFile) async {
  modSyncConnection ??= await createPeerConnection(iceServerConfigs);
  final offerMap = await modSyncDescFileToData(offerFile);
  RTCSessionDescription recievedOffer = RTCSessionDescription(offerMap.first.replaceFirst('sdp: ', ''), offerMap.last.replaceFirst('type: ', ''));
  await modSyncConnection!.setRemoteDescription(recievedOffer);
  modSyncConnectionReply = await modSyncConnection!.createAnswer();
  await modSyncConnection!.setLocalDescription(modSyncConnectionReply!);
  final replyString = modSyncConnectionReply!.toMap().toString().codeUnits.toString();
  return await modSyncReplyFile.writeAsString(replyString.substring(1, replyString.length - 1));
}

Future<void> modSyncProcessReply(File replyFile) async {
  final replyMap = await modSyncDescFileToData(replyFile);
  RTCSessionDescription recievedReply = RTCSessionDescription(replyMap.first.replaceFirst('sdp: ', ''), replyMap.last.replaceFirst('type: ', ''));
  modSyncConnection!.setRemoteDescription(recievedReply);
}

// Future<void> modSyncSendData(File fileToSend) async {
//   final fileBytes = await fileToSend.readAsBytes();
//   modSyncConnection.createDataChannel(label, dataChannelDict)
// }