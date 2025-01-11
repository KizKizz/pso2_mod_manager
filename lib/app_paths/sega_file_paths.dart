import 'dart:io';

import 'package:http/http.dart' as http;

class OfficialIceFile {
  OfficialIceFile(this.path, this.md5, this.size, this.server);

  String path;
  String md5;
  int size;
  String server;
}

Future<(List<OfficialIceFile>, String, String, String, String)> officialFileDetailsFetch() async {
  String serverManagementLink = 'http://patch01.pso2gs.net/patch_prod/patches/management_beta.txt';
  List<OfficialIceFile> officialList = [];
  String masterURL = '';
  String patchURL = '';
  String masterBackupURL = '';
  String patchBackupURL = '';

  final serverInfosFetch = await http.get(Uri.parse(serverManagementLink));
  if (serverInfosFetch.statusCode == 200) {
    final serverInfos = serverInfosFetch.body.trim().split('\n');
    masterURL = Uri.parse(serverInfos
            .firstWhere(
              (e) => e.startsWith('MasterURL='),
              orElse: () => '',
            )
            .split('MasterURL=')
            .last)
        .toString()
        .replaceFirst('%0D', '')
        .trim();
    patchURL = Uri.parse(serverInfos
            .firstWhere(
              (e) => e.startsWith('PatchURL='),
              orElse: () => '',
            )
            .split('PatchURL=')
            .last)
        .toString()
        .replaceFirst('%0D', '')
        .trim();
    masterBackupURL = Uri.parse(serverInfos
            .firstWhere(
              (e) => e.startsWith('BackupMasterURL='),
              orElse: () => '',
            )
            .split('BackupMasterURL=')
            .last)
        .toString()
        .replaceFirst('%0D', '')
        .trim();
    patchBackupURL = Uri.parse(serverInfos
            .firstWhere(
              (e) => e.startsWith('BackupPatchURL='),
              orElse: () => '',
            )
            .split('BackupPatchURL=')
            .last)
        .toString()
        .replaceFirst('%0D', '')
        .trim();

    // List<String> patchListFiles = ['patchlist_region1st.txt', 'patchlist_classic.txt', 'patchlist_avatar.txt', 'patchlist.txt', 'patchlist_all.txt', 'patchlist_prologue.txt', 'patchlist_reboot.txt'];
    const patchListFile = 'patchlist_all.txt';
    final serverURLs = [patchURL, masterURL, patchBackupURL, masterBackupURL];
    for (var url in serverURLs) {
      // for (var patchListFile in patchListFiles) {
        List<String> patchListInfos = [];
        final response = await http.get(Uri.parse(url + patchListFile), headers: {"User-Agent": "AQUA_HTTP"});
        if (response.statusCode == 200) {
          patchListInfos = response.body.trim().split('\n');
          if (patchListInfos.isNotEmpty) {
            for (var info in patchListInfos) {
              final infoDetails = info.split('	');
              officialList.add(OfficialIceFile(infoDetails[0].trim(), infoDetails[1].trim(), int.parse(infoDetails[2]), infoDetails[3].trim()));
            }
            File('${Directory.current.path}/$patchListFile').createSync();
            File('${Directory.current.path}/$patchListFile').writeAsStringSync(officialList.map((e) => e.path).join('\n'));
            return (officialList, masterURL.toString(), masterBackupURL, patchURL, patchBackupURL);
          }
        }
      // }
    }
  }

  return (officialList, masterURL.toString(), masterBackupURL, patchURL, patchBackupURL);
}
