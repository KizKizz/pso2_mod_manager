import 'dart:convert';
import 'dart:io';

import 'package:pso2_mod_manager/classes/category_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/mod_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';

import '../main.dart';

void test() {
  ModFile testModFile = ModFile('name', 'modName', 'itemName', 'md5', 'location', 'ogLocation', 'bkLocation', DateTime.now(), false, true, false);
  Mod testMod = Mod('Test Mod', 'category', 'itemName', false, DateTime.now(), [], true, false, [testModFile], [], []);
  Item testItem = Item('name', 'icon', 'category', 'location', true, false, [testMod]);
  Category testCate = Category('name', 'location', [testItem], true);

  testCate.toJson();
  File('C:\\Users\\kizkizz\\Documents\\GitHub\\test.json').writeAsStringSync(json.encode(testCate));

  
}
