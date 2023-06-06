// ignore_for_file: unused_import

import 'dart:async';
import 'dart:io';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/classes/mod_set_class.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

String curActiveLang = '';
List<String> langDropDownList = [];
String langDropDownSelected = '';
List<String> topBtnMenuItems = [];
String appVersion = '';
int refSheetsVersion = -1;
FilePickerResult? checksumLocation;
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
String? localChecksumMD5;
String? win32ChecksumMD5;
String win32CheckSumFilePath = '';
List<String> ogWin32FilePaths = [];
List<String> ogWin32RebootFilePaths = [];
List<String> ogWin32NAFilePaths = [];
List<String> ogWin32RebootNAFilePaths = [];
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
  'Accessories',
  'Basewears',
  'Body Paints',
  'Cast Arm Parts',
  'Cast Body Parts',
  'Cast Leg Parts',
  'Costumes',
  'Emotes',
  'Eyes',
  'Face Paints',
  'Hairs',
  'Innerwears',
  'Mags',
  'Misc',
  'Motions',
  'Outerwears',
  'Setwears'
];
bool isModViewModsApplying = false;
bool isModViewModsRemoving = false;
List<ModFile> startupReappliedModFiles = [];
List<Widget> previewDialogImages = [];
String previewDialogModName = '';
