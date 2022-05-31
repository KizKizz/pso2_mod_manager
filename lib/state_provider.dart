import 'package:flutter/cupertino.dart';

class stateProvider with ChangeNotifier {
  bool _isMainBinFound = false;

  bool get isMainBinFound => _isMainBinFound;

  void mainBinFoundTrue() {
    _isMainBinFound = true;
    notifyListeners();
  }

  void mainBinFoundFalse() {
    _isMainBinFound = false;
    notifyListeners();
  }
}
