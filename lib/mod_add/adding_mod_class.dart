import 'dart:io';

import 'package:pso2_mod_manager/mod_add/item_data_class.dart';

class AddingMod {
  AddingMod(this.modDir, this.submods, this.associatedItems, this.previewImages, this.previewVideos);

  Directory modDir;
  Map<Directory, List<File>> submods;
  List<ItemData> associatedItems;
  List<File> previewImages;
  List<File> previewVideos;
}
