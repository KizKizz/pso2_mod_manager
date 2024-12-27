import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ItemNameLanguage {
  en('EN'),
  jp('JP');

  final String value;
  const ItemNameLanguage(this.value);
}

Future<void> setItemNameLanguage(ItemNameLanguage nameLanguage) async {
  final prefs = await SharedPreferences.getInstance();

  itemNameLanguage = nameLanguage;
  prefs.setString('itemNameLanguage', itemNameLanguage.value);
}
