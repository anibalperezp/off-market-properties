import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker_fork/flutter_cupertino_date_picker_fork.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:intl/intl.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/models/listing/search/listing.dart';

class InfoTab extends StatefulWidget {
  InfoTab(
      {Key? key,
      this.listing,
      this.selectedIndex,
      this.enabled,
      this.callback,
      this.callbackSelectedIndex})
      : super(key: key);

  bool? enabled;
  Listing? listing;
  int? selectedIndex;
  ValueChanged<Listing>? callback;
  ValueChanged<int>? callbackSelectedIndex;

  @override
  _InfoTabState createState() => _InfoTabState();
}

class _InfoTabState extends State<InfoTab> {
  var formatter = new NumberFormat("#,###,###", "en_US");
  var formatterDecimal = new NumberFormat("#,###,###.##", "en_US");
  int nBedroomsController = 0;
  int nBathroomsController = 0;
  int nHalfBathroomsController = 0;
  String sUnitAreaController = 'sqft';
  String sVacancyTypeController = '';
  String sCoolingTypeController = '';
  String sHeatingTypeController = '';
  String sParkingTypeController = '';
  int nCoveredParkingController = 0;
  Listing? listingCached;
  final TextEditingController _lotLegalController = TextEditingController();
  final TextEditingController _yearBuildController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _priceEARController = TextEditingController();
  final TextEditingController _hoaFeeController = TextEditingController();
  final TextEditingController _sizeSqftController = TextEditingController();
  final TextEditingController _sizeLotController = TextEditingController();
  final TextEditingController _numberOfUnitController = TextEditingController();
  final FocusNode _textFieldPriceFocusNode = FocusNode();
  final FocusNode _textFieldEPFocusNode = FocusNode();
  final FocusNode _textFieldSqftFocusNode = FocusNode();
  final FocusNode _textFieldLotSizeFocusNode = FocusNode();
  final FocusNode _textFieldHOAFocusNode = FocusNode();

  final propTypes = [
    'Single Family',
    'Apartment',
    'Condo',
    'Townhome',
    'Lot',
    'Multi-Unit Complex'
  ];
  //Money Mask attributes
  String hoaFee = '0';
  String squareFt = '0';
  String lotSize = '0';
  String yearBuilt = '1900';
  String price = '0';
  String priceEstimated = '0';
  String numberOfUnits = '0';

  @override
  void initState() {
    // Dropdown Controllers
    this.nBedroomsController = this.widget.listing!.nBedrooms!;
    this.nBathroomsController = this.widget.listing!.nBathrooms!;
    this.nHalfBathroomsController = this.widget.listing!.nHalfBaths!;
    this.sUnitAreaController = this.widget.listing!.sUnitArea!;
    this.sVacancyTypeController = this.widget.listing!.sVacancyType!;
    this.sCoolingTypeController = this.widget.listing!.sCoolingType!;
    this.sHeatingTypeController = this.widget.listing!.sHeatingType!;
    this.sParkingTypeController = this.widget.listing!.sParkingType!;
    this.nCoveredParkingController = this.widget.listing!.nCoveredParking!;

    // Input Controllers
    // -------Price-------
    this.price = this.widget.listing!.nFirstPrice == null
        ? '0'
        : this.widget.listing!.nFirstPrice.toString();
    this._priceController.text = this.price == '0' || this.price.isEmpty
        ? ''
        : "\$${this.formatter.format(this.widget.listing!.nFirstPrice)}";
    // -------Price-------

    // EAR - Estimated After Repair Value
    this.priceEstimated = this.widget.listing!.nEstARV == null
        ? '0'
        : this.widget.listing!.nEstARV.toString();
    this._priceEARController.text =
        this.priceEstimated == '0' || this.priceEstimated.isEmpty
            ? ''
            : "\$${this.formatter.format(this.widget.listing!.nEstARV)}";
    // EAR - Estimated After Repair Value

    // -------Lot Size-+------
    double lotValue = this.widget.listing!.nLotSize == null
        ? 0.00
        : this.widget.listing!.nLotSize!;

    this.lotSize = lotValue.toStringAsFixed(2);
    this._sizeLotController.text = lotValue > 0
        ? lotValue.toStringAsFixed(
            2) //"${this.formatterDecimal.format(this.widget.listing!.nLotSize)}"
        : '';
    // -------Lot Size-+------

    // -------Sqft------------
    this.squareFt = this.widget.listing!.nSqft == null
        ? '0'
        : this.widget.listing!.nSqft.toString();

    this._sizeSqftController.text =
        this.squareFt == '0' || this.squareFt.isEmpty
            ? ''
            : "${this.formatter.format(this.widget.listing!.nSqft)}";

    // -------Sqft------------

    // -------HOA Fee------------
    this.hoaFee = widget.listing!.nMonthlyHoaFee == null
        ? '0'
        : widget.listing!.nMonthlyHoaFee.toString();

    this._hoaFeeController.text = this.hoaFee == '0' || this.hoaFee.isEmpty
        ? ''
        : "\$${this.formatter.format(this.widget.listing!.nMonthlyHoaFee)}";
    // -------HOA Fee------------

    // -------Year---------------

    this.yearBuilt = this.widget.listing!.nYearBuilt == null
        ? '1900'
        : this.widget.listing!.nYearBuilt.toString();
    this._yearBuildController.text = this.yearBuilt;

    // -------Year--------------

    _lotLegalController.text = this.widget.listing!.sLotLegalDescription!;

    // -------Number of Units--------------

    this.numberOfUnits = this.widget.listing!.nNumberofUnits == null
        ? '0'
        : this.widget.listing!.nNumberofUnits.toString();

    this._numberOfUnitController.text =
        this.numberOfUnits == '0' || this.numberOfUnits.isEmpty
            ? ''
            : this.numberOfUnits;

    // -------Number of Units--------------

    super.initState();
  }

  @override
  void didUpdateWidget(InfoTab oldWidget) {
    setState(
      () {
        // Input Controllers
        this.widget.listing = oldWidget.listing;
        this.widget.listing!.nMonthlyHoaFee = int.tryParse(this.hoaFee); //DONE
        this.widget.listing!.nSqft = int.tryParse(this.squareFt); //DONE
        this.widget.listing!.nYearBuilt = int.tryParse(this.yearBuilt); //DONE
        if (oldWidget.listing!.nLotSize != this.widget.listing!.nLotSize) {
          this.widget.listing!.nLotSize = double.tryParse(this.lotSize);
        }
        this.widget.listing!.nFirstPrice = int.tryParse(this.price); //DONE
        this.widget.listing!.nNumberofUnits = int.tryParse(numberOfUnits);
        this.widget.listing!.sLotLegalDescription =
            this._lotLegalController.text;
        this.widget.listing!.nEstARV = int.tryParse(this.priceEstimated);

        // Dropdown Controllers
        this.widget.listing!.nBedrooms = this.nBedroomsController;
        this.widget.listing!.nBathrooms = this.nBathroomsController;
        this.widget.listing!.nHalfBaths = this.nHalfBathroomsController;
        this.widget.listing!.sUnitArea = this.sUnitAreaController;
        this.widget.listing!.sVacancyType = this.sVacancyTypeController;
        this.widget.listing!.sCoolingType = this.sCoolingTypeController;
        this.widget.listing!.sHeatingType = this.sHeatingTypeController;
        this.widget.listing!.sParkingType = this.sParkingTypeController;
        this.widget.listing!.nCoveredParking = this.nCoveredParkingController;
        this.listingCached = this.widget.listing;
      },
    );
    super.didUpdateWidget(this.widget);
  }

  @override
  void dispose() {
    disposeClass();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 0),
          child: TextFormField(
            focusNode: _textFieldPriceFocusNode,
            controller: _priceController,
            inputFormatters: [
              CurrencyInputFormatter(
                  thousandSeparator: ThousandSeparator.Comma,
                  leadingSymbol: CurrencySymbols.DOLLAR_SIGN,
                  mantissaLength: 0)
            ],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onFieldSubmitted: (v) {
              unFocusInput();
            },
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              counterStyle: TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(color: Colors.red),
              ),
              labelText: 'Price',
            ),
            maxLength: 11,
            onChanged: (value) {
              setState(() {
                if (value.isEmpty || value == '\$') {
                  this.widget.listing!.nFirstPrice = 0;
                  this.price = '';
                } else {
                  this.price = value.replaceAll('\$', '').replaceAll(',', '');
                  this.widget.listing!.nFirstPrice = int.tryParse(this.price);
                }
                submitListing();
              });
            },
            validator: (value) {
              if (widget.listing!.nFirstPrice == null) {
                widget.listing!.nFirstPrice = 0;
              }
              if (widget.listing!.nFirstPrice! <= 0) {
                return 'Required';
              }
              return null;
            },
          ),
        ),
        Visibility(
            visible: this.widget.selectedIndex != 5,
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: TextFormField(
                controller: this._priceEARController,
                focusNode: _textFieldEPFocusNode,
                inputFormatters: [
                  CurrencyInputFormatter(
                      thousandSeparator: ThousandSeparator.Comma,
                      leadingSymbol: CurrencySymbols.DOLLAR_SIGN,
                      mantissaLength: 0)
                ],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onFieldSubmitted: (v) {
                  unFocusInput();
                },
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  counterStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  labelText: 'Estimated After Repair Value (Optional)',
                ),
                maxLength: 11,
                onChanged: (value) {
                  setState(() {
                    if (value.isEmpty || value == '\$') {
                      widget.listing!.nEstARV = 0;
                      this.priceEstimated = '';
                    } else {
                      this.priceEstimated =
                          value.replaceAll('\$', '').replaceAll(',', '');
                      widget.listing!.nEstARV =
                          int.tryParse(this.priceEstimated);
                    }
                    submitListing();
                  });
                },
                validator: (value) {
                  if (widget.listing!.nEstARV == null) {
                    widget.listing!.nEstARV = 0;
                  }
                  if (widget.listing!.nEstARV! > 0) {
                    if (widget.listing!.nFirstPrice != 0 &&
                        widget.listing!.nEstARV! <
                            widget.listing!.nFirstPrice!) {
                      return 'Must be greater than Price';
                    }
                  }
                  return null;
                },
              ),
            )),

        // NOT LOT OR MULTI UNIT
        // BEGIN
        // Baths, Beds, Half Baths
        Visibility(
          visible:
              this.widget.selectedIndex != 5 && this.widget.selectedIndex != 6,
          child: Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 3.8,
                  child: DropdownSearch<String>(
                      autoValidateMode: AutovalidateMode.onUserInteraction,
                      popupProps: PopupProps.bottomSheet(
                        bottomSheetProps: BottomSheetProps(
                          elevation: 16,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          fillColor: Colors.white,
                          labelText: "Bedrooms",
                          hintText: "Select Bedrooms",
                          filled: true,
                        ),
                      ),
                      items: [
                        '0',
                        '1',
                        '2',
                        '3',
                        '4',
                        '5',
                        '6',
                        '7',
                        '8',
                        '8+'
                      ],
                      validator: (String? value) {
                        if (value == '0') {
                          return 'Required';
                        }
                        return null;
                      },
                      // popupItemDisabled: (String s) => s.startsWith('Q'),
                      onChanged: (String? newValue) {
                        unFocusInput();
                        setState(() {
                          this.nBedroomsController = int.parse(newValue!);
                          submitListing();
                        });
                      },
                      selectedItem: this.nBedroomsController.toString()),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 3.8,
                  child: DropdownSearch<String>(
                      autoValidateMode: AutovalidateMode.onUserInteraction,
                      popupProps: PopupProps.bottomSheet(
                        bottomSheetProps: BottomSheetProps(
                          elevation: 16,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          fillColor: Colors.white,
                          labelText: "Full Baths",
                          hintText: "Select Full Baths",
                          filled: true,
                        ),
                      ),
                      items: [
                        '0',
                        '1',
                        '2',
                        '3',
                        '4',
                        '5',
                        '6',
                        '7',
                        '8',
                        '8+'
                      ],
                      // popupItemDisabled: (String s) => s.startsWith('Q'),
                      onChanged: (String? newValue) {
                        unFocusInput();
                        setState(() {
                          this.nBathroomsController = int.parse(newValue!);
                          submitListing();
                        });
                      },
                      validator: (String? value) {
                        if (value == '0') {
                          return 'Required';
                        }
                        return null;
                      },
                      selectedItem: this.nBathroomsController.toString()),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 0),
                  width: MediaQuery.of(context).size.width / 3.8,
                  child: DropdownSearch<String>(
                      autoValidateMode: AutovalidateMode.onUserInteraction,
                      popupProps: PopupProps.bottomSheet(
                        bottomSheetProps: BottomSheetProps(
                          elevation: 16,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          fillColor: Colors.white,
                          labelText: "Half Baths",
                          hintText: "Select Half Baths",
                          filled: true,
                        ),
                      ),
                      items: [
                        '0',
                        '1',
                        '2',
                        '3',
                        '4',
                        '5',
                        '6',
                        '7',
                        '8',
                        '8+'
                      ],
                      // popupItemDisabled: (String s) => s.startsWith('Q'),
                      onChanged: (String? newValue) {
                        unFocusInput();
                        setState(() {
                          this.nHalfBathroomsController = int.parse(newValue!);
                          submitListing();
                        });
                      },
                      selectedItem: this.nHalfBathroomsController.toString()),
                )
              ],
            ),
          ),
        ),

        //Sqft & Year
        Visibility(
          visible:
              this.widget.selectedIndex != 5 && this.widget.selectedIndex != 6,
          child: Padding(
            padding: EdgeInsets.only(top: 10, bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 2.3,
                  child: TextFormField(
                    focusNode: _textFieldSqftFocusNode,
                    controller: this._sizeSqftController,
                    inputFormatters: [
                      CurrencyInputFormatter(
                          thousandSeparator: ThousandSeparator.Comma,
                          leadingSymbol: '',
                          mantissaLength: 0)
                    ],
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onFieldSubmitted: (v) {
                      _textFieldSqftFocusNode.unfocus();
                      submitListing();
                    },
                    textInputAction: TextInputAction.next,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      counterStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.grey[400]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.grey[400]!),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      labelText: 'Sqft of Living Space',
                    ),
                    maxLength: 9,
                    onChanged: (value) {
                      setState(() {
                        if (value.isEmpty) {
                          widget.listing!.nSqft = 0;
                          this.squareFt = '0';
                        } else {
                          this.squareFt = value.replaceAll(',', '');

                          this.widget.listing!.nSqft =
                              int.tryParse(this.squareFt);
                        }
                        submitListing();
                      });
                    },
                    validator: (value) {
                      if (widget.listing!.nSqft == 0) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 2.4,
                  padding: EdgeInsets.only(top: 0, bottom: 20),
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    readOnly: true,
                    onFieldSubmitted: (v) {
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                      submitListing();
                    },
                    controller: _yearBuildController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.grey[400]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.grey[400]!),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      labelText: 'Year Built',
                      counterStyle: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      DatePicker.showDatePicker(
                        context,
                        onConfirm: (DateTime val, List<int> list) {
                          setState(
                            () {
                              this.widget.listing!.nYearBuilt = val.year;
                              this.yearBuilt = val.year.toString();
                              _yearBuildController.text = yearBuilt;
                              submitListing();
                            },
                          );
                        },
                        dateFormat: 'yyyy',
                        pickerTheme: DateTimePickerTheme(
                            cancelTextStyle:
                                TextStyle(color: baseColor, fontSize: 18),
                            confirmTextStyle:
                                TextStyle(color: baseColor, fontSize: 18),
                            itemTextStyle:
                                TextStyle(color: baseColor, fontSize: 23),
                            pickerHeight: 300),
                        minDateTime: DateTime(1900),
                        maxDateTime: DateTime(DateTime.now().year, 12, 31),
                        initialDateTime:
                            DateTime(int.tryParse(_yearBuildController.text)!),
                      );
                    },
                    validator: (String? value) {
                      if (value == '1900') {
                        return 'Must be after 1900';
                      }
                      return null;
                    },
                  ),
                )
              ],
            ),
          ),
        ),
        //Lot Size and Unit area
        Visibility(
          visible: this.widget.selectedIndex != 2,
          child: Padding(
            padding: EdgeInsets.only(top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 0),
                  width: MediaQuery.of(context).size.width / 2.3,
                  child: TextFormField(
                    focusNode: _textFieldLotSizeFocusNode,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (v) {
                      _textFieldLotSizeFocusNode.unfocus();
                      submitListing();
                    },
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      CurrencyInputFormatter(
                          leadingSymbol: '',
                          thousandSeparator: ThousandSeparator.Comma,
                          mantissaLength: 2)
                    ],
                    decoration: InputDecoration(
                      counterStyle: TextStyle(color: Colors.white),
                      hintStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        borderSide: BorderSide(color: Colors.grey[400]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        borderSide: BorderSide(color: Colors.grey[400]!),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      labelText: 'Lot Size',
                    ),
                    controller: _sizeLotController,
                    maxLength: 9,
                    onChanged: (value) {
                      if (value.isEmpty) {
                        widget.listing!.nLotSize = 0.00;
                        this.lotSize = '0.00';
                      } else {
                        this.lotSize = value.replaceAll(',', '');
                        this.widget.listing!.nLotSize =
                            double.tryParse(this.lotSize);
                      }
                      submitListing();
                    },
                    validator: (value) {
                      if (widget.listing!.nLotSize == 0) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                Container(
                    width: MediaQuery.of(context).size.width / 2.4,
                    padding: const EdgeInsets.only(bottom: 25.0),
                    child: DropdownSearch<String>(
                        autoValidateMode: AutovalidateMode.onUserInteraction,
                        items: ['sqft', 'acres'],
                        popupProps: PopupProps.bottomSheet(
                          bottomSheetProps: BottomSheetProps(
                            elevation: 16,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            fillColor: Colors.white,
                            labelText: "Unit Area (Lot Size)",
                            hintText: "Select Lot Size",
                            filled: true,
                          ),
                        ),
                        onChanged: (String? newValue) {
                          unFocusInput();
                          setState(() {
                            this.sUnitAreaController = newValue!;
                            submitListing();
                          });
                        },
                        validator: (String? value) {
                          if (value!.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                        selectedItem: this.sUnitAreaController)),
              ],
            ),
          ),
        ),

        //HOA Fee and Vacancy
        Visibility(
          visible:
              this.widget.selectedIndex != 5 && this.widget.selectedIndex != 6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 20, top: 20),
                width: MediaQuery.of(context).size.width / 2.3,
                child: TextFormField(
                  controller: this._hoaFeeController,
                  focusNode: _textFieldHOAFocusNode,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onFieldSubmitted: (v) {
                    _textFieldHOAFocusNode.unfocus();
                    submitListing();
                  },
                  inputFormatters: [
                    CurrencyInputFormatter(
                        leadingSymbol: CurrencySymbols.DOLLAR_SIGN,
                        thousandSeparator: ThousandSeparator.Comma,
                        mantissaLength: 0)
                  ],
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    counterStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    labelText: 'Monthy HOA Fee (Optional)',
                  ),
                  maxLength: 9,
                  onChanged: (value) {
                    setState(() {
                      if (value.isEmpty || value == '\$') {
                        widget.listing!.nMonthlyHoaFee = 0;
                        this.hoaFee = '0';
                      } else {
                        this.hoaFee =
                            value.replaceAll('\$', '').replaceAll(',', '');
                        this.widget.listing!.nMonthlyHoaFee =
                            int.tryParse(this.hoaFee);
                      }
                      submitListing();
                    });
                  },
                  validator: (String? value) {
                    if (widget.listing!.nMonthlyHoaFee == null) {
                      widget.listing!.nMonthlyHoaFee = 0;
                    }
                    return null;
                  },
                ),
              ),
              Container(
                  width: MediaQuery.of(context).size.width / 2.4,
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: DropdownSearch<String>(
                      autoValidateMode: AutovalidateMode.onUserInteraction,
                      items: ['Occupied', 'Vacant', 'Rented'],
                      popupProps: PopupProps.bottomSheet(
                        bottomSheetProps: BottomSheetProps(
                          elevation: 16,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          fillColor: Colors.white,
                          labelText: "Vacancy",
                          hintText: "Select Vacancy",
                          filled: true,
                        ),
                      ),
                      onChanged: (String? newValue) {
                        unFocusInput();
                        setState(() {
                          this.sVacancyTypeController = newValue!;
                          submitListing();
                        });
                      },
                      validator: (String? value) {
                        if (this.sVacancyTypeController.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                      selectedItem: this.sVacancyTypeController))
            ],
          ),
        ),

        // Cooling and Heating
        Visibility(
            visible: this.widget.selectedIndex != 5,
            child: Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width / 2.3,
                          child: DropdownSearch<String>(
                              autoValidateMode:
                                  AutovalidateMode.onUserInteraction,
                              items: ['Central', 'Non-Central', 'No Cooling'],
                              popupProps: PopupProps.bottomSheet(
                                bottomSheetProps: BottomSheetProps(
                                  elevation: 16,
                                  backgroundColor: Colors.white,
                                ),
                              ),
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                  fillColor: Colors.white,
                                  labelText: "Cooling Type",
                                  hintText: "Select Cooling Type",
                                  filled: true,
                                ),
                              ),
                              onChanged: (String? newValue) {
                                unFocusInput();
                                setState(() {
                                  this.sCoolingTypeController = newValue!;
                                  submitListing();
                                });
                              },
                              validator: (String? value) {
                                if (value!.trim().isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                              selectedItem: this.sCoolingTypeController)),
                      Container(
                          width: MediaQuery.of(context).size.width / 2.4,
                          child: DropdownSearch<String>(
                              autoValidateMode:
                                  AutovalidateMode.onUserInteraction,
                              items: ['Central', 'Non-Central', 'No Heating'],
                              popupProps: PopupProps.bottomSheet(
                                bottomSheetProps: BottomSheetProps(
                                  elevation: 16,
                                  backgroundColor: Colors.white,
                                ),
                              ),
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                  fillColor: Colors.white,
                                  labelText: "Heating Type",
                                  hintText: "Select Heating Type",
                                  filled: true,
                                ),
                              ),
                              onChanged: (String? newValue) {
                                unFocusInput();
                                setState(() {
                                  this..sHeatingTypeController = newValue!;
                                  submitListing();
                                });
                              },
                              validator: (String? value) {
                                if (value!.trim().isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                              selectedItem: this.sHeatingTypeController))
                    ]))),

        //Parking
        Visibility(
          visible:
              this.widget.selectedIndex != 5 && this.widget.selectedIndex != 6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  width: MediaQuery.of(context).size.width / 2.3,
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: DropdownSearch<String>(
                      autoValidateMode: AutovalidateMode.onUserInteraction,
                      popupProps: PopupProps.bottomSheet(
                        bottomSheetProps: BottomSheetProps(
                          elevation: 16,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          fillColor: Colors.white,
                          labelText: "Parking Type",
                          hintText: "Select Parking Type",
                          filled: true,
                        ),
                      ),
                      items: ['Attached', 'Detached', 'Carport', 'Uncovered'],
                      onChanged: (String? newValue) {
                        unFocusInput();
                        setState(() {
                          this.sParkingTypeController = newValue!;
                          submitListing();
                        });
                      },
                      validator: (String? value) {
                        if (value!.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                      selectedItem: this.sParkingTypeController)),
              Container(
                  width: MediaQuery.of(context).size.width / 2.4,
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: DropdownSearch<String>(
                      autoValidateMode: AutovalidateMode.onUserInteraction,
                      items: ['0', '1', '2', '3', '4', '4+'],
                      popupProps: PopupProps.bottomSheet(
                        bottomSheetProps: BottomSheetProps(
                          elevation: 16,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          fillColor: Colors.white,
                          labelText: "Covered Parking Spaces",
                          hintText: "Select Parking Spaces",
                          filled: true,
                        ),
                      ),
                      // popupItemDisabled: (String s) => s.startsWith('Q'),
                      onChanged: (String? newValue) {
                        unFocusInput();
                        setState(() {
                          this.nCoveredParkingController = int.parse(newValue!);
                          submitListing();
                        });
                      },
                      selectedItem: this.nCoveredParkingController.toString()))
            ],
          ),
        ),
        // NOT LOT OR MULTI UNIT
        // END

        //Multi-Unit Complex
        Visibility(
          visible: this.widget.selectedIndex == 6,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width / 2.3,
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextFormField(
                      controller: this._numberOfUnitController,
                      inputFormatters: [
                        CurrencyInputFormatter(
                            leadingSymbol: '',
                            mantissaLength: 0,
                            thousandSeparator: ThousandSeparator.None)
                      ],
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onFieldSubmitted: (v) {
                        submitListing();
                      },
                      textInputAction: TextInputAction.next,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        counterStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: Colors.grey[400]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: Colors.grey[400]!),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        labelText: 'Number of Units',
                      ),
                      maxLength: 5,
                      onChanged: (value) {
                        setState(() {
                          this.numberOfUnits = value;
                          widget.listing!.nNumberofUnits =
                              int.parse(this.numberOfUnits);
                          submitListing();
                        });
                      },
                      validator: (value) {
                        if (value!.isEmpty || value == '0') {
                          return 'Required';
                        }
                        return null;
                      },
                    )),
                //Year Built
                Container(
                  width: MediaQuery.of(context).size.width / 2.4,
                  padding: EdgeInsets.only(top: 0, bottom: 0),
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: false),
                    maxLength: 4,
                    readOnly: true,
                    onFieldSubmitted: (v) {
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                      submitListing();
                    },
                    controller: _yearBuildController,
                    decoration: InputDecoration(
                      counterStyle: TextStyle(color: Colors.white),
                      labelStyle: TextStyle(color: Colors.grey[400]!),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.grey[400]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.grey[400]!),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      labelText: 'Year Built',
                    ),
                    onTap: () {
                      DatePicker.showDatePicker(context,
                          onConfirm: (DateTime val, List<int> list) {
                        setState(() {
                          this.widget.listing!.nYearBuilt = val.year;
                          this.yearBuilt = val.year.toString();
                          _yearBuildController.text = yearBuilt;
                          submitListing();
                        });
                      },
                          dateFormat: 'yyyy',
                          pickerTheme: DateTimePickerTheme(
                              cancelTextStyle:
                                  TextStyle(color: baseColor, fontSize: 18),
                              confirmTextStyle:
                                  TextStyle(color: baseColor, fontSize: 18),
                              itemTextStyle:
                                  TextStyle(color: baseColor, fontSize: 23),
                              pickerHeight: 300),
                          minDateTime: DateTime(1900),
                          maxDateTime: DateTime(DateTime.now().year, 12, 31),
                          initialDateTime: DateTime(
                              int.tryParse(_yearBuildController.text)!));
                    },
                    validator: (value) {
                      if (widget.listing!.nYearBuilt == 1900) {
                        return 'Must be after 1900';
                      }
                      return null;
                    },
                  ),
                )
              ],
            ),
          ),
        ),

        //Lot Size
        Visibility(
          visible: this.widget.selectedIndex == 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: this._lotLegalController,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (v) {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
                submitListing();
              },
              minLines: 1,
              maxLines: 4,
              autocorrect: false,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(color: Colors.red),
                ),
                labelText: 'Lot Legal Description (Optional))',
              ),
              onChanged: (value) {
                setState(() {
                  this.widget.listing!.sLotLegalDescription = value;
                  submitListing();
                });
              },
              onEditingComplete: () {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
              },
              validator: (String? value) {
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  submitListing() {
    this.widget.callback!(this.widget.listing!);
    int index = propTypes.indexOf(this.widget.listing!.sPropertyType!);
    this.widget.callbackSelectedIndex!(index + 1);
  }

  unFocusInput() {
    _textFieldPriceFocusNode.unfocus();
    _textFieldEPFocusNode.unfocus();
    _textFieldSqftFocusNode.unfocus();
    _textFieldLotSizeFocusNode.unfocus();
    _textFieldHOAFocusNode.unfocus();
  }

  disposeClass() {
    this._priceController.dispose();
    this._priceEARController.dispose();
    this._hoaFeeController.dispose();
    this._sizeSqftController.dispose();
    this._sizeLotController.dispose();
    this._lotLegalController.dispose();
    this._yearBuildController.dispose();
    this._numberOfUnitController.dispose();
  }
}
