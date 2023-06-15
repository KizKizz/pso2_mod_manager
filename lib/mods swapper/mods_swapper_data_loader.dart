import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/mods%20swapper/mods_swapper_homepage.dart';
import 'package:pso2_mod_manager/mods%20swapper/mods_swapper_popup.dart';

class ModsSwapperDataLoader extends StatefulWidget {
  const ModsSwapperDataLoader({super.key, required this.fromItem, required this.fromSubmod});

  final Item fromItem;
  final SubMod fromSubmod;

  @override
  State<ModsSwapperDataLoader> createState() => _ModsSwapperDataLoaderState();
}

class _ModsSwapperDataLoaderState extends State<ModsSwapperDataLoader> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: sheetListFetchFromFiles(getCsvFiles(widget.fromItem.category)),
        builder: (
          BuildContext context,
          AsyncSnapshot snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Loading item sheets data',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CircularProgressIndicator(),
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
                      'error when loading item sheets data',
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Text(snapshot.error.toString(), softWrap: true, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15)),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Loading item sheets data',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    CircularProgressIndicator(),
                  ],
                ),
              );
            } else {
              //Applied Item list
              csvData = snapshot.data;

              return FutureBuilder(
                  future: getSwapToCsvList(csvData, widget.fromItem),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting && availableItemsCsvData.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Loading',
                              style: TextStyle(fontSize: 20),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            CircularProgressIndicator(),
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
                                'Loading',
                                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                child: Text(snapshot.error.toString(), softWrap: true, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15)),
                              ),
                            ],
                          ),
                        );
                      } else if (!snapshot.hasData) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Loading',
                                style: TextStyle(fontSize: 20),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              CircularProgressIndicator(),
                            ],
                          ),
                        );
                      } else {
                        //Applied Item list
                        availableItemsCsvData = snapshot.data;
                        if (curActiveLang == 'JP') {
                          availableItemsCsvData.sort(
                            (a, b) => a.jpName.compareTo(b.jpName),
                          );
                        } else {
                          availableItemsCsvData.sort(
                            (a, b) => a.enName.compareTo(b.enName),
                          );
                        }

                        return ModsSwapperHomePage(
                          fromItem: widget.fromItem,
                          fromSubmod: widget.fromSubmod,
                        );
                      }
                    }
                  });
            }
          }
        });
  }
}
