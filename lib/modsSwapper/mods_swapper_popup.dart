import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_data_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';

String modManSwapperDirPath = Uri.file('${Directory.current.path}/swapper').toFilePath();
String modManSwapperFromItemDirPath = Uri.file('${Directory.current.path}/swapper/fromitem').toFilePath();
String modManSwapperToItemDirPath = Uri.file('${Directory.current.path}/swapper/toitem').toFilePath();
String modManSwapperOutputDirPath = Uri.file('${Directory.current.path}/swapper/Swapped Items').toFilePath();

String toItemName = '';

bool isReplacingNQWithHQ = false;
bool isCopyAll = false;
bool isRemoveExtras = false;

void modsSwapperDialog(context, Item fromItem, SubMod fromSubmod) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
            backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
            contentPadding: const EdgeInsets.all(5),
            content: Banner(
              message: 'Experimental', textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal), location: BannerLocation.topEnd,
              child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height,
                  child: ModsSwapperDataLoader(fromItem: fromItem, fromSubmod: fromSubmod)),
            ));
      });
}
