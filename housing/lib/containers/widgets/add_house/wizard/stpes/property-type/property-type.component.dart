import 'package:another_flushbar/flushbar.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geocoding/geocoding.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/models/common/response-service.model.dart';
import 'package:zipcular/repository/facade/listing.facade.dart';
import '../../../../../../models/listing/search/listing.dart';
import '../../../../../../repository/services/prod/google.service.dart';

class PropertyTypeTab extends StatefulWidget {
  PropertyTypeTab(
      {Key? key,
      this.listing,
      this.selectedIndex,
      this.callback,
      this.enabled,
      this.callbackDispose,
      this.callbackCleanWizard,
      this.callbackSelectedIndex,
      this.callbackValidAddress,
      this.callbackLoadingNextStep,
      this.callbackRefreshData,
      this.validAddress,
      this.fromDraft})
      : super(key: key);

  Listing? listing;
  int? selectedIndex;
  bool? validAddress;
  ValueChanged<Listing>? callback;
  ValueChanged<bool>? callbackDispose;
  ValueChanged<bool>? callbackCleanWizard;
  ValueChanged<bool>? callbackValidAddress;
  ValueChanged<bool>? callbackLoadingNextStep;
  ValueChanged<int>? callbackSelectedIndex;
  ValueChanged<bool>? callbackRefreshData;
  bool? enabled;
  bool? fromDraft;

  @override
  State<PropertyTypeTab> createState() => _PropertyTypeTabState();
}

class _PropertyTypeTabState extends State<PropertyTypeTab> {
  TextEditingController typeAheadController = new TextEditingController();
  GoogleServs servs = new GoogleServs();
  List autocomplete = List.empty(growable: true);
  BuildContext? dialogContext;
  bool loadingDraft = false;
  bool keepAddressPrivate = false;
  bool propTypeChanged = false;
  bool loadingZipcode = false;
  final propTypes = [
    'Single Family',
    'Apartment',
    'Condo',
    'Townhome',
    'Lot',
    'Multi-Unit Complex'
  ];
  String propType = '';
  String zipCode = '';

  @override
  void initState() {
    typeAheadController.text = this.widget.listing!.sPropertyAddress!;
    this.keepAddressPrivate = this.widget.listing!.bKeepAddressPrivate!;
    this.zipCode = this.widget.listing!.sZipCode!;
    super.initState();
  }

  @override
  void dispose() {
    typeAheadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget widgetTest = Center(
        child: CircularProgressIndicator(
      strokeWidth: 2,
      color: buttonsColor,
    ));
    try {
      if (this.widget.listing!.propTypeChanged == true &&
          this.widget.listing!.sPropertyType!.isNotEmpty &&
          this.widget.listing!.sPropertyCondition!.isNotEmpty &&
          this.propType.isNotEmpty &&
          this.widget.listing!.sPropertyAddress!.isNotEmpty &&
          this.typeAheadController.text.isNotEmpty &&
          this.widget.listing!.sPropertyAddress !=
              this.typeAheadController.text) {
        initialData();
        setState(() {
          this.widget.listing!.sPropertyType = this.propType;
          this.widget.listing!.propTypeChanged = false;
          this.typeAheadController.text = '';
          this.keepAddressPrivate = false;
          this.zipCode = '';
        });
      }

      widgetTest = Column(children: [
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: IgnorePointer(
                ignoring: widget.enabled == false,
                child: DropdownSearch<String>(
                    items: propTypes,
                    popupProps: PopupProps.bottomSheet(
                      bottomSheetProps: BottomSheetProps(
                        elevation: 16,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
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
                        fillColor: Colors.white,
                        labelText: "Property Type",
                        hintText: "Select Property Type",
                        filled: true,
                      ),
                    ),
                    onChanged: (newValue) {
                      this.widget.callbackCleanWizard!(true);
                      setState(() {
                        this.widget.listing!.sPropertyType = newValue;
                        this.typeAheadController.text = '';
                        this.zipCode = '';
                        this.propType = newValue!;
                        this.widget.listing!.propTypeChanged = true;
                        this.keepAddressPrivate = false;
                        this.widget.listing!.bKeepAddressPrivate = false;
                        this.widget.listing!.sZipCode = '';
                      });
                      this.widget.callback!(this.widget.listing!);
                      int index = propTypes.indexOf(newValue!);
                      this.widget.callbackSelectedIndex!(index + 1);
                    },
                    validator: (String? value) {
                      if (value == null) {
                        return 'Field required';
                      }
                      if (value.isEmpty) {
                        return 'Property Type is required';
                      }
                      return null;
                    },
                    selectedItem: this.propType.isNotEmpty
                        ? this.propType
                        : this.widget.listing!.sPropertyType))),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 7),
          child: IgnorePointer(
            ignoring: widget.enabled == false,
            child: TypeAheadFormField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: this.typeAheadController,
                decoration: InputDecoration(
                  counter: this.loadingZipcode
                      ? Container(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(
                            color: buttonsColor,
                            strokeWidth: 2,
                          ))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Visibility(
                                child: Text('Zip Code: ',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 12)),
                                visible: this.zipCode.isNotEmpty),
                            SizedBox(width: 0),
                            Text(this.zipCode,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
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
                  labelText: 'Address',
                ),
              ),
              suggestionsCallback: (pattern) async {
                if (pattern.length > 5) {
                  autocomplete = await servs.autocompletedAddress(pattern);
                  return autocomplete
                      .map((place) => place['description'])
                      .toList();
                } else {
                  if (widget.validAddress == true) {
                    this.widget.callbackValidAddress!(false);
                  }

                  return List.empty(growable: true);
                }
              },
              itemBuilder: (context, dynamic suggestion) {
                return ListTile(
                  title: Text(suggestion),
                );
              },
              transitionBuilder: (context, suggestionsBox, controller) {
                Widget widgetTest = Container();
                try {
                  widgetTest = suggestionsBox;
                  return widgetTest;
                } catch (e) {
                  FirebaseCrashlytics.instance
                      .recordError(e, StackTrace.current);
                  return widgetTest;
                }
              },
              onSuggestionSelected: (dynamic suggestion) async {
                setState(() {
                  this.loadingZipcode = true;
                  this.typeAheadController.text = suggestion;
                  this.widget.listing!.sPropertyAddress =
                      this.typeAheadController.text;
                  this.widget.listing!.sPropertyType = this.propType;
                });
                bool result = await setLocation(suggestion);
                if (result == true) {
                  this.widget.callback!(this.widget.listing!);
                  this.widget.callbackValidAddress!(true);

                  if (widget.listing!.sPropertyAddress!.isNotEmpty &&
                      widget.listing!.sZipCode!.isNotEmpty) {
                    await validateAddress();
                  }

                  if (this.widget.selectedIndex == 0) {
                    initialData();
                    this.widget.listing!.sPropertyAddress =
                        this.typeAheadController.text;
                    this.widget.listing!.sPropertyType = this.propType;
                    this.widget.listing!.propTypeChanged = this.propTypeChanged;
                    this.widget.listing!.sZipCode = this.zipCode;
                    this.widget.callback!(this.widget.listing!);
                    int index = propTypes.indexOf(this.propType);
                    this.widget.callbackSelectedIndex!(index + 1);
                  }
                }
              },
              validator: (value) {
                if (this.typeAheadController.text.isEmpty) {
                  return 'Address is required';
                }
                if (this.widget.listing!.sPropertyType == 'Apartment') {
                  if (this
                          .widget
                          .listing!
                          .sPropertyAddress!
                          .toLowerCase()
                          .contains('apt') ||
                      this.widget.listing!.sPropertyAddress!.contains('#') ||
                      this
                          .widget
                          .listing!
                          .sPropertyAddress!
                          .toLowerCase()
                          .contains('apartment')) {
                    return null;
                  } else {
                    return 'Please enter the apartment number';
                  }
                }
                if (this.widget.validAddress == false) {
                  return 'Enter a valid address';
                }
                return null;
              },
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: <Widget>[
              Switch(
                value: this.keepAddressPrivate,
                activeColor: headerColor,
                onChanged: (value) {
                  setState(() {
                    this.keepAddressPrivate = value;
                    this.widget.listing!.bKeepAddressPrivate =
                        this.keepAddressPrivate;
                    this.widget.callback!(this.widget.listing!);
                  });
                },
              ),
              SizedBox(
                width: 10,
              ),
              Text("Keep Address Private",
                  style: TextStyle(fontSize: 15, color: Colors.grey[800])),
              SizedBox(
                width: 10,
              ),
              Ink(
                child: IconButton(
                  icon: const Icon(Icons.help, size: 25),
                  color: baseColor,
                  onPressed: () {
                    showDialogInformation(
                        context,
                        'Users will only see the City/State/Zip code of your listing',
                        'Information');
                  },
                ),
              )
            ],
          ),
        ),
      ]);
    } catch (e) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      });
    }
    return widgetTest;
  }

  validateAddress() async {
    setState(() {
      this.widget.callbackLoadingNextStep!(true);
    });
    ResponseService response = await ListingFacade().validateListing(
        this.widget.listing!.sZipCode!,
        this.widget.listing!.sPropertyAddress!,
        this.widget.listing!.sApartmentNumber!,
        this.widget.listing!.sPropertyType!);

    if (response.hasConnection == false) {
      final flush = Flushbar(
        message: 'No Internet Connection',
        flushbarStyle: FlushbarStyle.FLOATING,
        margin: EdgeInsets.all(8.0),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        icon: Icon(
          Icons.wifi_off_outlined,
          size: 28.0,
          color: headerColor,
        ),
        duration: Duration(seconds: 2),
        leftBarIndicatorColor: headerColor,
      );
      flush.show(context);
    }

    //Success Response
    if (response.bSuccess!) {
      if (response.data.bContinue) {
        setState(() {
          this.widget.callbackLoadingNextStep!(false);
        });
      } else {
        if (response.data.sStatus == 'DraftSameUser') {
          showDialogAlert(
              context, response.data.sHeader, response.data.sDescription, true);
        } else {
          showDialogAlert(context, response.data.sHeader,
              response.data.sDescription, false);
        }
      }
    }
  }

  setLocation(String address) async {
    if (address.length > 0) {
      List<Location> locations = await locationFromAddress(address);
      if (locations.length > 0) {
        this.widget.listing!.sLatitud = locations[0].latitude;
        this.widget.listing!.sLongitud = locations[0].longitude;

        final key = autocomplete
            .firstWhere((element) => address == element['description']);

        String tempZipCode = await servs.getZipcodeByKey(key['place_id']);

        setState(() {
          this.zipCode = tempZipCode;
          this.widget.listing!.sZipCode = this.zipCode.toString();
          this.loadingZipcode = false;
        });
      }
      return true;
    }
    return false;
  }

  getListingDrafted() async {
    setState(() {
      this.loadingDraft = true;
    });
    Listing? result;
    ResponseService response = await ListingFacade().getDraft(
        this.widget.listing!.sZipCode!.isNotEmpty
            ? this.widget.listing!.sZipCode!
            : this.zipCode.toString(),
        this.widget.listing!.sPropertyAddress!,
        this.widget.listing!.sApartmentNumber!,
        this.widget.listing!.sPropertyType!);

    if (response.hasConnection == false) {
      final flush = Flushbar(
        message: 'No Internet Connection',
        flushbarStyle: FlushbarStyle.FLOATING,
        margin: EdgeInsets.all(8.0),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        icon: Icon(
          Icons.wifi_off_outlined,
          size: 28.0,
          color: headerColor,
        ),
        duration: Duration(seconds: 2),
        leftBarIndicatorColor: headerColor,
      );
      flush.show(context);
    }

    if (response.bSuccess!) {
      result = response.data as Listing;
    }
    setState(() {
      this.loadingDraft = false;
    });
    return result;
  }

  //DIALOG
  showDialogAlert(
      BuildContext context, String title, String content, bool isDraft) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Okay",
          style: TextStyle(
              color: buttonsColor, fontSize: 15, fontWeight: FontWeight.bold)),
      onPressed: () {
        Navigator.pop(dialogContext!);
        widget.callbackDispose!(true);
      },
    );
    Widget noButton = TextButton(
      child: Text("No",
          style: TextStyle(
              color: buttonsColor, fontSize: 15, fontWeight: FontWeight.bold)),
      onPressed: () {
        this.widget.callbackLoadingNextStep!(false);
        Navigator.pop(dialogContext!);
      },
    );
    Widget yesButton = TextButton(
      child: this.loadingDraft == false
          ? Text("Yes",
              style: TextStyle(
                  color: buttonsColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold))
          : CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(buttonsColor),
              strokeWidth: 2,
            ),
      onPressed: () async {
        final draft = await getListingDrafted();
        setState(() {
          this.widget.listing = draft;
          this.typeAheadController.text = draft.sPropertyAddress;
        });
        this.widget.callback!(draft);
        this.widget.callbackRefreshData!(true);
        int index = propTypes.indexOf(draft.sPropertyType);
        this.widget.callbackSelectedIndex!(index + 1);
        this.widget.callbackLoadingNextStep!(false);
        this.widget.callbackValidAddress!(true);
        Navigator.pop(dialogContext!);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        Visibility(child: cancelButton, visible: !isDraft),
        Visibility(child: noButton, visible: isDraft),
        Visibility(child: yesButton, visible: isDraft)
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        dialogContext = context;
        return alert;
      },
    );
  }

  showDialogInformation(BuildContext context, String title, String type) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Okay",
          style: TextStyle(
              color: headerColor, fontSize: 15, fontWeight: FontWeight.bold)),
      onPressed: () {
        this.widget.callbackLoadingNextStep!(false);
        Navigator.pop(dialogContext!);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(type),
      content: Text(title),
      actions: [
        cancelButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        dialogContext = context;
        return alert;
      },
    );
  }

  initialData() {
    setState(() {
      this.widget.listing = new Listing(
          uLystingId: '-1',
          sTitle: '',
          nFirstPrice: 0,
          nCurrentPrice: 0,
          sPropertyAddress: '',
          bKeepAddressPrivate: false,
          sPropertyDescription: '',
          sPropertyType: '',
          nBedrooms: 0,
          nBathrooms: 0,
          nHalfBaths: 0,
          nSqft: 0,
          nLotSize: 0.00,
          nYearBuilt: 1900,
          sCoolingType: '',
          sHeatingType: '',
          sParkingType: '',
          nCoveredParking: 0,
          sVacancyType: '',
          nEarnestMoney: 0,
          sEarnestMoneyTerms: '',
          sAdditionalDealTerms: ' ',
          sLotLegalDescription: ' ',
          nNumberofUnits: 1,
          sShowingDateTime: '',
          sZipCode: '',
          imagesAssets: [],
          sResourcesUrl: [],
          sAmenities: [],
          sCompsInfo: [],
          sLatitud: 0,
          sLongitud: 0,
          sApartmentNumber: '',
          sUnitArea: '',
          sTypeOfSell: '',
          sPropertyCondition: '',
          sIsInMLS: '',
          nMonthlyHoaFee: 0,
          sContactName: '',
          sContactNumber: '',
          sContactEmail: '',
          nEstARV: 0,
          sIsOwner: '',
          bComparableAvailable: false,
          bNetworkBlast: false,
          bBoostOnPlatforms: false,
          sTags: [],
          sLystingCategory: '');
    });
  }
}
