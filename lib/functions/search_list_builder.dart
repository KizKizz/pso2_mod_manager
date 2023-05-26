import 'package:pso2_mod_manager/classes/category_type_class.dart';

Future<List<CategoryType>> searchListBuilder(List<CategoryType> moddedList, String searchTerm) async {
  List<CategoryType> newModdedList = [];
  for (var type in moddedList) {
    for (var cate in type.categories) {
      for (var item in cate.items) {
          for (var mod in item.mods) {
              for (var submod in mod.submods) {
                  for (var modFile in submod.modFiles) {
                    if (modFile.modFileName.contains(searchTerm)) {
                      newModdedList.add(type);
                    }
                  }
                }
              }
            }
          }
        }
      
    
  

  return newModdedList;
}