import 'dart:io';

import 'package:pso2_mod_manager/mod_add/item_data_class.dart';

class AddingMod {
  AddingMod(this.modDir, this.modAddingState, this.submods, this.submodNames, this.submodAddingStates, this.associatedItems, this.aItemAddingStates, this.previewImages, this.previewVideos);

  Directory modDir;
  bool modAddingState;
  List<Directory> submods;
  List<String> submodNames;
  List<bool> submodAddingStates;
  List<ItemData> associatedItems;
  List<bool> aItemAddingStates;
  List<File> previewImages;
  List<File> previewVideos;
}

enum ModAddDragDropState {
  waitingForFiles('waitingForFiles'),
  fileInList('fileInList'),
  unpackingFiles('unpackingFiles');

  final String value;
  const ModAddDragDropState(this.value);
}

enum ModAddProcessedState {
  waiting('waiting'),
  dataInList('dataInList'),
  loadingData('loadingData'),
  addingToMasterList('addingToMasterList'),
  noSelectedData('noSelectedData');

  final String value;
  const ModAddProcessedState(this.value);
}

extension RenameDuplicate on String {
  String renameDuplicate() {
    var affix = split('_').last;
    if (affix.isNotEmpty && int.tryParse(affix) != null) {
      int i = int.parse(affix);
      return '${this}_${i++}';
    } else {
      return '${this}_1';
    }
  }
}
