import 'package:cross_file/cross_file.dart';
import 'package:flutter/cupertino.dart';

class stateProvider with ChangeNotifier {
  bool _isMainBinFound = false;
  String _newItemDropDisplay = '';
  String _newSingleItemDropDisplay = '';
  String _newModDropDisplay = '';

  bool get isMainBinFound => _isMainBinFound;
  String get newItemDropDisplay => _newItemDropDisplay;
  String get newSingleItemDropDisplay => _newSingleItemDropDisplay;
  String get newModDropDisplay => _newModDropDisplay;

  void mainBinFoundTrue() {
    _isMainBinFound = true;
    notifyListeners();
  }

  void mainBinFoundFalse() {
    _isMainBinFound = false;
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
