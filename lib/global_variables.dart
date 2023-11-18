// ignore_for_file: unused_import

import 'dart:async';
import 'dart:io';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/classes/csv_ice_file_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/classes/mod_set_class.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:pso2_mod_manager/classes/profile_class.dart';

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
List<CategoryType> appliedItemList = [];
bool showBackgroundImage = true;
bool listsReloading = false;
bool isEmptyCatesHide = false;
List<CategoryType> hiddenItemCategories = [];
List<ModSet> modSetList = [];
List<Item> allSetItems = [];
bool isModSetAdding = false;
Item? modViewItem;
bool isModViewListHidden = false;
bool isModViewFromApplied = false;
List<Widget> previewImages = [];
String previewModName = '';
List<String> defaultCategoryTypes = ['Cast Parts', 'Layering Wears', 'Others'];
//Default Mod Caterories
List<String> defaultCateforyDirs = [
  'Accessories',      //0
  'Basewears',        //1
  'Body Paints',      //2
  'Cast Arm Parts',   //3
  'Cast Body Parts',  //4
  'Cast Leg Parts',   //5
  'Costumes',         //6
  'Emotes',           //7
  'Eyes',             //8
  'Face Paints',      //9
  'Hairs',            //10
  'Innerwears',       //11
  'Mags',             //12
  'Misc',             //13
  'Motions',          //14
  'Outerwears',       //15
  'Setwears'          //16
];
bool isModViewModsApplying = false;
bool isModViewModsRemoving = false;
List<ModFile> startupReappliedModFiles = [];
List<Widget> previewDialogImages = [];
String previewDialogModName = '';
String isAutoFetchingIconsOnStartup = 'minimal';
List<List<String>> csvInfosFromSheets = [];
//swapper
bool isReplacingNQWithHQ = false;
bool isCopyAll = false;
bool isRemoveExtras = false;
bool isEmotesToStandbyMotions = false;
List<CsvIceFile> csvData = [];
List<CsvIceFile> availableItemsCsvData = [];
List<CsvAccessoryIceFile> csvAccData = [];
List<CsvAccessoryIceFile> availableAccCsvData = [];
List<CsvEmoteIceFile> csvEmotesData = [];
List<CsvEmoteIceFile> availableEmotesCsvData = [];
List<String> officialPatchServerFileList = [];
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
