import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';

class ModViewPopup extends StatefulWidget {
  const ModViewPopup({super.key, required this.item});

  final Item item;

  @override
  State<ModViewPopup> createState() => _ModViewPopupState();
}

class _ModViewPopupState extends State<ModViewPopup> {
  @override
  Widget build(BuildContext context) {
    return Text('test');
  }
}
