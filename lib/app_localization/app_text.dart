import 'package:json_annotation/json_annotation.dart';

part 'app_text.g.dart';

AppText appText = AppText();

@JsonSerializable()
class AppText {
  AppText();

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
      defaults = 'Default';

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
      numModsCurrentlyApplied = '%p% Currently Applied',
      viewMods = 'View Mods',
      profileNum = 'Profile %p%',
      apply = 'Apply',
      restore = 'Restore',
      moreOptions = 'More Options',
      numVariant = '%p% Variant',
      numVariants = '%p% Variants';

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
      resetToDefaultColor = 'Reset To Default Theme Color';

  // Errors
  String failedToFetchRemoteLocaleData = 'Failed to fetch remote locale data',
      unableToUpdateFile = 'Unable to update %p%',
      unableToGetAppVersionDataFromGitHub = 'Unable to get app version data from GitHub',
      unableToGetItemDataVersionDataFromGitHub = 'Unable to get item data version data from GitHub';

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
      themeColorSchemes = 'Theme Color Schemes',
      backgroundSlideshow = 'Background Slideshow';

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
}
