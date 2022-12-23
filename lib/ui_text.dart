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
      b['newCatNameDupErrorText'],
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
      b['newCatNameLabelText'],
      b['newCatNameEmptyErrorText'],
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
    );
    curLangText = translation;
  }
}
