import 'package:pso2_mod_manager/main.dart';

class TranslationLanguage {
  TranslationLanguage(this.langInitial, this.langFilePath, this.selected);

  String langInitial;
  String langFilePath;
  bool selected;

  fromJson(Map<String, dynamic> json) {
    langInitial = json['langInitial'];
    langFilePath = json['langFilePath'];
    selected = json['selected'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['langInitial'] = langInitial;
    data['langFilePath'] = langFilePath;
    data['selected'] = selected;

    return data;
  }
}

class TranslationText {
  TranslationText(
    //Header buttons
    this.pathsReselectBtnText,
    this.foldersBtnText,
    this.modsFolderBtnText,
    this.backupFolderBtnText,
    this.deletedItemsBtnText,
    this.checksumBtnText,
    this.checksumMissingBtnText,
    this.modSetsBtnText,
    this.modListBtnText,
    this.previewBtnText,
    this.lightModeBtnText,
    this.darkModeBtnText,

    //Header buttons tooltips
    this.pathsReselectTooltipText,
    this.foldersTooltipText,
    this.modsFolderTooltipText,
    this.checksumToolTipText,
    this.modSetsTooltipText,
    this.previewTooltipText,
    this.lightModeTooltipText,
    this.darkModeTooltipText,
    this.languageTooltipText,

    //Main Headers
    this.itemsHeaderText,
    this.availableModsHeaderText,
    this.previewHeaderText,
    this.appliedModsHeadersText,
    this.setsHeaderText,
    this.modsInSetHeaderText,

    //Mod Items
    this.refreshBtnTootipText,
    this.newCatBtnTooltipText,
    this.newItemBtnTooltipText,
    this.inExplorerBtnTootipText,
    this.searchLabelText,
    this.newCatNameLabelText,
    this.addCatBtnText,
    this.singleAddBtnText,
    this.multiAddBtnText,
    this.singleDropBoxLabelText,
    this.multiDropBoxLabelText,
    this.iconDropBoxLabelText,
    this.addSelectCatLabelText,
    this.addItemNamLabelText,
    this.addModNameLabelText,
    this.addModTootipText,
    this.addModToTooltipText,
    this.favLabelText,
    this.accessoriesLabelText,
    this.basewearsLabelText,
    this.bodypaintsLabelText,
    this.emotesLabelText,
    this.innerLabelText,
    this.miscLabelText,
    this.motionsLabelText,
    this.outerLabelText,
    this.setwearsLabelText,
    this.unapplyThisModTooltipText,
    this.applyThisModTooltipText,
    this.modNameLabelText,
    this.modsSetSaveTooltipText,
    this.modsSetClickTooltipText,
    this.applyModUnderTooltipText,
    this.toTheGameTooltipText,
    this.unapplyModUnderTooltipText,
    this.fromTheGameTooltipText,
    this.newSetNameLabelText,
    this.addNewSetTootipText,
    this.addSetBtnText,
    this.holdToDeleteBtnTooltipText,
    this.holdToRemoveBtnTooltipText,
    this.holdToReapplyBtnTooltipText,
    this.holdToRemoveAllBtnTooltipText,

    //Misc
    this.itemsLabelText,
    this.itemLabelText,
    this.fileAppliedColonLabelText,
    this.fileAppliedLabelText,
    this.closeBtnText,
    this.openBtnTooltipText,
    this.addBtnText,
    this.addBtnTooltipText,
    this.removeBtnTooltipText,
    this.deleteBtnTooltipText,
    this.refreshingLabelText,
    this.modscolonLableText,
    this.appliedcolonLabelText,
    this.toFavTooltipText,
    this.fromFavTooltipText,
    this.doneBtnText,
    this.filesLabelText,
    this.fileLabelText,
    this.curFilesInSetAppliedTooltipText,
    this.deleteCatPopupText,
    this.deleteCatPopupMsgText,
    this.cannotDeleteCatPopupText,
    this.cannotDeleteCatPopupUnapplyText,
    this.deleteItemPopupText,
    this.deleteItemPopupMsgText,
    this.deleteModPopupText,
    this.deleteModPopupMsgText,
    this.unappyFilesFirstMsgText,
    this.removeFromFavFirstMsgText,
    this.noSearchResultFoundText,
    this.fromText,
    this.loadingUIText,
    this.checksumSelectPopupText,
    this.newUpdateAvailText,
    this.newAppVerText,
    this.curAppVerText,
    this.patchNoteLabelText,
    this.updateBtnText,
    this.dismissBtnText,
    this.waitingUserActionText,
    this.pso2binReselectPopupText,
    this.modmanReselectPopupText,
    this.curPathText,
    this.chooseNewPathText,

    //Error messages
    this.newCatNameEmptyErrorText,
    this.newCatNameDupErrorText,
    this.newItemNameEmpty,
    this.newItemNameDuplicate,
    this.multiItemsLeftOver,
    this.originalFileOf,
    this.isNotFound,
    this.replaced,
    this.backupFileOf,
    this.setRemovalErrorText,
    this.pso2binNotFoundPopupText,
    this.modmanFolderNotFoundLabelText,
    this.modmanFolderNotFoundText,

    //version 160
    this.addModsBtnLabel,
    this.addModsTooltip,
    this.checksumDownloadingBtnLabel,
    this.itemRefUpdateAvailableText,
    this.downloadingText,
    this.filesOfText,
    this.downloadUpdateBtnLabel,
    this.sortCategoryTooltipText,
    this.sortCateByNameText,
    this.sortCateByNumItemsText,
    this.preparingLabelText,
    this.dragNdropBoxLabelText,
    this.removeBtnLabel,
    this.clearAllBtnLabel,
    this.progressBtnLabel,
    this.waitingForDataLabelText,
    this.errorLoadingRestartApp,
    this.editTooltipText,
    this.renameSpaceLabelText,
    this.spaceBeforeAddingLabelText,
    this.errorModsInToBeAddedListLabelText,
    this.returnBtnLabel,
    this.addAllBtnLabelText,
    this.errorFilesNotSupportedText,
    this.checksumHoldBtnTooltip,

    //version 161
    this.modsLabelText,
    this.modLabelText,
    this.modAddedSuccessfullyText,

    //version 162
    this.preparingItemsText,
    this.mayTakeSomeTimeText,

    //version 164
    this.removeItemFromAdding,
    this.removeModFromAdding,
    this.addItemBackToAdding,
    this.addModBackToAdding,

    //version 166
    this.newUserNoticeText,

    //version 167
    this.clickContinueIfStuckBtnLabel,
    this.skipVersionUpdateBtnLabel,
    this.singleFileAppliedLabelText,
    this.titleNewUpdateToolTip,

    //version 168
    this.nameCannotBeEmptyErrorText,
    this.nameAlreadyExistsErrorText,
  );

  //Header buttons
  String pathsReselectBtnText;
  String foldersBtnText;
  String modsFolderBtnText;
  String backupFolderBtnText;
  String deletedItemsBtnText;
  String checksumBtnText;
  String checksumMissingBtnText;
  String modSetsBtnText;
  String modListBtnText;
  String previewBtnText;
  String lightModeBtnText;
  String darkModeBtnText;

  //Header buttons tooltips
  String pathsReselectTooltipText;
  String foldersTooltipText;
  String modsFolderTooltipText;
  String checksumToolTipText;
  String modSetsTooltipText;
  String previewTooltipText;
  String lightModeTooltipText;
  String darkModeTooltipText;
  String languageTooltipText;

  //Main Headers
  String itemsHeaderText;
  String availableModsHeaderText;
  String previewHeaderText;
  String appliedModsHeadersText;
  String setsHeaderText;
  String modsInSetHeaderText;

  //Mod Items
  String refreshBtnTootipText;
  String newCatBtnTooltipText;
  String newItemBtnTooltipText;
  String inExplorerBtnTootipText;
  String searchLabelText;
  String newCatNameLabelText;
  String addCatBtnText;
  String singleAddBtnText;
  String multiAddBtnText;
  String singleDropBoxLabelText;
  String multiDropBoxLabelText;
  String iconDropBoxLabelText;
  String addSelectCatLabelText;
  String addItemNamLabelText;
  String addModNameLabelText;
  String addModTootipText;
  String addModToTooltipText;
  String favLabelText;
  String accessoriesLabelText;
  String basewearsLabelText;
  String bodypaintsLabelText;
  String emotesLabelText;
  String innerLabelText;
  String miscLabelText;
  String motionsLabelText;
  String outerLabelText;
  String setwearsLabelText;
  String unapplyThisModTooltipText;
  String applyThisModTooltipText;
  String modNameLabelText;
  String modsSetSaveTooltipText;
  String modsSetClickTooltipText;
  String applyModUnderTooltipText;
  String toTheGameTooltipText;
  String unapplyModUnderTooltipText;
  String fromTheGameTooltipText;
  String newSetNameLabelText;
  String addNewSetTootipText;
  String addSetBtnText;
  String holdToDeleteBtnTooltipText;
  String holdToRemoveBtnTooltipText;
  String holdToReapplyBtnTooltipText;
  String holdToRemoveAllBtnTooltipText;

  //Misc
  String itemsLabelText;
  String itemLabelText;
  String fileAppliedColonLabelText;
  String fileAppliedLabelText;
  String closeBtnText;
  String openBtnTooltipText;
  String addBtnText;
  String addBtnTooltipText;
  String removeBtnTooltipText;
  String deleteBtnTooltipText;
  String refreshingLabelText;
  String modscolonLableText;
  String appliedcolonLabelText;
  String toFavTooltipText;
  String fromFavTooltipText;
  String doneBtnText;
  String filesLabelText;
  String fileLabelText;
  String curFilesInSetAppliedTooltipText;
  String deleteCatPopupText;
  String deleteCatPopupMsgText;
  String cannotDeleteCatPopupText;
  String cannotDeleteCatPopupUnapplyText;
  String deleteItemPopupText;
  String deleteItemPopupMsgText;
  String deleteModPopupText;
  String deleteModPopupMsgText;
  String unappyFilesFirstMsgText;
  String removeFromFavFirstMsgText;
  String noSearchResultFoundText;
  String fromText;
  String loadingUIText;
  String checksumSelectPopupText;
  String newUpdateAvailText;
  String newAppVerText;
  String curAppVerText;
  String patchNoteLabelText;
  String updateBtnText;
  String dismissBtnText;
  String waitingUserActionText;
  String pso2binReselectPopupText;
  String modmanReselectPopupText;
  String curPathText;
  String chooseNewPathText;

  //Error messages
  String newCatNameEmptyErrorText;
  String newCatNameDupErrorText;
  String newItemNameEmpty;
  String newItemNameDuplicate;
  String multiItemsLeftOver;
  String originalFileOf;
  String isNotFound;
  String replaced;
  String backupFileOf;
  String setRemovalErrorText;
  String pso2binNotFoundPopupText;
  String modmanFolderNotFoundLabelText;
  String modmanFolderNotFoundText;

  //version 160
  String addModsBtnLabel;
  String addModsTooltip;
  String checksumDownloadingBtnLabel;
  String itemRefUpdateAvailableText;
  String downloadingText;
  String filesOfText;
  String downloadUpdateBtnLabel;
  String sortCategoryTooltipText;
  String sortCateByNameText;
  String sortCateByNumItemsText;
  String preparingLabelText;
  String dragNdropBoxLabelText;
  String removeBtnLabel;
  String clearAllBtnLabel;
  String progressBtnLabel;
  String waitingForDataLabelText;
  String errorLoadingRestartApp;
  String editTooltipText;
  String renameSpaceLabelText;
  String spaceBeforeAddingLabelText;
  String errorModsInToBeAddedListLabelText;
  String returnBtnLabel;
  String addAllBtnLabelText;
  String errorFilesNotSupportedText;
  String checksumHoldBtnTooltip;

  //version 161
  String modsLabelText;
  String modLabelText;
  String modAddedSuccessfullyText;

  //version 162
  String preparingItemsText;
  String mayTakeSomeTimeText;

  //version 164
  String removeItemFromAdding;
  String removeModFromAdding;
  String addItemBackToAdding;
  String addModBackToAdding;

  //version 166
  String newUserNoticeText;

  //version 167
  String skipVersionUpdateBtnLabel;
  String clickContinueIfStuckBtnLabel;
  String singleFileAppliedLabelText;
  String titleNewUpdateToolTip;

  //verion 168
  String nameCannotBeEmptyErrorText;
  String nameAlreadyExistsErrorText;

  fromJson(Map<String, dynamic> json) {
    //Header buttons
    pathsReselectBtnText = json['pathsReselectBtnText'];
    foldersBtnText = json['foldersBtnText'];
    modsFolderBtnText = json['modsFolderBtnText'];
    backupFolderBtnText = json['backupFolderBtnText'];
    deletedItemsBtnText = json['deletedItemsBtnText'];
    checksumBtnText = json['checksumBtnText'];
    checksumMissingBtnText = json['checksumMissingBtnText'];
    modSetsBtnText = json['modSetsBtnText'];
    modListBtnText = json['modListBtnText'];
    previewBtnText = json['previewBtnText'];
    lightModeBtnText = json['lightModeBtnText'];
    darkModeBtnText = json['darkModeBtnText'];

    //Header buttons tooltips
    pathsReselectTooltipText = json['pathsReselectTooltipText'];
    foldersTooltipText = json['foldersTooltipText'];
    modsFolderTooltipText = json['modsFolderTooltipText'];
    checksumToolTipText = json['checksumToolTipText'];
    modSetsTooltipText = json['modSetsTooltipText'];
    previewTooltipText = json['previewTooltipText'];
    lightModeTooltipText = json['lightModeTooltipText'];
    darkModeTooltipText = json['darkModeTooltipText'];
    languageTooltipText = json['languageTooltipText'];

    //Main Headers
    itemsHeaderText = json['itemsHeaderText'];
    availableModsHeaderText = json['availableModsHeaderText'];
    previewHeaderText = json['previewHeaderText'];
    appliedModsHeadersText = json['appliedModsHeadersText'];
    setsHeaderText = json['setsHeaderText'];
    modsInSetHeaderText = json['modsInSetHeaderText'];

    //Mod Items
    refreshBtnTootipText = json['refreshBtnTootipText'];
    newCatBtnTooltipText = json['newCatBtnTooltipText'];
    newItemBtnTooltipText = json['newItemBtnTooltipText'];
    inExplorerBtnTootipText = json['inExplorerBtnTootipText'];
    searchLabelText = json['searchLabelText'];
    newCatNameLabelText = json['newCatNameLabelText'];
    addCatBtnText = json['addCatBtnText'];
    singleAddBtnText = json['singleAddBtnText'];
    multiAddBtnText = json['multiAddBtnText'];
    singleDropBoxLabelText = json['singleDropBoxLabelText'];
    multiDropBoxLabelText = json['multiDropBoxLabelText'];
    iconDropBoxLabelText = json['iconDropBoxLabelText'];
    addSelectCatLabelText = json['addSelectCatLabelText'];
    addItemNamLabelText = json['addItemNamLabelText'];
    addModNameLabelText = json['addModNameLabelText'];
    addModTootipText = json['addModTootipText'];
    addModToTooltipText = json['addModToTooltipText'];
    favLabelText = json['favLabelText'];
    accessoriesLabelText = json['accessoriesLabelText'];
    basewearsLabelText = json['basewearsLabelText'];
    bodypaintsLabelText = json['bodypaintsLabelText'];
    emotesLabelText = json['emotesLabelText'];
    innerLabelText = json['innerLabelText'];
    miscLabelText = json['miscLabelText'];
    motionsLabelText = json['motionsLabelText'];
    outerLabelText = json['outerLabelText'];
    setwearsLabelText = json['setwearsLabelText'];
    unapplyThisModTooltipText = json['unapplyThisModTooltipText'];
    applyThisModTooltipText = json['applyThisModTooltipText'];
    modNameLabelText = json['modNameLabelText'];
    modsSetSaveTooltipText = json['modsSetSaveTooltipText'];
    modsSetClickTooltipText = json['modsSetClickTooltipText'];
    applyModUnderTooltipText = json['applyModUnderTooltipText'];
    toTheGameTooltipText = json['toTheGameTooltipText'];
    unapplyModUnderTooltipText = json['unapplyModUnderTooltipText'];
    fromTheGameTooltipText = json['fromTheGameTooltipText'];
    newSetNameLabelText = json['newSetNameLabelText'];
    addNewSetTootipText = json['addNewSetTootipText'];
    addSetBtnText = json['addSetBtnText'];
    holdToDeleteBtnTooltipText = json['holdToDeleteBtnTooltipText'];
    holdToRemoveBtnTooltipText = json['holdToRemoveBtnTooltipText'];
    holdToReapplyBtnTooltipText = json['holdToReapplyBtnTooltipText'];
    holdToRemoveAllBtnTooltipText = json['holdToRemoveAllBtnTooltipText'];

    //Misc
    itemsLabelText = json['itemsLabelText'];
    itemLabelText = json['itemLabelText'];
    fileAppliedColonLabelText = json['fileAppliedLabelText'];
    fileAppliedLabelText = json['fileAppliedLabelText'];
    closeBtnText = json['closeBtnText'];
    openBtnTooltipText = json['openBtnTooltipText'];
    addBtnText = json['addBtnText'];
    addBtnTooltipText = json['addBtnTooltipText'];
    removeBtnTooltipText = json['removeBtnTooltipText'];
    deleteBtnTooltipText = json['deleteBtnTooltipText'];
    refreshingLabelText = json['refreshingLabelText'];
    modscolonLableText = json['modscolonLableText'];
    appliedcolonLabelText = json['appliedcolonLabelText'];
    toFavTooltipText = json['toFavTooltipText'];
    fromFavTooltipText = json['fromFavTooltipText'];
    doneBtnText = json['doneBtnText'];
    filesLabelText = json['filesLabelText'];
    fileLabelText = json['fileLabelText'];
    curFilesInSetAppliedTooltipText = json['curFilesInSetAppliedTooltipText'];
    deleteCatPopupText = json['deleteCatPopupText'];
    deleteCatPopupMsgText = json['deleteCatPopupMsgText'];
    cannotDeleteCatPopupText = json['cannotDeleteCatPopupText'];
    cannotDeleteCatPopupUnapplyText = json['cannotDeleteCatPopupUnapplyText'];
    deleteItemPopupText = json['deleteItemPopupText'];
    deleteItemPopupMsgText = json['deleteItemPopupMsgText'];
    deleteModPopupText = json['deteleteModPopupText'];
    deleteModPopupMsgText = json['deleteModPopupMsgText'];
    unappyFilesFirstMsgText = json['unappyFilesFirstMsgText'];
    noSearchResultFoundText = json['noSearchResultFoundText'];
    fromText = json['fromText'];
    loadingUIText = json['loadingUIText'];
    checksumSelectPopupText = json['checksumSelectPopupText'];
    newUpdateAvailText = json['newUpdateAvailText'];
    newAppVerText = json['newAppVerText'];
    curAppVerText = json['curAppVerText'];
    patchNoteLabelText = json['patchNoteLabelText'];
    updateBtnText = json['updateBtnText'];
    dismissBtnText = json['dismissBtnText'];
    waitingUserActionText = json['waitingUserActionText'];
    pso2binReselectPopupText = json['pso2binReselectPopupText'];
    modmanReselectPopupText = json['modmanReselectPopupText'];
    curPathText = json['curPathText'];
    chooseNewPathText = json[chooseNewPathText];

    //Error messages
    newCatNameEmptyErrorText = json['newCatNameEmptyErrorText'];
    newCatNameDupErrorText = json['newCatNameDupErrorText'];
    newItemNameEmpty = json['newItemNameEmpty'];
    newItemNameDuplicate = json['newItemNameDuplicate'];
    multiItemsLeftOver = json['multiItemsLeftOver'];
    originalFileOf = json['originalFileOf'];
    isNotFound = json['isNotFound'];
    replaced = json['replaced'];
    backupFileOf = json['backupFileOf'];
    setRemovalErrorText = json['setRemovalErrorText'];
    pso2binNotFoundPopupText = json['pso2binNotFoundPopupText'];
    modmanFolderNotFoundLabelText = json['modmanFolderNotFoundLabelText'];
    modmanFolderNotFoundText = json['modmanFolderNotFoundText'];

    //version 160
    addModsBtnLabel = json['addModsBtnLabel'];
    addModsTooltip = json['addModsTooltip'];
    checksumDownloadingBtnLabel = json['checksumDownloadingBtnLabel'];
    itemRefUpdateAvailableText = json['itemRefUpdateAvailableText'];
    downloadingText = json['downloadingText'];
    filesOfText = json['filesOfText'];
    downloadUpdateBtnLabel = json['downloadUpdateBtnLabel'];
    sortCategoryTooltipText = json['sortCategoryTooltipText'];
    sortCateByNameText = json['sortCateByNameText'];
    sortCateByNumItemsText = json['sortCateByNumItemsText'];
    preparingLabelText = json['preparingLabelText'];
    dragNdropBoxLabelText = json['dragNdropBoxLabelText'];
    removeBtnLabel = json['removeBtnLabel'];
    clearAllBtnLabel = json['clearAllBtnLabel'];
    progressBtnLabel = json['progressBtnLabel'];
    waitingForDataLabelText = json['waitingForDataLabelText'];
    errorLoadingRestartApp = json['errorLoadingRestartApp'];
    editTooltipText = json['editTooltipText'];
    renameSpaceLabelText = json['renameSpaceLabelText'];
    spaceBeforeAddingLabelText = json['spaceBeforeAddingLabelText'];
    errorModsInToBeAddedListLabelText = json['errorModsInToBeAddedListLabelText'];
    returnBtnLabel = json['returnBtnLabel'];
    addAllBtnLabelText = json['addAllBtnLabelText'];
    errorFilesNotSupportedText = json['errorFilesNotSupportedText'];
    checksumHoldBtnTooltip = json['checksumHoldBtnTooltip'];

    //version 161
    modsLabelText = json['modsLabelText'];
    modLabelText = json['modLabelText'];
    modAddedSuccessfullyText = json['modAddedSuccessfullyText'];

    //version 162
    preparingItemsText = json['preparingItemsText'];
    mayTakeSomeTimeText = json['mayTakeSomeTimeText'];

    //version 164
    removeItemFromAdding = json['removeItemFromAdding'];
    removeModFromAdding = json['removeModFromAdding'];
    addItemBackToAdding = json['addItemBackToAdding'];
    addModBackToAdding = json['addModBackToAdding'];

    //version 166
    newUserNoticeText = json['newUserNoticeText'];

    //version 167
    skipVersionUpdateBtnLabel = json['skipVersionUpdateBtnLabel'];
    clickContinueIfStuckBtnLabel = json['clickContinueIfStuckBtnLabel'];
    singleFileAppliedLabelText = json['singleFileAppliedLabelText'];
    titleNewUpdateToolTip = json['titleNewUpdateToolTip'];

    //version 168
    nameCannotBeEmptyErrorText = json['nameCannotBeEmptyErrorText'];
    nameAlreadyExistsErrorText = json['nameAlreadyExistsErrorText'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    //Header buttons
    data['pathsReselectBtnText'] = pathsReselectBtnText;
    data['foldersBtnText'] = foldersBtnText;
    data['modsFolderBtnText'] = modsFolderBtnText;
    data['backupFolderBtnText'] = backupFolderBtnText;
    data['deletedItemsBtnText'] = deletedItemsBtnText;
    data['checksumBtnText'] = checksumBtnText;
    data['checksumMissingBtnText'] = checksumMissingBtnText;
    data['modSetsBtnText'] = modSetsBtnText;
    data['modListBtnText'] = modListBtnText;
    data['previewBtnText'] = previewBtnText;
    data['lightModeBtnText'] = lightModeBtnText;
    data['darkModeBtnText'] = darkModeBtnText;

    //Header buttons tooltips
    data['pathsReselectTooltipText'] = pathsReselectTooltipText;
    data['foldersTooltipText'] = foldersTooltipText;
    data['modsFolderTooltipText'] = modsFolderTooltipText;
    data['checksumToolTipText'] = checksumToolTipText;
    data['modSetsTooltipText'] = modSetsTooltipText;
    data['previewTooltipText'] = previewTooltipText;
    data['lightModeTooltipText'] = lightModeTooltipText;
    data['darkModeTooltipText'] = darkModeTooltipText;
    data['languageTooltipText'] = languageTooltipText;

    //Main Headers
    data['itemsHeaderText'] = itemsHeaderText;
    data['availableModsHeaderText'] = availableModsHeaderText;
    data['previewHeaderText'] = previewHeaderText;
    data['appliedModsHeadersText'] = appliedModsHeadersText;
    data['setsHeaderText'] = setsHeaderText;
    data['modsInSetHeaderText'] = modsInSetHeaderText;

    //Mod Items
    data['refreshBtnTootipText'] = refreshBtnTootipText;
    data['newCatBtnTooltipText'] = newCatBtnTooltipText;
    data['newItemBtnTooltipText'] = newItemBtnTooltipText;
    data['inExplorerBtnTootipText'] = inExplorerBtnTootipText;
    data['searchLabelText'] = searchLabelText;
    data['newCatNameLabelText'] = newCatNameLabelText;
    data['addCatBtnText'] = addCatBtnText;
    data['singleAddBtnText'] = singleAddBtnText;
    data['multiAddBtnText'] = multiAddBtnText;
    data['singleDropBoxLabelText'] = singleDropBoxLabelText;
    data['multiDropBoxLabelText'] = multiDropBoxLabelText;
    data['iconDropBoxLabelText'] = iconDropBoxLabelText;
    data['addSelectCatLabelText'] = addSelectCatLabelText;
    data['addItemNamLabelText'] = addItemNamLabelText;
    data['addModNameLabelText'] = addModNameLabelText;
    data['addModTootipText'] = addModTootipText;
    data['addModToTooltipText'] = addModToTooltipText;
    data['favLabelText'] = favLabelText;
    data['accessoriesLabelText'] = accessoriesLabelText;
    data['basewearsLabelText'] = basewearsLabelText;
    data['bodypaintsLabelText'] = bodypaintsLabelText;
    data['emotesLabelText'] = emotesLabelText;
    data['innerLabelText'] = innerLabelText;
    data['miscLabelText'] = miscLabelText;
    data['motionsLabelText'] = motionsLabelText;
    data['outerLabelText'] = outerLabelText;
    data['setwearsLabelText'] = setwearsLabelText;
    data['unapplyThisModTooltipText'] = unapplyThisModTooltipText;
    data['applyThisModTooltipText'] = applyThisModTooltipText;
    data['modNameLabelText'] = modNameLabelText;
    data['modsSetSaveTooltipText'] = modsSetSaveTooltipText;
    data['modsSetClickTooltipText'] = modsSetClickTooltipText;
    data['applyModUnderTooltipText'] = applyModUnderTooltipText;
    data['toTheGameTooltipText'] = toTheGameTooltipText;
    data['unapplyModUnderTooltipText'] = unapplyModUnderTooltipText;
    data['fromTheGameTooltipText'] = fromTheGameTooltipText;
    data['newSetNameLabelText'] = newSetNameLabelText;
    data['addNewSetTootipText'] = addNewSetTootipText;
    data['addSetBtnText'] = addSetBtnText;
    data['holdToDeleteBtnTooltipText'] = holdToDeleteBtnTooltipText;
    data['holdToRemoveBtnTooltipText'] = holdToRemoveBtnTooltipText;
    data['holdToReapplyBtnTooltipText'] = holdToReapplyBtnTooltipText;
    data['holdToRemoveAllBtnTooltipText'] = holdToRemoveAllBtnTooltipText;

    //Misc
    data['itemsLabelText'] = itemsLabelText;
    data['itemLabelText'] = itemLabelText;
    data['fileAppliedColonLabelText'] = fileAppliedColonLabelText;
    data['fileAppliedLabelText'] = fileAppliedLabelText;
    data['closeBtnText'] = closeBtnText;
    data['openBtnTooltipText'] = openBtnTooltipText;
    data['addBtnText'] = addBtnText;
    data['addBtnTooltipText'] = addBtnTooltipText;
    data['removeBtnTooltipText'] = removeBtnTooltipText;
    data['deleteBtnTooltipText'] = deleteBtnTooltipText;
    data['refreshingLabelText'] = refreshingLabelText;
    data['modscolonLableText'] = modscolonLableText;
    data['appliedcolonLabelText'] = appliedcolonLabelText;
    data['toFavTooltipText'] = toFavTooltipText;
    data['fromFavTooltipText'] = fromFavTooltipText;
    data['doneBtnText'] = doneBtnText;
    data['filesLabelText'] = filesLabelText;
    data['fileLabelText'] = fileLabelText;
    data['curFilesInSetAppliedTooltipText'] = curFilesInSetAppliedTooltipText;
    data['deleteCatPopupText'] = deleteCatPopupText;
    data['deleteCatPopupMsgText'] = deleteCatPopupMsgText;
    data['cannotDeleteCatPopupText'] = cannotDeleteCatPopupText;
    data['cannotDeleteCatPopupUnapplyText'] = cannotDeleteCatPopupUnapplyText;
    data['deleteItemPopupText'] = deleteItemPopupText;
    data['deleteItemPopupMsgText'] = deleteItemPopupMsgText;
    data['deleteModPopupText'] = deleteModPopupText;
    data['deleteModPopupMsgText'] = deleteModPopupMsgText;
    data['unappyFilesFirstMsgText'] = unappyFilesFirstMsgText;
    data['removeFromFavFirstMsgText'] = removeFromFavFirstMsgText;
    data['noSearchResultFoundText'] = noSearchResultFoundText;
    data['fromText'] = fromText;
    data['loadingUIText'] = loadingUIText;
    data['checksumSelectPopupText'] = checksumSelectPopupText;
    data['newUpdateAvailText'] = newUpdateAvailText;
    data['newAppVerText'] = newAppVerText;
    data['curAppVerText'] = curAppVerText;
    data['patchNoteLabelText'] = patchNoteLabelText;
    data['updateBtnText'] = updateBtnText;
    data['dismissBtnText'] = dismissBtnText;
    data['waitingUserActionText'] = waitingUserActionText;
    data['pso2binReselectPopupText'] = pso2binReselectPopupText;
    data['modmanReselectPopupText'] = modmanReselectPopupText;
    data['curPathText'] = curPathText;
    data['chooseNewPathText'] = chooseNewPathText;

    //Error messages
    data['newCatNameEmptyErrorText'] = newCatNameEmptyErrorText;
    data['newCatNameDupErrorText'] = newCatNameDupErrorText;
    data['newItemNameEmpty'] = newItemNameEmpty;
    data['newItemNameDuplicate'] = newItemNameDuplicate;
    data['multiItemsLeftOver'] = multiItemsLeftOver;
    data['originalFileOf'] = originalFileOf;
    data['isNotFound'] = isNotFound;
    data['replaced'] = replaced;
    data['backupFileOf'] = backupFileOf;
    data['setRemovalErrorText'] = setRemovalErrorText;
    data['pso2binNotFoundPopupText'] = pso2binNotFoundPopupText;
    data['modmanFolderNotFoundLabelText'] = modmanFolderNotFoundLabelText;
    data['modmanFolderNotFoundText'] = modmanFolderNotFoundText;

    //version 160
    data['addModsBtnLabel'] = addModsBtnLabel;
    data['addModsTooltip'] = addModsTooltip;
    data['checksumDownloadingBtnLabel'] = checksumDownloadingBtnLabel;
    data['itemRefUpdateAvailableText'] = itemRefUpdateAvailableText;
    data['downloadingText'] = downloadingText;
    data['filesOfText'] = filesOfText;
    data['downloadUpdateBtnLabel'] = downloadUpdateBtnLabel;
    data['sortCategoryTooltipText'] = sortCategoryTooltipText;
    data['sortCateByNameText'] = sortCateByNameText;
    data['sortCateByNumItemsText'] = sortCateByNumItemsText;
    data['preparingLabelText'] = preparingLabelText;
    data['dragNdropBoxLabelText'] = dragNdropBoxLabelText;
    data['removeBtnLabel'] = removeBtnLabel;
    data['clearAllBtnLabel'] = clearAllBtnLabel;
    data['progressBtnLabel'] = progressBtnLabel;
    data['waitingForDataLabelText'] = waitingForDataLabelText;
    data['errorLoadingRestartApp'] = errorLoadingRestartApp;
    data['editTooltipText'] = editTooltipText;
    data['renameSpaceLabelText'] = renameSpaceLabelText;
    data['spaceBeforeAddingLabelText'] = spaceBeforeAddingLabelText;
    data['errorModsInToBeAddedListLabelText'] = errorModsInToBeAddedListLabelText;
    data['returnBtnLabel'] = returnBtnLabel;
    data['addAllBtnLabelText'] = addAllBtnLabelText;
    data['errorFilesNotSupportedText'] = errorFilesNotSupportedText;
    data['checksumHoldBtnTooltip'] = checksumHoldBtnTooltip;

    //version 161
    data['modsLabelText'] = modsLabelText;
    data['modLabelText'] = modLabelText;
    data['modAddedSuccessfullyText'] = modAddedSuccessfullyText;

    // version 162
    data['preparingItemsText'] = preparingItemsText;
    data['mayTakeSomeTimeText'] = mayTakeSomeTimeText;

    //version 164
    data['removeItemFromAdding'] = removeItemFromAdding;
    data['removeModFromAdding'] = removeModFromAdding;
    data['addItemBackToAdding'] = addItemBackToAdding;
    data['addModBackToAdding'] = addModBackToAdding;

    //version 166
    data['newUserNoticeText'] = newUserNoticeText;

    //version 167
    data['skipVersionUpdateBtnLabel'] = skipVersionUpdateBtnLabel;
    data['clickContinueIfStuckBtnLabel'] = clickContinueIfStuckBtnLabel;
    data['singleFileAppliedLabelText'] = singleFileAppliedLabelText;
    data['titleNewUpdateToolTip'] = titleNewUpdateToolTip;

    //version 168
    data['nameCannotBeEmptyErrorText'] = nameCannotBeEmptyErrorText;
    data['nameAlreadyExistsErrorText'] = nameAlreadyExistsErrorText;

    return data;
  }
}

void convertLangTextData(var jsonResponse) {
  for (var b in jsonResponse) {
    TranslationText translation = TranslationText(
      //Header buttons
      b['pathsReselectBtnText'],
      b['foldersBtnText'],
      b['modsFolderBtnText'],
      b['backupFolderBtnText'],
      b['deletedItemsBtnText'],
      b['checksumBtnText'],
      b['checksumMissingBtnText'],
      b['modSetsBtnText'],
      b['modListBtnText'],
      b['previewBtnText'],
      b['lightModeBtnText'],
      b['darkModeBtnText'],

      //Header buttons tooltips
      b['pathsReselectTooltipText'],
      b['foldersTooltipText'],
      b['modsFolderTooltipText'],
      b['checksumToolTipText'],
      b['modSetsTooltipText'],
      b['previewTooltipText'],
      b['lightModeTooltipText'],
      b['darkModeTooltipText'],
      b['languageTooltipText'],

      //Main Headers
      b['itemsHeaderText'],
      b['availableModsHeaderText'],
      b['previewHeaderText'],
      b['appliedModsHeadersText'],
      b['setsHeaderText'],
      b['modsInSetHeaderText'],

      //Mod Items
      b['refreshBtnTootipText'],
      b['newCatBtnTooltipText'],
      b['newItemBtnTooltipText'],
      b['inExplorerBtnTootipText'],
      b['searchLabelText'],
      b['newCatNameLabelText'],
      b['addCatBtnText'],
      b['singleAddBtnText'],
      b['multiAddBtnText'],
      b['singleDropBoxLabelText'],
      b['multiDropBoxLabelText'],
      b['iconDropBoxLabelText'],
      b['addSelectCatLabelText'],
      b['addItemNamLabelText'],
      b['addModNameLabelText'],
      b['addModTootipText'],
      b['addModToTooltipText'],
      b['favLabelText'],
      b['accessoriesLabelText'],
      b['basewearsLabelText'],
      b['bodypaintsLabelText'],
      b['emotesLabelText'],
      b['innerLabelText'],
      b['miscLabelText'],
      b['motionsLabelText'],
      b['outerLabelText'],
      b['setwearsLabelText'],
      b['unapplyThisModTooltipText'],
      b['applyThisModTooltipText'],
      b['modNameLabelText'],
      b['modsSetSaveTooltipText'],
      b['modsSetClickTooltipText'],
      b['applyModUnderTooltipText'],
      b['toTheGameTooltipText'],
      b['unapplyModUnderTooltipText'],
      b['fromTheGameTooltipText'],
      b['newSetNameLabelText'],
      b['addNewSetTootipText'],
      b['addSetBtnText'],
      b['holdToDeleteBtnTooltipText'],
      b['holdToRemoveBtnTooltipText'],
      b['holdToReapplyBtnTooltipText'],
      b['holdToRemoveAllBtnTooltipText'],

      //Misc
      b['itemsLabelText'],
      b['itemLabelText'],
      b['fileAppliedColonLabelText'],
      b['fileAppliedLabelText'],
      b['closeBtnText'],
      b['openBtnTooltipText'],
      b['addBtnText'],
      b['addBtnTooltipText'],
      b['removeBtnTooltipText'],
      b['deleteBtnTooltipText'],
      b['refreshingLabelText'],
      b['modscolonLableText'],
      b['appliedcolonLabelText'],
      b['toFavTooltipText'],
      b['fromFavTooltipText'],
      b['doneBtnText'],
      b['filesLabelText'],
      b['fileLabelText'],
      b['curFilesInSetAppliedTooltipText'],
      b['deleteCatPopupText'],
      b['deleteCatPopupMsgText'],
      b['cannotDeleteCatPopupText'],
      b['cannotDeleteCatPopupUnapplyText'],
      b['deleteItemPopupText'],
      b['deleteItemPopupMsgText'],
      b['deleteModPopupText'],
      b['deleteModPopupMsgText'],
      b['unappyFilesFirstMsgText'],
      b['removeFromFavFirstMsgText'],
      b['noSearchResultFoundText'],
      b['fromText'],
      b['loadingUIText'],
      b['checksumSelectPopupText'],
      b['newUpdateAvailText'],
      b['newAppVerText'],
      b['curAppVerText'],
      b['patchNoteLabelText'],
      b['updateBtnText'],
      b['dismissBtnText'],
      b['waitingUserActionText'],
      b['pso2binReselectPopupText'],
      b['modmanReselectPopupText'],
      b['curPathText'],
      b['chooseNewPathText'],

      //Error messages
      b['newCatNameEmptyErrorText'],
      b['newCatNameDupErrorText'],
      b['newItemNameEmpty'],
      b['newItemNameDuplicate'],
      b['multiItemsLeftOver'],
      b['originalFileOf'],
      b['isNotFound'],
      b['replaced'],
      b['backupFileOf'],
      b['setRemovalErrorText'],
      b['pso2binNotFoundPopupText'],
      b['modmanFolderNotFoundLabelText'],
      b['modmanFolderNotFoundText'],

      //version 160
      b['addModsBtnLabel'],
      b['addModsTooltip'],
      b['checksumDownloadingBtnLabel'],
      b['itemRefUpdateAvailableText'],
      b['downloadingText'],
      b['filesOfText'],
      b['downloadUpdateBtnLabel'],
      b['sortCategoryTooltipText'],
      b['sortCateByNameText'],
      b['sortCateByNumItemsText'],
      b['preparingLabelText'],
      b['dragNdropBoxLabelText'],
      b['removeBtnLabel'],
      b['clearAllBtnLabel'],
      b['progressBtnLabel'],
      b['waitingForDataLabelText'],
      b['errorLoadingRestartApp'],
      b['editTooltipText'],
      b['renameSpaceLabelText'],
      b['spaceBeforeAddingLabelText'],
      b['errorModsInToBeAddedListLabelText'],
      b['returnBtnLabel'],
      b['addAllBtnLabelText'],
      b['errorFilesNotSupportedText'],
      b['checksumHoldBtnTooltip'],

      //version 161
      b['modsLabelText'],
      b['modLabelText'],
      b['modAddedSuccessfullyText'],

      //version 162
      b['preparingItemsText'],
      b['mayTakeSomeTimeText'],

      //version 164
      b['removeItemFromAdding'],
      b['removeModFromAdding'],
      b['addItemBackToAdding'],
      b['addModBackToAdding'],

      //version 166
      b['newUserNoticeText'],

      //version 167
      b['skipVersionUpdateBtnLabel'],
      b['clickContinueIfStuckBtnLabel'],
      b['singleFileAppliedLabelText'],
      b['titleNewUpdateToolTip'],

      //version 168
      b['nameCannotBeEmptyErrorText'],
      b['nameAlreadyExistsErrorText'],
    );
    curLangText = translation;
  }
}

TranslationText defaultUILangLoader() {
  return TranslationText(
      //Header buttons
      'Paths Reselect',
      'Folders',
      'Mods',
      'Backups',
      'Deleted Items',
      'Checksum:',
      'Checksum missing. Click!',
      'Mod Sets',
      'Mod List',
      'Preview:',
      'Light',
      'Dark',

      //Header buttons tooltips
      'Reselect path for pso2_bin, Mod Manager folder',
      'Open Mods, Backups, Deleted Items folder',
      'modsFolderTooltipText',
      'Open Checksum folder',
      'Manage Mod Sets',
      'Show/Hide Preview window',
      'Switch to Dark theme',
      'Switch to Light theme',
      'Language select',

      //Main Headers
      'Items',
      'Available Mods',
      'Preview',
      'Applied Mods',
      'Sets',
      'Mods in Set',

      //Mod Items
      'Refreshing Mod List',
      'Add New Category',
      'Add New Item',
      ' in File Explorer',
      'Search for mods',
      'New Category Name',
      'Add Category',
      'Single Item',
      'Multiple Items',
      'Drop modded .ice files and folder(s)\nhere to add',
      'Drop modded item folder(s) here to add',
      'Drop item\'s\nicon here\n(Optional)',
      'Select a Category',
      'Item Name',
      'Mod Name (Optional)',
      'Add Mods',
      'Add mods to',
      'Favorite',
      'Accessories',
      'Basewears',
      'Body Paints',
      'Emotes',
      'Innerwears',
      'Misc',
      'Motions',
      'Outerwears',
      'Setwears',
      'Unapply this mod from the game',
      'Apply this mod to the game',
      'Mod Name',
      'Save all mods in applied list to sets',
      'Click on \'Mod Sets\' button to add new set',
      'Apply all mods under ',
      ' to the game',
      'Unapply all mods under ',
      ' from the game',
      'New Set Name',
      'Add New Set',
      'Add Set',
      'Hold to delete ',
      'Hold to remove ',
      'Hold to reapply all mods to the game',
      'Hold to remove all applied mods from the game',

      //Misc
      ' Items',
      ' Item',
      'Files applied:',
      'Files applied',
      'Close',
      'Open ',
      'Add',
      'Add ',
      'Remove ',
      'Delete ',
      'Refreshing',
      'Mods:',
      'Applied:',
      ' to favorites',
      ' from favorites',
      'Done',
      ' Files',
      ' File',
      'One or more mod files in this set currently being applied to the game',
      'Delete Category',
      ' and move it to Deleted Items folder?\nThis will also remove all items in this category',
      'Cannot delete ',
      '. Unaplly these mods first:\n\n',
      'Delete Item',
      ' and move it to Deleted Items folder?\nThis will also delete all mods in this item',
      'Delete Mod',
      ' and move it to Deleted Items folder?\nThis will also delete all files in this mod',
      '. Unapply these files first:\n\n',
      '. Remove from Favorites first',
      'No Results Found',
      ' from ',
      'Loading UI',
      'Select your checksum file',
      'New Update Available!',
      'New Version:',
      'Your Version:',
      'Patch Notes...',
      'Update',
      'Dismiss',
      'Waiting for user\'s action',
      'pso2_bin Path Reselect',
      'Mod Manager Folder Path Reselect',
      'Current path:',
      'Choose a new path?',

      //Error messages
      'Category name can\'t be empty',
      'Category name already exist',
      'Name can\'t be empty',
      'The name already exists',
      'The file(s) bellow won\'t be added. Use the \'Single Item\' Tab or \'Add Mod\' instead.',
      'Original file of ',
      ' is not found!',
      'Replaced: ',
      'Backup file of ',
      'There are mod files currently being applied. Unapply them first!',
      'pso2_bin folder not found. Select it now?\nSelect \'Exit\' will close the app',
      'Mod Manager Folder not found',
      'Select a path to store your mods?\nSelect \'No\' will create a folder inside \'pso2_bin\' folder',

      //version 160
      'Add Mods',
      'Add new mods to Mod Manager',
      'Downloading checksum..',
      'New update for item reference available',
      'Downloading',
      'of',
      'Download Update',
      'Sort Categories',
      'Sort by name',
      'Sort by item amount',
      'Preparing',
      'Drag and drop folders, zip files\nand .ice files here\nMay take some time\nto process large amount of files',
      'Remove',
      'Clear All',
      'Process',
      'Waiting for data',
      'Error when loading data. Please restart the app.',
      'Edit',
      'Rename ',
      ' before adding',
      'There are still mods in the list waiting to be added',
      'Return',
      'Add All',
      'currently not supported. Open the archive file then drag the content in here instead',
      'Click to download checksum file. Hold to manually select',

      //version 161
      'Mods',
      'Mod',
      'Mods added successfully',

      //version 162
      'Preparing Items',
      'This may take some time',

      //version 164
      'Mark this item not to be added',
      'Mark this mod not to be added',
      'Mark this item to be added',
      'Mark this mod to be added',

      //version 166
      'If this is your first time using PSO2NGS Mod Manager please restore the game files to their orginals before applying mods to the game',

      //version 167
      'Skip this update',
      'Click to continue if app is stuck',
      'File Applied',
      'New update available. Click to go to download page',
      'Name cannot be empty',
      'Name already exists');
}
