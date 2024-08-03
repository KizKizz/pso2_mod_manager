import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_wp_homepage.dart';

String uiInTextArgs(String uiText, List<String> inTextArgs, List<dynamic> args) {
  String tempText = uiText;
  if (inTextArgs.length == args.length) {
    for (int i = 0; i < inTextArgs.length; i++) {
      tempText = tempText.replaceAll(inTextArgs[i], args[i]);
    }
  }

  return tempText;
}

String uiInTextArg(String uiText, dynamic arg) {
  return uiText.replaceAll('<x>', arg);
}

void widgetsLanguageRefresh() {
  defaultCategoryTypeNames = [curLangText!.dfCastParts, curLangText!.dfLayeringWears, curLangText!.dfOthers];
  defaultCategoryNames = [
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

  weaponTypes = [
    curLangText!.uiAll,
    curLangText!.uiSwords,
    curLangText!.uiWiredLances,
    curLangText!.uiPartisans,
    curLangText!.uiTwinDaggers,
    curLangText!.uiDoubleSabers,
    curLangText!.uiKnuckles,
    curLangText!.uiKatanas,
    curLangText!.uiSoaringBlades,
    curLangText!.uiAssualtRifles,
    curLangText!.uiLaunchers,
    curLangText!.uiTwinMachineGuns,
    curLangText!.uiBows,
    curLangText!.uiGunblades,
    curLangText!.uiRods,
    curLangText!.uiTalises,
    curLangText!.uiWands,
    curLangText!.uiJetBoots,
    curLangText!.uiHarmonizers,
    curLangText!.uiUnknownWeapons
  ];

//   motionTypes = [
//   curLangText!.uiAll,
//   curLangText!.uiGlideMotion,
//   curLangText!.uiJumpMotion,
//   curLangText!.uiLandingMotion,
//   curLangText!.uiDashMotion,
//   curLangText!.uiRunMotion,
//   curLangText!.uiStandbyMotion,
//   curLangText!.uiSwimMotion
// ];

  itemTypes = [curLangText!.uiAll, curLangText!.uiPSO2, curLangText!.uiNGS];

  itemVars = [curLangText!.uiAll, curLangText!.uiWeapons, curLangText!.uiCamos];
}
