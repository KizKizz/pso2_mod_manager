import 'dart:typed_data';

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

Future<Uint8List?> getVideoThumbnail(String videoPath) async {
  Media media = Media(videoPath);
  Player tempPlayer = Player();
  final controller = VideoController(tempPlayer);
  await controller.player.open(media);
  await controller.player.setVolume(0);
  int totalWaitTime = 0;
  while (controller.player.state.bufferingPercentage < 100 && totalWaitTime < 30000) {
    await Future.delayed(Duration(milliseconds: 10));
    totalWaitTime += 10;
  }
  if (totalWaitTime >= 30000) return null;
  await controller.player.seek(Duration(seconds: 3));
  await controller.player.pause();
  final videoThumbnail = await controller.player.screenshot();
  await tempPlayer.dispose();

  return videoThumbnail;
}
