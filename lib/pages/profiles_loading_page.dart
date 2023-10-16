import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/pages/paths_loading_page.dart';

class ProfileLoader extends StatefulWidget {
  const ProfileLoader({super.key});

  @override
  State<ProfileLoader> createState() => _ProfileLoaderState();
}

class _ProfileLoaderState extends State<ProfileLoader> {
  @override
  Widget build(BuildContext context) {
    return const PathsLoadingPage();
  }
}

// Future<bool> profileLoader(context) async {
//   List<ModFile> reappliedModsResult = [];
//   List<VitalGaugeBackground> reappliedVGresult = [];
//   return await showDialog(
//       barrierDismissible: false,
//       context: context,
//       builder: (context) => StatefulBuilder(builder: (context, setState) {
//             return Dialog.fullscreen(
//                 //shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
//                 backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue),
//                 //contentPadding: const EdgeInsets.all(16),
//                 child: FutureBuilder(
//                     future: pathsLoader(context),
//                     builder: (
//                       BuildContext context,
//                       AsyncSnapshot snapshot,
//                     ) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return Center(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Text(
//                                 curLangText!.uiLoadingPaths,
//                                 style: const TextStyle(fontSize: 20),
//                               ),
//                               const SizedBox(
//                                 height: 20,
//                               ),
//                               const CircularProgressIndicator(),
//                             ],
//                           ),
//                         );
//                       } else {
//                         if (snapshot.hasError) {
//                           return Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   curLangText!.uiErrorWhenLoadingPaths,
//                                   style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
//                                 ),
//                                 const SizedBox(
//                                   height: 10,
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//                                   child: Text(snapshot.error.toString(), softWrap: true, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15)),
//                                 ),
//                                 ElevatedButton(
//                                     onPressed: () {
//                                       windowManager.destroy();
//                                     },
//                                     child: Text(curLangText!.uiExit))
//                               ],
//                             ),
//                           );
//                         } else if (!snapshot.hasData) {
//                           return Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   curLangText!.uiLoadingPaths,
//                                   style: const TextStyle(fontSize: 20),
//                                 ),
//                                 const SizedBox(
//                                   height: 20,
//                                 ),
//                                 const CircularProgressIndicator(),
//                               ],
//                             ),
//                           );
//                         } else {
//                           //mod loading page
//                           return FutureBuilder(
//                               future: modFileStructureLoader(context, true),
//                               builder: (
//                                 BuildContext context,
//                                 AsyncSnapshot snapshot,
//                               ) {
//                                 if (snapshot.connectionState == ConnectionState.waiting) {
//                                   return Center(
//                                     child: Column(
//                                       mainAxisAlignment: MainAxisAlignment.center,
//                                       crossAxisAlignment: CrossAxisAlignment.center,
//                                       children: [
//                                         Text(
//                                           curLangText!.uiLoadingMods,
//                                           style: const TextStyle(fontSize: 20),
//                                         ),
//                                         const SizedBox(
//                                           height: 20,
//                                         ),
//                                         const CircularProgressIndicator(),
//                                         // Visibility(
//                                         //   visible: Provider.of<StateProvider>(context, listen: true).modsLoaderProgressStatus.isNotEmpty,
//                                         //   child: Padding(
//                                         //       padding: const EdgeInsets.symmetric(vertical: 20),
//                                         //       child: Text(
//                                         //         Provider.of<StateProvider>(context, listen: true).modsLoaderProgressStatus,
//                                         //         style: const TextStyle(fontSize: 18),
//                                         //         textAlign: TextAlign.center,
//                                         //       )),
//                                         // )
//                                       ],
//                                     ),
//                                   );
//                                 } else {
//                                   if (snapshot.hasError) {
//                                     return Center(
//                                       child: Column(
//                                         mainAxisAlignment: MainAxisAlignment.center,
//                                         crossAxisAlignment: CrossAxisAlignment.center,
//                                         children: [
//                                           Text(
//                                             curLangText!.uiErrorWhenLoadingMods,
//                                             style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
//                                           ),
//                                           const SizedBox(
//                                             height: 10,
//                                           ),
//                                           Padding(
//                                             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//                                             child: Text(snapshot.error.toString(), softWrap: true, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15)),
//                                           ),
//                                           ElevatedButton(
//                                               onPressed: () {
//                                                 windowManager.destroy();
//                                               },
//                                               child: Text(curLangText!.uiExit))
//                                         ],
//                                       ),
//                                     );
//                                   } else if (!snapshot.hasData) {
//                                     return Center(
//                                       child: Column(
//                                         mainAxisAlignment: MainAxisAlignment.center,
//                                         crossAxisAlignment: CrossAxisAlignment.center,
//                                         children: [
//                                           Text(
//                                             curLangText!.uiLoadingMods,
//                                             style: const TextStyle(fontSize: 20),
//                                           ),
//                                           const SizedBox(
//                                             height: 20,
//                                           ),
//                                           const CircularProgressIndicator(),
//                                         ],
//                                       ),
//                                     );
//                                   } else {
//                                     //Item list
//                                     moddedItemsList = snapshot.data;

//                                     //Applied list loading page
//                                     return FutureBuilder(
//                                         future: appliedListBuilder(moddedItemsList),
//                                         builder: (
//                                           BuildContext context,
//                                           AsyncSnapshot snapshot,
//                                         ) {
//                                           if (snapshot.connectionState == ConnectionState.waiting) {
//                                             return Center(
//                                               child: Column(
//                                                 mainAxisAlignment: MainAxisAlignment.center,
//                                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                                 children: [
//                                                   Text(
//                                                     curLangText!.uiLoadingAppliedMods,
//                                                     style: const TextStyle(fontSize: 20),
//                                                   ),
//                                                   const SizedBox(
//                                                     height: 20,
//                                                   ),
//                                                   const CircularProgressIndicator(),
//                                                 ],
//                                               ),
//                                             );
//                                           } else {
//                                             if (snapshot.hasError) {
//                                               return Center(
//                                                 child: Column(
//                                                   mainAxisAlignment: MainAxisAlignment.center,
//                                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                                   children: [
//                                                     Text(
//                                                       curLangText!.uiErrorWhenLoadingAppliedMods,
//                                                       style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
//                                                     ),
//                                                     const SizedBox(
//                                                       height: 10,
//                                                     ),
//                                                     Padding(
//                                                       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//                                                       child: Text(snapshot.error.toString(), softWrap: true, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15)),
//                                                     ),
//                                                     ElevatedButton(
//                                                         onPressed: () {
//                                                           windowManager.destroy();
//                                                         },
//                                                         child: Text(curLangText!.uiExit))
//                                                   ],
//                                                 ),
//                                               );
//                                             } else if (!snapshot.hasData) {
//                                               return Center(
//                                                 child: Column(
//                                                   mainAxisAlignment: MainAxisAlignment.center,
//                                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                                   children: [
//                                                     Text(
//                                                       curLangText!.uiLoadingAppliedMods,
//                                                       style: const TextStyle(fontSize: 20),
//                                                     ),
//                                                     const SizedBox(
//                                                       height: 20,
//                                                     ),
//                                                     const CircularProgressIndicator(),
//                                                   ],
//                                                 ),
//                                               );
//                                             } else {
//                                               //Applied Item list
//                                               appliedItemList = snapshot.data;

//                                               //applied mods checking page
//                                               return FutureBuilder(
//                                                   future: appliedFileCheck(appliedItemList),
//                                                   builder: (
//                                                     BuildContext context,
//                                                     AsyncSnapshot snapshot,
//                                                   ) {
//                                                     if (snapshot.connectionState == ConnectionState.waiting) {
//                                                       return Center(
//                                                         child: Column(
//                                                           mainAxisAlignment: MainAxisAlignment.center,
//                                                           crossAxisAlignment: CrossAxisAlignment.center,
//                                                           children: [
//                                                             Text(
//                                                               curLangText!.uiCheckingAppliedMods,
//                                                               style: const TextStyle(fontSize: 20),
//                                                             ),
//                                                             const SizedBox(
//                                                               height: 20,
//                                                             ),
//                                                             const CircularProgressIndicator(),
//                                                           ],
//                                                         ),
//                                                       );
//                                                     } else {
//                                                       if (snapshot.hasError) {
//                                                         return Center(
//                                                           child: Column(
//                                                             mainAxisAlignment: MainAxisAlignment.center,
//                                                             crossAxisAlignment: CrossAxisAlignment.center,
//                                                             children: [
//                                                               Text(
//                                                                 curLangText!.uiErrorWhenCheckingAppliedMods,
//                                                                 style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
//                                                               ),
//                                                               const SizedBox(
//                                                                 height: 10,
//                                                               ),
//                                                               Padding(
//                                                                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//                                                                 child: Text(snapshot.error.toString(),
//                                                                     softWrap: true, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15)),
//                                                               ),
//                                                               ElevatedButton(
//                                                                   onPressed: () {
//                                                                     windowManager.destroy();
//                                                                   },
//                                                                   child: Text(curLangText!.uiExit))
//                                                             ],
//                                                           ),
//                                                         );
//                                                       } else if (!snapshot.hasData) {
//                                                         return Center(
//                                                           child: Column(
//                                                             mainAxisAlignment: MainAxisAlignment.center,
//                                                             crossAxisAlignment: CrossAxisAlignment.center,
//                                                             children: [
//                                                               Text(
//                                                                 curLangText!.uiCheckingAppliedMods,
//                                                                 style: const TextStyle(fontSize: 20),
//                                                               ),
//                                                               const SizedBox(
//                                                                 height: 20,
//                                                               ),
//                                                               const CircularProgressIndicator(),
//                                                             ],
//                                                           ),
//                                                         );
//                                                       } else {
//                                                         //Return
//                                                         reappliedModsResult = snapshot.data;
//                                                         //reapply vital gauge
//                                                         return FutureBuilder(
//                                                             future: appliedVitalGaugesCheck(),
//                                                             builder: (
//                                                               BuildContext context,
//                                                               AsyncSnapshot snapshot,
//                                                             ) {
//                                                               if (snapshot.connectionState == ConnectionState.waiting) {
//                                                                 return Center(
//                                                                   child: Column(
//                                                                     mainAxisAlignment: MainAxisAlignment.center,
//                                                                     crossAxisAlignment: CrossAxisAlignment.center,
//                                                                     children: [
//                                                                       Text(
//                                                                         curLangText!.uiLoadingModSets,
//                                                                         style: const TextStyle(fontSize: 20),
//                                                                       ),
//                                                                       const SizedBox(
//                                                                         height: 20,
//                                                                       ),
//                                                                       const CircularProgressIndicator(),
//                                                                     ],
//                                                                   ),
//                                                                 );
//                                                               } else {
//                                                                 if (snapshot.hasError) {
//                                                                   return Center(
//                                                                     child: Column(
//                                                                       mainAxisAlignment: MainAxisAlignment.center,
//                                                                       crossAxisAlignment: CrossAxisAlignment.center,
//                                                                       children: [
//                                                                         Text(
//                                                                           curLangText!.uiErrorWhenLoadingModSets,
//                                                                           style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
//                                                                         ),
//                                                                         const SizedBox(
//                                                                           height: 10,
//                                                                         ),
//                                                                         Padding(
//                                                                           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//                                                                           child: Text(snapshot.error.toString(),
//                                                                               softWrap: true, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15)),
//                                                                         ),
//                                                                         ElevatedButton(
//                                                                             onPressed: () {
//                                                                               windowManager.destroy();
//                                                                             },
//                                                                             child: Text(curLangText!.uiExit))
//                                                                       ],
//                                                                     ),
//                                                                   );
//                                                                 } else if (!snapshot.hasData) {
//                                                                   return Center(
//                                                                     child: Column(
//                                                                       mainAxisAlignment: MainAxisAlignment.center,
//                                                                       crossAxisAlignment: CrossAxisAlignment.center,
//                                                                       children: [
//                                                                         Text(
//                                                                           curLangText!.uiLoadingModSets,
//                                                                           style: const TextStyle(fontSize: 20),
//                                                                         ),
//                                                                         const SizedBox(
//                                                                           height: 20,
//                                                                         ),
//                                                                         const CircularProgressIndicator(),
//                                                                       ],
//                                                                     ),
//                                                                   );
//                                                                 } else {
//                                                                   reappliedVGresult = snapshot.data;

//                                                                   return FutureBuilder(
//                                                                       future: modSetLoader(),
//                                                                       builder: (
//                                                                         BuildContext context,
//                                                                         AsyncSnapshot snapshot,
//                                                                       ) {
//                                                                         if (snapshot.connectionState == ConnectionState.waiting) {
//                                                                           return Center(
//                                                                             child: Column(
//                                                                               mainAxisAlignment: MainAxisAlignment.center,
//                                                                               crossAxisAlignment: CrossAxisAlignment.center,
//                                                                               children: [
//                                                                                 Text(
//                                                                                   curLangText!.uiLoadingModSets,
//                                                                                   style: const TextStyle(fontSize: 20),
//                                                                                 ),
//                                                                                 const SizedBox(
//                                                                                   height: 20,
//                                                                                 ),
//                                                                                 const CircularProgressIndicator(),
//                                                                               ],
//                                                                             ),
//                                                                           );
//                                                                         } else {
//                                                                           if (snapshot.hasError) {
//                                                                             return Center(
//                                                                               child: Column(
//                                                                                 mainAxisAlignment: MainAxisAlignment.center,
//                                                                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                                                                 children: [
//                                                                                   Text(
//                                                                                     curLangText!.uiErrorWhenLoadingModSets,
//                                                                                     style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
//                                                                                   ),
//                                                                                   const SizedBox(
//                                                                                     height: 10,
//                                                                                   ),
//                                                                                   Padding(
//                                                                                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//                                                                                     child: Text(snapshot.error.toString(),
//                                                                                         softWrap: true, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15)),
//                                                                                   ),
//                                                                                   ElevatedButton(
//                                                                                       onPressed: () {
//                                                                                         windowManager.destroy();
//                                                                                       },
//                                                                                       child: Text(curLangText!.uiExit))
//                                                                                 ],
//                                                                               ),
//                                                                             );
//                                                                           } else if (!snapshot.hasData) {
//                                                                             return Center(
//                                                                               child: Column(
//                                                                                 mainAxisAlignment: MainAxisAlignment.center,
//                                                                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                                                                 children: [
//                                                                                   Text(
//                                                                                     curLangText!.uiLoadingModSets,
//                                                                                     style: const TextStyle(fontSize: 20),
//                                                                                   ),
//                                                                                   const SizedBox(
//                                                                                     height: 20,
//                                                                                   ),
//                                                                                   const CircularProgressIndicator(),
//                                                                                 ],
//                                                                               ),
//                                                                             );
//                                                                           } else {
//                                                                             modSetList = snapshot.data;
//                                                                             if (reappliedModsResult.isEmpty && reappliedVGresult.isEmpty) {
//                                                                               Navigator.pop(context, true);
//                                                                               return const SizedBox();
//                                                                             } else {
//                                                                               return SizedBox(
//                                                                                 width: double.infinity,
//                                                                                 height: double.infinity,
//                                                                                 child: Padding(
//                                                                                   padding: const EdgeInsets.all(16.0),
//                                                                                   child: Column(
//                                                                                     mainAxisAlignment: MainAxisAlignment.center,
//                                                                                     crossAxisAlignment: CrossAxisAlignment.center,
//                                                                                     children: [
//                                                                                       // reapplied mods
//                                                                                       if (reappliedModsResult.isNotEmpty)
//                                                                                       Padding(
//                                                                                         padding: const EdgeInsets.only(bottom: 10),
//                                                                                         child: Text(
//                                                                                           curLangText!.uiReappliedModsAfterChecking,
//                                                                                           style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
//                                                                                         ),
//                                                                                       ),
//                                                                                       if (reappliedModsResult.isNotEmpty)
//                                                                                       Expanded(
//                                                                                         child: ScrollbarTheme(
//                                                                                           data: ScrollbarThemeData(
//                                                                                             thumbColor: MaterialStateProperty.resolveWith((states) {
//                                                                                               if (states.contains(MaterialState.hovered)) {
//                                                                                                 return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.7);
//                                                                                               }
//                                                                                               return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5);
//                                                                                             }),
//                                                                                           ),
//                                                                                           child: SingleChildScrollView(
//                                                                                             child: ListView.builder(
//                                                                                                 shrinkWrap: true,
//                                                                                                 padding: const EdgeInsets.all(2),
//                                                                                                 physics: const NeverScrollableScrollPhysics(),
//                                                                                                 itemCount: reappliedModsResult.length,
//                                                                                                 itemBuilder: (context, i) {
//                                                                                                   return ListTile(
//                                                                                                     title: Center(
//                                                                                                         child: Text(
//                                                                                                             '${reappliedModsResult[i].category} > ${reappliedModsResult[i].itemName} > ${reappliedModsResult[i].modName} > ${reappliedModsResult[i].submodName} > ${reappliedModsResult[i].modFileName}')),
//                                                                                                   );
//                                                                                                 }),
//                                                                                           ),
//                                                                                         ),
//                                                                                       ),

//                                                                                       //reapplied vg
//                                                                                       if (reappliedVGresult.isNotEmpty)
//                                                                                       Padding(
//                                                                                         padding: const EdgeInsets.only(bottom: 10),
//                                                                                         child: Text(
//                                                                                           curLangText!.uiReappliedVitalGaugesAfterChecking,
//                                                                                           style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
//                                                                                         ),
//                                                                                       ),
//                                                                                       if (reappliedVGresult.isNotEmpty)
//                                                                                       Expanded(
//                                                                                         child: ScrollbarTheme(
//                                                                                           data: ScrollbarThemeData(
//                                                                                             thumbColor: MaterialStateProperty.resolveWith((states) {
//                                                                                               if (states.contains(MaterialState.hovered)) {
//                                                                                                 return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.7);
//                                                                                               }
//                                                                                               return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5);
//                                                                                             }),
//                                                                                           ),
//                                                                                           child: SingleChildScrollView(
//                                                                                             child: ListView.builder(
//                                                                                                 shrinkWrap: true,
//                                                                                                 padding: const EdgeInsets.all(2),
//                                                                                                 physics: const NeverScrollableScrollPhysics(),
//                                                                                                 itemCount: reappliedVGresult.length,
//                                                                                                 itemBuilder: (context, i) {
//                                                                                                   return ListTile(
//                                                                                                     title: Center(
//                                                                                                         child: Text('${reappliedVGresult[i].iceName} > ${reappliedVGresult[i].ddsName}')),
//                                                                                                   );
//                                                                                                 }),
//                                                                                           ),
//                                                                                         ),
//                                                                                       ),

//                                                                                       //button
//                                                                                       Padding(
//                                                                                         padding: const EdgeInsets.only(top: 10),
//                                                                                         child: ElevatedButton(
//                                                                                             onPressed: () {
//                                                                                               Navigator.of(context).pop();
//                                                                                             },
//                                                                                             child: Text(curLangText!.uiGotIt)),
//                                                                                       ),
//                                                                                     ],
//                                                                                   ),
//                                                                                 ),
//                                                                               );
//                                                                             }
//                                                                           }
//                                                                         }
//                                                                       });
//                                                                 }
//                                                               }
//                                                             });
//                                                       }
//                                                     }
//                                                   });
//                                             }
//                                           }
//                                         });
//                                   }
//                                 }
//                               });
//                         }
//                       }
//                     }));
//           }));
// }
