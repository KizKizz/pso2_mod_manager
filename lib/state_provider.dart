import 'package:flutter/cupertino.dart';

class stateProvider with ChangeNotifier {
  bool _isMainBinFound = false;
  bool _isCateDeleted = false;

  bool get isMainBinFound => _isMainBinFound;
  bool get isCateDeleted => _isCateDeleted;

  void mainBinFoundTrue() {
    _isMainBinFound = true;
    notifyListeners();
  }

  void mainBinFoundFalse() {
    _isMainBinFound = false;
    notifyListeners();
  }

  //Cate Delete
   void cateDeletedTrue() {
    _isCateDeleted = true;
    notifyListeners();
  }

  void cateDeletedFalse() {
    _isCateDeleted = false;
    notifyListeners();
  }
}
