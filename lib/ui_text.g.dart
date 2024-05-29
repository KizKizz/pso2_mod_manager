// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ui_text.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TranslationLanguage _$TranslationLanguageFromJson(Map<String, dynamic> json) =>
    TranslationLanguage(
      json['langInitial'] as String,
      json['revision'] as int,
      json['langFilePath'] as String,
      json['selected'] as bool,
    );

Map<String, dynamic> _$TranslationLanguageToJson(
        TranslationLanguage instance) =>
    <String, dynamic>{
      'langInitial': instance.langInitial,
      'revision': instance.revision,
      'langFilePath': instance.langFilePath,
      'selected': instance.selected,
    };

TranslationText _$TranslationTextFromJson(Map<String, dynamic> json) =>
    TranslationText()
      ..uiCancel = json['uiCancel'] as String
      ..uiAdd = json['uiAdd'] as String
      ..uiDismiss = json['uiDismiss'] as String
      ..uiBack = json['uiBack'] as String
      ..uiError = json['uiError'] as String
      ..uiApply = json['uiApply'] as String
      ..uiClose = json['uiClose'] as String
      ..uiReset = json['uiReset'] as String
      ..uiGotIt = json['uiGotIt'] as String
      ..uiReturn = json['uiReturn'] as String
      ..uiSure = json['uiSure'] as String
      ..uiYes = json['uiYes'] as String
      ..uiNo = json['uiNo'] as String
      ..uiClearAll = json['uiClearAll'] as String
      ..uiExit = json['uiExit'] as String
      ..uiON = json['uiON'] as String
      ..uiOFF = json['uiOFF'] as String
      ..uiMove = json['uiMove'] as String
      ..uiContinue = json['uiContinue'] as String
      ..uiUnknown = json['uiUnknown'] as String
      ..uiUnknownItem = json['uiUnknownItem'] as String
      ..uiUnknownAccessory = json['uiUnknownAccessory'] as String
      ..uiUnknownEmote = json['uiUnknownEmote'] as String
      ..uiUnknownMotion = json['uiUnknownMotion'] as String
      ..uiGenderMale = json['uiGenderMale'] as String
      ..uiGenderFemale = json['uiGenderFemale'] as String
      ..uiGenderBoth = json['uiGenderBoth'] as String
      ..dfCastParts = json['dfCastParts'] as String
      ..dfLayeringWears = json['dfLayeringWears'] as String
      ..dfOthers = json['dfOthers'] as String
      ..dfAccessories = json['dfAccessories'] as String
      ..dfBasewears = json['dfBasewears'] as String
      ..dfBodyPaints = json['dfBodyPaints'] as String
      ..dfCastArmParts = json['dfCastArmParts'] as String
      ..dfCastBodyParts = json['dfCastBodyParts'] as String
      ..dfCastLegParts = json['dfCastLegParts'] as String
      ..dfCostumes = json['dfCostumes'] as String
      ..dfEmotes = json['dfEmotes'] as String
      ..dfEyes = json['dfEyes'] as String
      ..dfFacePaints = json['dfFacePaints'] as String
      ..dfHairs = json['dfHairs'] as String
      ..dfInnerwears = json['dfInnerwears'] as String
      ..dfMags = json['dfMags'] as String
      ..dfMisc = json['dfMisc'] as String
      ..dfMotions = json['dfMotions'] as String
      ..dfOuterwears = json['dfOuterwears'] as String
      ..dfSetwears = json['dfSetwears'] as String
      ..uiSettings = json['uiSettings'] as String
      ..uiLanguage = json['uiLanguage'] as String
      ..uiAddANewLanguage = json['uiAddANewLanguage'] as String
      ..uiNewLanguageInititalInput =
          json['uiNewLanguageInititalInput'] as String
      ..uiNewLanguageInitialEmptyError =
          json['uiNewLanguageInitialEmptyError'] as String
      ..uiNewLanguageInititalAlreadyExisted =
          json['uiNewLanguageInititalAlreadyExisted'] as String
      ..uiCurrentLanguage = json['uiCurrentLanguage'] as String
      ..uiReselectPso2binPath = json['uiReselectPso2binPath'] as String
      ..uiReselectModManFolderPath =
          json['uiReselectModManFolderPath'] as String
      ..uiOpenModsFolder = json['uiOpenModsFolder'] as String
      ..uiOpenBackupFolder = json['uiOpenBackupFolder'] as String
      ..uiOpenDeletedItemsFolder = json['uiOpenDeletedItemsFolder'] as String
      ..uiTheme = json['uiTheme'] as String
      ..uiSwitchToDarkTheme = json['uiSwitchToDarkTheme'] as String
      ..uiSwitchToLightTheme = json['uiSwitchToLightTheme'] as String
      ..uiAppearance = json['uiAppearance'] as String
      ..uiDarkTheme = json['uiDarkTheme'] as String
      ..uiLightTheme = json['uiLightTheme'] as String
      ..uiUIOpacity = json['uiUIOpacity'] as String
      ..uiUIColors = json['uiUIColors'] as String
      ..uiPrimarySwatch = json['uiPrimarySwatch'] as String
      ..uiMainUIBackground = json['uiMainUIBackground'] as String
      ..uiPrimaryColor = json['uiPrimaryColor'] as String
      ..uiPrimaryLight = json['uiPrimaryLight'] as String
      ..uiPrimaryDark = json['uiPrimaryDark'] as String
      ..uiMainCanvasBackground = json['uiMainCanvasBackground'] as String
      ..uiHoldToResetColors = json['uiHoldToResetColors'] as String
      ..uiBackgroundImage = json['uiBackgroundImage'] as String
      ..uiClicktoChangeBackgroundImage =
          json['uiClicktoChangeBackgroundImage'] as String
      ..uiNoBackgroundImageFound = json['uiNoBackgroundImageFound'] as String
      ..uiSelectBackgroundImage = json['uiSelectBackgroundImage'] as String
      ..uiHideBackgroundImage = json['uiHideBackgroundImage'] as String
      ..uiShowBackgroundImage = json['uiShowBackgroundImage'] as String
      ..uiHoldToRemoveBackgroundImage =
          json['uiHoldToRemoveBackgroundImage'] as String
      ..uiVersion = json['uiVersion'] as String
      ..uiMadeBy = json['uiMadeBy'] as String
      ..uiNewUpdateAvailableClickToDownload =
          json['uiNewUpdateAvailableClickToDownload'] as String
      ..uiAddNewModsToMM = json['uiAddNewModsToMM'] as String
      ..uiAddMods = json['uiAddMods'] as String
      ..uiManageModSets = json['uiManageModSets'] as String
      ..uiManageModList = json['uiManageModList'] as String
      ..uiModSets = json['uiModSets'] as String
      ..uiModList = json['uiModList'] as String
      ..uiRefreshMM = json['uiRefreshMM'] as String
      ..uiRefresh = json['uiRefresh'] as String
      ..uiOpenChecksumFolder = json['uiOpenChecksumFolder'] as String
      ..uiChecksumDownloadSelect = json['uiChecksumDownloadSelect'] as String
      ..uiSelectLocalChecksum = json['uiSelectLocalChecksum'] as String
      ..uiChecksum = json['uiChecksum'] as String
      ..uiChecksumMissingClick = json['uiChecksumMissingClick'] as String
      ..uiChecksumOutdatedClick = json['uiChecksumOutdatedClick'] as String
      ..uiChecksumDownloading = json['uiChecksumDownloading'] as String
      ..uiPreviewShowHide = json['uiPreviewShowHide'] as String
      ..uiPreview = json['uiPreview'] as String
      ..uiOpenMMSettings = json['uiOpenMMSettings'] as String
      ..uiNewMMUpdateAvailable = json['uiNewMMUpdateAvailable'] as String
      ..uiNewVersion = json['uiNewVersion'] as String
      ..uiCurrentVersion = json['uiCurrentVersion'] as String
      ..uiPatchNote = json['uiPatchNote'] as String
      ..uiSkipMMUpdate = json['uiSkipMMUpdate'] as String
      ..uiUpdate = json['uiUpdate'] as String
      ..uiNewRefSheetsUpdate = json['uiNewRefSheetsUpdate'] as String
      ..uiDownloading = json['uiDownloading'] as String
      ..uiOf = json['uiOf'] as String
      ..uiRefSheetsDownloadingCount =
          json['uiRefSheetsDownloadingCount'] as String
      ..uiDownloadUpdate = json['uiDownloadUpdate'] as String
      ..uiNewUserNotice = json['uiNewUserNotice'] as String
      ..uiUpdateNow = json['uiUpdateNow'] as String
      ..uiTurnOffStartupIconsFetching =
          json['uiTurnOffStartupIconsFetching'] as String
      ..uiTurnOnStartupIconsFetching =
          json['uiTurnOnStartupIconsFetching'] as String
      ..uiStartupItemIconsFetching =
          json['uiStartupItemIconsFetching'] as String
      ..uiTurnOffSlidingItemIcons = json['uiTurnOffSlidingItemIcons'] as String
      ..uiTurnOnSlidingItemIcons = json['uiTurnOnSlidingItemIcons'] as String
      ..uiSlidingItemIcons = json['uiSlidingItemIcons'] as String
      ..uiWillNotFetchItemIcon = json['uiWillNotFetchItemIcon'] as String
      ..uiOnlyFetchOneIcon = json['uiOnlyFetchOneIcon'] as String
      ..uiFetchAllMissingItemIcons =
          json['uiFetchAllMissingItemIcons'] as String
      ..uiMinimal = json['uiMinimal'] as String
      ..uiAll = json['uiAll'] as String
      ..uiSwapItems = json['uiSwapItems'] as String
      ..uiSwapAnItemToAnotherItem = json['uiSwapAnItemToAnotherItem'] as String
      ..uiProfiles = json['uiProfiles'] as String
      ..uiClickToChangeToThisProfileHoldToRename =
          json['uiClickToChangeToThisProfileHoldToRename'] as String
      ..uiVitalGauge = json['uiVitalGauge'] as String
      ..uiCreateAndSwapVitalGaugeBackground =
          json['uiCreateAndSwapVitalGaugeBackground'] as String
      ..uiRemoveProfanityFilter = json['uiRemoveProfanityFilter'] as String
      ..uiExtras = json['uiExtras'] as String
      ..uiOtherFeaturesOfPSO2NGSModManager =
          json['uiOtherFeaturesOfPSO2NGSModManager'] as String
      ..uiAutoRadiusRemovalTooltip =
          json['uiAutoRadiusRemovalTooltip'] as String
      ..uiAutoBoundaryRadiusRemoval =
          json['uiAutoBoundaryRadiusRemoval'] as String
      ..uiPrioritizeLocalBackupTooltip =
          json['uiPrioritizeLocalBackupTooltip'] as String
      ..uiPrioritizeLocalBackups = json['uiPrioritizeLocalBackups'] as String
      ..uiPrioritizeSegaBackups = json['uiPrioritizeSegaBackups'] as String
      ..uiCmxRefreshToolTip = json['uiCmxRefreshToolTip'] as String
      ..uiRefreshingCmx = json['uiRefreshingCmx'] as String
      ..uiRefreshCmx = json['uiRefreshCmx'] as String
      ..uiItemNameLanguage = json['uiItemNameLanguage'] as String
      ..uiItemNameLanguageTooltip = json['uiItemNameLanguageTooltip'] as String
      ..uiOpenMainModManFolder = json['uiOpenMainModManFolder'] as String
      ..uiOpenExportedModsFolder = json['uiOpenExportedModsFolder'] as String
      ..uiImportExportedMods = json['uiImportExportedMods'] as String
      ..uiStartPSO2 = json['uiStartPSO2'] as String
      ..uiLaunchGameJPVerOnly = json['uiLaunchGameJPVerOnly'] as String
      ..uiIfGameNotLaunching = json['uiIfGameNotLaunching'] as String
      ..uiItemList = json['uiItemList'] as String
      ..uiLoadingUILanguage = json['uiLoadingUILanguage'] as String
      ..uiReloadingMods = json['uiReloadingMods'] as String
      ..uiShowFavList = json['uiShowFavList'] as String
      ..uiFavItemList = json['uiFavItemList'] as String
      ..uiUnhideAllCate = json['uiUnhideAllCate'] as String
      ..uiTurnOffAutoHideEmptyCate =
          json['uiTurnOffAutoHideEmptyCate'] as String
      ..uiTurnOnAutoHideEmptyCate = json['uiTurnOnAutoHideEmptyCate'] as String
      ..uiShowHideCate = json['uiShowHideCate'] as String
      ..uiHiddenItemList = json['uiHiddenItemList'] as String
      ..uiSortByNameDescen = json['uiSortByNameDescen'] as String
      ..uiSortByNameAscen = json['uiSortByNameAscen'] as String
      ..uiSortItemList = json['uiSortItemList'] as String
      ..uiAddNewCateGroup = json['uiAddNewCateGroup'] as String
      ..uiSearchForMods = json['uiSearchForMods'] as String
      ..uiUnhide = json['uiUnhide'] as String
      ..uiItem = json['uiItem'] as String
      ..uiItems = json['uiItems'] as String
      ..uiRemove = json['uiRemove'] as String
      ..uiFromFavList = json['uiFromFavList'] as String
      ..uiMod = json['uiMod'] as String
      ..uiMods = json['uiMods'] as String
      ..uiApplied = json['uiApplied'] as String
      ..uiOpen = json['uiOpen'] as String
      ..uiInFileExplorer = json['uiInFileExplorer'] as String
      ..uiHoldToRemove = json['uiHoldToRemove'] as String
      ..uiFromMM = json['uiFromMM'] as String
      ..uiSuccess = json['uiSuccess'] as String
      ..uiSuccessfullyRemoved = json['uiSuccessfullyRemoved'] as String
      ..uiHoldToDelete = json['uiHoldToDelete'] as String
      ..uiSortCateInThisGroup = json['uiSortCateInThisGroup'] as String
      ..uiAddANewCateTo = json['uiAddANewCateTo'] as String
      ..uiHoldToHide = json['uiHoldToHide'] as String
      ..uiFromItemList = json['uiFromItemList'] as String
      ..uiFrom = json['uiFrom'] as String
      ..uiClearAvailableModsView = json['uiClearAvailableModsView'] as String
      ..uiAvailableMods = json['uiAvailableMods'] as String
      ..uiVariant = json['uiVariant'] as String
      ..uiVariants = json['uiVariants'] as String
      ..uiFromTheGame = json['uiFromTheGame'] as String
      ..uiCouldntFindBackupFileFor =
          json['uiCouldntFindBackupFileFor'] as String
      ..uiToTheGame = json['uiToTheGame'] as String
      ..uiCouldntFindOGFileFor = json['uiCouldntFindOGFileFor'] as String
      ..uiSuccessfullyApplied = json['uiSuccessfullyApplied'] as String
      ..uiToFavList = json['uiToFavList'] as String
      ..uiHoldToRemoveAllAppliedMods =
          json['uiHoldToRemoveAllAppliedMods'] as String
      ..uiAddAllAppliedModsToSets = json['uiAddAllAppliedModsToSets'] as String
      ..uiAppliedMods = json['uiAppliedMods'] as String
      ..uiFilesApplied = json['uiFilesApplied'] as String
      ..uiNoPreViewAvailable = json['uiNoPreViewAvailable'] as String
      ..uiCreateNewModSet = json['uiCreateNewModSet'] as String
      ..uiEnterNewModSetName = json['uiEnterNewModSetName'] as String
      ..uiRemoveAllModsIn = json['uiRemoveAllModsIn'] as String
      ..uiSuccessfullyRemoveAllModsIn =
          json['uiSuccessfullyRemoveAllModsIn'] as String
      ..uiApplyAllModsIn = json['uiApplyAllModsIn'] as String
      ..uiSuccessfullyAppliedAllModsIn =
          json['uiSuccessfullyAppliedAllModsIn'] as String
      ..uiAddToThisSet = json['uiAddToThisSet'] as String
      ..uiFromThisSet = json['uiFromThisSet'] as String
      ..uiToAnotherItem = json['uiToAnotherItem'] as String
      ..uiUnableToObtainOrginalFilesFromSegaServers =
          json['uiUnableToObtainOrginalFilesFromSegaServers'] as String
      ..uiSwitchingProfile = json['uiSwitchingProfile'] as String
      ..uiProfile = json['uiProfile'] as String
      ..uiHoldToApplyAllAvailableModsToTheGame =
          json['uiHoldToApplyAllAvailableModsToTheGame'] as String
      ..uiHoldToReapplyAllModsInAppliedList =
          json['uiHoldToReapplyAllModsInAppliedList'] as String
      ..uiHoldToModifyBoundaryRadius =
          json['uiHoldToModifyBoundaryRadius'] as String
      ..uiAddToFavList = json['uiAddToFavList'] as String
      ..uiRemoveFromFavList = json['uiRemoveFromFavList'] as String
      ..uiMore = json['uiMore'] as String
      ..uiSwapToAnotherItem = json['uiSwapToAnotherItem'] as String
      ..uiRemoveBoundaryRadius = json['uiRemoveBoundaryRadius'] as String
      ..uiRemoveFromMM = json['uiRemoveFromMM'] as String
      ..uiAddToModSets = json['uiAddToModSets'] as String
      ..uiRemoveFromThisSet = json['uiRemoveFromThisSet'] as String
      ..uiSelect = json['uiSelect'] as String
      ..uiDeselect = json['uiDeselect'] as String
      ..uiSelectAllAppliedMods = json['uiSelectAllAppliedMods'] as String
      ..uiDeselectAllAppliedMods = json['uiDeselectAllAppliedMods'] as String
      ..uiSelectAll = json['uiSelectAll'] as String
      ..uiDeselectAll = json['uiDeselectAll'] as String
      ..uiHoldToReapplySelectedMods =
          json['uiHoldToReapplySelectedMods'] as String
      ..uiHoldToRemoveSelectedMods =
          json['uiHoldToRemoveSelectedMods'] as String
      ..uiAddSelectedModsToModSets =
          json['uiAddSelectedModsToModSets'] as String
      ..uiFailed = json['uiFailed'] as String
      ..uiFailedToRemove = json['uiFailedToRemove'] as String
      ..uiUnknownErrorWhenRemovingModFromTheGame =
          json['uiUnknownErrorWhenRemovingModFromTheGame'] as String
      ..uiSuccessWithErrors = json['uiSuccessWithErrors'] as String
      ..uiCmx = json['uiCmx'] as String
      ..uiAddChangeCmxFile = json['uiAddChangeCmxFile'] as String
      ..uiCmxFile = json['uiCmxFile'] as String
      ..uiMoveThisCategoryToAnotherGroup =
          json['uiMoveThisCategoryToAnotherGroup'] as String
      ..uiUnhideX = json['uiUnhideX'] as String
      ..uiRemoveXFromFav = json['uiRemoveXFromFav'] as String
      ..uiOpenXInFileExplorer = json['uiOpenXInFileExplorer'] as String
      ..uiHoldToRemoveXFromModMan = json['uiHoldToRemoveXFromModMan'] as String
      ..uiSuccessfullyRemovedXFromModMan =
          json['uiSuccessfullyRemovedXFromModMan'] as String
      ..uiSuccessfullyAppliedX = json['uiSuccessfullyAppliedX'] as String
      ..uiSuccessfullyAppliedXInY = json['uiSuccessfullyAppliedXInY'] as String
      ..uiAddNewCateToXGroup = json['uiAddNewCateToXGroup'] as String
      ..uiHoldToHideXFromItemList = json['uiHoldToHideXFromItemList'] as String
      ..uiHoldToRemoveXfromY = json['uiHoldToRemoveXfromY'] as String
      ..uiApplyXToTheGame = json['uiApplyXToTheGame'] as String
      ..uiRemoveXFromTheGame = json['uiRemoveXFromTheGame'] as String
      ..uiApplyAllModsInXToTheGame =
          json['uiApplyAllModsInXToTheGame'] as String
      ..uiRemoveAllModsInXFromTheGame =
          json['uiRemoveAllModsInXFromTheGame'] as String
      ..uiHoldToRemoveXFromThisSet =
          json['uiHoldToRemoveXFromThisSet'] as String
      ..uiSuccessfullyRemovedXFromY =
          json['uiSuccessfullyRemovedXFromY'] as String
      ..uiSelectX = json['uiSelectX'] as String
      ..uiDeselectX = json['uiDeselectX'] as String
      ..uiDirNotFound = json['uiDirNotFound'] as String
      ..uiExportThisMod = json['uiExportThisMod'] as String
      ..uiExportSelectedMods = json['uiExportSelectedMods'] as String
      ..uiRenameThisSet = json['uiRenameThisSet'] as String
      ..uiModSetRename = json['uiModSetRename'] as String
      ..uiImportMods = json['uiImportMods'] as String
      ..uiSelectApplyingLocations = json['uiSelectApplyingLocations'] as String
      ..uiApplyToAllLocations = json['uiApplyToAllLocations'] as String
      ..uiPreparing = json['uiPreparing'] as String
      ..uiDragDropFiles = json['uiDragDropFiles'] as String
      ..uiAchiveCurrentlyNotSupported =
          json['uiAchiveCurrentlyNotSupported'] as String
      ..uiProcess = json['uiProcess'] as String
      ..uiWaitingForData = json['uiWaitingForData'] as String
      ..uiErrorWhenLoadingAddModsData =
          json['uiErrorWhenLoadingAddModsData'] as String
      ..uiProcessingFiles = json['uiProcessingFiles'] as String
      ..uiSelectACategory = json['uiSelectACategory'] as String
      ..uiEditName = json['uiEditName'] as String
      ..uiMarkThisNotToBeAdded = json['uiMarkThisNotToBeAdded'] as String
      ..uiMarkThisToBeAdded = json['uiMarkThisToBeAdded'] as String
      ..uiNameCannotBeEmpty = json['uiNameCannotBeEmpty'] as String
      ..uiRename = json['uiRename'] as String
      ..uiBeforeAdding = json['uiBeforeAdding'] as String
      ..uiThereAreStillModsThatWaitingToBeAdded =
          json['uiThereAreStillModsThatWaitingToBeAdded'] as String
      ..uiModsAddedSuccessfully = json['uiModsAddedSuccessfully'] as String
      ..uiAddAll = json['uiAddAll'] as String
      ..uiDuplicateNamesFound = json['uiDuplicateNamesFound'] as String
      ..uiRenameTheModsBelowBeforeAdding =
          json['uiRenameTheModsBelowBeforeAdding'] as String
      ..uiDuplicateModsIn = json['uiDuplicateModsIn'] as String
      ..uiRenameForMe = json['uiRenameForMe'] as String
      ..uiAddingMods = json['uiAddingMods'] as String
      ..uiPickAColor = json['uiPickAColor'] as String
      ..uiDuplicatesInAppliedModsFound =
          json['uiDuplicatesInAppliedModsFound'] as String
      ..uiApplyingWouldReplaceModFiles =
          json['uiApplyingWouldReplaceModFiles'] as String
      ..uiNewCateGroup = json['uiNewCateGroup'] as String
      ..uiNameAlreadyExisted = json['uiNameAlreadyExisted'] as String
      ..uiNewCateGroupName = json['uiNewCateGroupName'] as String
      ..uiNewCate = json['uiNewCate'] as String
      ..uiNewCateName = json['uiNewCateName'] as String
      ..uiRemovingCateGroup = json['uiRemovingCateGroup'] as String
      ..uiCateFoundWhenDeletingGroup =
          json['uiCateFoundWhenDeletingGroup'] as String
      ..uiThereAre = json['uiThereAre'] as String
      ..uiCatesFoundWhenDeletingGroup =
          json['uiCatesFoundWhenDeletingGroup'] as String
      ..uiMoveEverythingToOthers = json['uiMoveEverythingToOthers'] as String
      ..uiNoDeleteAll = json['uiNoDeleteAll'] as String
      ..uiRemovingCate = json['uiRemovingCate'] as String
      ..uiItemFoundWhenDeletingCate =
          json['uiItemFoundWhenDeletingCate'] as String
      ..uiItemsFoundWhenDeletingCate =
          json['uiItemsFoundWhenDeletingCate'] as String
      ..uiSuccessfullyRemovedTheseMods =
          json['uiSuccessfullyRemovedTheseMods'] as String
      ..uiPso2binFolderNotFoundSelect =
          json['uiPso2binFolderNotFoundSelect'] as String
      ..uiSelectPso2binFolderPath = json['uiSelectPso2binFolderPath'] as String
      ..uiMMFolderNotFound = json['uiMMFolderNotFound'] as String
      ..uiSelectPathToStoreMMFolder =
          json['uiSelectPathToStoreMMFolder'] as String
      ..uiSelectAFolderToStoreMMFolder =
          json['uiSelectAFolderToStoreMMFolder'] as String
      ..uiCurrentPath = json['uiCurrentPath'] as String
      ..uiReselect = json['uiReselect'] as String
      ..uiMMPathReselectNoteCurrentPath =
          json['uiMMPathReselectNoteCurrentPath'] as String
      ..uiWindowsStoreVerNote = json['uiWindowsStoreVerNote'] as String
      ..uiCheckingAppliedMods = json['uiCheckingAppliedMods'] as String
      ..uiErrorWhenCheckingAppliedMods =
          json['uiErrorWhenCheckingAppliedMods'] as String
      ..uiReappliedModsAfterChecking =
          json['uiReappliedModsAfterChecking'] as String
      ..uireApplyingModFiles = json['uireApplyingModFiles'] as String
      ..uiDontReapplyRemoveFromAppliedList =
          json['uiDontReapplyRemoveFromAppliedList'] as String
      ..uiReapply = json['uiReapply'] as String
      ..uiLoadingAppliedMods = json['uiLoadingAppliedMods'] as String
      ..uiErrorWhenLoadingAppliedMods =
          json['uiErrorWhenLoadingAppliedMods'] as String
      ..uiLoadingModSets = json['uiLoadingModSets'] as String
      ..uiErrorWhenLoadingModSets = json['uiErrorWhenLoadingModSets'] as String
      ..uiLoadingMods = json['uiLoadingMods'] as String
      ..uiErrorWhenLoadingMods = json['uiErrorWhenLoadingMods'] as String
      ..uiSkipStartupIconFectching =
          json['uiSkipStartupIconFectching'] as String
      ..uiLoadingPaths = json['uiLoadingPaths'] as String
      ..uiErrorWhenLoadingPaths = json['uiErrorWhenLoadingPaths'] as String
      ..uiPrevious = json['uiPrevious'] as String
      ..uiNext = json['uiNext'] as String
      ..uiAutoPlay = json['uiAutoPlay'] as String
      ..uiStopAutoPlay = json['uiStopAutoPlay'] as String
      ..uiMovingCategory = json['uiMovingCategory'] as String
      ..uiSelectACategoryGroupBelowToMove =
          json['uiSelectACategoryGroupBelowToMove'] as String
      ..uiCategory = json['uiCategory'] as String
      ..uiCategories = json['uiCategories'] as String
      ..uiModsLoader = json['uiModsLoader'] as String
      ..uiAutoFetchItemIcons = json['uiAutoFetchItemIcons'] as String
      ..uiOneIconEachItem = json['uiOneIconEachItem'] as String
      ..uiFetchAll = json['uiFetchAll'] as String
      ..uiChooseAVariantFoundBellow =
          json['uiChooseAVariantFoundBellow'] as String
      ..uiChooseAnItemBellowToSwap =
          json['uiChooseAnItemBellowToSwap'] as String
      ..uiSearchSwapItems = json['uiSearchSwapItems'] as String
      ..uiReplaceNQwithHQ = json['uiReplaceNQwithHQ'] as String
      ..uiSwapAllFilesInsideIce = json['uiSwapAllFilesInsideIce'] as String
      ..uiRemoveUnmatchingFiles = json['uiRemoveUnmatchingFiles'] as String
      ..uiSwap = json['uiSwap'] as String
      ..uiNoteModsMightNotWokAfterSwapping =
          json['uiNoteModsMightNotWokAfterSwapping'] as String
      ..uiItemID = json['uiItemID'] as String
      ..uiAdjustedID = json['uiAdjustedID'] as String
      ..uiSwapToIdleMotion = json['uiSwapToIdleMotion'] as String
      ..uiSwappingQueue = json['uiSwappingQueue'] as String
      ..uiClearQueue = json['uiClearQueue'] as String
      ..uiAddToQueue = json['uiAddToQueue'] as String
      ..uiItemsToSwap = json['uiItemsToSwap'] as String
      ..uiNoMatchingIceFoundToSwap =
          json['uiNoMatchingIceFoundToSwap'] as String
      ..uiSwappingItem = json['uiSwappingItem'] as String
      ..uiErrorWhenSwapping = json['uiErrorWhenSwapping'] as String
      ..uiSuccessfullySwapped = json['uiSuccessfullySwapped'] as String
      ..uiAddToModManager = json['uiAddToModManager'] as String
      ..uiFailedToSwap = json['uiFailedToSwap'] as String
      ..uiUnableToSwapTheseFilesBelow =
          json['uiUnableToSwapTheseFilesBelow'] as String
      ..uiLoadingItemRefSheetsData =
          json['uiLoadingItemRefSheetsData'] as String
      ..uiErrorWhenLoadingItemRefSheets =
          json['uiErrorWhenLoadingItemRefSheets'] as String
      ..uiFetchingItemInfo = json['uiFetchingItemInfo'] as String
      ..uiErrorWhenFetchingItemInfo =
          json['uiErrorWhenFetchingItemInfo'] as String
      ..uiItemCategoryNotFound = json['uiItemCategoryNotFound'] as String
      ..uiExperimental = json['uiExperimental'] as String
      ..uiChooseAnItemBelow = json['uiChooseAnItemBelow'] as String
      ..uiSelectAnItemToBeReplaced =
          json['uiSelectAnItemToBeReplaced'] as String
      ..uiItemCategories = json['uiItemCategories'] as String
      ..uiFetchingItemPatchListsFromServers =
          json['uiFetchingItemPatchListsFromServers'] as String
      ..uiErrorWhenTryingToFetchingItemPatchListsFromServers =
          json['uiErrorWhenTryingToFetchingItemPatchListsFromServers'] as String
      ..uiDuplicateModsInside = json['uiDuplicateModsInside'] as String
      ..uiRenameThis = json['uiRenameThis'] as String
      ..uiClickToRename = json['uiClickToRename'] as String
      ..uiDuplicatedMod = json['uiDuplicatedMod'] as String
      ..uiDuplicatedMods = json['uiDuplicatedMods'] as String
      ..uiGroupSameItemVariants = json['uiGroupSameItemVariants'] as String
      ..uiAddFolders = json['uiAddFolders'] as String
      ..uiAddFiles = json['uiAddFiles'] as String
      ..uiCharacters = json['uiCharacters'] as String
      ..uiPathTooLongError = json['uiPathTooLongError'] as String
      ..uiExtracting = json['uiExtracting'] as String
      ..uiCopying = json['uiCopying'] as String
      ..uiSorting = json['uiSorting'] as String
      ..uiSortingIceFiles = json['uiSortingIceFiles'] as String
      ..uiSortingOtherFiles = json['uiSortingOtherFiles'] as String
      ..uiProcessing = json['uiProcessing'] as String
      ..uiNewProfileName = json['uiNewProfileName'] as String
      ..uiApplyingAllAvailableMods =
          json['uiApplyingAllAvailableMods'] as String
      ..uiLocatingOriginalFiles = json['uiLocatingOriginalFiles'] as String
      ..uiErrorWhenLocatingOriginalFiles =
          json['uiErrorWhenLocatingOriginalFiles'] as String
      ..uiPatchNotes = json['uiPatchNotes'] as String
      ..uiMMUpdate = json['uiMMUpdate'] as String
      ..uiMMUpdateSuccess = json['uiMMUpdateSuccess'] as String
      ..uiDownloadingUpdate = json['uiDownloadingUpdate'] as String
      ..uiDownloadingUpdateError = json['uiDownloadingUpdateError'] as String
      ..uiGoToDownloadPage = json['uiGoToDownloadPage'] as String
      ..uiGitHubPage = json['uiGitHubPage'] as String
      ..uiBoundaryRadiusModification =
          json['uiBoundaryRadiusModification'] as String
      ..uiIndexingFiles = json['uiIndexingFiles'] as String
      ..uispaceFoundExcl = json['uispaceFoundExcl'] as String
      ..uiMatchingFilesFound = json['uiMatchingFilesFound'] as String
      ..uiExtractingFiles = json['uiExtractingFiles'] as String
      ..uiReadingspace = json['uiReadingspace'] as String
      ..uiEditingBoundaryRadiusValue =
          json['uiEditingBoundaryRadiusValue'] as String
      ..uiPackingFiles = json['uiPackingFiles'] as String
      ..uiReplacingModFiles = json['uiReplacingModFiles'] as String
      ..uiAllDone = json['uiAllDone'] as String
      ..uiMakeSureToReapplyThisMod =
          json['uiMakeSureToReapplyThisMod'] as String
      ..uiBoundaryRadiusValueNotFound =
          json['uiBoundaryRadiusValueNotFound'] as String
      ..uiNoAqpFileFound = json['uiNoAqpFileFound'] as String
      ..uiNoMatchingFileFound = json['uiNoMatchingFileFound'] as String
      ..uiOnlyBasewearsAndSetwearsCanBeModified =
          json['uiOnlyBasewearsAndSetwearsCanBeModified'] as String
      ..uiCustomBackgrounds = json['uiCustomBackgrounds'] as String
      ..uiHoldToDeleteThisBackground =
          json['uiHoldToDeleteThisBackground'] as String
      ..uiOpenInFileExplorer = json['uiOpenInFileExplorer'] as String
      ..uiCreateBackground = json['uiCreateBackground'] as String
      ..uiSwappedAvailableBackgrounds =
          json['uiSwappedAvailableBackgrounds'] as String
      ..uiHoldToRestoreThisBackgroundToItsOriginal =
          json['uiHoldToRestoreThisBackgroundToItsOriginal'] as String
      ..uiRestoreAll = json['uiRestoreAll'] as String
      ..uiCroppedImageName = json['uiCroppedImageName'] as String
      ..uiSaveCroppedArea = json['uiSaveCroppedArea'] as String
      ..uiOverwriteImage = json['uiOverwriteImage'] as String
      ..uiVitalGaugeBackGroundsInstruction =
          json['uiVitalGaugeBackGroundsInstruction'] as String
      ..uicheckingReplacedVitalGaugeBackgrounds =
          json['uicheckingReplacedVitalGaugeBackgrounds'] as String
      ..uierrorWhenCheckingReplacedVitalGaugeBackgrounds =
          json['uierrorWhenCheckingReplacedVitalGaugeBackgrounds'] as String
      ..uiReappliedVitalGaugesAfterChecking =
          json['uiReappliedVitalGaugesAfterChecking'] as String
      ..uiRequiredDotnetRuntimeMissing =
          json['uiRequiredDotnetRuntimeMissing'] as String
      ..uiRequiresDotnetRuntimeToWorkProperly =
          json['uiRequiresDotnetRuntimeToWorkProperly'] as String
      ..uiYourDotNetVersions = json['uiYourDotNetVersions'] as String
      ..uiUseButtonBelowToGetDotnet =
          json['uiUseButtonBelowToGetDotnet'] as String
      ..uiGetDotnetRuntime6 = json['uiGetDotnetRuntime6'] as String
      ..uiNoGamedataFound = json['uiNoGamedataFound'] as String
      ..uiNoGameDataFoundMessage = json['uiNoGameDataFoundMessage'] as String
      ..uiDuplicatesFoundInTheCurrentSet =
          json['uiDuplicatesFoundInTheCurrentSet'] as String
      ..uiReplaceAll = json['uiReplaceAll'] as String
      ..uiReplaceDuplicateFilesOnly =
          json['uiReplaceDuplicateFilesOnly'] as String
      ..uiNewModSet = json['uiNewModSet'] as String
      ..uiCreateAndAddModsToThisSet =
          json['uiCreateAndAddModsToThisSet'] as String
      ..uiAddNewSet = json['uiAddNewSet'] as String
      ..uiEnterNewName = json['uiEnterNewName'] as String
      ..uiModExport = json['uiModExport'] as String
      ..uiExportingMods = json['uiExportingMods'] as String
      ..uiErrorWhenExportingMods = json['uiErrorWhenExportingMods'] as String
      ..uiExport = json['uiExport'] as String
      ..uiWaiting = json['uiWaiting'] as String
      ..uiExportedNote = json['uiExportedNote'] as String
      ..uiFilesNotSupported = json['uiFilesNotSupported'] as String
      ..uiImportModDragDrop = json['uiImportModDragDrop'] as String
      ..uiCreateASetForImportedMods =
          json['uiCreateASetForImportedMods'] as String
      ..uiEnterImportedSetName = json['uiEnterImportedSetName'] as String
      ..uiImport = json['uiImport'] as String
      ..uiImportAndApply = json['uiImportAndApply'] as String
      ..uiApplyingImportedMods = json['uiApplyingImportedMods'] as String
      ..uiNoFilesInGameDataToReplace =
          json['uiNoFilesInGameDataToReplace'] as String
      ..uiLoadingPlayerItemData = json['uiLoadingPlayerItemData'] as String
      ..uiErrorWhenLoadingPlayerItemData =
          json['uiErrorWhenLoadingPlayerItemData'] as String;

Map<String, dynamic> _$TranslationTextToJson(TranslationText instance) =>
    <String, dynamic>{
      'uiCancel': instance.uiCancel,
      'uiAdd': instance.uiAdd,
      'uiDismiss': instance.uiDismiss,
      'uiBack': instance.uiBack,
      'uiError': instance.uiError,
      'uiApply': instance.uiApply,
      'uiClose': instance.uiClose,
      'uiReset': instance.uiReset,
      'uiGotIt': instance.uiGotIt,
      'uiReturn': instance.uiReturn,
      'uiSure': instance.uiSure,
      'uiYes': instance.uiYes,
      'uiNo': instance.uiNo,
      'uiClearAll': instance.uiClearAll,
      'uiExit': instance.uiExit,
      'uiON': instance.uiON,
      'uiOFF': instance.uiOFF,
      'uiMove': instance.uiMove,
      'uiContinue': instance.uiContinue,
      'uiUnknown': instance.uiUnknown,
      'uiUnknownItem': instance.uiUnknownItem,
      'uiUnknownAccessory': instance.uiUnknownAccessory,
      'uiUnknownEmote': instance.uiUnknownEmote,
      'uiUnknownMotion': instance.uiUnknownMotion,
      'uiGenderMale': instance.uiGenderMale,
      'uiGenderFemale': instance.uiGenderFemale,
      'uiGenderBoth': instance.uiGenderBoth,
      'dfCastParts': instance.dfCastParts,
      'dfLayeringWears': instance.dfLayeringWears,
      'dfOthers': instance.dfOthers,
      'dfAccessories': instance.dfAccessories,
      'dfBasewears': instance.dfBasewears,
      'dfBodyPaints': instance.dfBodyPaints,
      'dfCastArmParts': instance.dfCastArmParts,
      'dfCastBodyParts': instance.dfCastBodyParts,
      'dfCastLegParts': instance.dfCastLegParts,
      'dfCostumes': instance.dfCostumes,
      'dfEmotes': instance.dfEmotes,
      'dfEyes': instance.dfEyes,
      'dfFacePaints': instance.dfFacePaints,
      'dfHairs': instance.dfHairs,
      'dfInnerwears': instance.dfInnerwears,
      'dfMags': instance.dfMags,
      'dfMisc': instance.dfMisc,
      'dfMotions': instance.dfMotions,
      'dfOuterwears': instance.dfOuterwears,
      'dfSetwears': instance.dfSetwears,
      'uiSettings': instance.uiSettings,
      'uiLanguage': instance.uiLanguage,
      'uiAddANewLanguage': instance.uiAddANewLanguage,
      'uiNewLanguageInititalInput': instance.uiNewLanguageInititalInput,
      'uiNewLanguageInitialEmptyError': instance.uiNewLanguageInitialEmptyError,
      'uiNewLanguageInititalAlreadyExisted':
          instance.uiNewLanguageInititalAlreadyExisted,
      'uiCurrentLanguage': instance.uiCurrentLanguage,
      'uiReselectPso2binPath': instance.uiReselectPso2binPath,
      'uiReselectModManFolderPath': instance.uiReselectModManFolderPath,
      'uiOpenModsFolder': instance.uiOpenModsFolder,
      'uiOpenBackupFolder': instance.uiOpenBackupFolder,
      'uiOpenDeletedItemsFolder': instance.uiOpenDeletedItemsFolder,
      'uiTheme': instance.uiTheme,
      'uiSwitchToDarkTheme': instance.uiSwitchToDarkTheme,
      'uiSwitchToLightTheme': instance.uiSwitchToLightTheme,
      'uiAppearance': instance.uiAppearance,
      'uiDarkTheme': instance.uiDarkTheme,
      'uiLightTheme': instance.uiLightTheme,
      'uiUIOpacity': instance.uiUIOpacity,
      'uiUIColors': instance.uiUIColors,
      'uiPrimarySwatch': instance.uiPrimarySwatch,
      'uiMainUIBackground': instance.uiMainUIBackground,
      'uiPrimaryColor': instance.uiPrimaryColor,
      'uiPrimaryLight': instance.uiPrimaryLight,
      'uiPrimaryDark': instance.uiPrimaryDark,
      'uiMainCanvasBackground': instance.uiMainCanvasBackground,
      'uiHoldToResetColors': instance.uiHoldToResetColors,
      'uiBackgroundImage': instance.uiBackgroundImage,
      'uiClicktoChangeBackgroundImage': instance.uiClicktoChangeBackgroundImage,
      'uiNoBackgroundImageFound': instance.uiNoBackgroundImageFound,
      'uiSelectBackgroundImage': instance.uiSelectBackgroundImage,
      'uiHideBackgroundImage': instance.uiHideBackgroundImage,
      'uiShowBackgroundImage': instance.uiShowBackgroundImage,
      'uiHoldToRemoveBackgroundImage': instance.uiHoldToRemoveBackgroundImage,
      'uiVersion': instance.uiVersion,
      'uiMadeBy': instance.uiMadeBy,
      'uiNewUpdateAvailableClickToDownload':
          instance.uiNewUpdateAvailableClickToDownload,
      'uiAddNewModsToMM': instance.uiAddNewModsToMM,
      'uiAddMods': instance.uiAddMods,
      'uiManageModSets': instance.uiManageModSets,
      'uiManageModList': instance.uiManageModList,
      'uiModSets': instance.uiModSets,
      'uiModList': instance.uiModList,
      'uiRefreshMM': instance.uiRefreshMM,
      'uiRefresh': instance.uiRefresh,
      'uiOpenChecksumFolder': instance.uiOpenChecksumFolder,
      'uiChecksumDownloadSelect': instance.uiChecksumDownloadSelect,
      'uiSelectLocalChecksum': instance.uiSelectLocalChecksum,
      'uiChecksum': instance.uiChecksum,
      'uiChecksumMissingClick': instance.uiChecksumMissingClick,
      'uiChecksumOutdatedClick': instance.uiChecksumOutdatedClick,
      'uiChecksumDownloading': instance.uiChecksumDownloading,
      'uiPreviewShowHide': instance.uiPreviewShowHide,
      'uiPreview': instance.uiPreview,
      'uiOpenMMSettings': instance.uiOpenMMSettings,
      'uiNewMMUpdateAvailable': instance.uiNewMMUpdateAvailable,
      'uiNewVersion': instance.uiNewVersion,
      'uiCurrentVersion': instance.uiCurrentVersion,
      'uiPatchNote': instance.uiPatchNote,
      'uiSkipMMUpdate': instance.uiSkipMMUpdate,
      'uiUpdate': instance.uiUpdate,
      'uiNewRefSheetsUpdate': instance.uiNewRefSheetsUpdate,
      'uiDownloading': instance.uiDownloading,
      'uiOf': instance.uiOf,
      'uiRefSheetsDownloadingCount': instance.uiRefSheetsDownloadingCount,
      'uiDownloadUpdate': instance.uiDownloadUpdate,
      'uiNewUserNotice': instance.uiNewUserNotice,
      'uiUpdateNow': instance.uiUpdateNow,
      'uiTurnOffStartupIconsFetching': instance.uiTurnOffStartupIconsFetching,
      'uiTurnOnStartupIconsFetching': instance.uiTurnOnStartupIconsFetching,
      'uiStartupItemIconsFetching': instance.uiStartupItemIconsFetching,
      'uiTurnOffSlidingItemIcons': instance.uiTurnOffSlidingItemIcons,
      'uiTurnOnSlidingItemIcons': instance.uiTurnOnSlidingItemIcons,
      'uiSlidingItemIcons': instance.uiSlidingItemIcons,
      'uiWillNotFetchItemIcon': instance.uiWillNotFetchItemIcon,
      'uiOnlyFetchOneIcon': instance.uiOnlyFetchOneIcon,
      'uiFetchAllMissingItemIcons': instance.uiFetchAllMissingItemIcons,
      'uiMinimal': instance.uiMinimal,
      'uiAll': instance.uiAll,
      'uiSwapItems': instance.uiSwapItems,
      'uiSwapAnItemToAnotherItem': instance.uiSwapAnItemToAnotherItem,
      'uiProfiles': instance.uiProfiles,
      'uiClickToChangeToThisProfileHoldToRename':
          instance.uiClickToChangeToThisProfileHoldToRename,
      'uiVitalGauge': instance.uiVitalGauge,
      'uiCreateAndSwapVitalGaugeBackground':
          instance.uiCreateAndSwapVitalGaugeBackground,
      'uiRemoveProfanityFilter': instance.uiRemoveProfanityFilter,
      'uiExtras': instance.uiExtras,
      'uiOtherFeaturesOfPSO2NGSModManager':
          instance.uiOtherFeaturesOfPSO2NGSModManager,
      'uiAutoRadiusRemovalTooltip': instance.uiAutoRadiusRemovalTooltip,
      'uiAutoBoundaryRadiusRemoval': instance.uiAutoBoundaryRadiusRemoval,
      'uiPrioritizeLocalBackupTooltip': instance.uiPrioritizeLocalBackupTooltip,
      'uiPrioritizeLocalBackups': instance.uiPrioritizeLocalBackups,
      'uiPrioritizeSegaBackups': instance.uiPrioritizeSegaBackups,
      'uiCmxRefreshToolTip': instance.uiCmxRefreshToolTip,
      'uiRefreshingCmx': instance.uiRefreshingCmx,
      'uiRefreshCmx': instance.uiRefreshCmx,
      'uiItemNameLanguage': instance.uiItemNameLanguage,
      'uiItemNameLanguageTooltip': instance.uiItemNameLanguageTooltip,
      'uiOpenMainModManFolder': instance.uiOpenMainModManFolder,
      'uiOpenExportedModsFolder': instance.uiOpenExportedModsFolder,
      'uiImportExportedMods': instance.uiImportExportedMods,
      'uiStartPSO2': instance.uiStartPSO2,
      'uiLaunchGameJPVerOnly': instance.uiLaunchGameJPVerOnly,
      'uiIfGameNotLaunching': instance.uiIfGameNotLaunching,
      'uiItemList': instance.uiItemList,
      'uiLoadingUILanguage': instance.uiLoadingUILanguage,
      'uiReloadingMods': instance.uiReloadingMods,
      'uiShowFavList': instance.uiShowFavList,
      'uiFavItemList': instance.uiFavItemList,
      'uiUnhideAllCate': instance.uiUnhideAllCate,
      'uiTurnOffAutoHideEmptyCate': instance.uiTurnOffAutoHideEmptyCate,
      'uiTurnOnAutoHideEmptyCate': instance.uiTurnOnAutoHideEmptyCate,
      'uiShowHideCate': instance.uiShowHideCate,
      'uiHiddenItemList': instance.uiHiddenItemList,
      'uiSortByNameDescen': instance.uiSortByNameDescen,
      'uiSortByNameAscen': instance.uiSortByNameAscen,
      'uiSortItemList': instance.uiSortItemList,
      'uiAddNewCateGroup': instance.uiAddNewCateGroup,
      'uiSearchForMods': instance.uiSearchForMods,
      'uiUnhide': instance.uiUnhide,
      'uiItem': instance.uiItem,
      'uiItems': instance.uiItems,
      'uiRemove': instance.uiRemove,
      'uiFromFavList': instance.uiFromFavList,
      'uiMod': instance.uiMod,
      'uiMods': instance.uiMods,
      'uiApplied': instance.uiApplied,
      'uiOpen': instance.uiOpen,
      'uiInFileExplorer': instance.uiInFileExplorer,
      'uiHoldToRemove': instance.uiHoldToRemove,
      'uiFromMM': instance.uiFromMM,
      'uiSuccess': instance.uiSuccess,
      'uiSuccessfullyRemoved': instance.uiSuccessfullyRemoved,
      'uiHoldToDelete': instance.uiHoldToDelete,
      'uiSortCateInThisGroup': instance.uiSortCateInThisGroup,
      'uiAddANewCateTo': instance.uiAddANewCateTo,
      'uiHoldToHide': instance.uiHoldToHide,
      'uiFromItemList': instance.uiFromItemList,
      'uiFrom': instance.uiFrom,
      'uiClearAvailableModsView': instance.uiClearAvailableModsView,
      'uiAvailableMods': instance.uiAvailableMods,
      'uiVariant': instance.uiVariant,
      'uiVariants': instance.uiVariants,
      'uiFromTheGame': instance.uiFromTheGame,
      'uiCouldntFindBackupFileFor': instance.uiCouldntFindBackupFileFor,
      'uiToTheGame': instance.uiToTheGame,
      'uiCouldntFindOGFileFor': instance.uiCouldntFindOGFileFor,
      'uiSuccessfullyApplied': instance.uiSuccessfullyApplied,
      'uiToFavList': instance.uiToFavList,
      'uiHoldToRemoveAllAppliedMods': instance.uiHoldToRemoveAllAppliedMods,
      'uiAddAllAppliedModsToSets': instance.uiAddAllAppliedModsToSets,
      'uiAppliedMods': instance.uiAppliedMods,
      'uiFilesApplied': instance.uiFilesApplied,
      'uiNoPreViewAvailable': instance.uiNoPreViewAvailable,
      'uiCreateNewModSet': instance.uiCreateNewModSet,
      'uiEnterNewModSetName': instance.uiEnterNewModSetName,
      'uiRemoveAllModsIn': instance.uiRemoveAllModsIn,
      'uiSuccessfullyRemoveAllModsIn': instance.uiSuccessfullyRemoveAllModsIn,
      'uiApplyAllModsIn': instance.uiApplyAllModsIn,
      'uiSuccessfullyAppliedAllModsIn': instance.uiSuccessfullyAppliedAllModsIn,
      'uiAddToThisSet': instance.uiAddToThisSet,
      'uiFromThisSet': instance.uiFromThisSet,
      'uiToAnotherItem': instance.uiToAnotherItem,
      'uiUnableToObtainOrginalFilesFromSegaServers':
          instance.uiUnableToObtainOrginalFilesFromSegaServers,
      'uiSwitchingProfile': instance.uiSwitchingProfile,
      'uiProfile': instance.uiProfile,
      'uiHoldToApplyAllAvailableModsToTheGame':
          instance.uiHoldToApplyAllAvailableModsToTheGame,
      'uiHoldToReapplyAllModsInAppliedList':
          instance.uiHoldToReapplyAllModsInAppliedList,
      'uiHoldToModifyBoundaryRadius': instance.uiHoldToModifyBoundaryRadius,
      'uiAddToFavList': instance.uiAddToFavList,
      'uiRemoveFromFavList': instance.uiRemoveFromFavList,
      'uiMore': instance.uiMore,
      'uiSwapToAnotherItem': instance.uiSwapToAnotherItem,
      'uiRemoveBoundaryRadius': instance.uiRemoveBoundaryRadius,
      'uiRemoveFromMM': instance.uiRemoveFromMM,
      'uiAddToModSets': instance.uiAddToModSets,
      'uiRemoveFromThisSet': instance.uiRemoveFromThisSet,
      'uiSelect': instance.uiSelect,
      'uiDeselect': instance.uiDeselect,
      'uiSelectAllAppliedMods': instance.uiSelectAllAppliedMods,
      'uiDeselectAllAppliedMods': instance.uiDeselectAllAppliedMods,
      'uiSelectAll': instance.uiSelectAll,
      'uiDeselectAll': instance.uiDeselectAll,
      'uiHoldToReapplySelectedMods': instance.uiHoldToReapplySelectedMods,
      'uiHoldToRemoveSelectedMods': instance.uiHoldToRemoveSelectedMods,
      'uiAddSelectedModsToModSets': instance.uiAddSelectedModsToModSets,
      'uiFailed': instance.uiFailed,
      'uiFailedToRemove': instance.uiFailedToRemove,
      'uiUnknownErrorWhenRemovingModFromTheGame':
          instance.uiUnknownErrorWhenRemovingModFromTheGame,
      'uiSuccessWithErrors': instance.uiSuccessWithErrors,
      'uiCmx': instance.uiCmx,
      'uiAddChangeCmxFile': instance.uiAddChangeCmxFile,
      'uiCmxFile': instance.uiCmxFile,
      'uiMoveThisCategoryToAnotherGroup':
          instance.uiMoveThisCategoryToAnotherGroup,
      'uiUnhideX': instance.uiUnhideX,
      'uiRemoveXFromFav': instance.uiRemoveXFromFav,
      'uiOpenXInFileExplorer': instance.uiOpenXInFileExplorer,
      'uiHoldToRemoveXFromModMan': instance.uiHoldToRemoveXFromModMan,
      'uiSuccessfullyRemovedXFromModMan':
          instance.uiSuccessfullyRemovedXFromModMan,
      'uiSuccessfullyAppliedX': instance.uiSuccessfullyAppliedX,
      'uiSuccessfullyAppliedXInY': instance.uiSuccessfullyAppliedXInY,
      'uiAddNewCateToXGroup': instance.uiAddNewCateToXGroup,
      'uiHoldToHideXFromItemList': instance.uiHoldToHideXFromItemList,
      'uiHoldToRemoveXfromY': instance.uiHoldToRemoveXfromY,
      'uiApplyXToTheGame': instance.uiApplyXToTheGame,
      'uiRemoveXFromTheGame': instance.uiRemoveXFromTheGame,
      'uiApplyAllModsInXToTheGame': instance.uiApplyAllModsInXToTheGame,
      'uiRemoveAllModsInXFromTheGame': instance.uiRemoveAllModsInXFromTheGame,
      'uiHoldToRemoveXFromThisSet': instance.uiHoldToRemoveXFromThisSet,
      'uiSuccessfullyRemovedXFromY': instance.uiSuccessfullyRemovedXFromY,
      'uiSelectX': instance.uiSelectX,
      'uiDeselectX': instance.uiDeselectX,
      'uiDirNotFound': instance.uiDirNotFound,
      'uiExportThisMod': instance.uiExportThisMod,
      'uiExportSelectedMods': instance.uiExportSelectedMods,
      'uiRenameThisSet': instance.uiRenameThisSet,
      'uiModSetRename': instance.uiModSetRename,
      'uiImportMods': instance.uiImportMods,
      'uiSelectApplyingLocations': instance.uiSelectApplyingLocations,
      'uiApplyToAllLocations': instance.uiApplyToAllLocations,
      'uiPreparing': instance.uiPreparing,
      'uiDragDropFiles': instance.uiDragDropFiles,
      'uiAchiveCurrentlyNotSupported': instance.uiAchiveCurrentlyNotSupported,
      'uiProcess': instance.uiProcess,
      'uiWaitingForData': instance.uiWaitingForData,
      'uiErrorWhenLoadingAddModsData': instance.uiErrorWhenLoadingAddModsData,
      'uiProcessingFiles': instance.uiProcessingFiles,
      'uiSelectACategory': instance.uiSelectACategory,
      'uiEditName': instance.uiEditName,
      'uiMarkThisNotToBeAdded': instance.uiMarkThisNotToBeAdded,
      'uiMarkThisToBeAdded': instance.uiMarkThisToBeAdded,
      'uiNameCannotBeEmpty': instance.uiNameCannotBeEmpty,
      'uiRename': instance.uiRename,
      'uiBeforeAdding': instance.uiBeforeAdding,
      'uiThereAreStillModsThatWaitingToBeAdded':
          instance.uiThereAreStillModsThatWaitingToBeAdded,
      'uiModsAddedSuccessfully': instance.uiModsAddedSuccessfully,
      'uiAddAll': instance.uiAddAll,
      'uiDuplicateNamesFound': instance.uiDuplicateNamesFound,
      'uiRenameTheModsBelowBeforeAdding':
          instance.uiRenameTheModsBelowBeforeAdding,
      'uiDuplicateModsIn': instance.uiDuplicateModsIn,
      'uiRenameForMe': instance.uiRenameForMe,
      'uiAddingMods': instance.uiAddingMods,
      'uiPickAColor': instance.uiPickAColor,
      'uiDuplicatesInAppliedModsFound': instance.uiDuplicatesInAppliedModsFound,
      'uiApplyingWouldReplaceModFiles': instance.uiApplyingWouldReplaceModFiles,
      'uiNewCateGroup': instance.uiNewCateGroup,
      'uiNameAlreadyExisted': instance.uiNameAlreadyExisted,
      'uiNewCateGroupName': instance.uiNewCateGroupName,
      'uiNewCate': instance.uiNewCate,
      'uiNewCateName': instance.uiNewCateName,
      'uiRemovingCateGroup': instance.uiRemovingCateGroup,
      'uiCateFoundWhenDeletingGroup': instance.uiCateFoundWhenDeletingGroup,
      'uiThereAre': instance.uiThereAre,
      'uiCatesFoundWhenDeletingGroup': instance.uiCatesFoundWhenDeletingGroup,
      'uiMoveEverythingToOthers': instance.uiMoveEverythingToOthers,
      'uiNoDeleteAll': instance.uiNoDeleteAll,
      'uiRemovingCate': instance.uiRemovingCate,
      'uiItemFoundWhenDeletingCate': instance.uiItemFoundWhenDeletingCate,
      'uiItemsFoundWhenDeletingCate': instance.uiItemsFoundWhenDeletingCate,
      'uiSuccessfullyRemovedTheseMods': instance.uiSuccessfullyRemovedTheseMods,
      'uiPso2binFolderNotFoundSelect': instance.uiPso2binFolderNotFoundSelect,
      'uiSelectPso2binFolderPath': instance.uiSelectPso2binFolderPath,
      'uiMMFolderNotFound': instance.uiMMFolderNotFound,
      'uiSelectPathToStoreMMFolder': instance.uiSelectPathToStoreMMFolder,
      'uiSelectAFolderToStoreMMFolder': instance.uiSelectAFolderToStoreMMFolder,
      'uiCurrentPath': instance.uiCurrentPath,
      'uiReselect': instance.uiReselect,
      'uiMMPathReselectNoteCurrentPath':
          instance.uiMMPathReselectNoteCurrentPath,
      'uiWindowsStoreVerNote': instance.uiWindowsStoreVerNote,
      'uiCheckingAppliedMods': instance.uiCheckingAppliedMods,
      'uiErrorWhenCheckingAppliedMods': instance.uiErrorWhenCheckingAppliedMods,
      'uiReappliedModsAfterChecking': instance.uiReappliedModsAfterChecking,
      'uireApplyingModFiles': instance.uireApplyingModFiles,
      'uiDontReapplyRemoveFromAppliedList':
          instance.uiDontReapplyRemoveFromAppliedList,
      'uiReapply': instance.uiReapply,
      'uiLoadingAppliedMods': instance.uiLoadingAppliedMods,
      'uiErrorWhenLoadingAppliedMods': instance.uiErrorWhenLoadingAppliedMods,
      'uiLoadingModSets': instance.uiLoadingModSets,
      'uiErrorWhenLoadingModSets': instance.uiErrorWhenLoadingModSets,
      'uiLoadingMods': instance.uiLoadingMods,
      'uiErrorWhenLoadingMods': instance.uiErrorWhenLoadingMods,
      'uiSkipStartupIconFectching': instance.uiSkipStartupIconFectching,
      'uiLoadingPaths': instance.uiLoadingPaths,
      'uiErrorWhenLoadingPaths': instance.uiErrorWhenLoadingPaths,
      'uiPrevious': instance.uiPrevious,
      'uiNext': instance.uiNext,
      'uiAutoPlay': instance.uiAutoPlay,
      'uiStopAutoPlay': instance.uiStopAutoPlay,
      'uiMovingCategory': instance.uiMovingCategory,
      'uiSelectACategoryGroupBelowToMove':
          instance.uiSelectACategoryGroupBelowToMove,
      'uiCategory': instance.uiCategory,
      'uiCategories': instance.uiCategories,
      'uiModsLoader': instance.uiModsLoader,
      'uiAutoFetchItemIcons': instance.uiAutoFetchItemIcons,
      'uiOneIconEachItem': instance.uiOneIconEachItem,
      'uiFetchAll': instance.uiFetchAll,
      'uiChooseAVariantFoundBellow': instance.uiChooseAVariantFoundBellow,
      'uiChooseAnItemBellowToSwap': instance.uiChooseAnItemBellowToSwap,
      'uiSearchSwapItems': instance.uiSearchSwapItems,
      'uiReplaceNQwithHQ': instance.uiReplaceNQwithHQ,
      'uiSwapAllFilesInsideIce': instance.uiSwapAllFilesInsideIce,
      'uiRemoveUnmatchingFiles': instance.uiRemoveUnmatchingFiles,
      'uiSwap': instance.uiSwap,
      'uiNoteModsMightNotWokAfterSwapping':
          instance.uiNoteModsMightNotWokAfterSwapping,
      'uiItemID': instance.uiItemID,
      'uiAdjustedID': instance.uiAdjustedID,
      'uiSwapToIdleMotion': instance.uiSwapToIdleMotion,
      'uiSwappingQueue': instance.uiSwappingQueue,
      'uiClearQueue': instance.uiClearQueue,
      'uiAddToQueue': instance.uiAddToQueue,
      'uiItemsToSwap': instance.uiItemsToSwap,
      'uiNoMatchingIceFoundToSwap': instance.uiNoMatchingIceFoundToSwap,
      'uiSwappingItem': instance.uiSwappingItem,
      'uiErrorWhenSwapping': instance.uiErrorWhenSwapping,
      'uiSuccessfullySwapped': instance.uiSuccessfullySwapped,
      'uiAddToModManager': instance.uiAddToModManager,
      'uiFailedToSwap': instance.uiFailedToSwap,
      'uiUnableToSwapTheseFilesBelow': instance.uiUnableToSwapTheseFilesBelow,
      'uiLoadingItemRefSheetsData': instance.uiLoadingItemRefSheetsData,
      'uiErrorWhenLoadingItemRefSheets':
          instance.uiErrorWhenLoadingItemRefSheets,
      'uiFetchingItemInfo': instance.uiFetchingItemInfo,
      'uiErrorWhenFetchingItemInfo': instance.uiErrorWhenFetchingItemInfo,
      'uiItemCategoryNotFound': instance.uiItemCategoryNotFound,
      'uiExperimental': instance.uiExperimental,
      'uiChooseAnItemBelow': instance.uiChooseAnItemBelow,
      'uiSelectAnItemToBeReplaced': instance.uiSelectAnItemToBeReplaced,
      'uiItemCategories': instance.uiItemCategories,
      'uiFetchingItemPatchListsFromServers':
          instance.uiFetchingItemPatchListsFromServers,
      'uiErrorWhenTryingToFetchingItemPatchListsFromServers':
          instance.uiErrorWhenTryingToFetchingItemPatchListsFromServers,
      'uiDuplicateModsInside': instance.uiDuplicateModsInside,
      'uiRenameThis': instance.uiRenameThis,
      'uiClickToRename': instance.uiClickToRename,
      'uiDuplicatedMod': instance.uiDuplicatedMod,
      'uiDuplicatedMods': instance.uiDuplicatedMods,
      'uiGroupSameItemVariants': instance.uiGroupSameItemVariants,
      'uiAddFolders': instance.uiAddFolders,
      'uiAddFiles': instance.uiAddFiles,
      'uiCharacters': instance.uiCharacters,
      'uiPathTooLongError': instance.uiPathTooLongError,
      'uiExtracting': instance.uiExtracting,
      'uiCopying': instance.uiCopying,
      'uiSorting': instance.uiSorting,
      'uiSortingIceFiles': instance.uiSortingIceFiles,
      'uiSortingOtherFiles': instance.uiSortingOtherFiles,
      'uiProcessing': instance.uiProcessing,
      'uiNewProfileName': instance.uiNewProfileName,
      'uiApplyingAllAvailableMods': instance.uiApplyingAllAvailableMods,
      'uiLocatingOriginalFiles': instance.uiLocatingOriginalFiles,
      'uiErrorWhenLocatingOriginalFiles':
          instance.uiErrorWhenLocatingOriginalFiles,
      'uiPatchNotes': instance.uiPatchNotes,
      'uiMMUpdate': instance.uiMMUpdate,
      'uiMMUpdateSuccess': instance.uiMMUpdateSuccess,
      'uiDownloadingUpdate': instance.uiDownloadingUpdate,
      'uiDownloadingUpdateError': instance.uiDownloadingUpdateError,
      'uiGoToDownloadPage': instance.uiGoToDownloadPage,
      'uiGitHubPage': instance.uiGitHubPage,
      'uiBoundaryRadiusModification': instance.uiBoundaryRadiusModification,
      'uiIndexingFiles': instance.uiIndexingFiles,
      'uispaceFoundExcl': instance.uispaceFoundExcl,
      'uiMatchingFilesFound': instance.uiMatchingFilesFound,
      'uiExtractingFiles': instance.uiExtractingFiles,
      'uiReadingspace': instance.uiReadingspace,
      'uiEditingBoundaryRadiusValue': instance.uiEditingBoundaryRadiusValue,
      'uiPackingFiles': instance.uiPackingFiles,
      'uiReplacingModFiles': instance.uiReplacingModFiles,
      'uiAllDone': instance.uiAllDone,
      'uiMakeSureToReapplyThisMod': instance.uiMakeSureToReapplyThisMod,
      'uiBoundaryRadiusValueNotFound': instance.uiBoundaryRadiusValueNotFound,
      'uiNoAqpFileFound': instance.uiNoAqpFileFound,
      'uiNoMatchingFileFound': instance.uiNoMatchingFileFound,
      'uiOnlyBasewearsAndSetwearsCanBeModified':
          instance.uiOnlyBasewearsAndSetwearsCanBeModified,
      'uiCustomBackgrounds': instance.uiCustomBackgrounds,
      'uiHoldToDeleteThisBackground': instance.uiHoldToDeleteThisBackground,
      'uiOpenInFileExplorer': instance.uiOpenInFileExplorer,
      'uiCreateBackground': instance.uiCreateBackground,
      'uiSwappedAvailableBackgrounds': instance.uiSwappedAvailableBackgrounds,
      'uiHoldToRestoreThisBackgroundToItsOriginal':
          instance.uiHoldToRestoreThisBackgroundToItsOriginal,
      'uiRestoreAll': instance.uiRestoreAll,
      'uiCroppedImageName': instance.uiCroppedImageName,
      'uiSaveCroppedArea': instance.uiSaveCroppedArea,
      'uiOverwriteImage': instance.uiOverwriteImage,
      'uiVitalGaugeBackGroundsInstruction':
          instance.uiVitalGaugeBackGroundsInstruction,
      'uicheckingReplacedVitalGaugeBackgrounds':
          instance.uicheckingReplacedVitalGaugeBackgrounds,
      'uierrorWhenCheckingReplacedVitalGaugeBackgrounds':
          instance.uierrorWhenCheckingReplacedVitalGaugeBackgrounds,
      'uiReappliedVitalGaugesAfterChecking':
          instance.uiReappliedVitalGaugesAfterChecking,
      'uiRequiredDotnetRuntimeMissing': instance.uiRequiredDotnetRuntimeMissing,
      'uiRequiresDotnetRuntimeToWorkProperly':
          instance.uiRequiresDotnetRuntimeToWorkProperly,
      'uiYourDotNetVersions': instance.uiYourDotNetVersions,
      'uiUseButtonBelowToGetDotnet': instance.uiUseButtonBelowToGetDotnet,
      'uiGetDotnetRuntime6': instance.uiGetDotnetRuntime6,
      'uiNoGamedataFound': instance.uiNoGamedataFound,
      'uiNoGameDataFoundMessage': instance.uiNoGameDataFoundMessage,
      'uiDuplicatesFoundInTheCurrentSet':
          instance.uiDuplicatesFoundInTheCurrentSet,
      'uiReplaceAll': instance.uiReplaceAll,
      'uiReplaceDuplicateFilesOnly': instance.uiReplaceDuplicateFilesOnly,
      'uiNewModSet': instance.uiNewModSet,
      'uiCreateAndAddModsToThisSet': instance.uiCreateAndAddModsToThisSet,
      'uiAddNewSet': instance.uiAddNewSet,
      'uiEnterNewName': instance.uiEnterNewName,
      'uiModExport': instance.uiModExport,
      'uiExportingMods': instance.uiExportingMods,
      'uiErrorWhenExportingMods': instance.uiErrorWhenExportingMods,
      'uiExport': instance.uiExport,
      'uiWaiting': instance.uiWaiting,
      'uiExportedNote': instance.uiExportedNote,
      'uiFilesNotSupported': instance.uiFilesNotSupported,
      'uiImportModDragDrop': instance.uiImportModDragDrop,
      'uiCreateASetForImportedMods': instance.uiCreateASetForImportedMods,
      'uiEnterImportedSetName': instance.uiEnterImportedSetName,
      'uiImport': instance.uiImport,
      'uiImportAndApply': instance.uiImportAndApply,
      'uiApplyingImportedMods': instance.uiApplyingImportedMods,
      'uiNoFilesInGameDataToReplace': instance.uiNoFilesInGameDataToReplace,
      'uiLoadingPlayerItemData': instance.uiLoadingPlayerItemData,
      'uiErrorWhenLoadingPlayerItemData':
          instance.uiErrorWhenLoadingPlayerItemData,
    };
