import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_paths/sega_file_paths.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_functions/pso2_version_check.dart';
import 'package:pso2_mod_manager/item_aqm_inject/aqm_injected_item_class.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_board_class.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_card_class.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_sleeve_class.dart';
import 'package:pso2_mod_manager/mod_add/item_data_class.dart';
import 'package:pso2_mod_manager/mod_data/category_type_class.dart';
import 'package:pso2_mod_manager/mod_sets/mod_set_class.dart';
import 'package:pso2_mod_manager/vital_gauge/vital_gauge_class.dart';
import 'package:signals/signals_flutter.dart';

List<String> defaultCategoryTypes = ['Cast Parts', 'Layering Wears', 'Others'];
List<String> defaultCategoryDirs = [
  'Accessories', //0
  'Basewears', //1
  'Body Paints', //2
  'Cast Arm Parts', //3
  'Cast Body Parts', //4
  'Cast Leg Parts', //5
  'Costumes', //6
  'Emotes', //7
  'Eyes', //8
  'Face Paints', //9
  'Hairs', //10
  'Innerwears', //11
  'Mags', //12
  'Misc', //13
  'Motions', //14
  'Outerwears', //15
  'Setwears', //16
  'Weapons' //17
];
List<String> boundingRadiusCategoryDirs = [
  'Basewears', //1
  'Body Paints', //2
  'Cast Arm Parts', //3
  'Cast Body Parts', //4
  'Cast Leg Parts', //5
  'Outerwears', //15
  'Setwears', //16
];
List<String> aqmInjectCategoryDirs = [
  'Basewears', //1
  // 'Cast Arm Parts', //3
  // 'Cast Body Parts', //4
  // 'Cast Leg Parts', //5
  'Outerwears', //15
  'Setwears', //16
];
final defaultWeaponTypes = [
  'Swords',
  'Wired Lances',
  'Partisans',
  'Twin Daggers',
  'Double Sabers',
  'Knuckles',
  'Katanas',
  'Soaring Blades',
  'Assault Rifles',
  'Launchers',
  'Twin Machine Guns',
  'Bows',
  'Gunblades',
  'Rods',
  'Talises',
  'Wands',
  'Jet Boots',
  'Harmonizers'
];

final defaultMotionTypes = ['Glide Motion', 'Jump Motion', 'Landing Motion', 'Dash Motion', 'Run Motion', 'Standby Motion', 'Swim Motion'];
final modSortingSelections = ['Name (Alphabetical)', 'Recently Added', 'Recently Applied'];
String charToReplace = '[\\/:*?"<>|]';
String charToReplaceWithoutSeparators = '[:*?"<>|]';

String curAppVersion = '';
bool offlineMode = false;
List<CategoryType> masterModList = [];
List<ModSet> masterModSetList = [];
TextEditingController searchTextController = TextEditingController();
Signal<List<File>> backgroundImageFiles = Signal([]);
List<String> modAddDragDropPaths = [];
List<ItemData> pItemData = [];
List<OfficialIceFile> oItemData = [];
List<OfficialIceFile> oItemDataNA = [];
String segaMasterServerURL = '';
String segaMasterServerBackupURL = '';
String segaPatchServerURL = '';
String segaPatchServerBackupURL = '';
Signal<String> modApplyStatus = Signal('');
Signal<String> modPopupStatus = Signal('');
List<CategoryType> masterAppliedModList = [];
List<AqmInjectedItem> masterAqmInjectedItemList = [];
List<VitalGaugeBackground> masterVitalGaugeBackgroundList = [];
List<LineStrikeCard> masterLineStrikeCardList = [];
List<LineStrikeBoard> masterLineStrikeBoardList = [];
List<LineStrikeSleeve> masterLineStrikeSleeveList = [];
List<File> modCustomAQMFiless = [];
Signal<String> mainGridStatus = Signal('');
Signal<bool> checksumAvailability = Signal(false);
List<ItemData> masterQuickSwapItemList = [];
Signal<PSO2RegionVersion> pso2RegionVersion = Signal(PSO2RegionVersion.unknown);
List<String> modifiedIceList = [];
List<String> modAddFilterList = [];
Signal<bool> appLoadingFinished = Signal(false);
Signal<int> uiDialogBackgroundColorAlpha = Signal(uiBackgroundColorAlpha.value + 50 <= 255 ? uiBackgroundColorAlpha.value + 50 : uiBackgroundColorAlpha.value);
