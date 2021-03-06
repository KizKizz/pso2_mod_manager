import 'package:cross_file/cross_file.dart';
import 'package:flutter/cupertino.dart';

class stateProvider with ChangeNotifier {
  bool _isMainBinFound = false;
  bool _isMainModManPathFound = false;
  bool _previewWindowVisible = false;
  bool _addingBoxState = false;
  bool _isUpdateAvailable = false;
  int _cateListItemCount = 0;
  String _newItemDropDisplay = '';
  String _newSingleItemDropDisplay = '';
  String _newModDropDisplay = '';

  bool get isMainBinFound => _isMainBinFound;
  bool get isMainModManPathFound => _isMainModManPathFound;
  bool get previewWindowVisible => _previewWindowVisible;
  bool get addingBoxState => _addingBoxState;
  bool get isUpdateAvailable => _isUpdateAvailable;
  int get cateListItemCount => _cateListItemCount;
  String get newItemDropDisplay => _newItemDropDisplay;
  String get newSingleItemDropDisplay => _newSingleItemDropDisplay;
  String get newModDropDisplay => _newModDropDisplay;

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
