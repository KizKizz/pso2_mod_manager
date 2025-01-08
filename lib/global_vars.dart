import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_paths/sega_file_paths.dart';
import 'package:pso2_mod_manager/mod_add/item_data_class.dart';
import 'package:pso2_mod_manager/mod_data/category_type_class.dart';
import 'package:pso2_mod_manager/mod_sets/mod_set_class.dart';
import 'package:signals/signals_flutter.dart';

String curAppVersion = '';
bool offlineMode = false;
List<CategoryType> masterModList = [];
List<ModSet> masterModSetList = [];
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

TextEditingController searchTextController = TextEditingController();
Signal<List<File>> backgroundImageFiles = Signal([]);
List<String> modAddDragDropPaths = [];
List<ItemData> pItemData = [];
List<OfficialIceFile> oItemData = [];
