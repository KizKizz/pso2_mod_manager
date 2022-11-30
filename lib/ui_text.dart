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
  );

  //Header buttons
  String pathsReselectBtnText;
  String foldersBtnText;
  String modsFolderBtnText;
  String backupFolderBtnText;
  String deletedItemsBtnText;
  String checksumBtnText;
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

  //New Language popup

  fromJson(Map<String, dynamic> json) {
    //Header buttons
    pathsReselectBtnText = json['pathsReselectBtnText'];
    foldersBtnText = json['foldersBtnText'];
    modsFolderBtnText = json['modsFolderBtnText'];
    backupFolderBtnText = json['backupFolderBtnText'];
    deletedItemsBtnText = json['deletedItemsBtnText'];
    checksumBtnText = json['checksumBtnText'];
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
    );
    curLangText = translation;
  }
}
