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
  int _cateListItemCount = 0;
  int _refSheetsCount = 0;
  String _newItemDropDisplay = '';
  String _newSingleItemDropDisplay = '';
  String _newModDropDisplay = '';

  bool get isMainBinFound => _isMainBinFound;
  bool get isMainModManPathFound => _isMainModManPathFound;
  bool get previewWindowVisible => _previewWindowVisible;
  bool get setsWindowVisible => _setsWindowVisible;
  bool get languageReload => _languageReload;
  bool get addingBoxState => _addingBoxState;
  bool get isUpdateAvailable => _isUpdateAvailable;
  bool get refSheetsUpdateAvailable => _refSheetsUpdateAvailable;
  int get cateListItemCount => _cateListItemCount;
  int get refSheetsCount => _refSheetsCount;
  String get newItemDropDisplay => _newItemDropDisplay;
  String get newSingleItemDropDisplay => _newSingleItemDropDisplay;
  String get newModDropDisplay => _newModDropDisplay;

  void refSheetsCountUp() {
    _refSheetsCount++;
    notifyListeners();
  }

  void refSheetsCountReset() {
    _refSheetsCount = 0;
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
