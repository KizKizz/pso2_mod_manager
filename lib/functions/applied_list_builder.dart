
import 'package:pso2_mod_manager/classes/category_type_class.dart';

// Future<List<CategoryType>> appliedListBuilder(List<CategoryType> moddedList) async {
//   const JsonEncoder encoder = JsonEncoder.withIndent('  ');

//   var jsonData = jsonDecode(encoder.convert(moddedList.map((cateType) => cateType.toJson()).toList()));
//   // var jsonData = jsonDecode(moddedList.map((cateType) => cateType.toJson());

//   List<CategoryType> newModdedList = [];
//   for (var type in jsonData) {
//     newModdedList.add(CategoryType.fromJson(type));
//   }

//   for (var cateType in newModdedList) {
//     List<String> appliedCate = [];
//     for (var cate in cateType.categories) {
//       cate.items.retainWhere((element) => element.applyStatus == true);
//       if (cate.items.isNotEmpty) {
//         appliedCate.add(cate.categoryName);
//       }
//       for (var item in cate.items) {
//         item.mods.retainWhere((element) => element.applyStatus == true);
//         for (var mod in item.mods) {
//           mod.submods.retainWhere((element) => element.applyStatus == true);
//           for (var submod in mod.submods) {
//             submod.modFiles.retainWhere((element) => element.applyStatus == true);
//           }
//         }
//       }
//     }
//     cateType.categories.retainWhere((element) => appliedCate.contains(element.categoryName));
//   }
//   newModdedList.retainWhere((element) => element.categories.isNotEmpty);

//   return newModdedList;
// }

Future<List<CategoryType>> appliedListBuilder(List<CategoryType> moddedList) async {
  List<CategoryType> newModdedList = [];
  for (var type in moddedList) {
    for (var cate in type.categories) {
      for (var item in cate.items) {
        if (item.applyStatus == true) {
          for (var mod in item.mods) {
            if (mod.applyStatus == true) {
              for (var submod in mod.submods) {
                if (submod.applyStatus == true) {
                  for (var modFile in submod.modFiles) {
                    if (modFile.applyStatus == true && !newModdedList.contains(type)) {
                      newModdedList.add(type);
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  return newModdedList;
}
