import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_home/main_mod_grid.dart';
import 'package:sidebarx/sidebarx.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  SidebarXController sidebarXController = SidebarXController(selectedIndex: 0, extended: false);
  List<Widget> homepageWidgets = [const MainModGrid()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: Row(
          spacing: 5,
          children: [
            SidebarX(
              controller: sidebarXController,
              theme: SidebarXTheme(
                  width: 60,
                  margin: const EdgeInsets.all(5),
                  itemPadding: const EdgeInsets.all(5),
                  selectedItemPadding: const EdgeInsets.all(5),
                  itemTextPadding: const EdgeInsets.only(left: 15),
                  selectedItemTextPadding: const EdgeInsets.only(left: 15),
                  selectedIconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
                  selectedTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                  hoverIconTheme: IconThemeData(color: Theme.of(context).colorScheme.tertiary),
                  hoverTextStyle: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer.withAlpha(200),
                      boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withAlpha(50), spreadRadius: 2, blurRadius: 3, offset: const Offset(2, 2))],
                      border: Border.all(width: 1.5, color: Theme.of(context).colorScheme.primary),
                      borderRadius: const BorderRadius.all(Radius.circular(10)))),
              extendedTheme: const SidebarXTheme(
                width: 140,
                margin: EdgeInsets.all(5),
                itemTextPadding: EdgeInsets.only(left: 15),
                selectedItemTextPadding: EdgeInsets.only(left: 15),
              ),
              headerBuilder: (context, extended) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: extended
                      ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 5,
                            children: [Icon(modManCurActiveProfile == 1 ? Icons.filter_1 : Icons.filter_2), Text(appText.dText(appText.profileNum, modManCurActiveProfile.toString()))],
                          ),
                      )
                      : Icon(modManCurActiveProfile == 1 ? Icons.filter_1 : Icons.filter_2),
                );
              },
              headerDivider: Divider(
                height: 15,
                thickness: 1,
                indent: 3,
                endIndent: 3,
                color: Theme.of(context).colorScheme.primary,
              ),
              items: [
                SidebarXItem(
                  icon: Icons.grid_view,
                  label: appText.modList,
                  onTap: () => sidebarXController.selectIndex(0),
                ),
                SidebarXItem(icon: Icons.search, label: appText.modSets),
              ],
              // footerDivider: Divider(
              //   height: 15,
              //   thickness: 2,
              //   indent: 3,
              //   endIndent: 3,
              //   color: Theme.of(context).colorScheme.primary,
              // ),
              footerItems: [
                SidebarXItem(icon: Icons.settings, label: appText.settings),
              ],
            ),
            Expanded(child: Padding(padding: const EdgeInsets.only(top: 5, bottom: 5, right: 5), child: homepageWidgets[sidebarXController.selectedIndex]))
          ],
        ),
      ),
    );
  }
}
