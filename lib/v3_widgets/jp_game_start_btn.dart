// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/mod_checksum/checksum_functions.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/v3_home/settings.dart';
import 'package:pso2_mod_manager/v3_widgets/notifications.dart';
import 'package:signals/signals_flutter.dart';

class JpGameStartBtn extends StatefulWidget {
  const JpGameStartBtn({super.key});

  @override
  State<JpGameStartBtn> createState() => _JpGameStartBtnState();
}

class _JpGameStartBtnState extends State<JpGameStartBtn> {
  @override
  Widget build(BuildContext context) {
    // Refresh
    if (settingChangeStatus.watch(context) != settingChangeStatus.peek()) {
      setState(
        () {},
      );
    }
    return SizedBox(
      height: 20,
      child: OutlinedButton.icon(
          style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5), side: BorderSide(width: 1.5, color: Theme.of(context).colorScheme.primary)))),
          onPressed: () async {
            File startBatch = File('$mainDataDirPath${p.separator}startpso2jp.bat');
            if (!startBatch.existsSync()) await startBatch.create(recursive: true);
            if (startBatch.existsSync()) {
              // checksum
              await checksumToGameData();
              //create start file

              if (File('$pso2binDirPath${p.separator}sub${p.separator}ucldr_PSO2_JP_loader_x64.exe').existsSync()) {
                await startBatch.writeAsString(
                    'cd "$pso2binDirPath${p.separator}sub"\nSET -pso2=+0x33aca2b9\nstart "" "$pso2binDirPath${p.separator}sub${p.separator}ucldr_PSO2_JP_loader_x64.exe" "$pso2binDirPath${p.separator}sub${p.separator}pso2.exe" +0x33aca2b9 -reboot -optimize"');
                await Process.run(startBatch.path, []);
                startBatch.deleteSync();
              } else {
                errorNotification(appText.anticheatLoaderFileNotFound);
              }
            } else {
              errorNotification(appText.couldntCreateCustomLauncher);
            }
          },
          icon: const Icon(
            Icons.play_arrow_rounded,
            size: 18,
          ),
          label: Text(
            appText.launchPSO2,
          )),
    );
  }
}
