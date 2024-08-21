// ignore_for_file: unused_import

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/classes/csv_ice_file_class.dart';
import 'package:pso2_mod_manager/classes/csv_item_class.dart';
import 'package:pso2_mod_manager/classes/enum_classes.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/mod_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/classes/mod_set_class.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:pso2_mod_manager/classes/profile_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:signals/signals.dart';

String curActiveLang = '';
List<String> langDropDownList = [];
String langDropDownSelected = '';
List<String> topBtnMenuItems = [];
String appVersion = '';
String savedAppVersion = '';
int refSheetsVersion = -1;
//FilePickerResult? checksumLocation;
String? checksumLocation;
bool previewWindowVisible = true;
double windowsWidth = 1280.0;
double windowsHeight = 720.0;
Directory dataDir = Directory('');
var dataStreamController = StreamController();
TextEditingController newSetTextController = TextEditingController();
TextEditingController newLangTextController = TextEditingController();
final newSetFormKey = GlobalKey<FormState>();
bool firstTimeUser = false;
String versionToSkipUpdate = '';
//String? localChecksumMD5;
//String? win32ChecksumMD5;
//String win32CheckSumFilePath = '';
List<String> ogWin32FilePaths = [];
List<String> ogWin32RebootFilePaths = [];
List<String> ogWin32NAFilePaths = [];
List<String> ogWin32RebootNAFilePaths = [];
List<List<String>> ogDataFilePaths = [ogWin32FilePaths, ogWin32RebootFilePaths, ogWin32NAFilePaths, ogWin32RebootNAFilePaths];
List<CategoryType> moddedItemsList = [];
// List<CategoryType> appliedItemList = [];
bool showBackgroundImage = true;
bool listsReloading = false;
bool isEmptyCatesHide = false;
List<CategoryType> hiddenItemCategories = [];
List<ModSet> modSetList = [];
List<Item> allSetItems = [];
// bool isModSetAdding = false;
// Item? modViewItem;
bool isModViewListHidden = false;
bool isModViewFromApplied = false;
List<Widget> previewImages = [];
String previewModName = '';
List<String> defaultCategoryTypes = ['Cast Parts', 'Layering Wears', 'Others'];
List<String> defaultCategoryTypeNames = [curLangText!.dfCastParts, curLangText!.dfLayeringWears, curLangText!.dfOthers];
//List<String> defaultCategoryTypesJP = ['キャストパーツ', 'レイヤリングウェア', 'その他'];
//Default Mod Caterories
List<String> defaultCategoryNames = [
  curLangText!.dfAccessories, //0
  curLangText!.dfBasewears, //1
  curLangText!.dfBodyPaints, //2
  curLangText!.dfCastArmParts, //3
  curLangText!.dfCastBodyParts, //4
  curLangText!.dfCastLegParts, //5
  curLangText!.dfCostumes, //6
  curLangText!.dfEmotes, //7
  curLangText!.dfEyes, //8
  curLangText!.dfFacePaints, //9
  curLangText!.dfHairs, //10
  curLangText!.dfInnerwears, //11
  curLangText!.dfMags, //12
  curLangText!.dfMisc, //13
  curLangText!.dfMotions, //14
  curLangText!.dfOuterwears, //15
  curLangText!.dfSetwears, //16
  curLangText!.dfWeapons //17
];
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
List<String> defaultCategoryDirsToIgnoreQuickSwapApply = [
  // 'Accessories', //0
  // 'Basewears', //1
  // 'Body Paints', //2
  // 'Cast Arm Parts', //3
  // 'Cast Body Parts', //4
  // 'Cast Leg Parts', //5
  // 'Costumes', //6
  'Emotes', //7
  // 'Eyes', //8
  // 'Face Paints', //9
  // 'Hairs', //10
  // 'Innerwears', //11
  'Mags', //12
  'Misc', //13
  'Motions', //14
  // 'Outerwears', //15
  // 'Setwears', //16
  'Weapons' //17
];
// List<String> defaultCateforyDirsJP = [
//   'アクセサリー', //0
//   'ベースウェア/フルセットウェア', //1
//   'ボディペイント', //2
//   'キャストアームパーツ', //3
//   'キャストボディパーツ', //4
//   'キャストレッグパーツ', //5
//   'コスチューム', //6
//   'ロビーアクション', //7
//   '瞳・まゆ・まつげ', //8
//   'メイクパターン', //9
//   'ヘアスタイル', //10
//   'インナーウェア', //11
//   'マグ', //12
//   'その他', //13
//   'モーション', //14
//   'アウターウェア', //15
//   'セットウェア' //16
// ];
final modViewModsApplyRemoving = signal<bool>(false);
List<ModFile> startupReappliedModFiles = [];
List<Widget> previewDialogImages = [];
String previewDialogModName = '';
String isAutoFetchingIconsOnStartup = 'minimal';
//List<List<String>> csvInfosFromSheets = [];
//swapper
bool isReplacingNQWithHQ = false;
bool isCopyAll = false;
bool isRemoveExtras = false;
bool isEmotesToStandbyMotions = false;
List<CsvIceFile> csvData = [];
List<CsvIceFile> availableItemsCsvData = [];
List<CsvAccessoryIceFile> csvAccData = [];
List<CsvAccessoryIceFile> availableAccCsvData = [];
List<CsvWeaponIceFile> availableWeaponCsvData = [];
List<CsvEmoteIceFile> csvEmotesData = [];
List<CsvWeaponIceFile> csvWeaponsData = [];
List<CsvEmoteIceFile> availableEmotesCsvData = [];
List<String> officialServerFileList = [];
List<String> officialMasterFiles = [];
List<String> officialPatchFiles = [];
List<CsvItem> playerItemData = [];
String charToReplace = '[\\/:*?"<>|]';
String charToReplaceWithoutSeparators = '[:*?"<>|]';
int modManCurActiveProfile = 1;
String modManProfile1Name = '';
String modManProfile2Name = '';
bool modsAdderGroupSameItemVariants = false;
//bool isStartupModsLoad = true;
bool firstTimeLanguageSet = true;
String profanityFilterIce = 'ffbff2ac5b7a7948961212cefd4d402c';
bool profanityFilterRemoval = false;
int modManRefSheetsLocalVersion = 0;
bool isSlidingItemIcons = false;
bool profanityFilterRemove = false;
bool removeBoundaryRadiusOnModsApply = false;
bool prioritizeLocalBackup = false;
List<ModFile> selectedModFilesInAppliedList = [];
List<SubMod> selectedSubmodsInAppliedList = [];
bool cmxRefreshing = false;
String modManCurActiveItemNameLanguage = '';
bool modAdderIgnoreListState = false;
bool showPreviewPanel = false;
bool autoAqmInject = false;
String modManCustomAqmFileName = '';
String modManCustomAqmFilePath = '';
bool gameguardAnticheat = false;
List<CsvItem> quickApplyItemList = [];
bool itemsWithNewModsOnTop = false;
bool newModsOnTop = false;
bool markModdedItem = false;
final saveApplyButtonState = signal<SaveApplyButtonState>(SaveApplyButtonState.none);
bool itemListCateExpansionState = false;
bool modAdderAddToModSets = false;
bool aqmAutoBoundingRadius = false;
