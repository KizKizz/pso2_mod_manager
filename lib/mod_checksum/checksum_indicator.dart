import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_checksum/checksum_functions.dart';
import 'package:signals/signals_flutter.dart';

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
              child: Card(
                  shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(5))),
                  color: Colors.transparent,
                  margin: EdgeInsets.zero,
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 5),
                    child: Center(child: Text('${appText.checksum}: ${appText.ok}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
                  )),
            ),
            Visibility(
                visible: !checksumAvailability.watch(context),
                child: InkWell(
                  onTap: () async {
                    await checksumFileSelect();
                  },
                  child: Card(
                      shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(5))),
                      color: Colors.transparent,
                      margin: EdgeInsets.zero,
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 5),
                        child: Center(
                            child: Text('${appText.checksum}: ${appText.notFoundClickToBrowse}',
                                textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.redAccent))),
                      )),
                ))
          ],
        ));
  }
}
