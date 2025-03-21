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

  // Motion Type Names
  String dfGlideMotion = 'Glide Motion',
      dfJumpMotion = 'Jump Motion',
      dfLandingMotion = 'Landing Motion',
      dfDashMotion = 'Dash Motion',
      dfRunMotion = 'Run Motion',
      dfStandbyMotion = 'Standby Motion',
      dfSwimMotion = 'Swim Motion';

  // Sorting Name
  String nameAlphabetical = 'Name (Alphabetical)', recentlyAdded = 'Recently Added', recentlyApplied = 'Recently Applied';

  // Line Strike types
  String cards = 'Cards', boards = 'Boards', sleeves = 'Sleeves';

  // Card Elements
  String cardDarkElement = 'Dark', cardLightElement = 'Light', cardFireElement = 'Fire', cardIceElement = 'Ice', cardLightningElement = 'Lightning', cardWindElement = 'Wind';

  // Weapon types
  String wpSwords = 'Swords',
      wpWiredLances = 'Wired Lances',
      wpPartisans = 'Partisans',
      wpTwinDaggers = 'Twin Daggers',
      wpDoubleSabers = 'Double Sabers',
      wpKnuckles = 'Knuckles',
      wpKatanas = 'Katanas',
      wpSoaringBlades = 'Soaring Blades',
      wpAssaultRifles = 'Assault Rifles',
      wpLaunchers = 'Launchers',
      wpTwinMachineGuns = 'Twin Machine Guns',
      wpBows = 'Bows',
      wpGunblades = 'Gunblades',
      wpRods = 'Rods',
      wpTalises = 'Talises',
      wpWands = 'Wands',
      wpJetBoots = 'Jet Boots',
      wpHarmonizers = 'Harmonizers';

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
      clear = 'Clear',
      process = 'Process',
      add = 'Add',
      rename = 'Rename',
      both = 'Both',
      swap = 'Swap',
      types = 'Types',
      all = 'All',
      motions = 'Motions',
      next = 'Next',
      normal = 'Normal',
      open = 'Open',
      successful = 'Successful',
      failed = 'Failed',
      replace = 'Replace',
      cmx = 'CMX',
      aqm = 'AQM',
      bounding = 'Bounding',
      export = 'Export',
      delete = 'Delete',
      sort = 'Sort',
      create = 'Create',
      success = 'Success',
      checksum = 'Checksum',
      profiles = 'Profiles',
      profile1 = 'Profile 1',
      profile2 = 'Profile 2',
      reload = 'Reload',
      overwrite = 'Overwrite',
      images = 'Images',
      videos = 'Videos',
      select = 'Select',
      continues = 'Continue',
      imported = 'Imported',
      filters = 'Filters',
      details = 'Details',
      help = 'Help';

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
      intervalNumSecond = '%p%s',
      loading = 'Loading...',
      viewVariants = 'View Variants',
      addMods = 'Add Mods',
      addFolders = 'Add Folders',
      addFiles = 'Add Files',
      processFiles = 'Process Files',
      ignoreList = 'Ignore List',
      archives = 'Archives',
      iceFiles = 'Ice Files',
      step1 = 'Step 1',
      step2 = 'Step 2',
      processingItems = 'Processing Items',
      numMatchedItem = '%p% Matched Item',
      numMatchedItems = '%p% Matched Items',
      editItemsAndVariants = 'Edit Items & Variants',
      saveAndReturn = 'Save & Return',
      numFile = '%p% File',
      numFiles = '%p% Files',
      matchedItems = 'Matched Items',
      changeTextTo = 'Change "%p%" to',
      itemSwap = 'Item Swap',
      openInFileExplorer = 'Open In File Explorer',
      downloadingFileName = 'Downloading %p%',
      addToModManager = 'Add To Mod Manager',
      creatingBackupForModFile = 'Creating backup for %p%',
      copyingModFileToGameData = 'Copying %p% to game data',
      copyingIconFileToGameData = 'Copying icon "%p%" to game data',
      localBackupFoundForModFile = 'Local backup found for %p%',
      restoringBackupFileToGameData = 'Restoring %p% to game data',
      applyingMod = 'Applying "%p%"',
      restoringModBackups = 'Restoring "%p%" Backups',
      numItems = '%p% Items',
      numItem = '%p% Item',
      addToSet = 'Add to Set',
      setApplyLocations = 'Set apply locations',
      swapToAnotherItem = 'Swap to another item',
      addPreviews = 'Add previews',
      removeBoundingRadius = 'Remove bounding radius',
      injectCustomAQM = 'Inject custom AQM',
      removeCustomAQMs = 'Remove custom AQM',
      editingMod = 'Editing "%p%"',
      extractingFile = 'Extracting "%p%"',
      readingFile = 'Reading "%p%"',
      boundingValueFoundReplacingWithNewValue = 'Bounding value found, replacing it with "%p%"',
      boundingValueNotFoundInFile = 'Bounding radius value not found in "%p%"',
      repackingFile = 'Repacking "%p%"',
      aqmInject = 'AQM Inject',
      injectAQM = 'Inject AQM',
      removeBounding = 'Remove Bounding',
      aqmInjected = 'AQM Injected',
      boundingRemoved = 'Bounding Removed',
      removeCustomAQM = 'Remove Custom AQM',
      restoreBounding = 'Restore Bounding',
      restoreAll = 'Restore All',
      permanentlyDeleteItem = 'Permanently delete "%p%"?',
      holdToDelete = 'Hold To Delete',
      successfullyDeletedItem = 'Successfully deleted "%p%"',
      setSubmodToBeActiveInSet = 'Set "%p%" to be active in "%p%" Set',
      submodIsCurrentlyActiveInSet = '"%p%" is currently active in "%p%" Set',
      notFoundClickToBrowse = 'Not Found. Click To Browse',
      vitalGauge = 'Vital Gauge',
      convertingFileToDds = 'Converting "%p%" to dds',
      imageName = 'Image Name',
      showAll = 'Show All',
      lineStrike = 'Line Strike',
      exportingFile = 'Exporting "%p%',
      convertingFileToPng = 'Converting "%p%" to png',
      restoringFile = 'Restoring "%p%"',
      successfullyAppliedFile = 'Successfully applied "%p%"',
      failedToApplyFile = 'Failed to apply "%p%"',
      successfullyRestoredFile = 'Successfully restored "%p%"',
      failedToRestoredFile = 'Failed to restore "%p%"',
      reapplyingFile = 'Re-Applying "%p%"',
      extensionFile = '%p% File',
      applyThisSet = 'Apply This Set',
      restoreThisSet = 'Restore This Set',
      launchPSO2 = 'Launch PSO2',
      swapAll = 'Swap All',
      modExport = 'Mod Export',
      enterANameToExport = 'Enter a name to export',
      exportingMods = 'Exporting Mods',
      unknownMod = 'Unknown Mod',
      enterModName = 'Enter mod name',
      clearAll = 'Clear All',
      backupSuccess = 'Backup success',
      applyLocations = 'Apply Locations',
      applyToAllLocations = 'Apply To All Locations',
      currentlyApplyingToLocations = 'Currently applying to: %p%',
      allLocations = 'All locations',
      defaultHomepage = 'Default Homepage',
      madeBy = 'Made by %p%',
      holdToRestoreNumAppliedMods = 'Hold To Restore %p% Applied Mods',
      holdToRestoreNumAppliedMod = 'Hold To Restore %p% Applied Mod',
      injectedAQMFile = 'Injected AQM: %p%',
      addingMods = 'Adding Mods',
      modHasBeenAddedToSet = '"%p%" has been added to "%p%" Set',
      modHasBeenRemovedFromSet = '"%p%" has been removed from "%p%" Set',
      addToSets = 'Add To Sets',
      refreshItemIcon = 'Refresh Item Icons',
      refreshingItemIcons = 'Refreshing Item Icons',
      fetchingIconsInItem = 'Fetching Icons In "%p%"',
      selectAll = 'Select All',
      viewQueue = 'View Queue',
      hideQueue = 'Hide Queue',
      addToQueue = 'Add To Queue',
      latestBackup = 'Latest Backup: %p%';

  // Text Strings
  String loadingUILanguage = 'Loading UI Language',
      selectUILanguage = 'Select UI language',
      selectItemNameLanguage = 'Select item name language',
      checkingAppVersion = 'Checking App Version',
      newAppVersionFound = 'New App Version Found',
      extractingDownloadedZipFile = 'Extracting downloaded zip file',
      extractCompletedReadyToPatch = 'Extraction completed, ready to patch',
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
      dragdropBoxMessage2 = 'Only .zip, .rar, .7z, .pmm and ice files are supported',
      checkingGitHubAccess = 'Checking GitHub Access',
      accessToGitHubIsLimited = 'Access to GitHub is limited',
      itemDataManualDownloadMessage = 'Please download Item Data directly from the provided link, then browse its location\nSkip if you already have the latest Item Data',
      downloadItemData = 'Download Item Data',
      browseDownloadedItemDataLocation = 'Browse Downloaded Item Data Location',
      loadingItemData = 'Loading Item Data',
      waitingForItems = 'Waiting For Items',
      fetchingDataFromSegaServers = 'Fetching Data From Sega Servers',
      enterNewNameHere = 'Enter new name here',
      loadingModSets = 'Loading Mod Sets',
      addNewSet = 'Add New Set',
      showNoNameItems = 'Show No Name Items',
      hideNoNameItems = 'Hide No Name Items',
      swapToIdleMotions = 'Swap To Idle Motions',
      swapToEmotes = 'Swap To Emotes',
      swapToBasewears = 'Swap To Basewears',
      swapToSetwears = 'Swap To Setwears',
      swapToBodyPaints = 'Swap To Body Paints',
      swapToInnerwears = 'Swap To Innerwears',
      replaceLQTexturesWithHQ = 'Replace LQ Textures With HQ',
      sortingFileData = 'Sorting file data',
      itemSwapFinished = 'Item Swap Finished',
      fileDownloadSuccessful = 'File download successful',
      fileDownloadFailed = 'File download failed',
      checkingAppliedMods = 'Checking Applied Mods',
      restoredMods = 'Restored Mods',
      reApplyAll = 'Re-Apply All',
      removeAll = 'Remove All',
      appliedList = 'Applied List',
      duplicatesInAppliedMods = 'Duplicates In Applied Mods',
      duplicateInAQMInjectedItems = 'Duplicate In AQM Injected Items',
      matchingFilesFound = 'Matching files found',
      noMatchingFilesFound = 'No matching files found',
      loadingAqmInjectedItems = 'Loading AQM Injected Items',
      addCustomAqmFiles = 'Add Custom AQM Files',
      currentAqmFile = 'Current AQM File',
      fetchingFiles = 'Fetching Files',
      newModSet = 'New Mod Set',
      enterNewSetName = 'Enter name of the Set',
      createNewBackground = 'Create New Background',
      loadingVitalGaugeBackgrounds = 'Loading Vital Gauge Backgrounds',
      generatingIceFile = 'Generating ice file',
      showAppliedOnly = 'Show Applied Only',
      checkingAppliedVitalGauges = 'Checking Applied Vital Gauges',
      loadingLineStrikeCards = 'Loading Line Strike Cards',
      loadingLineStrikeBoards = 'Loading Line Strike Boards',
      loadingLineStrikeSleeves = 'Loading Line Strike Sleeves',
      selectCardElement = 'Select Card Element',
      exportToPngImage = 'Export to png image',
      checkingAppliedLineStrikeItems = 'Checking Applied Line Strike Items',
      loadingQuickSwapItems = 'Loading Quick Swap Items',
      selecteMoreItems = 'Select More Items',
      selectSetsToAdd = 'Select Set(s) to add',
      enterFilterText = 'Enter filter text (Case sensitive)',
      currentFilters = 'Current Filters',
      addFilter = 'Add Filter',
      collapseAll = 'Collapse All',
      expandAll = 'Expand All',
      weaponTypes = 'Weapon Types',
      replaceTheEntireMod = 'Replace The Entire Mod',
      replaceConflictedFilesOnly = 'Replace Conflicted Files Only',
      skipConflictedFiles = 'Skip Conflicted Files',
      conflictingFiles = 'Conflicting files:',
      categorizeModsByItems = 'Categorize Mods By Items',
      modConfigsRestore = 'Mod Configs Restore',
      saveAndRestoreAllAppliedMods = 'Save & Restore All Applied Mods',
      reApplyAllSavedMods = 'Re-Apply All Saved Mods',
      savingModFilesAndRestoringOriginalFiles = 'Saving Mod Files And Restoring Original Files',
      reApplyingSavedModFiles = 'Re-Applying Saved Mod Files';

  // Errors
  String failedToFetchRemoteLocaleData = 'Failed to fetch remote locale data',
      unableToUpdateFile = 'Unable to update %p%',
      unableToGetAppVersionDataFromGitHub = 'Unable to get app version data from GitHub',
      unableToGetItemDataVersionDataFromGitHub = 'Unable to get item data version data from GitHub',
      fileIsNotSupported = '"%p%" is not supported',
      fileAlreadyOnTheList = '"%p%" already on the list',
      nameAlreadyExists = 'Name already exists',
      noMatchingFilesBetweenItemsToSwap = 'No matching files between items to swap',
      nameCannotBeEmpty = 'Name cannot be empty',
      failedToReplaceCard = 'Failed to replace card',
      failedToReplaceCardIcon = 'Failed to replace card icon',
      failedToReplaceBoard = 'Failed to replace board',
      failedToReplaceBoardIcon = 'Failed to replace board icon',
      failedToReplaceSleeve = 'Failed to replace sleeve',
      failedToReplaceSleeveIcon = 'Failed to replace sleeve icon',
      anticheatLoaderFileNotFound = '"ucldr_PSO2_JP_loader_x64.exe" not found\nRun the game at least once then try again',
      couldntCreateCustomLauncher = 'Cound not create custom launcher',
      restoredVitalGauges = 'Restored Vital Gauges',
      restoredAQMInjectedItems = 'Restored AQM Injected Items';

  // Infos
  String pso2binDirPathInfo = 'PSO2 game data folder, this folder located inside the game installation directory',
      mainDirPathInfo = 'This folder stores your mods and other Mod Manager related stuff\nPreferably outside of pso2 installation directory and nested folders',
      restoredModInfo = 'These mods have been restored by game update or file check',
      restoredVitalGaugeInfo = 'These Vital Gauge backgrounds have been restored by game update or file check',
      restoredAQMInjectedItemInfo = 'Custom AQM and Bounding Radius of these items have been restored by game update or file check',
      duplicateAppliedInfo = 'This mod was found using the same files as "%p%"',
      duplicateAqmInjectInfo = 'This mod was found using the same files as "%p%" in AQM Inject',
      selectSetsToAddToOrRemoveFrom = 'Select Set(s) to add to or to remove from',
      jpGameStartInfo = 'If the game is not starting, try to run the Mod Manager as admin and try again',
      filterRemoveInfo = 'Click and hold on the filters to remove',
      firstTimeInfo = 'If this is your first time using PSO2NGS Mod Manager and your game currently contains mods, please remove them first',
      emptyModViewInfo = 'Select an item to display its mods here';

  // Help menu
  String applyRestoreMods = 'Apply - restore mods',
      addModsToModSets = 'Add mods to Mod Sets',
      swapItemToAnotherItem = 'Swap an item to another item',
      swapModsToAnotherItem = 'Swap a mod to another item',
      addModsToModManager = 'Add mods to Mod Manager',
      addCustomImagesToVitalGauge = 'Add custom images to Vital Gauge',
      addCustomImagesToLineStrike = 'Add custom images to Line Strike';

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
      itemIconSlides = 'Item Icon Slides',
      boundingRadiusRemovalValue = 'Bounding Radius Removal Value',
      autoRemoveBoundingRadius = 'Auto Remove Bounding Radius',
      autoInjectCustomAQM = 'Auto Inject Custom AQM',
      customAQMFiles = 'Custom AQM Files',
      originalFilesRestorePriority = 'Original Files Restore Priority',
      segaServers = 'Sega Servers',
      localBackups = 'Local Backups',
      removeProfanityFilter = 'Remove Profanity Filter',
      markModdedItemInGame = 'Mark Modded Items In Game',
      sideBar = 'Side Bar',
      minimal = 'Minimal',
      alwaysExpanded = 'Always Expand',
      modConfigsLastSaveDate = 'Mod Configs (Latest Backup: %p%)',
      backupNow = 'Backup Now',
      mainPaths = 'Main Paths',
      currentPathFolder = 'Current path: %p%',
      selectPso2BinFolder = 'Select pso2_bin Folder',
      selectModManagerDataFolder = 'Select Mod Manager Data Folder',
      locations = 'Locations',
      pso2binFolder = 'pso2_bin Folder',
      modManagerMainFolder = 'Mod Manager Main Data Folder',
      modDataFolder = 'Mod Data Folder',
      modBackupFolder = 'Mod Backup Folder',
      checksumFolder = 'Checksum Folder',
      modConfigsBackupFolder = 'Mod Configs Backup Folder',
      reselectpso2binPath = 'Re-Select pso2_bin path?',
      reselectMainModManagerPath = 'Re-Select main Mod Manager path?',
      currentPathLocation = 'Current path: %p%',
      reselectPath = 'Re-Select Path',
      backgroundImageFolder = 'Background Image Folder',
      verTwoMainDataPathLocation = 'Ver.2 Mod Manager Main Data Folder Location:',
      hideEmptyCategories = 'Hide Empty Categories',
      auxiliaryUIOpacity = 'Auxiliary UI Opacity',
      showPreview = 'Show Preview',
      hidePreview = 'Hide Preview',
      applyOnlyHQFilesFromMods = 'Apply Only HQ Files From Mods',
      selectedOnly = 'Selected Only',
      allPossible = 'All Possible',
      applyHQFilesOnly = 'Apply HQ Files Only',
      applyHQOnlyInfo =
          'All Possible: Always try to apply HQ files to the game\nSelected Only: Only HQ files of the selected mods will be applied to the game\nNote: If a mod does not have any HQ file, all files will be applied like normal',
      hideUIWhenAppUnfocused = 'Hide UI When App Unfocused',
      interval = 'Interval',
      startAfter = 'Start After',
      tapToReturn = 'Tap To Return',
      homepageStyle = 'Homepage Style',
      legacy = 'Legacy',
      hideAppliedList = 'Hide Applied List';

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

  String motionTypeName(String name) {
    if (name == 'All') return all;
    int index = defaultMotionTypes.indexOf(name);

    switch (index) {
      case 0:
        return dfGlideMotion;
      case 1:
        return dfJumpMotion;
      case 2:
        return dfLandingMotion;
      case 3:
        return dfDashMotion;
      case 4:
        return dfRunMotion;
      case 5:
        return dfStandbyMotion;
      case 6:
        return dfSwimMotion;
      default:
        return name;
    }
  }

  String categoryTypeName(String name) {
    if (name == 'All') return all;
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
    if (name == 'All') return all;
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

  String sortingTypeName(String name) {
    if (name == 'All') return all;
    int index = modSortingSelections.indexOf(name);

    switch (index) {
      case 0:
        return nameAlphabetical;
      case 1:
        return recentlyAdded;
      case 2:
        return recentlyApplied;
      default:
        return name;
    }
  }

  String weaponTypeName(String name) {
    if (name == 'All') return all;
    int index = defaultWeaponTypes.indexOf(name);

    switch (index) {
      case 0:
        return wpSwords;
      case 1:
        return wpWiredLances;
      case 2:
        return wpPartisans;
      case 3:
        return wpTwinDaggers;
      case 4:
        return wpDoubleSabers;
      case 5:
        return wpKnuckles;
      case 6:
        return wpKatanas;
      case 7:
        return wpSoaringBlades;
      case 8:
        return wpAssaultRifles;
      case 9:
        return wpLaunchers;
      case 10:
        return wpTwinMachineGuns;
      case 11:
        return wpBows;
      case 12:
        return wpGunblades;
      case 13:
        return wpRods;
      case 14:
        return wpTalises;
      case 15:
        return wpWands;
      case 16:
        return wpJetBoots;
      case 17:
        return wpHarmonizers;
      default:
        return name;
    }
  }
}
