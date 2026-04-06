import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LocationButton extends StatelessWidget {
  const LocationButton({super.key, required this.label, required this.folderPath});

  final String label;
  final String folderPath;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
          onPressed: () async {
            launchUrlString(folderPath);
          },
          child: Text(label)),
    );
  }
}
