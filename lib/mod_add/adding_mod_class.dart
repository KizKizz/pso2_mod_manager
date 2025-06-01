import 'dart:io';

import 'package:pso2_mod_manager/mod_add/item_data_class.dart';
import 'package:path/path.dart' as p;

class AddingMod {
  AddingMod(this.modDir, this.modAddingState, this.submods, this.submodNames, this.submodAddingStates, this.associatedItems, this.aItemAddingStates, this.sameItemIceNames, this.previewImages,
      this.previewVideos);

  Directory modDir;
  bool modAddingState;
  List<Directory> submods;
  List<String> submodNames;
  List<bool> submodAddingStates;
  List<ItemData> associatedItems;
  List<bool> aItemAddingStates;
  List<MapEntry<String, List<String>>> sameItemIceNames;
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
    String curPath = this;
    String curName = p.basename(curPath);
    List<String> affixes = curName.split('_');
    if (affixes.isNotEmpty && int.tryParse(affixes.last) != null) {
      int i = int.parse(affixes.last) + 1;
      affixes.last = i.toString();
      String newName = affixes.join('_');
      return p.dirname(curPath) + p.separator + newName;
    } else {
      return '${curPath}_1';
    }
  }
}
