import 'dart:io';

import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/main_widgets/first_time_popup.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v2_home/homepage_v2.dart';
import 'package:pso2_mod_manager/v3_functions/json_backup.dart';
import 'package:pso2_mod_manager/v3_home/help_page_grid.dart';
import 'package:pso2_mod_manager/v3_home/main_applied_mod_grid.dart';
import 'package:pso2_mod_manager/v3_home/main_item_aqm_inject_grid.dart';
import 'package:pso2_mod_manager/v3_home/main_item_swap_grid.dart';
import 'package:pso2_mod_manager/v3_home/main_line_strike_grid.dart';
import 'package:pso2_mod_manager/v3_home/main_modset_grid.dart';
import 'package:pso2_mod_manager/v3_home/main_vital_gauge_grid.dart';
import 'package:pso2_mod_manager/v3_home/mod_add.dart';
import 'package:pso2_mod_manager/v3_home/main_item_grid.dart';
import 'package:pso2_mod_manager/v3_home/main_mod_grid.dart';
import 'package:pso2_mod_manager/v3_home/settings.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:signals/signals_flutter.dart';
import 'package:path/path.dart' as p;

Signal<Widget> homepageCurrentWidget = Signal(const MainItemGrid());
Signal<bool> sideBarCollapse = Signal<bool>(true);
SideMenuController mainSideMenuController = SideMenuController();
SideMenuController footerSideMenuController = SideMenuController();
List<Widget> homepageWidgets = [
  const MainItemGrid(),
  const MainModGrid(),
  const MainModSetGrid(),
  const MainAppliedModGrid(),
  const MainItemSwapGrid(),
  const MainItemAqmInjectGrid(),
  const MainVitalGaugeGrid(),
  const MainLineStrikeGrid()
];
List<Widget> homepageV2Widgets = [
  const HomepageV2(),
  const MainModGrid(),
  const MainModSetGrid(),
  // const MainAppliedModGrid(),
  const MainItemSwapGrid(),
  const MainItemAqmInjectGrid(),
  const MainVitalGaugeGrid(),
  const MainLineStrikeGrid()
];
List<Widget> homepageFooterWidgets = [const ModAdd(), const Settings(), const HelpPageGrid()];

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  void initState() {
    footerSideMenuController.changePage(-1);
    sideMenuAlwaysExpanded ? sideBarCollapse.value = false : sideBarCollapse.value = true;
    if (!v2Homepage.value) mainSideMenuController.changePage(defaultHomepageIndex);
    homepageCurrentWidget.value = v2Homepage.value ? homepageV2Widgets.first : homepageWidgets[defaultHomepageIndex];
    if (Directory('${Directory.current.path}${p.separator}appUpdate').existsSync()) {
      Directory('${Directory.current.path}${p.separator}appUpdate').deleteSync(recursive: true);
    }

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      appLoadingFinished.value = true;
      await jsonAutoBackup();
      // ignore: use_build_context_synchronously
      if (firstBootUp) firstTimePopup(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Refresh
    if (settingChangeStatus.watch(context) != settingChangeStatus.peek()) {
      setState(
        () {},
      );
    }
    List<String> homepageWidgetNames = [appText.itemList, appText.modList, appText.modSets, appText.appliedList, appText.itemSwap, appText.aqmInject, appText.vitalGauge, appText.lineStrike];
    List<Icon> homepageWidgetIcons = [
      const Icon(Icons.list_alt),
      const Icon(Icons.grid_view),
      const Icon(Icons.library_books_outlined),
      const Icon(Icons.turned_in),
      const Icon(Icons.swap_horizontal_circle_outlined),
      const Icon(Icons.auto_fix_high),
      const Icon(Icons.calendar_view_day_rounded),
      const Icon(Icons.view_carousel_outlined)
    ];
    List<String> homepageV2WidgetNames =
        showAppliedListV2.watch(context) ? [appText.itemList, appText.modList, appText.modSets, appText.itemSwap, appText.aqmInject, appText.vitalGauge, appText.lineStrike] : homepageWidgetNames;
    List<Icon> homepageV2WidgetIcons = showAppliedListV2.watch(context)
        ? [
            const Icon(Icons.list_alt),
            const Icon(Icons.grid_view),
            const Icon(Icons.library_books_outlined),
            // const Icon(Icons.turned_in),
            const Icon(Icons.swap_horizontal_circle_outlined),
            const Icon(Icons.auto_fix_high),
            const Icon(Icons.calendar_view_day_rounded),
            const Icon(Icons.view_carousel_outlined)
          ]
        : homepageWidgetIcons;
    if (showAppliedListV2.value) {
      homepageV2Widgets = [
        const HomepageV2(),
        const MainModGrid(),
        const MainModSetGrid(),
        // const MainAppliedModGrid(),
        const MainItemSwapGrid(),
        const MainItemAqmInjectGrid(),
        const MainVitalGaugeGrid(),
        const MainLineStrikeGrid()
      ];
    } else {
      homepageV2Widgets = [
        const HomepageV2(),
        const MainModGrid(),
        const MainModSetGrid(),
        const MainAppliedModGrid(),
        const MainItemSwapGrid(),
        const MainItemAqmInjectGrid(),
        const MainVitalGaugeGrid(),
        const MainLineStrikeGrid()
      ];
    }

    // footer
    List<String> homepageFooterWidgetNames = [appText.addMods, appText.settings, appText.help];
    List<Icon> homepageFooterWidgetIcon = [
      const Icon(Icons.add_circle_outline_sharp),
      const Icon(Icons.settings),
      const Icon(Icons.help_outline)
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        spacing: 5,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
              padding: const EdgeInsets.only(left: 5, top: 5, bottom: 5),
              child: CardOverlay(
                  paddingValue: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 2),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 5,
                          children: [
                            Icon(modManCurActiveProfile == 1 ? Icons.filter_1 : Icons.filter_2),
                            Text(appText.dText(appText.profileNum, modManCurActiveProfile.toString()), textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                      // top
                      SizedBox(
                        height: MediaQuery.of(context).size.height - 291,
                        child: SideMenu(
                          style: SideMenuStyle(
                            displayMode: sideBarCollapse.watch(context) ? SideMenuDisplayMode.compact : SideMenuDisplayMode.open,
                            openSideMenuWidth: 140,
                            compactSideMenuWidth: 60,
                            hoverColor: Theme.of(context).hoverColor,
                            selectedColor: Theme.of(context).colorScheme.primaryContainer,
                            selectedIconColor: Theme.of(context).iconTheme.color,
                            unselectedIconColor: Theme.of(context).iconTheme.color,
                            selectedTitleTextStyle: Theme.of(context).textTheme.labelLarge,
                            unselectedTitleTextStyle: Theme.of(context).textTheme.labelLarge,
                            iconSize: 20,
                            itemBorderRadius: const BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                            showTooltip: false,
                            showHamburger: false,
                            itemHeight: 40.0,
                            itemInnerSpacing: 6.7,
                            itemOuterPadding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),

                            // Additional properties for expandable items
                            selectedTitleTextStyleExpandable: Theme.of(context).textTheme.labelLarge,
                            unselectedTitleTextStyleExpandable: Theme.of(context).textTheme.labelLarge,
                            selectedIconColorExpandable: Theme.of(context).iconTheme.color,
                            unselectedIconColorExpandable: Theme.of(context).iconTheme.color,
                            arrowCollapse: Colors.blueGrey,
                            arrowOpen: Colors.lightBlueAccent,
                          ),
                          controller: mainSideMenuController,
                          title: const Divider(thickness: 1, height: 5, indent: 5, endIndent: 5),
                          items: v2Homepage.watch(context)
                              ? [
                                  for (int i = 0; i < homepageV2Widgets.length; i++)
                                    SideMenuItem(
                                      icon: homepageV2WidgetIcons[i],
                                      title: homepageV2WidgetNames[i],
                                      onTap: (index, sideMenuController) {
                                        homepageCurrentWidget.value = homepageV2Widgets[i];
                                        footerSideMenuController.changePage(-1);
                                        mainSideMenuController.changePage(index);
                                      },
                                    ),
                                ]
                              : [
                                  for (int i = 0; i < homepageWidgets.length; i++)
                                    SideMenuItem(
                                      icon: homepageWidgetIcons[i],
                                      title: homepageWidgetNames[i],
                                      onTap: (index, sideMenuController) {
                                        homepageCurrentWidget.value = homepageWidgets[i];
                                        footerSideMenuController.changePage(-1);
                                        mainSideMenuController.changePage(index);
                                      },
                                    ),
                                ],
                        ),
                      ),

                      // bottom
                      SizedBox(
                        height: 155,
                        child: SideMenu(
                            style: SideMenuStyle(
                              displayMode: sideBarCollapse.watch(context) ? SideMenuDisplayMode.compact : SideMenuDisplayMode.open,
                              openSideMenuWidth: 140,
                              compactSideMenuWidth: 60,
                              hoverColor: Theme.of(context).hoverColor,
                              selectedColor: Theme.of(context).colorScheme.primaryContainer,
                              selectedIconColor: Theme.of(context).iconTheme.color,
                              unselectedIconColor: Theme.of(context).iconTheme.color,
                              selectedTitleTextStyle: Theme.of(context).textTheme.labelLarge,
                              unselectedTitleTextStyle: Theme.of(context).textTheme.labelLarge,
                              iconSize: 20,
                              itemBorderRadius: const BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                              showTooltip: false,
                              showHamburger: false,
                              itemHeight: 40.0,
                              itemInnerSpacing: 6.7,
                              itemOuterPadding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),

                              // Additional properties for expandable items
                              selectedTitleTextStyleExpandable: Theme.of(context).textTheme.labelLarge,
                              unselectedTitleTextStyleExpandable: Theme.of(context).textTheme.labelLarge,
                              selectedIconColorExpandable: Theme.of(context).iconTheme.color,
                              unselectedIconColorExpandable: Theme.of(context).iconTheme.color,
                            ),
                            title: const Divider(thickness: 1, height: 5, indent: 5, endIndent: 5),
                            items: [
                              for (int i = 0; i < homepageFooterWidgets.length; i++)
                                SideMenuItem(
                                  icon: homepageFooterWidgetIcon[i],
                                  title: homepageFooterWidgetNames[i],
                                  onTap: (index, sideMenuController) {
                                    homepageCurrentWidget.value = homepageFooterWidgets[i];
                                    mainSideMenuController.changePage(-1);
                                    footerSideMenuController.changePage(index);
                                  },
                                )
                            ],
                            controller: footerSideMenuController),
                      ),
                      // expand button
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: IconButton(
                            visualDensity: VisualDensity.adaptivePlatformDensity,
                            style: ButtonStyle(
                                shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ))),
                            onPressed: () {
                              sideBarCollapse.watch(context) ? sideBarCollapse.value = false : sideBarCollapse.value = true;
                              setState(() {});
                            },
                            icon: Icon(sideBarCollapse.watch(context) ? Icons.arrow_forward_ios : Icons.arrow_back_ios_new)),
                      )
                    ],
                  ))),
          Expanded(child: Padding(padding: const EdgeInsets.only(top: 5.5, bottom: 5, right: 5), child: homepageCurrentWidget.watch(context)))
        ],
      ),
    );
  }
}
