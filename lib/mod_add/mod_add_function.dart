Column(
              spacing: 5,
              children: [
                Expanded(
                  child: CardOverlay(
                      paddingValue: 5,
                      child: Column(spacing: 5, children: [
                        Expanded(
                            child: DropTarget(
                          onDragDone: (detail) {
                            setState(() {
                              for (var file in detail.files) {
                                if (p.extension(file.path) == '' || dragDropSupportedExts.contains(p.extension(file.path))) {
                                  if (!modAddDragDropPaths.value.contains(file.path)) {
                                    modAddDragDropPaths.value.add(file.path);
                                  } else {
                                    errorNotification(context, appText.dText(appText.fileAlreadyOnTheList, file.name));
                                  }
                                } else {
                                  errorNotification(context, appText.dText(appText.fileIsNotSupported, file.name));
                                }
                              }
                            });
                          },
                          child: modAddDragDropPaths.watch(context).isEmpty
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            appText.dragdropBoxMessage,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context).textTheme.titleMedium,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            appText.dragdropBoxMessage2,
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                )
                              : SuperListView.builder(
                                  physics: const SuperRangeMaintainingScrollPhysics(),
                                  itemCount: modAddDragDropPaths.watch(context).length,
                                  itemBuilder: (context, index) {
                                    return ListTileTheme(
                                        data: const ListTileThemeData(minTileHeight: 45, minVerticalPadding: 0),
                                        child: ListTile(
                                          title: Text(
                                            p.basename(modAddDragDropPaths.value[index]),
                                            style: Theme.of(context).textTheme.titleSmall,
                                          ),
                                          subtitle: Text(
                                            FileSystemEntity.isFileSync(modAddDragDropPaths.value[index]) ? appText.file : appText.folder,
                                            style: Theme.of(context).textTheme.bodyMedium,
                                          ),
                                          trailing: IconButton(
                                              onPressed: () => setState(() {
                                                    modAddDragDropPaths.value.removeAt(index);
                                                  }),
                                              color: Colors.redAccent,
                                              icon: const Icon(Icons.remove_circle_outline)),
                                          contentPadding: const EdgeInsets.all(5),
                                          dense: true,
                                        ));
                                  },
                                ),
                        )),
                        OverflowBar(
                          spacing: 5,
                          overflowSpacing: 5,
                          alignment: MainAxisAlignment.center,
                          overflowAlignment: OverflowBarAlignment.center,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                  onPressed: () async {
                                    const XTypeGroup fileTypeGroup = XTypeGroup(
                                      label: 'Files',
                                      extensions: <String>['zip', 'rar', '7z', '*'],
                                    );
                                    final List<XFile> selectedFiles = await openFiles(acceptedTypeGroups: <XTypeGroup>[fileTypeGroup]);
                                    if (selectedFiles.isNotEmpty) {
                                      modAddDragDropPaths.value.addAll(selectedFiles.map((e) => e.path));
                                    }
                                  },
                                  child: Text(appText.addFiles)),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                  onPressed: () async {
                                    final List<String?> selectedDirPaths = await getDirectoryPaths();
                                    if (selectedDirPaths.isNotEmpty) {
                                      for (var path in selectedDirPaths) {
                                        modAddDragDropPaths.value.add(path!);
                                      }
                                    }
                                  },
                                  child: Text(appText.addFolders)),
                            ),
                            OutlinedButton(onPressed: () {}, child: Text(appText.ignoreList)),
                          ],
                        ),
                        Row(
                      spacing: 5,
                      children: [
                        Expanded(
                            flex: 1,
                            child: FloatingActionButton(
                                onPressed: modAddDragDropPaths.watch(context).isNotEmpty
                                    ? () => setState(() {
                                          modAddDragDropPaths.value.clear();
                                        })
                                    : null,
                                child: Text(appText.clear))),
                        Expanded(flex: 2, child: ElevatedButton(onPressed: () {}, child: Text(appText.processFiles))),
                      ],
                    )
                      ])),
                ),
              ],
            )