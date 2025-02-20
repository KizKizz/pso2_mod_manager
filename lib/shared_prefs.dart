import 'dart:ui';

import 'package:pso2_mod_manager/app_colorscheme.dart';
import 'package:pso2_mod_manager/app_localization/item_locale.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/settings/other_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';

bool firstBootUp = true;
ItemNameLanguage itemNameLanguage = ItemNameLanguage.en;
String appVersionUpdateSkip = '';
AppThemeMode appThemeMode = AppThemeMode.dark;
Signal<int> uiBackgroundColorAlpha = Signal<int>(150);
Color lightModeSeedColor = lightColorScheme.primary;
Color darkModeSeedColor = darkColorScheme.primary;
Signal<bool> hideAppBackgroundSlides = Signal<bool>(false);
Signal<int> backgroundImageSlideInterval = Signal<int>(10);
Signal<bool> itemIconSlides = Signal<bool>(false);
Signal<String> selectedDisplayCategory = Signal<String>('All');
Signal<String> selectedModDisplayCategory = Signal<String>('All');
Signal<String> selectedDisplayCategoryAppliedList = Signal<String>('All');
Signal<String> selectedDisplaySort = Signal<String>('Name (Alphabetical)');
Signal<String> selectedDisplaySortModSet = Signal<String>('Name (Alphabetical)');
bool originalFilesBackupsFromSega = true;
double boundingRadiusRemovalValue = -10;
Signal<String> selectedCustomAQMFilePath = Signal('');
bool removeProfanityFilter = false;
bool replaceItemIconOnApplied = true;
bool sideMenuAlwaysExpanded = false;
bool enableModAddFilters = false;
int defaultHomepageIndex = 0;
bool hideEmptyCategories = true;
bool modAddCategorizeModsByItems = true;
Signal<bool> showPreviewBox = Signal(true);

int modManCurActiveProfile = 1;
String pso2binDirPath = '';
String mainDataDirPath = '';
String verTwoMainDataDirPath = '';

// Auto features
bool autoBoundingRadiusRemoval = false;
bool autoInjectCustomAqm = false;

Future<void> prefsLoad() async {
  final prefs = await SharedPreferences.getInstance();

  // First time boot
  firstBootUp = prefs.getBool('firstBootUp') ?? true;

  // ver 2 main data dir path
  verTwoMainDataDirPath = prefs.getString('mainModManDirPath') ?? '';

  // Item Name Language
  itemNameLanguage = ItemNameLanguage.values.firstWhere((e) => e.value == prefs.getString('itemNameLanguage'), orElse: () => ItemNameLanguage.en);

  // App Version Update Skip
  appVersionUpdateSkip = prefs.getString('appVersionUpdateSkip') ?? '';

  // Active Profile
  modManCurActiveProfile = prefs.getInt('modManCurActiveProfile') ?? 1;

  // pso2bin dir path
  pso2binDirPath = modManCurActiveProfile == 1 ? prefs.getString('pso2binDirPath') ?? '' : prefs.getString('pso2binDirPath_profile2') ?? '';

  // Main dir path
  mainDataDirPath = prefs.getString('mainDataDirPath') ?? '';

  // Main UI alpha
  uiBackgroundColorAlpha.value = prefs.getInt('uiBackgroundColorAlpha') ?? 150;

  // Aux UI alpha
  uiDialogBackgroundColorAlpha.value = prefs.getInt('uiDialogBackgroundColorAlpha') ?? 180;

  // App Theme Mode
  appThemeMode = AppThemeMode.values.firstWhere((e) => e.value == prefs.getString('appThemeMode'), orElse: () => AppThemeMode.dark);

  // Hide App background slides
  hideAppBackgroundSlides.value = prefs.getBool('hideAppBackgroundSlides') ?? false;

  // Background image slide interval
  backgroundImageSlideInterval.value = prefs.getInt('backgroundImageSlideInterval') ?? 10;

  // Item icon slides
  itemIconSlides.value = prefs.getBool('itemIconSlides') ?? false;

  // Main list filter
  selectedDisplayCategory.value = prefs.getString('selectedDisplayCategory') ?? 'All';

  // Main Mod list filter
  selectedModDisplayCategory.value = prefs.getString('selectedModDisplayCategory') ?? 'All';

  // Main list applied list filter
  selectedDisplayCategoryAppliedList.value = prefs.getString('selectedDisplayCategoryAppliedList') ?? 'All';

  // Main list sort
  selectedDisplaySort.value = prefs.getString('selectedDisplaySort') ?? 'Name (Alphabetical)';

  // Mod set list sort
  selectedDisplaySortModSet.value = prefs.getString('selectedDisplaySortModSet') ?? 'Name (Alphabetical)';

  // Color schemes
  final lightModeSeedColorValue = prefs.getStringList('lightModeSeedColorValue') ??
      [lightColorScheme.primary.r.toString(), lightColorScheme.primary.g.toString(), lightColorScheme.primary.b.toString(), lightColorScheme.primary.a.toString()];
  lightModeSeedColor = Color.from(
      red: double.parse(lightModeSeedColorValue[0]), green: double.parse(lightModeSeedColorValue[1]), blue: double.parse(lightModeSeedColorValue[2]), alpha: double.parse(lightModeSeedColorValue[3]));
  final darkModeSeedColorValue = prefs.getStringList('darkModeSeedColorValue') ??
      [darkColorScheme.primary.r.toString(), darkColorScheme.primary.g.toString(), darkColorScheme.primary.b.toString(), darkColorScheme.primary.a.toString()];
  darkModeSeedColor = Color.from(
      red: double.parse(darkModeSeedColorValue[0]), green: double.parse(darkModeSeedColorValue[1]), blue: double.parse(darkModeSeedColorValue[2]), alpha: double.parse(darkModeSeedColorValue[3]));

  // Backup priority
  originalFilesBackupsFromSega = prefs.getBool('originalFilesBackupsFromSega') ?? true;

  // Bounding radius value
  boundingRadiusRemovalValue = prefs.getDouble('boundingRadiusRemovalValue') ?? -10;

  // Auto bounding radius
  autoBoundingRadiusRemoval = prefs.getBool('autoBoundingRadiusRemoval') ?? false;

  // Selected custom AQM File Path
  selectedCustomAQMFilePath.value = prefs.getString('selectedCustomAQMFilePath') ?? '';

  // Auto inject custom aqm
  autoInjectCustomAqm = prefs.getBool('autoInjectCustomAqm') ?? false;

  // Remove profanity
  removeProfanityFilter = prefs.getBool('removeProfanityFilter') ?? false;

  // Mark modded items
  replaceItemIconOnApplied = prefs.getBool('replaceItemIconOnApplied') ?? true;

  // Mark modded items
  sideMenuAlwaysExpanded = prefs.getBool('sideMenuAlwaysExpanded') ?? false;

  // Mod add filter
  enableModAddFilters = prefs.getBool('enableModAddFilters') ?? false;

  // Default homepage
  defaultHomepageIndex = prefs.getInt('defaultHomepageIndex') ?? 0;

  // Hide empty categories
  hideEmptyCategories = prefs.getBool('hideEmptyCategories') ?? true;

  // categorize by items
  modAddCategorizeModsByItems = prefs.getBool('modAddCategorizeModsByItems') ?? true;
  
  // show previwe box
  showPreviewBox.value = prefs.getBool('showPreviewBox') ?? true;
}
