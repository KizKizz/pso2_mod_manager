// // ignore_for_file: unused_import

// import 'package:flutter/material.dart';
// import 'package:pso2_mod_manager/functions/applied_list_builder.dart';
// import 'package:pso2_mod_manager/global_variables.dart';
// import 'package:pso2_mod_manager/loaders/language_loader.dart';
// import 'package:pso2_mod_manager/pages/applied_mods_checking_page.dart';
// import 'package:pso2_mod_manager/pages/mod_set_loading_page.dart';
// import 'package:window_manager/window_manager.dart';

// class AppliedModsLoadingPage extends StatefulWidget {
//   const AppliedModsLoadingPage({super.key});

//   @override
//   State<AppliedModsLoadingPage> createState() => _AppliedModsLoadingPageState();
// }

// class _AppliedModsLoadingPageState extends State<AppliedModsLoadingPage> {
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//         future: appliedListBuilder(moddedItemsList),
//         builder: (
//           BuildContext context,
//           AsyncSnapshot snapshot,
//         ) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Text(
//                     curLangText!.uiLoadingAppliedMods,
//                     style: const TextStyle(fontSize: 20),
//                   ),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   const CircularProgressIndicator(),
//                 ],
//               ),
//             );
//           } else {
//             if (snapshot.hasError) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Text(
//                       curLangText!.uiErrorWhenLoadingAppliedMods,
//                       style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
//                     ),
//                     const SizedBox(
//                       height: 10,
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//                       child: Text(snapshot.error.toString(), softWrap: true, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15)),
//                     ),
//                     ElevatedButton(
//                         onPressed: () {
//                           windowManager.destroy();
//                         },
//                         child: Text(curLangText!.uiExit))
//                   ],
//                 ),
//               );
//             } else if (!snapshot.hasData) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Text(
//                       curLangText!.uiLoadingAppliedMods,
//                       style: const TextStyle(fontSize: 20),
//                     ),
//                     const SizedBox(
//                       height: 20,
//                     ),
//                     const CircularProgressIndicator(),
//                   ],
//                 ),
//               );
//             } else {
//               //Applied Item list
//               appliedItemList = snapshot.data;

//               return const AppliedModsCheckingPage();
//             }
//           }
//         });
//   }
// }
