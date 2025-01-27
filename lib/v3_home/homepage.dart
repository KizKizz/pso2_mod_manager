import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/main_widgets/sidebar_button.dart';
import 'package:pso2_mod_manager/v3_home/main_applied_mod_grid.dart';
import 'package:pso2_mod_manager/v3_home/main_item_aqm_inject_grid.dart';
import 'package:pso2_mod_manager/v3_home/main_item_swap_grid.dart';
import 'package:pso2_mod_manager/v3_home/main_modset_grid.dart';
import 'package:pso2_mod_manager/v3_home/main_vital_gauge_grid.dart';
import 'package:pso2_mod_manager/v3_home/mod_add.dart';
import 'package:pso2_mod_manager/v3_home/main_item_grid.dart';
import 'package:pso2_mod_manager/v3_home/main_mod_grid.dart';
import 'package:pso2_mod_manager/v3_home/settings.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:signals/signals_flutter.dart';

Signal<Widget> homepageCurrentWidget = Signal(const MainItemGrid());
SidebarXController sidebarXController = SidebarXController(selectedIndex: 0, extended: false);
SideMenuController sideMenuController = SideMenuController();
int sideButtonSlectedIndex = 0;
List<Widget> homepageWidgets = [
  const MainItemGrid(),
  const MainModGrid(),
  const MainAppliedModGrid(),
  const MainModSetGrid(),
  const MainItemSwapGrid(),
  const MainItemAqmInjectGrid(),
  const MainVitalGaugeGrid(),
];
List<Widget> homepageFooterWidgets = [const ModAdd(), const Settings()];

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        spacing: 5,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // SidebarX(
          //   controller: sidebarXController,
          //   theme: SidebarXTheme(
          //       width: 60,
          //       margin: const EdgeInsets.all(5),
          //       itemPadding: const EdgeInsets.all(5),
          //       selectedItemPadding: const EdgeInsets.all(5),
          //       itemTextPadding: const EdgeInsets.only(left: 15),
          //       selectedItemTextPadding: const EdgeInsets.only(left: 15),
          //       selectedIconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
          //       selectedTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          //       hoverIconTheme: IconThemeData(color: Theme.of(context).colorScheme.tertiary),
          //       hoverTextStyle: TextStyle(color: Theme.of(context).colorScheme.tertiary),
          //       decoration: BoxDecoration(
          //           color: Theme.of(context).colorScheme.surfaceContainer.withAlpha(uiBackgroundColorAlpha.watch(context)),
          //           boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withAlpha(50), spreadRadius: 2, blurRadius: 3, offset: const Offset(2, 2))],
          //           border: Border.all(width: 1.5, color: Theme.of(context).colorScheme.outline),
          //           borderRadius: const BorderRadius.all(Radius.circular(10)))),
          //   extendedTheme: const SidebarXTheme(
          //     width: 140,
          //     margin: EdgeInsets.all(5),
          //     itemTextPadding: EdgeInsets.only(left: 15),
          //     selectedItemTextPadding: EdgeInsets.only(left: 15),
          //   ),
          //   headerBuilder: (context, extended) {
          //     return Padding(
          //       padding: const EdgeInsets.only(top: 10),
          //       child: extended
          //           ? Center(
          //               child: Column(
          //                 mainAxisSize: MainAxisSize.min,
          //                 mainAxisAlignment: MainAxisAlignment.center,
          //                 spacing: 5,
          //                 children: [Icon(modManCurActiveProfile == 1 ? Icons.filter_1 : Icons.filter_2), Text(appText.dText(appText.profileNum, modManCurActiveProfile.toString()))],
          //               ),
          //             )
          //           : Icon(modManCurActiveProfile == 1 ? Icons.filter_1 : Icons.filter_2),
          //     );
          //   },
          //   headerDivider: Divider(
          //     height: 15,
          //     thickness: 1,
          //     indent: 3,
          //     endIndent: 3,
          //     color: Theme.of(context).colorScheme.outline,
          //   ),
          //   items: [
          //     SidebarXItem(
          //       icon: Icons.list_alt,
          //       label: appText.itemList,
          //       onTap: () {
          //         homepageCurrentWidget.value = const MainItemGrid();
          //       },
          //     ),
          //     SidebarXItem(
          //       icon: Icons.grid_view,
          //       label: appText.modList,
          //       onTap: () {
          //         homepageCurrentWidget.value = const MainModGrid();
          //       },
          //     ),
          //     SidebarXItem(
          //       icon: Icons.turned_in,
          //       label: appText.appliedList,
          //       onTap: () {
          //         homepageCurrentWidget.value = const MainAppliedModGrid();
          //       },
          //     ),
          //     SidebarXItem(
          //       icon: Icons.library_books_outlined,
          //       label: appText.modSets,
          //       onTap: () {
          //         homepageCurrentWidget.value = const MainModSetGrid();
          //       },
          //     ),
          //     SidebarXItem(
          //       icon: Icons.swap_horizontal_circle_outlined,
          //       label: appText.itemSwap,
          //       onTap: () {
          //         homepageCurrentWidget.value = const MainItemSwapGrid();
          //       },
          //     ),
          //     SidebarXItem(
          //       icon: Icons.auto_fix_high,
          //       label: appText.aqmInject,
          //       onTap: () {
          //         homepageCurrentWidget.value = const MainItemAqmInjectGrid();
          //       },
          //     ),
          //     SidebarXItem(
          //       icon: Icons.calendar_view_day_sharp,
          //       label: appText.vitalGauge,
          //       onTap: () {
          //         homepageCurrentWidget.value = const MainVitalGaugeGrid();
          //       },
          //     ),
          //   ],
          //   footerDivider: Divider(
          //     height: 5,
          //     thickness: 2,
          //     indent: 3,
          //     endIndent: 3,
          //     color: Theme.of(context).colorScheme.outline,
          //   ),
          //   footerItems: [
          //     SidebarXItem(
          //         icon: Icons.add_circle_outline,
          //         label: appText.addMods,
          //         onTap: () {
          //           homepageCurrentWidget.value = const ModAdd();
          //         }),
          //     SidebarXItem(
          //         icon: Icons.settings,
          //         label: appText.settings,
          //         onTap: () {
          //           homepageCurrentWidget.value = const Settings();
          //         }),
          //   ],
          // ),
          SideMenu(
            style: SideMenuStyle(
              displayMode: SideMenuDisplayMode.auto,
              decoration: BoxDecoration(),
              openSideMenuWidth: 140,
              compactSideMenuWidth: 60,
              hoverColor: Colors.blue[100],
              selectedColor: Colors.lightBlue,
              selectedIconColor: Colors.white,
              unselectedIconColor: Colors.black54,
              backgroundColor: Colors.grey,
              selectedTitleTextStyle: TextStyle(color: Colors.white),
              unselectedTitleTextStyle: TextStyle(color: Colors.black54),
              iconSize: 20,
              itemBorderRadius: const BorderRadius.all(
                Radius.circular(5.0),
              ),
              showTooltip: true,
              showHamburger: true,
              itemHeight: 50.0,
              itemInnerSpacing: 8.0,
              itemOuterPadding: const EdgeInsets.symmetric(horizontal: 5.0),
              toggleColor: Colors.black54,

              // Additional properties for expandable items
              selectedTitleTextStyleExpandable: TextStyle(color: Colors.white), // Adjust the style as needed
              unselectedTitleTextStyleExpandable: TextStyle(color: Colors.black54), // Adjust the style as needed
              selectedIconColorExpandable: Colors.white, // Adjust the color as needed
              unselectedIconColorExpandable: Colors.black54, // Adjust the color as needed
              arrowCollapse: Colors.blueGrey, // Adjust the color as needed
              arrowOpen: Colors.lightBlueAccent, // Adjust the color as needed
              iconSizeExpandable: 24.0, // Adjust the size as needed
            ),
            showToggle: true,
            alwaysShowFooter: true,
            controller: sideMenuController,
            items: [
              SideMenuItem(
                title: appText.addFolders,
                onTap: (index, sideMenuController) {},
              )
              // SideBarButton(
              //             iconData: Icons.list_alt,
              //             label: appText.itemList,
              //             showLabel: false,
              //             selected: sideButtonSlectedIndex == 0,
              //             onPressed: () {
              //               homepageCurrentWidget.value = homepageWidgets[0];
              //               sideButtonSlectedIndex = 0;
              //             },
              //           ),
              //           SideBarButton(
              //             iconData: Icons.grid_view,
              //             label: appText.modList,
              //             showLabel: false,
              //             selected: sideButtonSlectedIndex == 1,
              //             onPressed: () {
              //               homepageCurrentWidget.value = homepageWidgets[1];
              //               sideButtonSlectedIndex = 1;
              //             },
              //           ),
              //           SideBarButton(
              //             iconData: Icons.turned_in,
              //             label: appText.appliedList,
              //             showLabel: false,
              //             selected: sideButtonSlectedIndex == 2,
              //             onPressed: () {
              //               homepageCurrentWidget.value = homepageWidgets[2];
              //               sideButtonSlectedIndex = 2;
              //             },
              //           ),
              //           SideBarButton(
              //             iconData: Icons.library_books_outlined,
              //             label: appText.modSets,
              //             showLabel: false,
              //             selected: sideButtonSlectedIndex == 3,
              //             onPressed: () {
              //               homepageCurrentWidget.value = homepageWidgets[3];
              //               sideButtonSlectedIndex = 3;
              //             },
              //           ),
              //           SideBarButton(
              //             iconData: Icons.swap_horizontal_circle_outlined,
              //             label: appText.itemSwap,
              //             showLabel: false,
              //             selected: sideButtonSlectedIndex == 4,
              //             onPressed: () {
              //               homepageCurrentWidget.value = homepageWidgets[4];
              //               sideButtonSlectedIndex = 4;
              //             },
              //           ),
              //           SideBarButton(
              //             iconData: Icons.auto_fix_high,
              //             label: appText.aqmInject,
              //             showLabel: false,
              //             selected: sideButtonSlectedIndex == 5,
              //             onPressed: () {
              //               homepageCurrentWidget.value = homepageWidgets[5];
              //               sideButtonSlectedIndex = 5;
              //             },
              //           ),
              //           SideBarButton(
              //             iconData: Icons.calendar_view_day_rounded,
              //             label: appText.vitalGauge,
              //             showLabel: false,
              //             selected: sideButtonSlectedIndex == 6,
              //             onPressed: () {
              //               homepageCurrentWidget.value = homepageWidgets[6];
              //               sideButtonSlectedIndex = 6;
              //             },
              //           ),
            ],
          ),
          Expanded(child: Padding(padding: const EdgeInsets.only(top: 5.5, bottom: 5, right: 5), child: homepageCurrentWidget.watch(context)))
        ],
      ),
    );
  }
}
