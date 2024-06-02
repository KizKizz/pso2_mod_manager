// ignore_for_file: unused_import

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/functions/applied_list_builder.dart';
import 'package:pso2_mod_manager/functions/player_item_data.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/pages/applied_mods_checking_page.dart';
import 'package:pso2_mod_manager/pages/mod_set_loading_page.dart';
import 'package:pso2_mod_manager/pages/mods_loading_page.dart';
import 'package:window_manager/window_manager.dart';

final playerItemDataPreload = playerItemDataGet();

class PlayerItemDataPreloadingPage extends StatefulWidget {
  const PlayerItemDataPreloadingPage({super.key});

  @override
  State<PlayerItemDataPreloadingPage> createState() => _PlayerItemDataPreloadingPageState();
}

class _PlayerItemDataPreloadingPageState extends State<PlayerItemDataPreloadingPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: playerItemDataPreload,
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
                    curLangText!.uiLoadingPlayerItemData,
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
              if (File(modManPlayerItemDataPath).existsSync()) {
                File(modManPlayerItemDataPath).deleteSync();
              }
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      curLangText!.uiErrorWhenLoadingPlayerItemData,
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
                      curLangText!.uiLoadingPlayerItemData,
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
              playerItemData = snapshot.data;

              return const ModsLoadingPage();
            }
          }
        });
  }
}
