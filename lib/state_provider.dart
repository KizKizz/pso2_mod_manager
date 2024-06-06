import 'package:cross_file/cross_file.dart';
import 'package:flutter/cupertino.dart';

class StateProvider with ChangeNotifier {
  bool _isMainBinFound = false;
  bool _isMainModManPathFound = false;
  bool _previewWindowVisible = false;
  bool _setsWindowVisible = false;
  bool _addingBoxState = false;
  bool _isUpdateAvailable = false;
  bool _languageReload = false;
  bool _refSheetsUpdateAvailable = false;
  bool _listDataCheck = false;
  bool _modAdderReload = false;
  int _cateListItemCount = 0;
  double _playerItemDataDownloadPercent = 0;
  String _newItemDropDisplay = '';
  String _newSingleItemDropDisplay = '';
  String _newModDropDisplay = '';
  double _itemAdderSubItemETHeight = 40;
  bool _isChecksumMD5Match = true;
  double _uiOpacityValue = 0.6;
  bool _backgroundImageTrigger = false;
  int _uiBackgroundColorValue = 0;
  bool _reloadSplashScreen = false;
  bool _isSlidingItemIcons = true;
  bool _checksumDownloading = false;
  bool _modsSwapperSwitchToSwapPage = false;
  bool _reloadProfile = false;
  String _profileName = '';
  String _applyAllStatus = '';
  int _applyAllProgressCounter = 0;
  String _boundaryEditProgressStatus = '';
  String _modsLoaderProgressStatus = '';
  bool _showTitleBarButtons = false;
  bool _profanityFilterRemove = false;
  bool _removeBoundaryRadiusOnModsApply = false;
  bool _prioritizeLocalBackup = false;
  String _modAdderProgressStatus = '';
  String _gameEdition = '';
  bool _showPreviewPanel = false;
  bool _markModdedItem = true;
  bool _isStartupLoadingFinish = false;
  bool _mouseHoveringSubmods = false;
  bool _isCursorInAppliedList = true;

  bool get isMainBinFound => _isMainBinFound;
  bool get isMainModManPathFound => _isMainModManPathFound;
  bool get previewWindowVisible => _previewWindowVisible;
  bool get setsWindowVisible => _setsWindowVisible;
  bool get languageReload => _languageReload;
  bool get addingBoxState => _addingBoxState;
  bool get isUpdateAvailable => _isUpdateAvailable;
  bool get refSheetsUpdateAvailable => _refSheetsUpdateAvailable;
  bool get listDataCheck => _listDataCheck;
  bool get modAdderReload => _modAdderReload;
  int get cateListItemCount => _cateListItemCount;
  double get playerItemDataDownloadPercent => _playerItemDataDownloadPercent;
  String get newItemDropDisplay => _newItemDropDisplay;
  String get newSingleItemDropDisplay => _newSingleItemDropDisplay;
  String get newModDropDisplay => _newModDropDisplay;
  double get itemAdderSubItemETHeight => _itemAdderSubItemETHeight;
  bool get isChecksumMD5Match => _isChecksumMD5Match;
  double get uiOpacityValue => _uiOpacityValue;
  bool get backgroundImageTrigger => _backgroundImageTrigger;
  int get uiBackgroundColorValue => _uiBackgroundColorValue;
  bool get reloadSplashScreen => _reloadSplashScreen;
  bool get isSlidingItemIcons => _isSlidingItemIcons;
  bool get checksumDownloading => _checksumDownloading;
  bool get modsSwapperSwitchToSwapPage => _modsSwapperSwitchToSwapPage;
  bool get reloadProfile => _reloadProfile;
  String get profileName => _profileName;
  String get applyAllStatus => _applyAllStatus;
  int get applyAllProgressCounter => _applyAllProgressCounter;
  String get boundaryEditProgressStatus => _boundaryEditProgressStatus;
  String get modsLoaderProgressStatus => _modsLoaderProgressStatus;
  bool get showTitleBarButtons => _showTitleBarButtons;
  bool get profanityFilterRemove => _profanityFilterRemove;
  bool get removeBoundaryRadiusOnModsApply => _removeBoundaryRadiusOnModsApply;
  bool get prioritizeLocalBackup => _prioritizeLocalBackup;
  String get modAdderProgressStatus => _modAdderProgressStatus;
  String get gameEdition => _gameEdition;
  bool get showPreviewPanel => _showPreviewPanel;
  bool get markModdedItem => _markModdedItem;
  bool get isStartupLoadingFinish => _isStartupLoadingFinish;
  bool get mouseHoveringSubmods => _mouseHoveringSubmods;
  bool get isCursorInAppliedList => _isCursorInAppliedList;

  void cursorInALSet(bool state) {
    _isCursorInAppliedList = state;
    notifyListeners();
  }

  void mouseHoveringSubmodsSet(bool state) {
    _mouseHoveringSubmods = state;
    notifyListeners();
  }

  void startupLoadingFinishSet(bool state) {
    _isStartupLoadingFinish = state;
    notifyListeners();
  }

  void markModdedItemSet(bool state) {
    _markModdedItem = state;
    notifyListeners();
  }

  void showPreviewPanelSet(bool state) {
    _showPreviewPanel = state;
    notifyListeners();
  }

  void setGameEdition(String edition) {
    _gameEdition = edition;
    notifyListeners();
  }

  void setModAdderProgressStatus(String status) {
    _modAdderProgressStatus = status;
    notifyListeners();
  }

  void prioritizeLocalBackupTrue() {
    _prioritizeLocalBackup = true;
    notifyListeners();
  }

  void prioritizeLocalBackupFalse() {
    _prioritizeLocalBackup = false;
    notifyListeners();
  }

  void removeBoundaryRadiusOnModsApplyTrue() {
    _removeBoundaryRadiusOnModsApply = true;
    notifyListeners();
  }

  void removeBoundaryRadiusOnModsApplyFalse() {
    _removeBoundaryRadiusOnModsApply = false;
    notifyListeners();
  }

  void profanityFilterRemoveTrue() {
    _profanityFilterRemove = true;
    notifyListeners();
  }

  void profanityFilterRemoveFalse() {
    _profanityFilterRemove = false;
    notifyListeners();
  }

  void showTitleBarButtonsTrue() {
    _showTitleBarButtons = true;
    notifyListeners();
  }

  void showTitleBarButtonsFalse() {
    _showTitleBarButtons = false;
    notifyListeners();
  }

  void setModsLoaderProgressStatus(String status) {
    _modsLoaderProgressStatus = status;
    notifyListeners();
  }

  void setBoundaryEditProgressStatus(String status) {
    _boundaryEditProgressStatus = status;
    notifyListeners();
  }

  void applyAllProgressCounterIncrease() {
    _applyAllProgressCounter++;
    notifyListeners();
  }

  void applyAllProgressCounterReset() {
    _applyAllProgressCounter = 0;
    notifyListeners();
  }

  void setApplyAllStatus(String status) {
    _applyAllStatus = status;
    notifyListeners();
  }

  void setProfileName(String name) {
    _profileName = name;
    notifyListeners();
  }

  void reloadProfileTrue() {
    _reloadProfile = true;
    notifyListeners();
  }

  void reloadProfileFalse() {
    _reloadProfile = false;
    notifyListeners();
  }

  void modsSwapperSwitchToSwapPageTrue() {
    _modsSwapperSwitchToSwapPage = true;
    notifyListeners();
  }

  void modsSwapperSwitchToSwapPageFalse() {
    _modsSwapperSwitchToSwapPage = false;
    notifyListeners();
  }

  void checksumDownloadingTrue() {
    _checksumDownloading = true;
    notifyListeners();
  }

  void checksumDownloadingFalse() {
    _checksumDownloading = false;
    notifyListeners();
  }

  void isSlidingItemIconsTrue() {
    _isSlidingItemIcons = true;
    notifyListeners();
  }

  void isSlidingItemIconsFalse() {
    _isSlidingItemIcons = false;
    notifyListeners();
  }

  void reloadSplashScreenTrue() {
    _reloadSplashScreen = true;
    notifyListeners();
  }

  void reloadSplashScreenFalse() {
    _reloadSplashScreen = false;
    notifyListeners();
  }

  void uiBackgroundColorValueSet(int value) {
    _uiBackgroundColorValue = value;
    notifyListeners();
  }

  void backgroundImageTriggerTrue() {
    _backgroundImageTrigger = true;
    notifyListeners();
  }

  void backgroundImageTriggerFalse() {
    _backgroundImageTrigger = false;
    notifyListeners();
  }

  void uiOpacityValueSet(double value) {
    _uiOpacityValue = value;
    notifyListeners();
  }

  void checksumMD5MatchTrue() {
    _isChecksumMD5Match = true;
    notifyListeners();
  }

  void checksumMD5MatchFalse() {
    _isChecksumMD5Match = false;
    notifyListeners();
  }

  void itemAdderSubItemETHeightSet(double height) {
    _itemAdderSubItemETHeight = height;
    notifyListeners();
  }

  void modAdderReloadTrue() {
    _modAdderReload = true;
    notifyListeners();
  }

  void modAdderReloadFalse() {
    _modAdderReload = false;
    notifyListeners();
  }

  void listDataCheckTrue() {
    _listDataCheck = true;
    notifyListeners();
  }

  void listDataCheckFalse() {
    _listDataCheck = false;
    notifyListeners();
  }

  void playerItemDataDownloadPercentSet(double percent) {
    _playerItemDataDownloadPercent = percent;
    notifyListeners();
  }

  void playerItemDataDownloadPercentReset() {
    _playerItemDataDownloadPercent = 0;
    notifyListeners();
  }

  void refSheetsUpdateAvailableTrue() {
    _refSheetsUpdateAvailable = true;
    notifyListeners();
  }

  void refSheetsUpdateAvailableFalse() {
    _refSheetsUpdateAvailable = false;
    notifyListeners();
  }

  void languageReloadTrue() {
    _languageReload = true;
    notifyListeners();
  }

  void languageReloadFalse() {
    _languageReload = false;
    notifyListeners();
  }

  void isUpdateAvailableTrue() {
    _isUpdateAvailable = true;
    notifyListeners();
  }

  void isUpdateAvailableFalse() {
    _isUpdateAvailable = false;
    notifyListeners();
  }

  void cateListItemCountSet(int itemCount) {
    _cateListItemCount = itemCount;
    notifyListeners();
  }

  void cateListItemCountSetNoListener(int itemCount) {
    _cateListItemCount = itemCount;
  }

  void cateListItemCountReset() {
    _cateListItemCount = 0;
    notifyListeners();
  }

  void mainModManPathFoundTrue() {
    _isMainModManPathFound = true;
    notifyListeners();
  }

  void mainModManPathFoundFalse() {
    _isMainModManPathFound = false;
    notifyListeners();
  }

  void addingBoxStateTrue() {
    _addingBoxState = true;
    notifyListeners();
  }

  void addingBoxStateFalse() {
    _addingBoxState = false;
    notifyListeners();
  }

  void mainBinFoundTrue() {
    _isMainBinFound = true;
    notifyListeners();
  }

  void mainBinFoundFalse() {
    _isMainBinFound = false;
    notifyListeners();
  }

  void previewWindowVisibleSetTrue() {
    _previewWindowVisible = true;
    notifyListeners();
  }

  void previewWindowVisibleSetFalse() {
    _previewWindowVisible = false;
    notifyListeners();
  }

  void setsWindowVisibleSetTrue() {
    _setsWindowVisible = true;
    notifyListeners();
  }

  void setsWindowVisibleSetFalse() {
    _setsWindowVisible = false;
    notifyListeners();
  }

  //itemList Display
  void singleItemsDropAdd(List<XFile> paramList) {
    for (var file in paramList) {
      _newSingleItemDropDisplay += '${file.name}\n';
    }
    notifyListeners();
  }

  void singleItemsDropAddRemoveFirst() {
    var temp = _newSingleItemDropDisplay.split('\n');
    if (temp.length > 1) {
      temp.removeAt(0);
      _newSingleItemDropDisplay = temp.join('\n');
      _newSingleItemDropDisplay.trim();
    } else {
      _newSingleItemDropDisplay = '';
    }
    notifyListeners();
  }

  void singleItemDropAddClear() {
    _newSingleItemDropDisplay = '';
    notifyListeners();
  }

  //itemList Display
  void itemsDropAdd(List<XFile> paramList) {
    for (var file in paramList) {
      _newItemDropDisplay += '${file.name}\n';
    }
    notifyListeners();
  }

  void itemsDropAddRemoveFirst() {
    var temp = _newItemDropDisplay.split('\n');
    if (temp.length > 1) {
      temp.removeAt(0);
      _newItemDropDisplay = temp.join('\n');
      _newSingleItemDropDisplay.trim();
    } else {
      _newItemDropDisplay = '';
    }
    notifyListeners();
  }

  void itemsDropAddClear() {
    _newItemDropDisplay = '';
    notifyListeners();
  }

  //modList Display
  void modsDropAdd(List<XFile> paramList) {
    for (var file in paramList) {
      _newModDropDisplay += '${file.name}\n';
    }
    notifyListeners();
  }

  void modsDropAddRemoveFirst() {
    var temp = _newModDropDisplay.split('\n');
    if (temp.length > 1) {
      temp.removeAt(0);
      _newModDropDisplay = temp.join('\n');
      _newModDropDisplay.trim();
    } else {
      _newModDropDisplay = '';
    }
    notifyListeners();
  }

  void modsDropAddClear() {
    _newModDropDisplay = '';
    notifyListeners();
  }
}
