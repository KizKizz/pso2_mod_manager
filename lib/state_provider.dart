import 'package:cross_file/cross_file.dart';
import 'package:flutter/cupertino.dart';

class stateProvider with ChangeNotifier {
  bool _isMainBinFound = false;
  String _newItemDropDisplay = '';
  String _newModDropDisplay = '';

  bool get isMainBinFound => _isMainBinFound;
  String get newItemDropDisplay => _newItemDropDisplay;
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
  void itemsDropAdd(List<XFile> paramList) {
    for (var file in paramList) {
      if (file != paramList.last) {
        _newItemDropDisplay += '${file.name}\n ';
      } else {
        _newItemDropDisplay += file.name;
      }
    }
    notifyListeners();
  }

  void itemsDropAddRemoveFirst() {
    var temp = _newItemDropDisplay.split('\n');
    temp.removeAt(0);
    _newItemDropDisplay = temp.join('\n');
    _newItemDropDisplay.trim();
    notifyListeners();
  }

  //itemList Display
  void modsDropAdd(List<XFile> paramList) {
    for (var file in paramList) {
      if (file != paramList.last) {
        _newModDropDisplay += '${file.name}\n ';
      } else {
        _newModDropDisplay += file.name;
      }
    }
    notifyListeners();
  }

  void modsDropAddRemoveFirst() {
    var temp = _newModDropDisplay.split('\n');
    temp.removeAt(0);
    _newModDropDisplay = temp.join('\n');
    _newModDropDisplay.trim();
    notifyListeners();
  }
}
