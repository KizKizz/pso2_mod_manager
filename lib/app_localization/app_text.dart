import 'package:json_annotation/json_annotation.dart';
import 'package:pso2_mod_manager/global_vars.dart';

part 'app_text.g.dart';

AppText appText = AppText();

@JsonSerializable()
class AppText {
  AppText();

  //Default category types
  String dfCastParts = 'Cast Parts', dfLayeringWears = 'Layering Wears', dfOthers = 'Others';

  //Default category names
  String dfAccessories = 'Accessories', //0
      dfBasewears = 'Basewears', //1
      dfBodyPaints = 'Body Paints', //2
      dfCastArmParts = 'Cast Arm Parts', //3
      dfCastBodyParts = 'Cast Body Parts', //4
      dfCastLegParts = 'Cast Leg Parts', //5
      dfCostumes = 'Costumes', //6
      dfEmotes = 'Emotes', //7
      dfEyes = 'Eyes', //8
      dfFacePaints = 'Face Paints', //9
      dfHairs = 'Hairs', //10
      dfInnerwears = 'Innerwears', //11
      dfMags = 'Mags', //12
      dfMisc = 'Misc', //13
      dfMotions = 'Motions', //14
      dfOuterwears = 'Outerwears', //15
      dfSetwears = 'Setwears', //16
      dfWeapons = 'Weapons'; //17

  // One word Strings
  String ok = 'OK',
      cancel = 'Cancel',
      cont = 'Continue',
      error = 'Error',
      update = 'Update',
      skip = 'Skip',
      later = 'Later',
      status = 'Status',
      patch = "Patch",
      pause = 'Pause',
      resume = 'Resume',
      browse = 'Browse',
      save = 'Save',
      exit = 'Exit',
      settings = 'Settings',
      search = 'Search',
      returns = 'Return',
      close = 'Close',
      reset = 'Reset',
      defaults = 'Default',
      refresh = 'Refresh',
      hide = 'Hide',
      show = 'Show',
      remove = 'Remove',
      on = 'On',
      off = 'Off',
      view = 'View',
      xnew = 'New',
      file = 'File',
      folder = 'Folder',
      clear = 'Clear';

  // Short Strings
  String patchNotes = 'Patch Notes',
      appUpdate = 'App Update',
      tryAgain = 'Try Again',
      tryAgainLater = 'Try Again Later',
      modList = 'Mod List',
      itemList = 'Item List',
      modSets = 'Mod Sets',
      numMod = '%p% Mod',
      numMods = '%p% Mods',
      numCurrentlyApplied = '%p% Currently Applied',
      viewMods = 'View Mods',
      profileNum = 'Profile %p%',
      apply = 'Apply',
      restore = 'Restore',
      moreOptions = 'More Options',
      numVariant = '%p% Variant',
      numVariants = '%p% Variants',
      intervalNumSecond = 'Interval: %p%s',
      loading = 'Loading...',
      viewVariants = 'View Variants',
      addMods = 'Add Mods',
      addFolders = 'Add Folders',
      addFiles = 'Add Files',
      processFiles = 'Process Files',
      ignoreList = 'Ignore List';

  // Text Strings
  String loadingUILanguage = 'Loading UI Language',
      selectUILanguage = 'Select UI language',
      selectItemNameLanguage = 'Select item name language',
      checkingAppVersion = 'Checking App Version',
      newAppVersionFound = 'New App Version Found',
      extractingDownloadedZipFile = 'Extracting downloaded zip file',
      extractCompletedReadyToPatch = 'Extract completed, ready to patch',
      cannotCreatePatchLauncherCheckPerm = 'Cannot create patch launcher, check permission',
      checkingItemDataVersion = 'Checking Item Data Version',
      newItemDataVersionFound = 'New Item Data Version Found',
      fetchingNecessaryDirPaths = 'Fetching Necessary Directory Paths',
      missingPathsFound = 'Missing Path(s) Found',
      pso2binDirPath = 'pso2_bin directory path',
      mainDirPath = 'Main directory path',
      loadingModFiles = 'Loading Mod Files',
      selectAMod = 'Select a mod',
      resetToStartingColor = 'Reset to Starting Color',
      saveSelectedColorAndReturn = 'Save Selected Color & Return',
      returnWithoutSaving = 'Return Without Saving',
      resetToDefaultColor = 'Reset To Default Theme Color',
      dragdropBoxMessage = 'Drag and drop files or folders here',
      dragdropBoxMessage2 = 'Only .zip, .rar, .7z, and ice files are supported';

  // Errors
  String failedToFetchRemoteLocaleData = 'Failed to fetch remote locale data',
      unableToUpdateFile = 'Unable to update %p%',
      unableToGetAppVersionDataFromGitHub = 'Unable to get app version data from GitHub',
      unableToGetItemDataVersionDataFromGitHub = 'Unable to get item data version data from GitHub',
      fileIsNotSupported = '"%p%" is not supported',
      fileAlreadyOnTheList = '"%p%" already on the list';

  // Infos
  String pso2binDirPathInfo = 'PSO2 game data folder, this folder located inside the game installation directory',
      mainDirPathInfo = 'This folder stores your mods and other Mod Manager related stuff\nPreferably outside of pso2 installation directory and nested folders';

  // Settings Text
  String appSettings = 'App Settings',
      uiLanguage = 'UI Language',
      itemNameLanguage = 'Item Name Language',
      modSettings = 'Mod Settings',
      others = 'Others',
      themeMode = 'Theme Mode',
      light = 'Light',
      dark = 'Dark',
      uiOpacity = 'UI Opacity',
      themeColorScheme = 'Theme Color Scheme',
      backgroundSlideshow = 'Background Slideshow',
      addImages = 'Add Images',
      itemIconSlides = 'Item Icon Slides';

  factory AppText.fromJson(Map<String, dynamic> json) => _$AppTextFromJson(json);
  Map<String, dynamic> toJson() => _$AppTextToJson(this);

  String dText(String text, String param) {
    return text.replaceFirst('%p%', param);
  }

  String dTexts(String text, List<String> params) {
    String newText = text;
    for (var param in params) {
      newText = newText.replaceFirst('%p%', param);
    }
    return newText;
  }

  String categoryTypeName(String name) {
    int index = defaultCategoryTypes.indexOf(name);

    switch (index) {
      case 0:
        return dfCastParts;
      case 1:
        return dfLayeringWears;
      case 2:
        return dfOthers;
      default:
        return name;
    }
  }

  String categoryName(String name) {
    int index = defaultCategoryDirs.indexOf(name);

    switch (index) {
      case 0:
        return dfAccessories;
      case 1:
        return dfBasewears;
      case 2:
        return dfBodyPaints;
      case 3:
        return dfCastArmParts;
      case 4:
        return dfCastBodyParts;
      case 5:
        return dfCastLegParts;
      case 6:
        return dfCostumes;
      case 7:
        return dfEmotes;
      case 8:
        return dfEyes;
      case 9:
        return dfFacePaints;
      case 10:
        return dfHairs;
      case 11:
        return dfInnerwears;
      case 12:
        return dfMags;
      case 13:
        return dfMisc;
      case 14:
        return dfMotions;
      case 15:
        return dfOuterwears;
      case 16:
        return dfSetwears;
      case 17:
        return dfWeapons;
      default:
        return name;
    }
  }
}
