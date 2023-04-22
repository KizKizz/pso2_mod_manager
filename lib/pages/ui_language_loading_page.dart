import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/functions/language_loader.dart';
import 'package:pso2_mod_manager/pages/home_page.dart';

class UILanguageLoadingPage extends StatefulWidget {
  const UILanguageLoadingPage({Key? key}) : super(key: key);

  @override
  State<UILanguageLoadingPage> createState() => _UILanguageLoadingPageState();
}

class _UILanguageLoadingPageState extends State<UILanguageLoadingPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: uiTextLoader(),
        builder: (
          BuildContext context,
          AsyncSnapshot snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text(
                  'Loading Data',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 20,
                ),
                CircularProgressIndicator(),
              ],
            );
          } else {
            if (snapshot.hasError) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '',
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
              );
            } else if (!snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    'Loading Data',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CircularProgressIndicator(),
                ],
              );
            } else {
              curLangText = snapshot.data;
              return const HomePage();
            }
          }
        });
  }
}
