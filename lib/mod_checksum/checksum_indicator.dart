import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_checksum/checksum_functions.dart';
import 'package:signals/signals_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ChecksumIndicator extends StatefulWidget {
  const ChecksumIndicator({super.key});

  @override
  State<ChecksumIndicator> createState() => _ChecksumIndicatorState();
}

class _ChecksumIndicatorState extends State<ChecksumIndicator> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 5, right: 10),
        child: Row(
          spacing: 5,
          children: [
            Visibility(
              visible: checksumAvailability.watch(context),
              child: SizedBox(
                height: 20,
                child: OutlinedButton.icon(
                      style: ButtonStyle(
                        visualDensity: VisualDensity.adaptivePlatformDensity,
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)))),
                      onPressed: () => launchUrlString(File(modChecksumFilePath).parent.path),
                      icon: const Icon(Icons.app_registration_outlined, size: 18,),
                      label: Text('${appText.checksum}: ${appText.ok}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
              ) 
              
              
            ),
            Visibility(
                visible: !checksumAvailability.watch(context),
                child: SizedBox(
                  height: 20,
                  child: OutlinedButton.icon(
                      style: ButtonStyle(
                        visualDensity: VisualDensity.adaptivePlatformDensity,
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)))),
                      onPressed: () async {
                        await checksumFileSelect();
                      },
                      icon: const Icon(Icons.apps_outage_outlined, size: 18, color: Colors.redAccent),
                      label: Text('${appText.checksum}: ${appText.notFoundClickToBrowse}',
                          textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.redAccent))),
                ))
          ],
        ));
  }
}
