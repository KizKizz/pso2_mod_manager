import 'dart:io';

import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:path/path.dart' as p;

String mainModDirPath = '$mainDataDirPath${p.separator}Mods';
String backupDirPath = '';
String mainModListJsonPath = '';
String mainModSetListJsonPath = '';
String mainAqmInjectListJsonPath = '';
String mainVitalGaugeListJsonPath = '';
String mainLineStrikeCardListJsonPath = '';
String mainLineStrikeBoardListJsonPath = '';
String mainLineStrikeSleeveListJsonPath = '';
String mainQuickSwapListJsonPath = '';
String backgroundDirPath = '$mainDataDirPath${p.separator}Background Images';
String modAddTempDirPath = '$mainDataDirPath${p.separator}AddTemp';
String modSwapTempDirPath = '$mainDataDirPath${p.separator}SwapTemp';
String modBoundingRadiusTempDirPath = '$mainDataDirPath${p.separator}BoundingRadiusTemp';
String modAqmInjectTempDirPath = '$mainDataDirPath${p.separator}AQMInjectTemp';
String modSwapTempLItemDirPath = '$mainDataDirPath${p.separator}SwapTemp${p.separator}lItem';
String modSwapTempRItemDirPath = '$mainDataDirPath${p.separator}SwapTemp${p.separator}rItem';
String modSwapTempOutputDirPath = '$mainDataDirPath${p.separator}SwapTemp${p.separator}output';
String modVitalGaugeTempDirPath = '$mainDataDirPath${p.separator}VitalGaugeTemp';
String modItemIconTempDirPath = '$mainDataDirPath${p.separator}ItemIconTemp';
String markedItemIconsDirPath = '$mainDataDirPath${p.separator}Marked Item Icons';
String jsonBackupDirPath = '$mainDataDirPath${p.separator}Json Backup';
String pso2DataDirPath = '$pso2binDirPath${p.separator}data';
String modCustomAqmsDirPath = '$mainDataDirPath${p.separator}Custom AQMs';
String vitalGaugeDirPath = '$mainDataDirPath${p.separator}Vital Gauge';
String modChecksumFilePath = '$mainDataDirPath${p.separator}Checksum${p.separator}d4455ebc2bef618f29106da7692ebc1a';
String modifiedIceListFilePath = '$mainDataDirPath${p.separator}modifiedIceList.txt';

String lineStrikeExportedCardsDirPath = '$mainDataDirPath${p.separator}Line Strike${p.separator}ExportedCards';
String lineStrikeCardsDirPath = '$mainDataDirPath${p.separator}Line Strike${p.separator}Cards';
String lineStrikeCardTempDirPath = '$mainDataDirPath${p.separator}LineStrikeTemp${p.separator}Card';
String lineStrikeCustomizedCacheDirPath = '$mainDataDirPath${p.separator}Line Strike${p.separator}CustomizedCache';
String lineStrikeBoardsDirPath = '$mainDataDirPath${p.separator}Line Strike${p.separator}Boards';
String lineStrikeBoardTempDirPath = '$mainDataDirPath${p.separator}LineStrikeTemp${p.separator}Board';
String lineStrikeSleevesDirPath = '$mainDataDirPath${p.separator}Line Strike${p.separator}Sleeves';
String lineStrikeSleeveTempDirPath = '$mainDataDirPath${p.separator}LineStrikeTemp${p.separator}Sleeve';

// External programs
String sevenZipExePath = '${Directory.current.path}${p.separator}7zip-x64${p.separator}7z.exe';
String zamboniExePath = '${Directory.current.path}${p.separator}Zamboni${p.separator}Zamboni.exe';
String pngDdsConvExePath = '${Directory.current.path}${p.separator}png_dds_converter${p.separator}png_dds_converter.exe';

String githubIconDatabaseLink = 'https://raw.githubusercontent.com/KizKizz/pso2ngs_file_downloader/main';

Future<(bool, bool)> appMainPathsCheck() async {
  bool pso2bin = true;
  bool mainDir = true;
  if (pso2binDirPath.isEmpty || !await Directory(pso2binDirPath).exists()) pso2bin = false;
  if (mainDataDirPath.isEmpty || !await Directory(mainDataDirPath).exists()) mainDir = false;

  return (pso2bin, mainDir);
}

void createMainDirs() {
  // Create Mods folder and default categories
  Directory(mainModDirPath).createSync(recursive: true);
  for (var dirName in defaultCategoryDirs) {
    Directory(mainModDirPath + p.separator + dirName).createSync(recursive: true);
  }

  // Create background folder
  Directory(backgroundDirPath).createSync(recursive: true);

  // Profile 1
  if (modManCurActiveProfile == 1) {
    // Create Mod backup folders
    backupDirPath = '$mainDataDirPath${p.separator}Backups';
    Directory(backupDirPath).createSync(recursive: true);
    List<String> dataFolders = ['win32', 'win32_na', 'win32reboot', 'win32reboot_na'];
    for (var name in dataFolders) {
      Directory('$backupDirPath${p.separator}$name').createSync(recursive: true);
    }

    // Main mod list
    mainModListJsonPath = '$mainDataDirPath${p.separator}PSO2ModManModsList.json';

    // Main mod set list
    mainModSetListJsonPath = '$mainDataDirPath${p.separator}PSO2ModManSetsList.json';

    // Main aqm inject list
    mainAqmInjectListJsonPath = '$mainDataDirPath${p.separator}PSO2ModManAqmInjectedList.json';

    // Main vital gauge list
    mainVitalGaugeListJsonPath = '$mainDataDirPath${p.separator}PSO2ModManVitalGaugeList.json';

    // Main line strike card list
    mainLineStrikeCardListJsonPath = '$mainDataDirPath${p.separator}PSO2ModManLSCardList.json';
    
    // Main line strike board list
    mainLineStrikeBoardListJsonPath = '$mainDataDirPath${p.separator}PSO2ModManLSBoardList.json';
    
    // Main line strike sleeve list
    mainLineStrikeSleeveListJsonPath = '$mainDataDirPath${p.separator}PSO2ModManLSSleeveList.json';
    
    // Main quick swap list
    mainQuickSwapListJsonPath = '$mainDataDirPath${p.separator}PSO2ModManQuickSwapApplyItemList.json';
  }

  // Profile 2
  if (modManCurActiveProfile == 2) {
    // Create Mod backup folders
    backupDirPath = '$mainDataDirPath${p.separator}Backups_profile2';
    Directory(backupDirPath).createSync(recursive: true);
    List<String> dataFolders = ['win32', 'win32_na', 'win32reboot', 'win32reboot_na'];
    for (var name in dataFolders) {
      Directory('$backupDirPath${p.separator}$name').createSync(recursive: true);
    }

    // Main mod list
    mainModListJsonPath = '$mainDataDirPath${p.separator}PSO2ModManModsList_profile2.json';

    // Main mod set list
    mainModSetListJsonPath = '$mainDataDirPath${p.separator}PSO2ModManSetsList_profile2.json';

    // Main aqm inject list
    mainAqmInjectListJsonPath = '$mainDataDirPath${p.separator}PSO2ModManAqmInjectedList_profile2.json';

    // Main vital gauge list
    mainVitalGaugeListJsonPath = '$mainDataDirPath${p.separator}PSO2ModManVitalGaugeList_profile2.json';

    // Main line strike card list
    mainLineStrikeCardListJsonPath = '$mainDataDirPath${p.separator}PSO2ModManLSCardList_profile2.json';
    
    // Main line strike board list
    mainLineStrikeBoardListJsonPath = '$mainDataDirPath${p.separator}PSO2ModManLSBoardList_profile2.json';
    
    // Main line strike sleeve list
    mainLineStrikeSleeveListJsonPath = '$mainDataDirPath${p.separator}PSO2ModManLSSleeveList_profile2.json';
    
    // Main quick swap list
    mainQuickSwapListJsonPath = '$mainDataDirPath${p.separator}PSO2ModManQuickSwapApplyItemList_profile2.json';
  }
}
