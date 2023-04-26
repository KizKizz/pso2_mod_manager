import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/mod_files_loader.dart';
import 'package:pso2_mod_manager/pages/home_page.dart';

class ModsLoadingPage extends StatefulWidget {
  const ModsLoadingPage({Key? key}) : super(key: key);

  @override
  State<ModsLoadingPage> createState() => _ModsLoadingPageState();
}

class _ModsLoadingPageState extends State<ModsLoadingPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: categoryTypesLoader(),
        builder: (
          BuildContext context,
          AsyncSnapshot snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    'Loading Mods',
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
                      'Error when loading mod files',
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(snapshot.error.toString(), softWrap: true, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15)),
                    )
                  ],
                ),
              );
            } else if (!snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Text(
                      'Loading Mods',
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
              moddedItemsList = snapshot.data;
              
              return const HomePage();
            }
          }
        });
  }
}
