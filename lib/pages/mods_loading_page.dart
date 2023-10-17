import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/mod_files_loader.dart';
import 'package:pso2_mod_manager/pages/applied_mods_loading_page.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:window_manager/window_manager.dart';

//late final Future modListLoader;

class ModsLoadingPage extends StatefulWidget {
  const ModsLoadingPage({Key? key}) : super(key: key);

  @override
  State<ModsLoadingPage> createState() => _ModsLoadingPageState();
}

class _ModsLoadingPageState extends State<ModsLoadingPage> {
  // @override
  // void initState() {
  //   modListLoader = modFileStructureLoader(context, false);
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: modFileStructureLoader(context, Provider.of<StateProvider>(context, listen: false).reloadProfile),
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
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        Provider.of<StateProvider>(context, listen: true).modsLoaderProgressStatus,
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      )),
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
              //isStartupModsLoad = false;
              moddedItemsList = snapshot.data;

              return const AppliedModsLoadingPage();
            }
          }
        });
  }
}
