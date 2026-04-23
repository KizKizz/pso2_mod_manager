import 'package:fc_native_video_thumbnail/fc_native_video_thumbnail.dart';
import 'package:path/path.dart' as p;

Future<bool> getVideoThumbnail(String videoPath) async {
  final result = await FcNativeVideoThumbnail().saveThumbnailToFile(
            srcFile: videoPath,
            destFile: '${p.withoutExtension(videoPath)}.jpg',
            width: 1920,
            height: 1080,
            quality: 90);

  return result;
}
