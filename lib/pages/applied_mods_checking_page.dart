import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/functions/applied_files_check.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/pages/mod_set_loading_page.dart';

class AppliedModsCheckingPage extends StatefulWidget {
  const AppliedModsCheckingPage({Key? key}) : super(key: key);

  @override
  State<AppliedModsCheckingPage> createState() => _AppliedModsCheckingPageState();
}

class _AppliedModsCheckingPageState extends State<AppliedModsCheckingPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: appliedFileCheck(appliedItemList),
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
                    'Checking Applied Mods',
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
                      'Error when checking applied mod files',
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
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Checking Applied Mods',
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
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            'The mod(s) below have been automatically re-applied to the game:',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                          ),
                        ),
                        ScrollbarTheme(
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
                                    title: Center(child: Text('${result[i].category} > ${result[i].itemName} > ${result[i].modName} > ${result[i].submodName} > ${result[i].modFileName}')),
                                  );
                                }),
                          ),
                        ),

                        //button
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: ElevatedButton(
                              onPressed: () {
                                const ModSetsLoadingPage();
                                setState(() {});
                              },
                              child: const Text('OK')),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return const ModSetsLoadingPage();
              }
            }
          }
        });
  }
}
