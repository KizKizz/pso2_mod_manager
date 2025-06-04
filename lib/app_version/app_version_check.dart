import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';

const String latestGitHubReleaseAPILink = 'https://api.github.com/repos/KizKizz/pso2_mod_manager/releases/latest';

Future<(String, String)> appLatestReleaseFetch() async {
  String version = '';
  String patchNotes = '';
  final response = await http.get(Uri.parse(latestGitHubReleaseAPILink));
  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);
    // Get version tag
    version = jsonData.entries.firstWhere((e) => e.key == 'tag_name', orElse: () => const MapEntry('', '')).value.replaceFirst('v', '');
    // Get patch notes
    List<String> bodyText = jsonData.entries.firstWhere((e) => e.key == 'body', orElse: () => const MapEntry('', '')).value.split('\r\n\r\n');
    patchNotes = bodyText.firstWhere((e) => e.contains('### Patch notes:\r\n'), orElse: () => '').replaceFirst('### Patch notes:\r\n', '');
  } else {
    throw Exception(appText.unableToGetAppVersionDataFromGitHub);
  }

  return (version, patchNotes);
}

bool newAppVersionCheck(String remoteVersion) {
  final detailedCurVersion = curAppVersion.split('.');
  final detailedRemoteVersion = remoteVersion.split('.');

  if (int.parse(detailedRemoteVersion[0]) > int.parse(detailedCurVersion[0])) {
    return true;
  } else if (int.parse(detailedRemoteVersion[0]) >= int.parse(detailedCurVersion[0]) && int.parse(detailedRemoteVersion[1]) > int.parse(detailedCurVersion[1])) {
    return true;
  } else if (int.parse(detailedRemoteVersion[0]) >= int.parse(detailedCurVersion[0]) &&
      int.parse(detailedRemoteVersion[1]) >= int.parse(detailedCurVersion[1]) &&
      int.parse(detailedRemoteVersion[2]) > int.parse(detailedCurVersion[2])) {
    return true;
  } else {
    return false;
  }
}

Future<File> patchFileLauncherGenerate(String remoteVersion) async {
  File patchFile = File('${Directory.current.path}${p.separator}appUpdate${p.separator}patchLauncher.bat');
  if (!patchFile.existsSync()) {
    patchFile.createSync(recursive: true);
  }
  String commands = 'start /B "" "${'${Directory.current.path}${p.separator}appUpdate${p.separator}updater.exe'}" PSO2NGSModManager $remoteVersion "${Directory.current.path}"';
  await patchFile.writeAsString(commands);

  return patchFile;
}