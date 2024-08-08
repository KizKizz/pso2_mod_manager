enum ItemListSort {
  none('none'), alphabeticalOrder('Alphabetical Order'), recentModsAdded('Recent Mods Added');
  final String value;
  const ItemListSort(this.value);
}

enum ModViewListSort {
  none('none'), alphabeticalOrder('Alphabetical Order'), recentModsAdded('Recently Added');
  final String value;
  const ModViewListSort(this.value);
}

enum SaveApplyButtonState {
  none('none'), apply('apply'), remove('remove'), extra('extra');
  final String value;
  const SaveApplyButtonState(this.value);
}