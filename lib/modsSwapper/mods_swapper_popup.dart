
import 'package:card_banner/card_banner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_data_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';



String toItemName = '';


void modsSwapperDialog(context, Item fromItem, SubMod fromSubmod) {
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
              child: SizedBox(width: MediaQuery.of(context).size.width * 0.8, height: MediaQuery.of(context).size.height, child: ModsSwapperDataLoader(fromItem: fromItem, fromSubmod: fromSubmod)),
            ));
      });
}
