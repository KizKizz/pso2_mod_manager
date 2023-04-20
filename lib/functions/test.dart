import 'dart:convert';
import 'dart:io';

import 'package:pso2_mod_manager/classes/category_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/mod_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/main.dart';

void test() {
  ModFile testModFile = ModFile('name', 'modName', 'itemName', 'md5', Uri(), Uri(), Uri(), DateTime.now(), false, true, false);
  SubMod testSubMod = SubMod('Test Sub Mod', 'category', 'itemName', false, DateTime.now(), [], true, false, [], [], [testModFile]);
  Mod testMod = Mod('Test Mod', 'category', 'itemName', false, DateTime.now(), [], true, false, [], [], [testSubMod]);
  Item testItem = Item('name', Uri(), 'category', 'location', true, false, [testMod]);
  Category testCate = Category('name', Uri(), true, [testItem]);

  List<Category> testCateList = [testCate, testCate];

  testCateList.map((cate) => cate.toJson()).toList();
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  File(modsListJsonPath.toFilePath()).writeAsStringSync(encoder.convert(testCateList));

  //File('${Directory.current.path}/test.json').writeAsStringSync(json.encode(testCate.toJson()));
}
