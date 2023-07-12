import 'dart:io';

import 'package:card_banner/card_banner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/itemsSwapper/items_swapper_data_loader.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';

String modManSwapperDirPath = Uri.file('${Directory.current.path}/swapper').toFilePath();
String modManSwapperFromItemDirPath = Uri.file('${Directory.current.path}/swapper/fromitem').toFilePath();
String modManSwapperToItemDirPath = Uri.file('${Directory.current.path}/swapper/toitem').toFilePath();
String modManSwapperOutputDirPath = Uri.file('${Directory.current.path}/swapper/Swapped Items').toFilePath();

String toItemName = '';

bool isReplacingNQWithHQ = false;
bool isCopyAll = false;
bool isRemoveExtras = false;
bool isEmotesToStandbyMotions = false;
List<String> swapCategoriesF = [
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
  'Motions',
  'Outerwears',
  'Setwears'
];

String selectedCategoryF = swapCategoriesF[1];

void itemsSwapperDialog(context) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
            backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
            contentPadding: const EdgeInsets.all(5),
            content: CardBanner(
              text: curLangText!.uiExperimental,
              color: Colors.red,
              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              position: CardBannerPosition.TOPRIGHT,
              padding: 2,
              edgeSize: 0,
              child: SizedBox(width: MediaQuery.of(context).size.width * 0.8, height: MediaQuery.of(context).size.height, child: const ItemsSwapperDataLoader()),
            ));
      });
}
