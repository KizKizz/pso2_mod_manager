import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/system_loads/app_github_access_page.dart';
import 'package:pso2_mod_manager/system_loads/app_locale_page.dart';
import 'package:pso2_mod_manager/system_loads/app_mod_load_page.dart';
import 'package:pso2_mod_manager/system_loads/app_path_page.dart';
import 'package:pso2_mod_manager/system_loads/app_update_page.dart';
import 'package:pso2_mod_manager/system_loads/official_data_fetch_page.dart';
import 'package:pso2_mod_manager/system_loads/player_data_load_page.dart';
import 'package:pso2_mod_manager/system_loads/player_data_update_page.dart';
import 'package:pso2_mod_manager/v3_home/homepage.dart';
import 'package:signals/signals_flutter.dart';

Signal<Widget> curPage = Signal(appPages[pageIndex]);
int pageIndex = 0;
final List<Widget> appPages = [const AppGitHubAccessPage(), const LocalePage(), const AppUpdatePage(), const DataUpdatePage(), const OfficialDataFetchPage(), const PlayerDataLoadPage(), const AppPathPage(), const AppModLoadPage(), const Homepage()];