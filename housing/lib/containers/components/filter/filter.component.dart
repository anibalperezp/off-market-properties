import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker_fork/flutter_cupertino_date_picker_fork.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:zipcular/commons/analytics.service.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/containers/widgets/common/button_group_spaced.dart';
import 'package:zipcular/containers/widgets/common/og_tab.dart';
import 'package:zipcular/models/filter/filter.model.dart';
import 'package:zipcular/repository/provider/filter.provider.dart';

class Filter extends StatefulWidget {
  Filter({Key? key}) : super(key: key);

  @override
  _FilterState createState() {
    return new _FilterState();
  }
}

class _FilterState extends State<Filter> {
  FilterModel filterModel = FilterModel(
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
    sLystingCategory: [],
  );

  final format = new NumberFormat("#,###,###", "en_US");

  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget widgetObj = Container();
    try {
      widgetObj = Consumer<FilterProvider>(
        builder: (context, filterProvider, child) {
          filterModel = filterProvider.filterModel!;
          return Scaffold(
            appBar: AppBar(
              leading: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
              title: Text("Filters",
                  style: TextStyle(fontSize: 19, color: Colors.white)),
              backgroundColor: headerColor,
              toolbarHeight: 45,
              actions: [
                InkWell(
                  onTap: () async {
                    await AnalitysService().sendAnalyticsEvent(
                        'filter_reset_click', {
                      "screen_view": "filter_screen",
                      "item_id": 'empty',
                      'item_type': 'empty'
                    });
                    filterProvider.resetFilter();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.center,
                    child: Text(
                      "Reset",
                      style: TextStyle(fontSize: 19, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10.0,
                )
              ],
            ),
            body: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15.0),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    child: Container(
                        height: MediaQuery.of(context).size.height - 160,
                        //Height
                        //Pixel 3a: 160
                        width: MediaQuery.of(context).size.width - 32,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                "Listing Status",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromRGBO(65, 64, 66, 1),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(
                                height: 15.0,
                              ),
                              ButtonGroupSpaced(
                                  oneOnly: false,
                                  selectedColor: headerColor,
                                  selectedTextColor: Colors.grey,
                                  selectedItems:
                                      filterModel.sLystingStatus?.length == 0 ||
                                              filterModel
                                                      .sLystingStatus.length ==
                                                  filterProvider
                                                      .filterSettingsModel!
                                                      .sLystingStatus
                                                      .length
                                          ? ['Any']
                                          : filterModel.sLystingStatus,
                                  items: filterProvider
                                      .filterSettingsModel!.sLystingStatus,
                                  callback: (val) => setState(() {
                                        filterModel.sLystingStatus = val;
                                      })),
                              SizedBox(
                                height: 15.0,
                              ),
                              Text(
                                "Property Type",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromRGBO(65, 64, 66, 1),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(
                                height: 15.0,
                              ),
                              ButtonGroupSpaced(
                                oneOnly: false,
                                selectedColor: headerColor,
                                selectedTextColor: Colors.grey,
                                selectedItems:
                                    filterModel.sPropertyType.length == 0 ||
                                            filterModel.sPropertyType.length ==
                                                filterProvider
                                                    .filterSettingsModel!
                                                    .sPropertyType
                                                    .length
                                        ? ['Any']
                                        : filterModel.sPropertyType,
                                items: filterProvider
                                    .filterSettingsModel!.sPropertyType,
                                callback: (val) => setState(
                                  () {
                                    filterModel.sPropertyType = val;
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 25.0,
                              ),
                              Text(
                                "Days Listed",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromRGBO(65, 64, 66, 1),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(
                                height: 15.0,
                              ),
                              Center(
                                  child: NumberPicker(
                                      itemWidth: 60,
                                      itemHeight: 60,
                                      itemCount: 5,
                                      textMapper: (numberText) {
                                        if (numberText ==
                                            filterProvider.filterSettingsModel!
                                                .nDaysOnZipCularMin
                                                .toString()) {
                                          return 'Today';
                                        }
                                        if (numberText ==
                                            filterProvider.filterSettingsModel!
                                                .nDaysOnZipCularMax
                                                .toString()) {
                                          return 'Any';
                                        } else {
                                          return numberText;
                                        }
                                      },
                                      axis: Axis.horizontal,
                                      value: filterModel.nDaysOnZipCularMax,
                                      minValue: filterProvider
                                          .filterSettingsModel!
                                          .nDaysOnZipCularMin!,
                                      maxValue: filterProvider
                                          .filterSettingsModel!
                                          .nDaysOnZipCularMax!,
                                      step: 1,
                                      haptics: true,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: filterProvider
                                                        .daysOnMarketActive ==
                                                    false
                                                ? Colors.grey[300]!
                                                : headerColor),
                                        borderRadius:
                                            BorderRadius.circular(150),
                                      ),
                                      textStyle: TextStyle(
                                          color: buttonsColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w300),
                                      selectedTextStyle: TextStyle(
                                          color: filterProvider
                                                      .daysOnMarketActive ==
                                                  false
                                              ? buttonsColor
                                              : headerColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600),
                                      onChanged: (value) {
                                        setState(() {
                                          bool result = true;
                                          if (value == 0 || value == 30) {
                                            result = false;
                                          }
                                          setState(() {
                                            filterProvider
                                                .updateDaysOnMarketActive(
                                                    result);
                                            filterModel.nDaysOnZipCularMax =
                                                value;
                                          });
                                        });
                                      })),
                              SizedBox(
                                height: 20.0,
                              ),
                              Text(
                                "Deals",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromRGBO(65, 64, 66, 1),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              ButtonGroupSpaced(
                                  oneOnly: false,
                                  selectedColor: headerColor,
                                  selectedTextColor: Colors.grey,
                                  selectedItems:
                                      filterModel.sTypeOfSell.length == 0 ||
                                              filterModel.sTypeOfSell.length ==
                                                  filterProvider
                                                      .filterSettingsModel!
                                                      .sTypeOfSell
                                                      .length
                                          ? ['Any']
                                          : filterModel.sTypeOfSell,
                                  items: filterProvider
                                      .filterSettingsModel!.sTypeOfSell,
                                  callback: (val) => setState(() {
                                        filterModel.sTypeOfSell = val;
                                      })),
                              SizedBox(
                                height: 25.0,
                              ),
                              Text(
                                "Property Condition - Only for Off-Market",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromRGBO(65, 64, 66, 1),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              ButtonGroupSpaced(
                                  oneOnly: false,
                                  selectedColor: headerColor,
                                  selectedTextColor: Colors.grey,
                                  selectedItems:
                                      filterModel.sPropertyCondition.length ==
                                                  0 ||
                                              filterModel.sPropertyCondition
                                                      .length ==
                                                  filterProvider
                                                      .filterSettingsModel!
                                                      .sPropertyCondition
                                                      .length
                                          ? ['Any']
                                          : filterModel.sPropertyCondition,
                                  items: filterProvider
                                      .filterSettingsModel!.sPropertyCondition,
                                  callback: (val) => setState(() =>
                                      filterModel.sPropertyCondition = val)),
                              SizedBox(
                                height: 25.0,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Price Range",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color.fromRGBO(65, 64, 66, 1),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  )
                                ],
                              ),
                              Column(
                                children: [
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          Text('Min',
                                              style: TextStyle(
                                                  color: baseColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w800)),
                                          NumberPicker(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: filterProvider
                                                                .priceActiveMin ==
                                                            false
                                                        ? Colors.grey[300]!
                                                        : headerColor),
                                                borderRadius:
                                                    BorderRadius.circular(150),
                                              ),
                                              textMapper: (numberText) {
                                                var result = '';
                                                if (numberText ==
                                                    filterProvider
                                                        .filterSettingsModel!
                                                        .nPriceMin
                                                        .toString()) {
                                                  return 'No Min';
                                                } else {
                                                  result = numberText;
                                                }
                                                return "\$" +
                                                    NumberFormat.compact()
                                                        .format(int.tryParse(
                                                            result));
                                              },
                                              textStyle: TextStyle(
                                                  color: buttonsColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w300),
                                              selectedTextStyle: TextStyle(
                                                  color: filterProvider
                                                              .priceActiveMin ==
                                                          false
                                                      ? buttonsColor
                                                      : headerColor,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600),
                                              value: filterModel.nPriceMin,
                                              minValue:
                                                  filterProvider.filterSettingsModel!
                                                      .nPriceMin!,
                                              maxValue: filterProvider
                                                  .filterSettingsModel!
                                                  .nPriceMax!,
                                              step: 25000,
                                              haptics: true,
                                              onChanged: (value) {
                                                bool result = false;
                                                if (value !=
                                                    filterProvider
                                                        .filterSettingsModel!
                                                        .nPriceMin!) {
                                                  result = true;
                                                }
                                                setState(() {
                                                  filterProvider
                                                      .updatePriceActiveMin(
                                                          result);
                                                  filterModel.nPriceMin = value;
                                                });
                                              }),
                                        ],
                                      ),
                                      Container(
                                          child: Text('To',
                                              style: TextStyle(
                                                  color: Colors.grey[800],
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600)),
                                          padding: EdgeInsets.only(top: 20)),
                                      Column(
                                        children: [
                                          Text('Max',
                                              style: TextStyle(
                                                  color: baseColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w800)),
                                          NumberPicker(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: filterProvider
                                                                .priceActiveMax ==
                                                            false
                                                        ? Colors.grey[300]!
                                                        : headerColor),
                                                borderRadius:
                                                    BorderRadius.circular(150),
                                              ),
                                              textMapper: (numberText) {
                                                if (numberText ==
                                                    filterProvider
                                                        .filterSettingsModel!
                                                        .nPriceMax!
                                                        .toString()) {
                                                  return 'No Max';
                                                } else {
                                                  return "\$" +
                                                      NumberFormat.compact()
                                                          .format(int.tryParse(
                                                              numberText));
                                                }
                                              },
                                              textStyle: TextStyle(
                                                  color: buttonsColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w300),
                                              selectedTextStyle: TextStyle(
                                                  color: filterProvider
                                                              .priceActiveMax ==
                                                          false
                                                      ? buttonsColor
                                                      : headerColor,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600),
                                              value: filterModel.nPriceMax,
                                              minValue:
                                                  filterProvider.filterSettingsModel!
                                                      .nPriceMin!,
                                              maxValue: filterProvider
                                                  .filterSettingsModel!
                                                  .nPriceMax!,
                                              step: 25000,
                                              haptics: true,
                                              onChanged: (value) {
                                                setState(() {
                                                  bool result = false;
                                                  if (value !=
                                                      filterProvider
                                                          .filterSettingsModel!
                                                          .nPriceMax!) {
                                                    result = true;
                                                  }
                                                  setState(() {
                                                    filterProvider
                                                        .updatePriceActiveMax(
                                                            result);
                                                    filterModel.nPriceMax =
                                                        value;
                                                  });
                                                });
                                              }),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 25.0,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Price/Sqft",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color.fromRGBO(65, 64, 66, 1),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  )
                                ],
                              ),
                              Column(
                                children: [
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          Text('Min',
                                              style: TextStyle(
                                                  color: baseColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w800)),
                                          NumberPicker(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: filterProvider
                                                                .pricesqftActiveMin ==
                                                            false
                                                        ? Colors.grey[300]!
                                                        : headerColor),
                                                borderRadius:
                                                    BorderRadius.circular(150),
                                              ),
                                              textMapper: (numberText) {
                                                var result = '';
                                                if (numberText ==
                                                    filterProvider
                                                        .filterSettingsModel!
                                                        .nPricePerSqftMin!
                                                        .toString()) {
                                                  return 'No Min';
                                                } else {
                                                  result = numberText;
                                                }
                                                return "\$" +
                                                    NumberFormat.compact()
                                                        .format(int.tryParse(
                                                            result));
                                              },
                                              textStyle: TextStyle(
                                                  color: buttonsColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w300),
                                              selectedTextStyle: TextStyle(
                                                  color: filterProvider
                                                              .pricesqftActiveMin ==
                                                          false
                                                      ? buttonsColor
                                                      : headerColor,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600),
                                              value:
                                                  filterModel.nPricePerSqftMin,
                                              minValue:
                                                  filterProvider.filterSettingsModel!
                                                      .nPricePerSqftMin!,
                                              maxValue: filterProvider
                                                  .filterSettingsModel!
                                                  .nPricePerSqftMax!,
                                              step: 10,
                                              haptics: true,
                                              onChanged: (value) {
                                                setState(() {
                                                  bool result = false;
                                                  if (value !=
                                                      filterProvider
                                                          .filterSettingsModel!
                                                          .nPricePerSqftMin!) {
                                                    result = true;
                                                  }
                                                  setState(() {
                                                    filterProvider
                                                        .updatePricesqftActiveMinUpdate(
                                                            result);
                                                    filterModel
                                                            .nPricePerSqftMin =
                                                        value;
                                                  });
                                                });
                                              }),
                                        ],
                                      ),
                                      Padding(
                                          child: Text('To',
                                              style: TextStyle(
                                                  color: Colors.grey[800],
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600)),
                                          padding: EdgeInsets.only(top: 20)),
                                      Column(
                                        children: [
                                          Text('Max',
                                              style: TextStyle(
                                                  color: baseColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w800)),
                                          NumberPicker(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: filterProvider
                                                                .pricesqftActiveMax ==
                                                            false
                                                        ? Colors.grey[300]!
                                                        : headerColor),
                                                borderRadius:
                                                    BorderRadius.circular(150),
                                              ),
                                              textMapper: (numberText) {
                                                if (numberText ==
                                                    filterProvider
                                                        .filterSettingsModel!
                                                        .nPricePerSqftMax!
                                                        .toString()) {
                                                  return "No Max";
                                                } else {
                                                  return "\$" +
                                                      NumberFormat.compact()
                                                          .format(int.tryParse(
                                                              numberText));
                                                }
                                              },
                                              textStyle: TextStyle(
                                                  color: buttonsColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w300),
                                              selectedTextStyle: TextStyle(
                                                  color: filterProvider
                                                              .pricesqftActiveMax ==
                                                          false
                                                      ? buttonsColor
                                                      : headerColor,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600),
                                              value:
                                                  filterModel.nPricePerSqftMax,
                                              minValue:
                                                  filterProvider.filterSettingsModel!
                                                      .nPricePerSqftMin!,
                                              maxValue: filterProvider
                                                  .filterSettingsModel!
                                                  .nPricePerSqftMax!,
                                              step: 10,
                                              haptics: true,
                                              onChanged: (value) {
                                                bool result = false;
                                                if (value !=
                                                    filterProvider
                                                        .filterSettingsModel!
                                                        .nPricePerSqftMax) {
                                                  result = true;
                                                }
                                                setState(() {
                                                  filterProvider
                                                      .updatePricesqftActiveMax(
                                                          result);
                                                  filterModel.nPricePerSqftMax =
                                                      value;
                                                });
                                              }),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 25.0,
                              ),
                              Text(
                                "Bedrooms",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromRGBO(65, 64, 66, 1),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              OgTab(
                                  oneOnly: false,
                                  selectedItems:
                                      filterModel.nBedrooms.length == 0 ||
                                              filterProvider
                                                      .filterSettingsModel!
                                                      .nBedrooms
                                                      .length ==
                                                  filterModel.nBedrooms.length
                                          ? ['Any']
                                          : filterModel.nBedrooms,
                                  items: filterProvider
                                      .filterSettingsModel!.nBedrooms,
                                  callback: (val) => setState(() {
                                        filterModel.nBedrooms = val;
                                      })),
                              SizedBox(
                                height: 25.0,
                              ),
                              Text(
                                "Bathrooms",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromRGBO(65, 64, 66, 1),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              OgTab(
                                oneOnly: false,
                                selectedItems:
                                    filterModel.nBathrooms.length == 0 ||
                                            filterProvider.filterSettingsModel!
                                                    .nBathrooms.length ==
                                                filterModel.nBathrooms.length
                                        ? ['Any']
                                        : filterModel.nBathrooms,
                                items: filterProvider
                                    .filterSettingsModel!.nBathrooms,
                                callback: (val) => setState(() {
                                  filterModel.nBathrooms = val;
                                }),
                              ),
                              SizedBox(
                                height: 25.0,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Sqft",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color.fromRGBO(65, 64, 66, 1),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  )
                                ],
                              ),
                              Column(
                                children: [
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          Text('Min',
                                              style: TextStyle(
                                                  color: baseColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w800)),
                                          NumberPicker(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: filterProvider
                                                                .sqftActiveMin ==
                                                            false
                                                        ? Colors.grey[300]!
                                                        : headerColor),
                                                borderRadius:
                                                    BorderRadius.circular(150),
                                              ),
                                              textMapper: (numberText) {
                                                var result = '';
                                                if (numberText ==
                                                    filterProvider
                                                        .filterSettingsModel!
                                                        .nSqftMin
                                                        .toString()) {
                                                  return 'No Min';
                                                } else {
                                                  result = numberText;
                                                }
                                                return (int.tryParse(result)! -
                                                            1)
                                                        .toString() +
                                                    ' sfqt';
                                              },
                                              textStyle: TextStyle(
                                                  color: buttonsColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w300),
                                              selectedTextStyle: TextStyle(
                                                  color: filterProvider
                                                              .sqftActiveMin ==
                                                          false
                                                      ? buttonsColor
                                                      : headerColor,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600),
                                              value: filterModel.nSqftMin,
                                              minValue:
                                                  filterProvider
                                                      .filterSettingsModel!
                                                      .nSqftMin!,
                                              maxValue: filterProvider
                                                  .filterSettingsModel!
                                                  .nSqftMax!,
                                              step: 250,
                                              haptics: true,
                                              onChanged: (value) {
                                                bool result = false;
                                                if (value !=
                                                    filterProvider
                                                        .filterSettingsModel!
                                                        .nSqftMin) {
                                                  result = true;
                                                }
                                                setState(() {
                                                  filterProvider
                                                      .updateSqftActiveMin(
                                                          result);
                                                  filterModel.nSqftMin = value;
                                                });
                                              }),
                                        ],
                                      ),
                                      Padding(
                                          child: Text('To',
                                              style: TextStyle(
                                                  color: Colors.grey[800],
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600)),
                                          padding: EdgeInsets.only(top: 20)),
                                      Column(
                                        children: [
                                          Text('Max',
                                              style: TextStyle(
                                                  color: baseColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w800)),
                                          NumberPicker(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: filterProvider
                                                                .sqftActiveMax ==
                                                            false
                                                        ? Colors.grey[300]!
                                                        : headerColor),
                                                borderRadius:
                                                    BorderRadius.circular(150),
                                              ),
                                              textMapper: (numberText) {
                                                if (numberText ==
                                                    filterProvider
                                                        .filterSettingsModel!
                                                        .nSqftMax
                                                        .toString()) {
                                                  return 'No Max';
                                                } else {
                                                  return (int.tryParse(
                                                                  numberText)! -
                                                              1)
                                                          .toString() +
                                                      ' sqft';
                                                }
                                              },
                                              textStyle: TextStyle(
                                                  color: buttonsColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w300),
                                              selectedTextStyle: TextStyle(
                                                  color: filterProvider
                                                              .sqftActiveMax ==
                                                          false
                                                      ? buttonsColor
                                                      : headerColor,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600),
                                              value: filterModel.nSqftMax,
                                              minValue:
                                                  filterProvider
                                                      .filterSettingsModel!
                                                      .nSqftMin!,
                                              maxValue: filterProvider
                                                  .filterSettingsModel!
                                                  .nSqftMax!,
                                              step: 250,
                                              haptics: true,
                                              onChanged: (value) {
                                                bool result = false;
                                                if (value !=
                                                    filterProvider
                                                        .filterSettingsModel!
                                                        .nSqftMax) {
                                                  result = true;
                                                }
                                                setState(() {
                                                  filterProvider
                                                      .updateSqftActiveMax(
                                                          result);
                                                  filterModel.nSqftMax = value;
                                                });
                                              }),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 25.0,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Lot Size",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color.fromRGBO(65, 64, 66, 1),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  )
                                ],
                              ),
                              Column(
                                children: [
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          Text('Min',
                                              style: TextStyle(
                                                  color: baseColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w800)),
                                          NumberPicker(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: filterProvider
                                                                .lotSizeActiveMin ==
                                                            false
                                                        ? Colors.grey[300]!
                                                        : headerColor),
                                                borderRadius:
                                                    BorderRadius.circular(150),
                                              ),
                                              textMapper: (numberText) {
                                                String result =
                                                    getLabelValue(numberText);
                                                return result;
                                              },
                                              textStyle: TextStyle(
                                                  color: buttonsColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w300),
                                              selectedTextStyle: TextStyle(
                                                  color: filterProvider
                                                              .lotSizeActiveMin ==
                                                          false
                                                      ? buttonsColor
                                                      : headerColor,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600),
                                              value: filterModel.nLotSizeMin,
                                              minValue: filterProvider
                                                  .filterSettingsModel!.nLotSizeMin!,
                                              maxValue: filterProvider
                                                  .filterSettingsModel!
                                                  .nLotSizeMax!,
                                              step: 1,
                                              haptics: true,
                                              onChanged: (value) {
                                                bool result = false;
                                                if (value !=
                                                    filterProvider
                                                        .filterSettingsModel!
                                                        .nLotSizeMin) {
                                                  result = true;
                                                }
                                                setState(() {
                                                  filterProvider
                                                      .updateLotsSizeActiveMin(
                                                          result);
                                                  filterModel.nLotSizeMin =
                                                      value;
                                                });
                                              }),
                                        ],
                                      ),
                                      Padding(
                                        child: Text(
                                          'To',
                                          style: TextStyle(
                                              color: Colors.grey[800],
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        padding: EdgeInsets.only(top: 20),
                                      ),
                                      Column(
                                        children: [
                                          Text('Max',
                                              style: TextStyle(
                                                  color: baseColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w800)),
                                          NumberPicker(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: filterProvider
                                                                .lotSizeActiveMax ==
                                                            false
                                                        ? Colors.grey[300]!
                                                        : headerColor),
                                                borderRadius:
                                                    BorderRadius.circular(150),
                                              ),
                                              textMapper: (numberText) {
                                                String result =
                                                    getLabelValue(numberText);
                                                return result;
                                              },
                                              textStyle: TextStyle(
                                                  color: buttonsColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w300),
                                              selectedTextStyle: TextStyle(
                                                  color: filterProvider
                                                              .lotSizeActiveMax ==
                                                          false
                                                      ? buttonsColor
                                                      : headerColor,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600),
                                              value: filterModel.nLotSizeMax,
                                              minValue: filterProvider
                                                  .filterSettingsModel!.nLotSizeMin!,
                                              maxValue: filterProvider
                                                  .filterSettingsModel!
                                                  .nLotSizeMax!,
                                              step: 1,
                                              haptics: true,
                                              onChanged: (value) {
                                                bool result = false;
                                                if (value !=
                                                    filterProvider
                                                        .filterSettingsModel!
                                                        .nLotSizeMax) {
                                                  result = true;
                                                }
                                                setState(() {
                                                  filterProvider
                                                      .updateLotsSizeActiveMax(
                                                          result);
                                                  filterModel.nLotSizeMax =
                                                      value;
                                                });
                                              }),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 25.0,
                              ),
                              Text(
                                "Home Age",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromRGBO(65, 64, 66, 1),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              Row(
                                children: [
                                  new Row(
                                    children: <Widget>[
                                      GestureDetector(
                                        child: Container(
                                            height: 40,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.5,
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.only(
                                                left: 0.0, top: 0),
                                            decoration: BoxDecoration(
                                              color: filterProvider
                                                          .yearBuiltVisibleMin ==
                                                      false
                                                  ? Colors.white
                                                  : headerColor,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(5),
                                                bottomLeft: Radius.circular(5),
                                                topRight: Radius.circular(5),
                                                bottomRight: Radius.circular(5),
                                              ),
                                              border: Border.all(
                                                color: Colors.grey[300]!,
                                              ),
                                            ),
                                            child: Text(
                                                filterModel.nYearBuiltMin
                                                    .toString(),
                                                style: TextStyle(
                                                    color: filterProvider
                                                                .yearBuiltVisibleMin ==
                                                            false
                                                        ? buttonsColor
                                                        : Colors.white,
                                                    fontSize: 18))),
                                        onTap: () {
                                          DatePicker.showDatePicker(context,
                                              onConfirm: (DateTime val,
                                                  List<int> list) {
                                            setState(() {
                                              if (filterModel.nYearBuiltMin !=
                                                  val.year) {
                                                filterProvider
                                                    .updateYearBuiltVisibleMin(
                                                        true);
                                              }
                                              filterModel.nYearBuiltMin =
                                                  val.year;
                                            });
                                          },
                                              dateFormat: 'yyyy',
                                              pickerTheme: DateTimePickerTheme(
                                                  cancelTextStyle: TextStyle(
                                                      color: baseColor,
                                                      fontSize: 18),
                                                  confirmTextStyle: TextStyle(
                                                      color: baseColor,
                                                      fontSize: 18),
                                                  itemTextStyle: TextStyle(
                                                      color: baseColor,
                                                      fontSize: 23),
                                                  pickerHeight: 300),
                                              minDateTime: DateTime(
                                                  filterProvider
                                                      .filterSettingsModel!
                                                      .nYearBuiltMin!),
                                              maxDateTime: DateTime(
                                                  DateTime.now().year, 12, 31),
                                              initialDateTime: DateTime(
                                                  filterModel.nYearBuiltMin));
                                        },
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text('To',
                                          style: TextStyle(
                                              color: baseColor, fontSize: 17)),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      GestureDetector(
                                        child: Container(
                                          height: 40,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.5,
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.only(
                                              left: 0.0, top: 0),
                                          decoration: BoxDecoration(
                                            color: filterProvider
                                                        .yearBuiltVisibleMax ==
                                                    true
                                                ? headerColor
                                                : Colors.white,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(5),
                                              bottomLeft: Radius.circular(5),
                                              topRight: Radius.circular(5),
                                              bottomRight: Radius.circular(5),
                                            ),
                                            border: Border.all(
                                              color: Colors.grey[300]!,
                                            ),
                                          ),
                                          child: Text(
                                            filterModel.nYearBuiltMax
                                                .toString(),
                                            style: TextStyle(
                                                color: filterProvider
                                                            .yearBuiltVisibleMax ==
                                                        true
                                                    ? Colors.white
                                                    : buttonsColor,
                                                fontSize: 18),
                                          ),
                                        ),
                                        onTap: () {
                                          DatePicker.showDatePicker(context,
                                              onConfirm: (DateTime val,
                                                  List<int> list) {
                                            setState(() {
                                              if (this
                                                      .filterModel
                                                      .nYearBuiltMax !=
                                                  val.year) {
                                                filterProvider
                                                    .updateYearBuiltVisibleMax(
                                                        true);
                                              }
                                              this.filterModel.nYearBuiltMax =
                                                  val.year;
                                            });
                                          },
                                              dateFormat: 'yyyy',
                                              pickerTheme: DateTimePickerTheme(
                                                  cancelTextStyle: TextStyle(
                                                      color: baseColor,
                                                      fontSize: 18),
                                                  confirmTextStyle: TextStyle(
                                                      color: baseColor,
                                                      fontSize: 18),
                                                  itemTextStyle: TextStyle(
                                                      color: baseColor,
                                                      fontSize: 23),
                                                  pickerHeight: 300),
                                              minDateTime: DateTime(
                                                  filterModel.nYearBuiltMin),
                                              maxDateTime: DateTime(
                                                  filterProvider
                                                      .filterSettingsModel!
                                                      .nYearBuiltMax!,
                                                  12,
                                                  31),
                                              initialDateTime: DateTime(
                                                  filterModel.nYearBuiltMax));
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 25.0,
                              ),
                              Text(
                                "Photos",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromRGBO(65, 64, 66, 1),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(
                                height: 15.0,
                              ),
                              Center(
                                child: NumberPicker(
                                    itemWidth: 60,
                                    itemHeight: 60,
                                    itemCount: 5,
                                    textMapper: (numberText) {
                                      if (numberText ==
                                          filterProvider.filterSettingsModel!
                                              .nTotalPhotosMin
                                              .toString()) {
                                        return 'Any';
                                      } else {
                                        return numberText + '+';
                                      }
                                    },
                                    axis: Axis.horizontal,
                                    value: filterModel.nTotalPhotosMin,
                                    minValue: filterProvider
                                        .filterSettingsModel!.nTotalPhotosMin!,
                                    maxValue: filterProvider
                                        .filterSettingsModel!.nTotalPhotosMax!,
                                    step: 1,
                                    haptics: true,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: filterProvider.photosActive ==
                                                  false
                                              ? Colors.grey[300]!
                                              : headerColor),
                                      borderRadius: BorderRadius.circular(150),
                                    ),
                                    textStyle: TextStyle(
                                        color: buttonsColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w300),
                                    selectedTextStyle: TextStyle(
                                        color:
                                            filterProvider.photosActive == false
                                                ? buttonsColor
                                                : headerColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                    onChanged: (value) {
                                      bool result = false;
                                      if (value !=
                                          filterProvider.filterSettingsModel!
                                              .nTotalPhotosMin) {
                                        result = true;
                                      }
                                      setState(() {
                                        filterProvider
                                            .updatePhotosActive(result);
                                        filterModel.nTotalPhotosMin = value;
                                      });
                                    }),
                              ),
                              SizedBox(
                                height: 40.0,
                              ),
                            ],
                          ),
                        )),
                    top: 0,
                  ),
                  Positioned(
                    child: InkWell(
                      onTap: () async {
                        filterProvider.updateLoading(true);
                        filterProvider.updateYearBuiltVisibleMin(false);
                        filterProvider.updateYearBuiltVisibleMax(false);
                        filterProvider.applyFilter(filterModel);

                        if (filterProvider.result == 'Apply') {
                          await AnalitysService().sendAnalyticsEvent(
                              'filter_apply_click', {
                            "screen_view": "filter_screen",
                            "item_id": 'empty',
                            'item_type': 'empty'
                          });
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width - 38,
                        height: 55,
                        decoration: BoxDecoration(
                          color: headerColor,
                          borderRadius: BorderRadius.circular(15.0),
                          border: Border.all(
                            width: 3,
                            color: Colors.grey[300]!,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(169, 176, 185, 0.42),
                              spreadRadius: 0,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: filterProvider.isLoading == true
                              ? Container(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text(
                                  filterProvider.result,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    bottom: 0,
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      Future.delayed(
        Duration.zero,
        () async {
          await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
        },
      );
    }
    return widgetObj;
  }

  getLabelValue(String numberText) {
    switch (numberText) {
      case '1':
        return 'No Min';
      case '2':
        return '1000 sqft';
      case '3':
        return '2000 sqft';
      case '4':
        return '3000 sqft';
      case '5':
        return '4000 sqft';
      case '6':
        return '5000 sqft';
      case '7':
        return '6000 sqft';
      case '8':
        return '7000 sqft';
      case '9':
        return '8000 sqft';
      case '10':
        return '9000 sqft';
      case '11':
        return '10000 sqft';
      case '12':
        return '0.25 acres';
      case '13':
        return '0.50 acres';
      case '14':
        return '0.75 acres';
      case '15':
        return '1 acres';
      case '16':
        return '2 acres';
      case '17':
        return '3 acres';
      case '18':
        return '4 acres';
      case '19':
        return '5 acres';
      case '20':
        return '10 acres';
      case '21':
        return '15 acres';
      case '22':
        return '20 acres';
      case '23':
        return '25 acres';
      case '24':
        return 'No Max';
    }
  }
}
