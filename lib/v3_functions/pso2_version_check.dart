import 'dart:io';

import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:path/path.dart' as p;

enum PSO2RegionVersion {
  unknown('unknown'),
  na('na'),
  jp('jp');

  final String value;
  const PSO2RegionVersion(this.value);
}

Future<PSO2RegionVersion> pso2RegionCheck() async {
  String regionVersion = '';
  File editionFile = File('$pso2binDirPath${p.separator}sub${p.separator}edition.txt');
  if (editionFile.existsSync()) {
    regionVersion = await editionFile.readAsString();
    regionVersion = regionVersion.trim();
  }
  if (regionVersion == 'na') {
    return PSO2RegionVersion.na;
  } else if (regionVersion == 'jp') {
    return PSO2RegionVersion.jp;
  } else {
    return PSO2RegionVersion.unknown;
  }
}
