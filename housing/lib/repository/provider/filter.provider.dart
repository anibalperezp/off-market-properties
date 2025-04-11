import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';
import 'package:zipcular/models/common/response-service.model.dart';
import 'package:zipcular/models/filter/filter.model.dart';
import 'package:zipcular/models/settings/filter_setting.model.dart';
import 'package:zipcular/repository/facade/filter.facade.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';

class FilterProvider extends ChangeNotifier {
  UserRepository userRepository = UserRepository();
  bool isMap = false;
  String sConcatenation = '';
  String result = 'Apply';
  int nCounterDeals = 0;
  int nCounterTags = 0;
  int nCounterListingCategory = 0;
  bool bIsOffMarketOnly = false;
  bool isLoading = false;
  bool showResults = false;
  String sEastLng = "0";
  String sNorthLat = "0";
  String sWestLng = "0";
  String sSouthLat = "0";
  String nZoom = "0";
  DateTime selectedDate = DateTime.now();
  bool yearBuiltVisibleMin = false;
  bool yearBuiltVisibleMax = false;
  bool priceActiveMax = false;
  bool priceActiveMin = false;
  bool pricesqftActiveMax = false;
  bool pricesqftActiveMin = false;
  bool sqftActiveMax = false;
  bool sqftActiveMin = false;
  bool lotSizeActiveMin = false;
  bool lotSizeActiveMax = false;
  bool daysOnMarketActive = false;
  bool photosActive = false;
  FilterSettingModel? filterSettingsModel;
  List tags = [];

  FilterModel? filterModel = FilterModel(
      nBathrooms: 0,
      nBedrooms: 0,
      nBathroomsMax: 0,
      nBedroomsMax: 0,
      nDaysOnZipCularMax: 0,
      nDaysOnZipCularMin: 0,
      nLotSizeMax: 0,
      nLotSizeMin: 0,
      nPriceMax: 0,
      nPriceMin: 0,
      nPricePerSqftMax: 0,
      nPricePerSqftMin: 0,
      nTotalPhotosMax: 0,
      nTotalPhotosMin: 0,
      nYearBuiltMax: 2023,
      nCountFilter: 0,
      nSqftMax: 0,
      nSqftMin: 0,
      nYearBuiltMin: 1900,
      sLystingStatus: [],
      sPropertyType: [],
      sPropertyCondition: [],
      sTypeOfSell: [],
      sTags: [],
      sLystingCategory: []);

  ///
  /// Services
  ///
  Future<void> fetchFiltersFromDatabase() async {
    filterSettingsModel = initSettingsFilter();
    ResponseService response = await FilterFacade().getDefaultFilter();
    if (response.bSuccess!) {
      this.filterModel = getDefaultFilter(response.data as FilterModel);
      loadInitView();
      updateCounterTypeOfSell();
      updateListingCategories();
      updateTags();
    }
    notifyListeners();
  }

  applyFilter(FilterModel filterObj) async {
    try {
      // Init data
      FilterModel defaultFilter = clearFilter();
      sEastLng = await userRepository.readKey('sEastLng');
      sNorthLat = await userRepository.readKey('sNorthLat');
      sWestLng = await userRepository.readKey('sWestLng');
      sSouthLat = await userRepository.readKey('sSouthLat');
      nZoom = await userRepository.readKey('nZoom');

      //set information to filter
      defaultFilter.nLotSizeMin = filterObj.nLotSizeMin;
      if (filterObj.nLotSizeMax == filterSettingsModel!.nLotSizeMax) {
        defaultFilter.nLotSizeMax = 24;
      } else {
        defaultFilter.nLotSizeMax = filterObj.nLotSizeMax;
      }

      defaultFilter.nYearBuiltMin = filterObj.nYearBuiltMin;
      if (filterObj.nYearBuiltMax >= DateTime.now().year) {
        defaultFilter.nYearBuiltMax = 2050;
      } else {
        defaultFilter.nYearBuiltMax = filterObj.nYearBuiltMax;
      }

      if (filterObj.nPriceMin == filterSettingsModel!.nPriceMin) {
        defaultFilter.nPriceMin = 0;
      } else {
        defaultFilter.nPriceMin = filterObj.nPriceMin;
      }

      if (filterObj.nPriceMax == filterSettingsModel!.nPriceMax) {
        defaultFilter.nPriceMax = 50000000;
      } else {
        defaultFilter.nPriceMax = filterObj.nPriceMax - 1;
      }

      if (filterObj.nDaysOnZipCularMin ==
          filterSettingsModel!.nDaysOnZipCularMin) {
        defaultFilter.nDaysOnZipCularMin = 0;
      } else {
        defaultFilter.nDaysOnZipCularMin = filterObj.nDaysOnZipCularMin;
      }

      if (filterObj.nDaysOnZipCularMax ==
          filterSettingsModel!.nDaysOnZipCularMax) {
        defaultFilter.nDaysOnZipCularMax = 100000;
      } else {
        defaultFilter.nDaysOnZipCularMax = filterObj.nDaysOnZipCularMax;
      }

      defaultFilter.nPricePerSqftMin = filterObj.nPricePerSqftMin;
      if (filterObj.nPricePerSqftMax == filterSettingsModel!.nPricePerSqftMax) {
        defaultFilter.nPricePerSqftMax = 50000;
      } else {
        defaultFilter.nPricePerSqftMax = filterObj.nPricePerSqftMax;
      }

      defaultFilter.nTotalPhotosMin = filterObj.nTotalPhotosMin;
      if (filterObj.nTotalPhotosMax == filterSettingsModel!.nTotalPhotosMax) {
        defaultFilter.nTotalPhotosMax = 50;
      } else {
        defaultFilter.nTotalPhotosMax = filterObj.nTotalPhotosMax;
      }

      if (filterObj.nSqftMin == filterSettingsModel!.nSqftMin) {
        defaultFilter.nSqftMin = 0;
      } else {
        defaultFilter.nSqftMin = filterObj.nSqftMin;
      }

      if (filterObj.nSqftMax == filterSettingsModel!.nSqftMax) {
        defaultFilter.nSqftMax = 300000;
      } else {
        defaultFilter.nSqftMax = filterObj.nSqftMax - 1;
      }

      defaultFilter.sPropertyType =
          filterObj.sPropertyType.any((element) => element == "Any")
              ? [
                  "Apartment",
                  "Condo",
                  "Lot",
                  "Multi-Unit Complex",
                  "Single Family",
                  "Townhome"
                ]
              : filterObj.sPropertyType;

      defaultFilter.sLystingStatus =
          filterObj.sLystingStatus.any((element) => element == "Any")
              ? ["For Sale", "Sold", "Pending"]
              : filterObj.sLystingStatus;

      defaultFilter.nBathroomsMax = filterObj.nBathrooms
              .any((element) => element == "4+" || element == "Any")
          ? 4
          : 0;

      defaultFilter.nBathrooms =
          filterObj.nBathrooms.any((element) => element == "Any")
              ? ["0", "1", "2", "3"]
              : filterObj.nBathrooms;

      defaultFilter.nBedroomsMax = filterObj.nBedrooms
              .any((element) => element == "5+" || element == "Any")
          ? 5
          : 0;

      defaultFilter.nBedrooms =
          filterObj.nBedrooms.any((element) => element == "Any")
              ? ["0", "1", "2", "3", "4"]
              : filterObj.nBedrooms;

      defaultFilter.sPropertyCondition =
          filterObj.sPropertyCondition.any((element) => element == "Any")
              ? ["Average", "Bad", "Excellent", "Good", "Poor", "None"]
              : filterObj.sPropertyCondition;

      defaultFilter.sTypeOfSell =
          filterObj.sTypeOfSell.any((element) => element == "Any")
              ? [
                  "Fixer Upper",
                  "Tenant Occupied Rental",
                  "Seller Financing",
                  "Lease to Own",
                  "Rent to Own",
                  "Short Term Rental"
                ]
              : filterObj.sTypeOfSell;

      defaultFilter.sLystingCategory =
          filterObj.sLystingCategory.any((element) => element == "Any")
              ? []
              : filterObj.sLystingCategory;

      defaultFilter.sTags = filterObj.sTags.length == 0 ? [] : filterObj.sTags;

      ResponseService response = await FilterFacade().applyFilter(
          defaultFilter,
          isMap,
          sConcatenation,
          sWestLng,
          sSouthLat,
          sEastLng,
          sNorthLat,
          nZoom);

      if (response.bSuccess!) {
        filterObj.nCountFilter = int.tryParse(response.data.item2)!;
        var lerfilter = getDefaultFilter(filterObj);
        result = "View " + response.data.item1 + ' Results';
        showResults = true;
        filterModel = lerfilter;
        updateCounterTypeOfSell();
        updateListingCategories();
        updateTags();
        isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
    }
  }

  // Update local Counters
  updateCounterTypeOfSell() {
    nCounterDeals = filterModel!.sTypeOfSell.any((element) => element == "Any")
        ? 0
        : filterModel!.sTypeOfSell.length;
    notifyListeners();
  }

  updateListingCategories() {
    nCounterListingCategory =
        filterModel!.sLystingCategory.any((element) => element == "Any")
            ? 0
            : 1;
    notifyListeners();
  }

  updateTags() {
    nCounterTags = filterModel!.sTags.length;
    notifyListeners();
  }

  ///
  /// Services End
  ///
  loadInitView() {
    this.daysOnMarketActive = this.filterModel!.nDaysOnZipCularMax >
            this.filterSettingsModel!.nDaysOnZipCularMin! &&
        this.filterModel!.nDaysOnZipCularMax <
            this.filterSettingsModel!.nDaysOnZipCularMax!;

    this.priceActiveMin =
        this.filterModel!.nPriceMin > this.filterSettingsModel!.nPriceMin! &&
            this.filterModel!.nPriceMin < this.filterSettingsModel!.nPriceMax!;

    this.priceActiveMax =
        this.filterModel!.nPriceMax > this.filterSettingsModel!.nPriceMin! &&
            this.filterModel!.nPriceMax < this.filterSettingsModel!.nPriceMax!;

    this.pricesqftActiveMin = this.filterModel!.nPricePerSqftMin >
            this.filterSettingsModel!.nPricePerSqftMin! &&
        this.filterModel!.nPricePerSqftMin <
            this.filterSettingsModel!.nPricePerSqftMax!;

    this.pricesqftActiveMax = this.filterModel!.nPricePerSqftMax >
            this.filterSettingsModel!.nPricePerSqftMin! &&
        this.filterModel!.nPricePerSqftMax <
            this.filterSettingsModel!.nPricePerSqftMax!;

    this.sqftActiveMin =
        this.filterModel!.nSqftMin > this.filterSettingsModel!.nSqftMin! &&
            this.filterModel!.nSqftMin < this.filterSettingsModel!.nSqftMax!;

    this.sqftActiveMax =
        this.filterModel!.nSqftMax > this.filterSettingsModel!.nSqftMin! &&
            this.filterModel!.nSqftMax < this.filterSettingsModel!.nSqftMax!;

    this.lotSizeActiveMin = this.filterModel!.nLotSizeMin >
            this.filterSettingsModel!.nLotSizeMin! &&
        this.filterModel!.nLotSizeMin < this.filterSettingsModel!.nLotSizeMax!;

    this.lotSizeActiveMax = this.filterModel!.nLotSizeMax >
            this.filterSettingsModel!.nLotSizeMin! &&
        this.filterModel!.nLotSizeMax < this.filterSettingsModel!.nLotSizeMax!;

    this.yearBuiltVisibleMin = this.filterModel!.nYearBuiltMin >
            this.filterSettingsModel!.nYearBuiltMin! &&
        this.filterModel!.nYearBuiltMin <
            this.filterSettingsModel!.nYearBuiltMax!;

    this.yearBuiltVisibleMax = this.filterModel!.nYearBuiltMax >
            this.filterSettingsModel!.nYearBuiltMin! &&
        this.filterModel!.nYearBuiltMax <
            this.filterSettingsModel!.nYearBuiltMax!;

    this.photosActive = this.filterSettingsModel!.nTotalPhotosMin! !=
        filterModel!.nTotalPhotosMin;
  }
  ////////////////////////////

  ///
  /// Init Filter
  ///

  initSettingsFilter() {
    FilterSettingModel filterSettingModel = new FilterSettingModel(
        nPriceMin: 1,
        nPriceMax: 1000001,
        nYearBuiltMin: 1900,
        nYearBuiltMax: DateTime.now().year,
        nSqftMin: 1,
        nSqftMax: 7001,
        nPricePerSqftMin: 0,
        nPricePerSqftMax: 700,
        nBedrooms: ["Any", "1", "2", "3", "4", "5+"],
        nBedroomsMax: 5,
        nBathrooms: ["Any", "1", "2", "3", "4+"],
        nBathroomsMax: 4,
        sLystingStatus: ["Any", "For Sale", "Sold", "Pending"],
        sPropertyType: [
          "Any",
          "Single Family",
          "Apartment",
          "Condo",
          "Townhome",
          "Lot",
          "Multi-Unit Complex"
        ],
        sTypeOfSell: [
          "Any",
          "Fixer Upper",
          "Tenant Occupied Rental",
          "Seller Financing",
          "Lease to Own",
          "Rent to Own",
          "Short Term Rental"
        ],
        sPropertyCondition: [
          "Any",
          "Bad",
          "Poor",
          "Average",
          "Good",
          "Excellent"
        ],
        nLotSizeMin: 1,
        nLotSizeMax: 24,
        nTotalPhotosMin: 0,
        nTotalPhotosMax: 30,
        nDaysOnZipCularMin: 0,
        nDaysOnZipCularMax: 30,
        sTags: tags,
        sLystingCategory: ['Any', 'Off-Market']);
    return filterSettingModel;
  }

  getDefaultFilter(FilterModel defaultFilter) {
    try {
      if (defaultFilter.nYearBuiltMax >= DateTime.now().year) {
        defaultFilter.nYearBuiltMax = DateTime.now().year;
      }

      if (defaultFilter.nPriceMin == 0) {
        defaultFilter.nPriceMin = filterSettingsModel!.nPriceMin!;
      }
      if (defaultFilter.nPriceMax > filterSettingsModel!.nPriceMax!) {
        defaultFilter.nPriceMax = filterSettingsModel!.nPriceMax!;
      }
      if (defaultFilter.nPricePerSqftMax >
          filterSettingsModel!.nPricePerSqftMax!) {
        defaultFilter.nPricePerSqftMax = filterSettingsModel!.nPricePerSqftMax!;
      }
      if (defaultFilter.nSqftMin == 0) {
        defaultFilter.nSqftMin = filterSettingsModel!.nSqftMin!;
      }
      if (defaultFilter.nSqftMax > filterSettingsModel!.nSqftMax!) {
        defaultFilter.nSqftMax = filterSettingsModel!.nSqftMax!;
      }
      if (defaultFilter.nTotalPhotosMax >
          filterSettingsModel!.nTotalPhotosMax!) {
        defaultFilter.nTotalPhotosMax = filterSettingsModel!.nTotalPhotosMax!;
      }
      if (defaultFilter.nDaysOnZipCularMax >=
          filterSettingsModel!.nDaysOnZipCularMax!) {
        defaultFilter.nDaysOnZipCularMax = 30;
      }

      defaultFilter.sPropertyType = defaultFilter.sPropertyType.length == 0 ||
              filterSettingsModel!.sPropertyType!.length - 1 ==
                  defaultFilter.sPropertyType.length
          ? ["Any"]
          : List<String>.from(defaultFilter.sPropertyType.toList());

      defaultFilter.sLystingStatus = defaultFilter.sLystingStatus.length == 0 ||
              filterSettingsModel!.sLystingStatus.length - 1 ==
                  defaultFilter.sLystingStatus.length
          ? ["Any"]
          : List<String>.from(defaultFilter.sLystingStatus.toList());

      defaultFilter.sTypeOfSell = defaultFilter.sTypeOfSell.length == 0 ||
              filterSettingsModel!.sTypeOfSell.length - 1 ==
                  defaultFilter.sTypeOfSell.length
          ? ["Any"]
          : List<String>.from(defaultFilter.sTypeOfSell);

      defaultFilter.sLystingCategory =
          defaultFilter.sLystingCategory.length == 0
              ? ["Any"]
              : List<String>.from(defaultFilter.sLystingCategory);

      defaultFilter.nBathrooms = (defaultFilter.nBathrooms.length == 0 ||
                  filterSettingsModel!.nBathrooms.length - 2 ==
                      defaultFilter.nBathrooms.length) &&
              defaultFilter.nBathroomsMax == 4
          ? ["Any"]
          : List<String>.from(defaultFilter.nBathrooms.toList());

      defaultFilter.nBedrooms = (defaultFilter.nBedrooms.length == 0 ||
                  filterSettingsModel!.nBedrooms.length - 2 ==
                      defaultFilter.nBedrooms.length) &&
              defaultFilter.nBedroomsMax == 5
          ? ["Any"]
          : List<String>.from(defaultFilter.nBedrooms.toList());

      defaultFilter.sPropertyCondition =
          defaultFilter.sPropertyCondition?.length == 0 ||
                  filterSettingsModel!.sPropertyCondition.length - 1 ==
                      defaultFilter.sPropertyCondition.length
              ? ["Any"]
              : List<String>.from(defaultFilter.sPropertyCondition.toList());
    } catch (e) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      });
    }

    return defaultFilter;
  }

  clearFilter() {
    return FilterModel(
        nBathrooms: 0,
        nBedrooms: 0,
        nBathroomsMax: 0,
        nBedroomsMax: 0,
        nDaysOnZipCularMax: 0,
        nDaysOnZipCularMin: 0,
        nLotSizeMax: 0,
        nLotSizeMin: 0,
        nPriceMax: 0,
        nPriceMin: 0,
        nPricePerSqftMax: 0,
        nPricePerSqftMin: 0,
        nTotalPhotosMax: 0,
        nTotalPhotosMin: 0,
        nYearBuiltMax: 2023,
        nCountFilter: 0,
        nSqftMax: 0,
        nSqftMin: 0,
        nYearBuiltMin: 1900,
        sLystingStatus: [],
        sPropertyType: [],
        sPropertyCondition: [],
        sTypeOfSell: [],
        sTags: [],
        sLystingCategory: []);
  }

  resetFilter() async {
    //Initializing active flags

    sEastLng = await userRepository.readKey('sEastLng');
    sNorthLat = await userRepository.readKey('sNorthLat');
    sWestLng = await userRepository.readKey('sWestLng');
    sSouthLat = await userRepository.readKey('sSouthLat');
    nZoom = await userRepository.readKey('nZoom');

    this.yearBuiltVisibleMin = false;
    this.yearBuiltVisibleMax = false;
    this.priceActiveMax = false;
    this.priceActiveMin = false;
    this.pricesqftActiveMax = false;
    this.pricesqftActiveMin = false;
    this.sqftActiveMax = false;
    this.sqftActiveMin = false;
    this.lotSizeActiveMin = false;
    this.lotSizeActiveMax = false;
    this.daysOnMarketActive = false;
    this.photosActive = false;

    //set information to filter
    filterModel!.nLotSizeMin = 1;
    filterModel!.nLotSizeMax = 24;
    filterModel!.nYearBuiltMin = 1900;
    filterModel!.nYearBuiltMax = 2050;
    filterModel!.nPriceMin = 0;
    filterModel!.nPriceMax = 50000000;
    filterModel!.nDaysOnZipCularMin = 0;
    filterModel!.nDaysOnZipCularMax = 100000;
    filterModel!.nPricePerSqftMin = 0;
    filterModel!.nPricePerSqftMax = 50000;
    filterModel!.nTotalPhotosMin = 0;
    filterModel!.nTotalPhotosMax = 50;
    filterModel!.nSqftMin = 0;
    filterModel!.nSqftMax = 300000;
    filterModel!.sPropertyType = [
      "Apartment",
      "Condo",
      "Lot",
      "Multi-Unit Complex",
      "Single Family",
      "Townhome"
    ];
    filterModel!.sLystingStatus = ["For Sale", "Sold", "Pending"];
    filterModel!.nBathroomsMax = 4;
    filterModel!.nBathrooms = ["0", "1", "2", "3"];
    filterModel!.nBedroomsMax = 5;
    filterModel!.nBedrooms = ["0", "1", "2", "3", "4"];
    filterModel!.sPropertyCondition = [
      "Average",
      "Bad",
      "Excellent",
      "Good",
      "Poor",
      "None"
    ];
    filterModel!.sTypeOfSell = [
      "Fixer Upper",
      "Tenant Occupied Rental",
      "Seller Financing",
      "Lease to Own",
      "Rent to Own",
      "Short Term Rental"
    ];
    filterModel!.sLystingCategory = [];
    filterModel!.sTags = [];
    filterModel!.nCountFilter = 0;

    final response = await FilterFacade().applyFilter(filterModel!, isMap,
        sConcatenation, sWestLng, sSouthLat, sEastLng, sNorthLat, nZoom);
    result = "View " + response.data.item1 + ' Results';

    //Initializing filter model
    filterModel!.nPriceMin = this.filterSettingsModel!.nPriceMin!;
    filterModel!.nPriceMax = this.filterSettingsModel!.nPriceMax!;
    filterModel!.nPricePerSqftMin = this.filterSettingsModel!.nPricePerSqftMin!;
    filterModel!.nPricePerSqftMax = this.filterSettingsModel!.nPricePerSqftMax!;
    filterModel!.nSqftMin = this.filterSettingsModel!.nSqftMin!;
    filterModel!.nSqftMax = this.filterSettingsModel!.nSqftMax!;
    filterModel!.nYearBuiltMin = this.filterSettingsModel!.nYearBuiltMin!;
    filterModel!.nYearBuiltMax = this.filterSettingsModel!.nYearBuiltMax!;
    filterModel!.nTotalPhotosMin = this.filterSettingsModel!.nTotalPhotosMin!;
    filterModel!.nTotalPhotosMax = this.filterSettingsModel!.nTotalPhotosMax!;
    filterModel!.nDaysOnZipCularMin =
        this.filterSettingsModel!.nDaysOnZipCularMin!;
    filterModel!.nDaysOnZipCularMax =
        this.filterSettingsModel!.nDaysOnZipCularMax!;
    filterModel!.nLotSizeMin = this.filterSettingsModel!.nLotSizeMin!;
    filterModel!.nLotSizeMax = this.filterSettingsModel!.nLotSizeMax!;
    filterModel!.sPropertyType = ["Any"];
    filterModel!.sLystingStatus = ["Any"];
    filterModel!.sTypeOfSell = ["Any"];
    filterModel!.nBathrooms = ["Any"];
    filterModel!.nBedrooms = ["Any"];
    filterModel!.sPropertyCondition = ["Any"];
    filterModel!.sTags = [];
    filterModel!.sLystingCategory = ["Any"];
    filterModel!.nCountFilter = 0;
    nCounterDeals = 0;
    nCounterListingCategory = 0;
    nCounterTags = 0;
    updateCounterTypeOfSell();
    updateListingCategories();
    updateTags();
    isLoading = false;
    notifyListeners();
  }

  /////////////////////////////////
  /// Update local
  ///

  updatePriceActiveMin(bool value) {
    priceActiveMin = value;
    notifyListeners();
  }

  updatePriceActiveMax(bool value) {
    priceActiveMax = value;
    notifyListeners();
  }

  updatePricesqftActiveMinUpdate(bool value) {
    pricesqftActiveMin = value;
    notifyListeners();
  }

  updatePricesqftActiveMax(bool value) {
    pricesqftActiveMax = value;
    notifyListeners();
  }

  updateSqftActiveMin(bool value) {
    sqftActiveMin = value;
    notifyListeners();
  }

  updateSqftActiveMax(bool value) {
    sqftActiveMax = value;
    notifyListeners();
  }

  updateLotsSizeActiveMin(bool value) {
    lotSizeActiveMin = value;
    notifyListeners();
  }

  updateLotsSizeActiveMax(bool value) {
    lotSizeActiveMax = value;
    notifyListeners();
  }

  updateYearBuiltVisibleMin(bool value) {
    yearBuiltVisibleMin = value;
    notifyListeners();
  }

  updateYearBuiltVisibleMax(bool value) {
    yearBuiltVisibleMax = value;
    notifyListeners();
  }

  updatePhotosActive(bool value) {
    photosActive = value;
    notifyListeners();
  }

  updateLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  updateDaysOnMarketActive(bool value) {
    daysOnMarketActive = value;
    notifyListeners();
  }

  updateSystemTags(List value) {
    tags = value;
    notifyListeners();
  }

  updateShowResults(bool value) {
    showResults = value;
    result = 'Apply';
    notifyListeners();
  }
}
