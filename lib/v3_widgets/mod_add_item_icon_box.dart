import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:signals/signals_flutter.dart';

class ModAddItemIconBox extends StatefulWidget {
  const ModAddItemIconBox({super.key, required this.itemIcon});

  final String itemIcon;

  @override
  State<ModAddItemIconBox> createState() => _ModAddItemIconBoxState();
}

class _ModAddItemIconBoxState extends State<ModAddItemIconBox> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Card(
          shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(0))),
          color: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
          margin: EdgeInsets.zero,
          elevation: 5,
          child: widget.itemIcon.isNotEmpty
              ? Image.network(
                      'https://raw.githubusercontent.com/KizKizz/pso2ngs_file_downloader/main${widget.itemIcon}',
                      filterQuality: FilterQuality.none,
                      fit: BoxFit.cover,
                    )
              : Image.asset(
                  'assets/img/placeholdersquare.png',
                  filterQuality: FilterQuality.high,
                  fit: BoxFit.cover,
                )),
    );
  }
}
