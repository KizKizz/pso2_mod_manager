import 'package:json_annotation/json_annotation.dart';

part 'ui_text.g.dart';

@JsonSerializable()
class TranslationLanguage {
  TranslationLanguage(this.langInitial, this.langFilePath, this.selected);

  String langInitial;
  String langFilePath;
  bool selected;

  factory TranslationLanguage.fromJson(Map<String, dynamic> json) => _$TranslationLanguageFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationLanguageToJson(this);
}

@JsonSerializable()
class TranslationText {
  TranslationText();
  //General elements
  String uiCancel = 'Cancel',
      uiAdd = 'Add',
      uiDismiss = 'Dismiss',
      uiBack = 'Back',
      uiError = 'Error',
      uiApply = 'Apply',
      uiClose = 'Close',
      uiReset = 'Reset',
      uiGotIt = 'Got it',
      uiReturn = 'Return',
      uiSure = 'Sure',
      uiYes = 'Yes',
      uiNo = 'No',
      uiClearAll = 'Clear All',
      uiExit = 'Exit',
      uiON = 'ON',
      uiOFF = 'OFF';

  //main page
  String uiSettings = 'Settings',
      uiLanguage = 'Language',
      uiAddANewLanguage = 'Add a new language',
      uiNewLanguageInititalInput = 'Enter new language\'s initial:\n(2 characters, ex: EN for English)',
      uiNewLanguageInitialEmptyError = 'Language initial can\'t be empty',
      uiNewLanguageInititalAlreadyExisted = 'Language initial already existed',
      uiCurrentLanguage = 'Current Language',
      uiReselectPso2binPath = 'Reselect pso2_bin Path',
      uiReselectModManFolderPath = 'Reselect Mod Manager Folder Path',
      uiOpenModsFolder = 'Open Mods Folder',
      uiOpenBackupFolder = 'Open Backup Folder',
      uiOpenDeletedItemsFolder = 'Open Deleted Items Folder',
      uiTheme = 'Theme',
      uiSwitchToDarkTheme = 'Switch to dark theme',
      uiSwitchToLightTheme = 'Switch to light theme',
      uiAppearance = 'Appearance',
      uiDarkTheme = 'Dark Theme',
      uiLightTheme = 'Light Theme',
      uiUIOpacity = 'UI Opacity',
      uiUIColors = 'UI Colors',
      uiPrimarySwatch = 'Primary swatch',
      uiMainUIBackground = 'Main UI background',
      uiPrimaryColor = 'Primary color',
      uiPrimaryLight = 'Primary light',
      uiPrimaryDark = 'Primary dark',
      uiMainCanvasBackground = 'Main canvas background',
      uiHoldToResetColors = 'Hold to reset to default colors',
      uiBackgroundImage = 'Background Image',
      uiClicktoChangeBackgroundImage = 'Click to change',
      uiNoBackgroundImageFound = 'No image found. Click!',
      uiSelectBackgroundImage = 'Select your image',
      uiHideBackgroundImage = 'Hide background image',
      uiShowBackgroundImage = 'Show background image',
      uiHoldToRemoveBackgroundImage = 'Hold to remove background image',
      uiVersion = 'Version',
      uiMadeBy = 'Made by',
      uiNewUpdateAvailableClickToDownload = 'New update available. Click to go to download page',
      uiAddNewModsToMM = 'Add new mods to Mod Manager',
      uiAddMods = 'Add Mods',
      uiManageModSets = 'Manage Mod Sets',
      uiManageModList = 'Manage Mod List',
      uiModSets = 'Mod Sets',
      uiModList = 'Mod List',
      uiRefreshMM = 'Refresh Mod Manager',
      uiRefresh = 'Refresh',
      uiOpenChecksumFolder = 'Open Checksum Folder',
      uiChecksumDownloadSelect = 'Click to download or hold to manually select checksum',
      uiSelectLocalChecksum = 'Select your checksum file',
      uiChecksum = 'Checksum',
      uiChecksumMissingClick = 'Checksum missing. Click!',
      uiChecksumOutdatedClick = 'Checksum outdated. Click!',
      uiChecksumDownloading = 'Downloading checksum..',
      uiPreviewShowHide = 'Show/Hide Preview window',
      uiPreview = 'Preview',
      uiOpenMMSettings = 'Open Mod Manager Settings',
      uiNewMMUpdateAvailable = 'New Mod Manager update available!',
      uiNewVersion = 'New Version',
      uiCurrentVersion = 'Current Version',
      uiPatchNote = 'Patch Notes...',
      uiSkipMMUpdate = 'Skip This Version',
      uiUpdate = 'Update',
      uiNewRefSheetsUpdate = 'New update available for item reference sheets (Important for Add Mods function to work correctly)',
      uiDownloading = 'Downloading',
      uiOf = 'of',
      uiRefSheetsDownloadingCount = 'of the required item reference sheets. (Important for Add Mods function to work correctly)',
      uiDownloadUpdate = 'Download Update',
      uiNewUserNotice = 'If this is your first time using PSO2NGS Mod Manager please restore the game files to their originals before applying mods to the game',
      uiUpdateNow = 'Update Now',
      uiTurnOffStartupIconsFetching = 'Turn off startup item icons fetching',
      uiTurnOnStartupIconsFetching = 'Turn on startup item icons fetching',
      uiStartupItemIconsFetching = 'Startup Item Icons Fetching',
      uiTurnOffSlidingItemIcons = 'Turn off sliding item icons',
      uiTurnOnSlidingItemIcons = 'Turn on sliding item icons',
      uiSlidingItemIcons = 'Sliding Item Icons';

  //homepage
  String uiItemList = 'Item List',
      uiLoadingUILanguage = 'Loading UI Language',
      uiReloadingMods = 'Reloading Mods',
      uiShowFavList = 'Show Favorite List',
      uiFavItemList = 'Favorite Item List',
      uiUnhideAllCate = 'Unhide all categories',
      uiTurnOffAutoHideEmptyCate = 'Turn off auto hide empty categories',
      uiTurnOnAutoHideEmptyCate = 'Turn on auto hide empty categories',
      uiShowHideCate = 'Show/Hide categories',
      uiHiddenItemList = 'Hidden Item List',
      uiSortByNameDescen = 'Sort by name descending',
      uiSortByNameAscen = 'Sort by name ascending',
      uiSortItemList = 'Sort Item List',
      uiAddNewCateGroup = 'Add new Category Group',
      uiSearchForMods = 'Search for mods',
      uiUnhide = 'Unhide',
      uiItem = 'Item',
      uiItems = 'Items',
      uiRemove = 'Remove',
      uiFromFavList = 'from Favorite List',
      uiMod = 'Mod',
      uiMods = 'Mods',
      uiApplied = 'Applied',
      uiOpen = 'Open',
      uiInFileExplorer = 'in File Explorer',
      uiHoldToRemove = 'Hold to remove',
      uiFromMM = 'from Mod Manager',
      uiSuccess = 'Success',
      uiSuccessfullyRemoved = 'Successfully removed',
      uiHoldToDelete = 'Hold to delete',
      uiSortCateInThisGroup = 'Sort categories in this group',
      uiAddANewCateTo = 'Add a new Category to',
      uiHide = 'Hide',
      uiFromItemList = 'from Item List',
      uiFrom = 'from',
      uiClearAvailableModsView = 'Clear Available Mods view',
      uiAvailableMods = 'Available Mods',
      uiVariant = 'Variant',
      uiVariants = 'Variants',
      uiFromTheGame = 'from the game',
      uiCouldntFindBackupFileFor = 'Could not find backup file for',
      uiToTheGame = 'to the game',
      uiCouldntFindOGFileFor = 'Could not find original file for',
      uiSuccessfullyApplied = 'Sucessfully applied',
      uiToFavList = 'to Favorite List',
      uiHoldToRemoveAllAppliedMods = 'Hold to remove all applied mods from the game',
      uiAddAllAppliedModsToSets = 'Add all applied mods to Mod Sets',
      uiAppliedMods = 'Applied Mods',
      uiFilesApplied = 'Files applied',
      uiNoPreViewAvailable = 'No preview available',
      uiCreateNewModSet = 'Create new Mod Set',
      uiEnterNewModSetName = 'Enter new Mod Set name',
      uiRemoveAllModsIn = 'Remove all mods in',
      uiSuccessfullyRemoveAllModsIn = 'Successfully removed all mods in',
      uiApplyAllModsIn = 'Apply all mods in',
      uiSuccessfullyAppliedAllModsIn = 'Sucessfully applied all mods in',
      uiAddToThisSet = 'Add to this set',
      uiFromThisSet = 'from this set';

  //mod_add_handler
  String uiPreparing = 'Preparing',
      uiDragDropFiles = 'Drag and drop folders, zip files\nand .ice files here\nMay take some time\nto process large amount of files',
      uiAchiveCurrentlyNotSupported = 'currently not supported. Open the archive file then drag the content in here instead',
      uiProcess = 'Process',
      uiWaitingForData = 'Waiting for data',
      uiErrorWhenLoadingAddModsData = 'Error when loading data for Mods Adder. Please restart the app.',
      uiLoadingModsAdderData = 'Loading data for Mods Adder',
      uiSelectACategory = 'Select a Category',
      uiEditName = 'Edit Name',
      uiMarkThisNotToBeAdded = 'Mark this not to be added',
      uiMarkThisToBeAdded = 'Mark this to be added',
      uiNameCannotBeEmpty = 'Name cannot be empty',
      uiRename = 'Rename',
      uiBeforeAdding = 'before adding',
      uiThereAreStillModsThatWaitingToBeAdded = 'There are still mods in the list waiting to be added',
      uiModsAddedSuccessfully = 'Mods added successfully!',
      uiAddAll = 'Add All';

  //color_picker
  String uiPickAColor = 'Pick a color';

  //modfiles_apply
  String uiDuplicatesInAppliedModsFound = 'Duplicate(s) in applied mods found', uiApplyingWouldReplaceModFiles = 'Applying this mod would replace these applied mod files';

  //new_cate_adder
  String uiNewCateGroup = 'New Category Group',
      uiNameAlreadyExisted = 'Name already existed!',
      uiNewCateGroupName = 'New Category Group name',
      uiNewCate = 'New Category',
      uiNewCateName = 'New Category name',
      uiRemovingCateGroup = 'Removing Category Group',
      uiCateFoundWhenDeletingGroup = 'There is a Category in this group. Would you like to move it to "Others" Group?',
      uiThereAre = 'There are',
      uiCatesFoundWhenDeletingGroup = 'Categories in this group. Would you like to move them to Others Group?',
      uiMoveEverythingToOthers = 'Move everything to "Others"',
      uiNoDeleteAll = 'No, Delete All',
      uiRemovingCate = 'Removing Category',
      uiItemFoundWhenDeletingCate = 'There is an Item in this Category. Remove this Category would delete all its Items.\nContinue?',
      uiItemsFoundWhenDeletingCate = 'Items in this Category. Remove this Category would delete all its Items.\nContinue?';

  //unapply_all_mods
  String uiSuccessfullyRemovedTheseMods = 'Successfully removed these mods from the game';

  //paths_loader
  String uiPso2binFolderNotFoundSelect = 'pso2_bin folder not found. Select it now?\nSelecting "Exit" will close the app',
      uiSelectPso2binFolderPath = 'Select \'pso2_bin\' folder path',
      uiMMFolderNotFound = 'Mod Manager Folder not found',
      uiSelectPathToStoreMMFolder = 'Select a path to store your mods?\nSelecting "No" will create a folder inside "pso2_bin" folder\nNote: This folder stores mods and backups',
      uiSelectAFolderToStoreMMFolder = 'Select a folder to store Mod Manager folder',
      uiCurrentPath = 'Current path',
      uiReselect = 'Reselect',
      uiMMPathReselectNoteCurrentPath = 'Note: This folder stores mods and backups\n\nCurrent path:';

  //applied_mods_checking_page
  String uiCheckingAppliedMods = 'Checking Applied Mods',
      uiErrorWhenCheckingAppliedMods = 'Error when checking applied mod files',
      uiReappliedModsAfterChecking = 'The mod(s) below have been automatically re-applied to the game';

  //applied_mods_loading_page
  String uiLoadingAppliedMods = 'Loading Applied Mods', uiErrorWhenLoadingAppliedMods = 'Error when loading applied mod files';

  //mod_set_loading_page
  String uiLoadingModSets = 'Loading Mod Sets', uiErrorWhenLoadingModSets = 'Error when loading Mod Sets';

  //mod_loading_page
  String uiLoadingMods = 'Loading Mods', uiErrorWhenLoadingMods = 'Error when loading mod files';
  String uiSkipStartupIconFectching = 'Skip startup item icons fetching';

  //path_loading_page
  String uiLoadingPaths = 'Loading Paths', uiErrorWhenLoadingPaths = 'Error when loading paths';

  //preview Image diaglog
  String uiPrevious = 'Previous', uiNext = 'Next', uiAutoPlay = 'Auto Play', uiStopAutoPlay = 'Stop Auto Play';

  factory TranslationText.fromJson(Map<String, dynamic> json) => _$TranslationTextFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationTextToJson(this);
}

// TranslationText defaultUILangLoader() {
//   return TranslationText();
// }
