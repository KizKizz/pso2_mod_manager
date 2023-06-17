// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ui_text.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TranslationLanguage _$TranslationLanguageFromJson(Map<String, dynamic> json) =>
    TranslationLanguage(
      json['langInitial'] as String,
      json['langFilePath'] as String,
      json['selected'] as bool,
    );

Map<String, dynamic> _$TranslationLanguageToJson(
        TranslationLanguage instance) =>
    <String, dynamic>{
      'langInitial': instance.langInitial,
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
      ..uiPreparing = json['uiPreparing'] as String
      ..uiDragDropFiles = json['uiDragDropFiles'] as String
      ..uiAchiveCurrentlyNotSupported =
          json['uiAchiveCurrentlyNotSupported'] as String
      ..uiProcess = json['uiProcess'] as String
      ..uiWaitingForData = json['uiWaitingForData'] as String
      ..uiErrorWhenLoadingAddModsData =
          json['uiErrorWhenLoadingAddModsData'] as String
      ..uiLoadingModsAdderData = json['uiLoadingModsAdderData'] as String
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
      ..uiCheckingAppliedMods = json['uiCheckingAppliedMods'] as String
      ..uiErrorWhenCheckingAppliedMods =
          json['uiErrorWhenCheckingAppliedMods'] as String
      ..uiReappliedModsAfterChecking =
          json['uiReappliedModsAfterChecking'] as String
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
      ..uiNoMatchingIceFoundToSwap =
          json['uiNoMatchingIceFoundToSwap'] as String
      ..uiSwappingItem = json['uiSwappingItem'] as String
      ..uiErrorWhenSwapping = json['uiErrorWhenSwapping'] as String
      ..uiSuccessfullySwapped = json['uiSuccessfullySwapped'] as String
      ..uiAddToModManager = json['uiAddToModManager'] as String
      ..uiLoadingItemRefSheetsData =
          json['uiLoadingItemRefSheetsData'] as String
      ..uiErrorWhenLoadingItemRefSheets =
          json['uiErrorWhenLoadingItemRefSheets'] as String
      ..uiFetchingItemInfo = json['uiFetchingItemInfo'] as String
      ..uiErrorWhenFetchingItemInfo =
          json['uiErrorWhenFetchingItemInfo'] as String;

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
      'uiPreparing': instance.uiPreparing,
      'uiDragDropFiles': instance.uiDragDropFiles,
      'uiAchiveCurrentlyNotSupported': instance.uiAchiveCurrentlyNotSupported,
      'uiProcess': instance.uiProcess,
      'uiWaitingForData': instance.uiWaitingForData,
      'uiErrorWhenLoadingAddModsData': instance.uiErrorWhenLoadingAddModsData,
      'uiLoadingModsAdderData': instance.uiLoadingModsAdderData,
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
      'uiCheckingAppliedMods': instance.uiCheckingAppliedMods,
      'uiErrorWhenCheckingAppliedMods': instance.uiErrorWhenCheckingAppliedMods,
      'uiReappliedModsAfterChecking': instance.uiReappliedModsAfterChecking,
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
      'uiNoMatchingIceFoundToSwap': instance.uiNoMatchingIceFoundToSwap,
      'uiSwappingItem': instance.uiSwappingItem,
      'uiErrorWhenSwapping': instance.uiErrorWhenSwapping,
      'uiSuccessfullySwapped': instance.uiSuccessfullySwapped,
      'uiAddToModManager': instance.uiAddToModManager,
      'uiLoadingItemRefSheetsData': instance.uiLoadingItemRefSheetsData,
      'uiErrorWhenLoadingItemRefSheets':
          instance.uiErrorWhenLoadingItemRefSheets,
      'uiFetchingItemInfo': instance.uiFetchingItemInfo,
      'uiErrorWhenFetchingItemInfo': instance.uiErrorWhenFetchingItemInfo,
    };
