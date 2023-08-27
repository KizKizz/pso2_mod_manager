import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/classes/vital_gauge_class.dart';
import 'package:pso2_mod_manager/functions/applied_vital_gauge_check.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/pages/mod_set_loading_page.dart';
import 'package:window_manager/window_manager.dart';

class AppliedVitalGaugeCheckingPage extends StatefulWidget {
  const AppliedVitalGaugeCheckingPage({Key? key}) : super(key: key);

  @override
  State<AppliedVitalGaugeCheckingPage> createState() => _AppliedVitalGaugeCheckingPageState();
}

class _AppliedVitalGaugeCheckingPageState extends State<AppliedVitalGaugeCheckingPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: appliedVitalGaugesCheck(),
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
                    curLangText!.uicheckingReplacedVitalGaugeBackgrounds,
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
                      curLangText!.uierrorWhenCheckingReplacedVitalGaugeBackgrounds,
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
                      curLangText!.uicheckingReplacedVitalGaugeBackgrounds,
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
              List<VitalGaugeBackground> result = snapshot.data;
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
                            '${curLangText!.uiReappliedVitalGaugesAfterChecking}:',
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
                                      title: Center(child: Text('${result[i].iceName} > ${result[i].ddsName}')),
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
                                const ModSetsLoadingPage();
                                setState(() {});
                              },
                              child: Text(curLangText!.uiGotIt)),
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
