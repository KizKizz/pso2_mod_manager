import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/functions/applied_files_check.dart';
import 'package:pso2_mod_manager/functions/applied_list_builder.dart';
import 'package:pso2_mod_manager/functions/mod_set_functions.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/mod_files_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:window_manager/window_manager.dart';

Future<bool> profileLoader(context) async {
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
            return Dialog.fullscreen(
                //shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue),
                //contentPadding: const EdgeInsets.all(16),
                child: FutureBuilder(
                    future: pathsLoader(context),
                    builder: (
                      BuildContext context,
                      AsyncSnapshot snapshot,
                    ) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                curLangText!.uiLoadingPaths,
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const CircularProgressIndicator(),
                            ],
                          ),
                        );
                      } else {
                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  curLangText!.uiErrorWhenLoadingPaths,
                                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                  child: Text(snapshot.error.toString(), softWrap: true, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15)),
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                      windowManager.destroy();
                                    },
                                    child: Text(curLangText!.uiExit))
                              ],
                            ),
                          );
                        } else if (!snapshot.hasData) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  curLangText!.uiLoadingPaths,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const CircularProgressIndicator(),
                              ],
                            ),
                          );
                        } else {
                          //mod loading page
                          return FutureBuilder(
                              future: modFileStructureLoader(),
                              builder: (
                                BuildContext context,
                                AsyncSnapshot snapshot,
                              ) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          curLangText!.uiLoadingMods,
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        const CircularProgressIndicator(),
                                        // Padding(
                                        //   padding: const EdgeInsets.symmetric(vertical: 20),
                                        //   child: TextButton(
                                        //       onPressed: () {
                                        //         isAutoFetchingIconsOnStartup = false;
                                        //       },
                                        //       child: Text(curLangText!.uiSkipStartupIconFectching)),
                                        // )
                                      ],
                                    ),
                                  );
                                } else {
                                  if (snapshot.hasError) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            curLangText!.uiErrorWhenLoadingMods,
                                            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                            child: Text(snapshot.error.toString(), softWrap: true, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15)),
                                          ),
                                          ElevatedButton(
                                              onPressed: () {
                                                windowManager.destroy();
                                              },
                                              child: Text(curLangText!.uiExit))
                                        ],
                                      ),
                                    );
                                  } else if (!snapshot.hasData) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            curLangText!.uiLoadingMods,
                                            style: const TextStyle(fontSize: 20),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          const CircularProgressIndicator(),
                                        ],
                                      ),
                                    );
                                  } else {
                                    //Item list
                                    moddedItemsList = snapshot.data;
                              
                                    //Applied list loading page
                                    return FutureBuilder(
                                        future: appliedListBuilder(moddedItemsList),
                                        builder: (
                                          BuildContext context,
                                          AsyncSnapshot snapshot,
                                        ) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    curLangText!.uiLoadingAppliedMods,
                                                    style: const TextStyle(fontSize: 20),
                                                  ),
                                                  const SizedBox(
                                                    height: 20,
                                                  ),
                                                  const CircularProgressIndicator(),
                                                ],
                                              ),
                                            );
                                          } else {
                                            if (snapshot.hasError) {
                                              return Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      curLangText!.uiErrorWhenLoadingAppliedMods,
                                                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                                      child: Text(snapshot.error.toString(), softWrap: true, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15)),
                                                    ),
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          windowManager.destroy();
                                                        },
                                                        child: Text(curLangText!.uiExit))
                                                  ],
                                                ),
                                              );
                                            } else if (!snapshot.hasData) {
                                              return Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      curLangText!.uiLoadingAppliedMods,
                                                      style: const TextStyle(fontSize: 20),
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    const CircularProgressIndicator(),
                                                  ],
                                                ),
                                              );
                                            } else {
                                              //Applied Item list
                                              appliedItemList = snapshot.data;
                              
                                              //applied mods checking page
                                              return FutureBuilder(
                                                  future: appliedFileCheck(appliedItemList),
                                                  builder: (
                                                    BuildContext context,
                                                    AsyncSnapshot snapshot,
                                                  ) {
                                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                                      return Center(
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                              curLangText!.uiCheckingAppliedMods,
                                                              style: const TextStyle(fontSize: 20),
                                                            ),
                                                            const SizedBox(
                                                              height: 20,
                                                            ),
                                                            const CircularProgressIndicator(),
                                                          ],
                                                        ),
                                                      );
                                                    } else {
                                                      if (snapshot.hasError) {
                                                        return Center(
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              Text(
                                                                curLangText!.uiErrorWhenCheckingAppliedMods,
                                                                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
                                                              ),
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                                                child: Text(snapshot.error.toString(),
                                                                    softWrap: true, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15)),
                                                              ),
                                                              ElevatedButton(
                                                                  onPressed: () {
                                                                    windowManager.destroy();
                                                                  },
                                                                  child: Text(curLangText!.uiExit))
                                                            ],
                                                          ),
                                                        );
                                                      } else if (!snapshot.hasData) {
                                                        return Center(
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              Text(
                                                                curLangText!.uiCheckingAppliedMods,
                                                                style: const TextStyle(fontSize: 20),
                                                              ),
                                                              const SizedBox(
                                                                height: 20,
                                                              ),
                                                              const CircularProgressIndicator(),
                                                            ],
                                                          ),
                                                        );
                                                      } else {
                                                        //Return
                                                        List<ModFile> result = snapshot.data;
                                                        if (result.isNotEmpty) {
                                                          return SizedBox(
                                                            width: double.infinity,
                                                            height: double.infinity,
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(16.0),
                                                              child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(bottom: 10),
                                                                    child: Text(
                                                                      '${curLangText!.uiReappliedModsAfterChecking}:',
                                                                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child: ScrollbarTheme(
                                                                      data: ScrollbarThemeData(
                                                                        thumbColor: MaterialStateProperty.resolveWith((states) {
                                                                          if (states.contains(MaterialState.hovered)) {
                                                                            return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.7);
                                                                          }
                                                                          return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5);
                                                                        }),
                                                                      ),
                                                                      child: SingleChildScrollView(
                                                                        child: ListView.builder(
                                                                            shrinkWrap: true,
                                                                            padding: const EdgeInsets.all(2),
                                                                            physics: const NeverScrollableScrollPhysics(),
                                                                            itemCount: result.length,
                                                                            itemBuilder: (context, i) {
                                                                              return ListTile(
                                                                                title: Center(
                                                                                    child: Text(
                                                                                        '${result[i].category} > ${result[i].itemName} > ${result[i].modName} > ${result[i].submodName} > ${result[i].modFileName}')),
                                                                              );
                                                                            }),
                                                                      ),
                                                                    ),
                                                                  ),
                              
                                                                  //button
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(top: 10),
                                                                    child: ElevatedButton(
                                                                        onPressed: () {
                                                                          FutureBuilder(
                                                                              future: modSetLoader(),
                                                                              builder: (
                                                                                BuildContext context,
                                                                                AsyncSnapshot snapshot,
                                                                              ) {
                                                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                                                  return Center(
                                                                                    child: Column(
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                                      children: [
                                                                                        Text(
                                                                                          curLangText!.uiLoadingModSets,
                                                                                          style: const TextStyle(fontSize: 20),
                                                                                        ),
                                                                                        const SizedBox(
                                                                                          height: 20,
                                                                                        ),
                                                                                        const CircularProgressIndicator(),
                                                                                      ],
                                                                                    ),
                                                                                  );
                                                                                } else {
                                                                                  if (snapshot.hasError) {
                                                                                    return Center(
                                                                                      child: Column(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                                        children: [
                                                                                          Text(
                                                                                            curLangText!.uiErrorWhenLoadingModSets,
                                                                                            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
                                                                                          ),
                                                                                          const SizedBox(
                                                                                            height: 10,
                                                                                          ),
                                                                                          Padding(
                                                                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                                                                            child: Text(snapshot.error.toString(),
                                                                                                softWrap: true, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15)),
                                                                                          ),
                                                                                          ElevatedButton(
                                                                                              onPressed: () {
                                                                                                windowManager.destroy();
                                                                                              },
                                                                                              child: Text(curLangText!.uiExit))
                                                                                        ],
                                                                                      ),
                                                                                    );
                                                                                  } else if (!snapshot.hasData) {
                                                                                    return Center(
                                                                                      child: Column(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                                        children: [
                                                                                          Text(
                                                                                            curLangText!.uiLoadingModSets,
                                                                                            style: const TextStyle(fontSize: 20),
                                                                                          ),
                                                                                          const SizedBox(
                                                                                            height: 20,
                                                                                          ),
                                                                                          const CircularProgressIndicator(),
                                                                                        ],
                                                                                      ),
                                                                                    );
                                                                                  } else {
                                                                                    //Applied Item list
                                                                                    modSetList = snapshot.data;
                                                                                    Navigator.of(context).pop();
                              
                                                                                    return const SizedBox();
                                                                                  }
                                                                                }
                                                                              });
                                                                          setState(() {});
                                                                        },
                                                                        child: Text(curLangText!.uiGotIt)),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        } else {
                                                          return FutureBuilder(
                                                              future: modSetLoader(),
                                                              builder: (
                                                                BuildContext context,
                                                                AsyncSnapshot snapshot,
                                                              ) {
                                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                                  return Center(
                                                                    child: Column(
                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                      children: [
                                                                        Text(
                                                                          curLangText!.uiLoadingModSets,
                                                                          style: const TextStyle(fontSize: 20),
                                                                        ),
                                                                        const SizedBox(
                                                                          height: 20,
                                                                        ),
                                                                        const CircularProgressIndicator(),
                                                                      ],
                                                                    ),
                                                                  );
                                                                } else {
                                                                  if (snapshot.hasError) {
                                                                    return Center(
                                                                      child: Column(
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        children: [
                                                                          Text(
                                                                            curLangText!.uiErrorWhenLoadingModSets,
                                                                            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
                                                                          ),
                                                                          const SizedBox(
                                                                            height: 10,
                                                                          ),
                                                                          Padding(
                                                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                                                            child: Text(snapshot.error.toString(),
                                                                                softWrap: true, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15)),
                                                                          ),
                                                                          ElevatedButton(
                                                                              onPressed: () {
                                                                                windowManager.destroy();
                                                                              },
                                                                              child: Text(curLangText!.uiExit))
                                                                        ],
                                                                      ),
                                                                    );
                                                                  } else if (!snapshot.hasData) {
                                                                    return Center(
                                                                      child: Column(
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        children: [
                                                                          Text(
                                                                            curLangText!.uiLoadingModSets,
                                                                            style: const TextStyle(fontSize: 20),
                                                                          ),
                                                                          const SizedBox(
                                                                            height: 20,
                                                                          ),
                                                                          const CircularProgressIndicator(),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  } else {
                                                                    //Applied Item list
                                                                    modSetList = snapshot.data;
                                                                    Navigator.pop(context, true);
                              
                                                                    return const SizedBox();
                                                                  }
                                                                }
                                                              });
                                                        }
                                                      }
                                                    }
                                                  });
                                            }
                                          }
                                        });
                                  }
                                }
                              });
                        }
                      }
                    }));
          }));
}
