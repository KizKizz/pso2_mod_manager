import 'dart:convert';
import 'dart:io';

import 'package:pso2_mod_manager/classes/category_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/mod_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/main.dart';

void test() {
  ModFile testModFile = ModFile('name', 'submodName', 'modName', 'itemName', 'category', 'md5', 'ogmd5', '', [], [], DateTime.now(), false, true, false);
  SubMod testSubMod = SubMod('name', 'modName', 'itemName', 'category', '', false, DateTime(0), false, false, [], [], [], [testModFile]);
  Mod testMod = Mod('Test Mod', 'itemName', 'category', 'Uri()',false, DateTime.now(), true, false, [], [], [], [testSubMod]);
  Item testItem = Item('name', '', 'category', '', false, false, DateTime(0), false, [testMod]);
  Category testCate = Category('name', '', true, [testItem]);

  List<Category> testCateList = [testCate, testCate];

  testCateList.map((cate) => cate.toJson()).toList();
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  File(modsListJsonPath.toFilePath()).writeAsStringSync(encoder.convert(testCateList));

  //File('${Directory.current.path}/test.json').writeAsStringSync(json.encode(testCate.toJson()));
}
