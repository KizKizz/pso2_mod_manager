import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_home/main_applied_mod_grid.dart';
import 'package:pso2_mod_manager/v3_home/main_item_aqm_inject_grid.dart';
import 'package:pso2_mod_manager/v3_home/main_item_swap_grid.dart';
import 'package:pso2_mod_manager/v3_home/main_modset_grid.dart';
import 'package:pso2_mod_manager/v3_home/main_vital_gauge_grid.dart';
import 'package:pso2_mod_manager/v3_home/mod_add.dart';
import 'package:pso2_mod_manager/v3_home/main_item_grid.dart';
import 'package:pso2_mod_manager/v3_home/main_mod_grid.dart';
import 'package:pso2_mod_manager/v3_home/settings.dart';
import 'package:signals/signals_flutter.dart';

Signal<Widget> homepageCurrentWidget = Signal(const MainItemGrid());
bool sideBarCollapse = true;
SideMenuController mainSideMenuController = SideMenuController();
SideMenuController footerSideMenuController = SideMenuController();
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
    List<String> homepageWidgetNames = [appText.itemList, appText.modList, appText.appliedList, appText.modSets, appText.itemSwap, appText.aqmInject, appText.vitalGauge];
    List<Icon> homepageWidgetIcons = [
      const Icon(Icons.list_alt),
      const Icon(Icons.grid_view),
      const Icon(Icons.turned_in),
      const Icon(Icons.library_books_outlined),
      const Icon(Icons.swap_horizontal_circle_outlined),
      const Icon(Icons.auto_fix_high),
      const Icon(Icons.calendar_view_day_rounded),
    ];
    List<String> homepageFooterWidgetNames = [appText.addMods, appText.settings];
    List<Icon> homepageFooterWidgetIcon = [
      const Icon(Icons.add_circle_outline_sharp),
      const Icon(Icons.settings),
    ];
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        spacing: 5,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5, top: 5, bottom: 5),
            child: SideMenu(
                style: SideMenuStyle(
                  displayMode: sideBarCollapse ? SideMenuDisplayMode.compact : SideMenuDisplayMode.open,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer.withAlpha(uiBackgroundColorAlpha.watch(context)),
                      boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withAlpha(50), spreadRadius: 2, blurRadius: 3, offset: const Offset(2, 2))],
                      border: Border.all(width: 1.5, color: Theme.of(context).colorScheme.outline),
                      borderRadius: const BorderRadius.all(Radius.circular(10))),
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
                  itemInnerSpacing: 6.5,
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
                title: Padding(
                  padding: const EdgeInsets.only(top: 10, left: 2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 5,
                    children: [
                      Icon(modManCurActiveProfile == 1 ? Icons.filter_1 : Icons.filter_2),
                      Text(appText.dText(appText.profileNum, modManCurActiveProfile.toString()), textAlign: TextAlign.center),
                      const Divider(thickness: 1, height: 5, indent: 5, endIndent: 5)
                    ],
                  ),
                ),
                items: [
                  for (int i = 0; i < homepageWidgets.length; i++)
                    SideMenuItem(
                      icon: homepageWidgetIcons[i],
                      title: homepageWidgetNames[i],
                      onTap: (index, sideMenuController) {
                        homepageCurrentWidget.value = homepageWidgets[i];
                        footerSideMenuController.changePage(-1);
                        mainSideMenuController.changePage(index);
                      },
                    )
                ],
                alwaysShowFooter: true,
                footer: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 100,
                      child: SideMenu(
                          style: SideMenuStyle(
                            displayMode: sideBarCollapse ? SideMenuDisplayMode.compact : SideMenuDisplayMode.open,
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
                            itemInnerSpacing: 6.5,
                            itemOuterPadding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),

                            // Additional properties for expandable items
                            selectedTitleTextStyleExpandable: Theme.of(context).textTheme.labelLarge,
                            unselectedTitleTextStyleExpandable: Theme.of(context).textTheme.labelLarge,
                            selectedIconColorExpandable: Theme.of(context).iconTheme.color,
                            unselectedIconColorExpandable: Theme.of(context).iconTheme.color,
                            
                          ),
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
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: SizedBox(
                        width: double.infinity,
                        child: IconButton(
                            visualDensity: VisualDensity.adaptivePlatformDensity,
                            style: ButtonStyle(
                                shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ))),
                            onPressed: () {
                              sideBarCollapse ? sideBarCollapse = false : sideBarCollapse = true;
                              setState(() {});
                            },
                            icon: Icon(sideBarCollapse ? Icons.arrow_forward_ios : Icons.arrow_back_ios)),
                      ),
                    )
                  ],
                )),
          ),
          Expanded(child: Padding(padding: const EdgeInsets.only(top: 5.5, bottom: 5, right: 5), child: homepageCurrentWidget.watch(context)))
        ],
      ),
    );
  }
}
