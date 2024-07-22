import 'dart:io';

import 'package:pso2_mod_manager/aqmInjection/aqm_injection_homepage.dart';
import 'package:pso2_mod_manager/aqmInjection/aqm_injection_page.dart';
import 'package:pso2_mod_manager/classes/aqm_item_class.dart';
import 'package:pso2_mod_manager/global_variables.dart';

Future<List<AqmItem>> appliedAqmItemCheck(context) async {
  List<AqmItem> reappliedItems = [];
  if (modManCustomAqmFilePath.isNotEmpty && File(modManCustomAqmFilePath).existsSync()) {
    final appliedAqmItems = await basewearsListGet();
    for (var item in appliedAqmItems) {
      if (item.isApplied) {
        itemAqmInject(context, item.hqIcePath, item.lqIcePath, item.iconIcePath);
        reappliedItems.add(item);
      }
    }
  }
  return reappliedItems;
}
