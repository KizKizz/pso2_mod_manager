import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/classes/csv_ice_file_class.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/itemsSwapper/items_swapper_wp_homepage.dart';

List<CsvWeaponIceFile> wpSwapperDropDownItemSort(String searchedText, String selectedWeaponType, String selectedItemType, String selectedItemVar) {
  List<CsvWeaponIceFile> sortedList = [];
  List<CsvWeaponIceFile> baseList = [];

  if (searchedText.isNotEmpty) {
    baseList = csvWeaponsData
        .where((element) => modManCurActiveItemNameLanguage == 'JP'
            ? element.jpName.toLowerCase().contains(swapperFromItemsSearchTextController.text.toLowerCase())
            : element.enName.toLowerCase().contains(swapperFromItemsSearchTextController.text.toLowerCase()))
        .toList();
  } else {
    baseList = csvWeaponsData;
  }

  //sort
  if (selectedItemType == itemTypes.first && selectedWeaponType == weaponTypes.first) {
    sortedList = baseList;
  } else if (selectedItemType == itemTypes.first && selectedWeaponType != weaponTypes.first) {
    sortedList = baseList.where((element) => element.subCategory.contains(selectedWeaponType)).toList();
  } else if (selectedItemType != itemTypes.first && selectedWeaponType == weaponTypes.first) {
    sortedList = baseList.where((element) => element.itemType.contains(selectedItemType)).toList();
  } else {
    sortedList = baseList.where((element) => element.subCategory.contains(selectedWeaponType) && element.itemType.contains(selectedItemType)).toList();
  }
  if (selectedItemVar == itemVars[2]) {
    if (sortedList.isEmpty) sortedList = baseList;
    sortedList = sortedList.where((element) => element.subCategory.characters.first == '*' || element.subCategory.characters.first == '*').toList();
  } else if (selectedItemVar == itemVars[1]) {
    if (sortedList.isEmpty) sortedList = baseList;
    sortedList = sortedList.where((element) => element.subCategory.characters.first != '*' || element.subCategory.characters.first != '*').toList();
  }

  debugPrint('$selectedWeaponType > $selectedItemVar > $selectedItemType');

  return sortedList;
}
