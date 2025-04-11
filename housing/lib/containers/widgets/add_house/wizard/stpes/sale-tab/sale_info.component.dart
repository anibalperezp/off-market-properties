import 'package:another_flushbar/flushbar.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zipcular/models/listing/search/listing.dart';
import 'package:zipcular/repository/provider/filter.provider.dart';
import 'package:zipcular/repository/services/prod/google.service.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class SaleTab extends StatefulWidget {
  SaleTab(
      {Key? key,
      this.useContactInfo,
      this.listing,
      this.selectedIndex,
      this.callback,
      this.enabled,
      this.callbackContactInfo,
      this.callbackSelectedIndex})
      : super(key: key);

  bool? useContactInfo;
  Listing? listing;
  int? selectedIndex;
  ValueChanged<Listing>? callback;
  ValueChanged<bool>? callbackContactInfo;
  bool? enabled;
  final ValueChanged<int>? callbackSelectedIndex;

  @override
  _SaleTabState createState() => _SaleTabState();
}

class _SaleTabState extends State<SaleTab> {
  GoogleServs servs = new GoogleServs();
  String propConditionController = '';
  String typeOfSellController = '';
  List<MultiSelectItem<dynamic>> _items = [];
  List<dynamic> _selectedTags = [];
  final beenSold = [
    "Fixer Upper",
    "Seller Financing",
    "Lease to Own",
    "Rent to Own",
    "Short Term Rental"
  ];
  final propTypes = [
    'Single Family',
    'Apartment',
    'Condo',
    'Townhome',
    'Lot',
    'Multi-Unit Complex'
  ];

  @override
  void initState() {
    this.propConditionController = this.widget.listing!.sPropertyCondition!;
    this.typeOfSellController = this.widget.listing!.sTypeOfSell!;
    final tags = Provider.of<FilterProvider>(context, listen: false)
        .filterSettingsModel!
        .sTags;
    _selectedTags = this.widget.listing!.sTags ?? [];

    for (var tag in tags) {
      _items.add(MultiSelectItem(tag, tag.toString()));
    }
    super.initState();
  }

  @override
  void didUpdateWidget(SaleTab oldWidget) {
    if (this.widget.listing!.sTypeOfSell != oldWidget.listing!.sTypeOfSell!) {
      this.widget.listing!.sTypeOfSell = this.typeOfSellController;
      this.widget.listing!.sPropertyCondition = this.propConditionController;
      this.widget.listing!.sTags = _selectedTags.cast<String>();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    if (this.widget.selectedIndex != 5 &&
        !beenSold.contains('Tenant Occupied Rental')) {
      beenSold.add('Tenant Occupied Rental');
    } else if (this.widget.selectedIndex == 5) {
      beenSold.remove('Fixer Upper');
      beenSold.remove('Short Term Rental');
      beenSold.remove('Tenant Occupied Rental');
    }
    return Column(
      children: [
        Padding(
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
                  labelText: "This property is being sold:",
                  hintText: "Select Property Type",
                  filled: true,
                ),
              ),
              items: beenSold,
              onChanged: (String? newValue) {
                setState(() {
                  this.typeOfSellController = newValue!;
                  this.widget.listing!.sTypeOfSell = newValue;
                  submitListing();
                });
              },
              validator: (String? value) {
                if (value!.isEmpty) {
                  return 'Required';
                }
                return null;
              },
              selectedItem: this.typeOfSellController),
        ),
        Visibility(
          visible: this.widget.selectedIndex != 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: DropdownSearch<String>(
                autoValidateMode: AutovalidateMode.onUserInteraction,
                popupProps: PopupProps.bottomSheet(
                  bottomSheetProps: BottomSheetProps(
                      elevation: 16, backgroundColor: Colors.white),
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
                    labelText: "Property Condition:",
                    hintText: "Select Condition",
                    filled: true,
                  ),
                ),
                items: ['Bad', 'Poor', 'Average', 'Good', 'Excellent'],
                onChanged: (newValue) {
                  setState(() {
                    this.propConditionController = newValue!;
                    this.widget.listing!.sPropertyCondition = newValue;
                    submitListing();
                  });
                },
                validator: (String? value) {
                  if (value!.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
                selectedItem: this.propConditionController),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: MultiSelectBottomSheetField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            initialValue: _selectedTags,
            initialChildSize: 0.6,
            listType: MultiSelectListType.CHIP,
            searchable: true,
            itemsTextStyle: TextStyle(fontSize: 17),
            searchHintStyle: TextStyle(fontSize: 17),
            buttonIcon: Icon(Icons.add_circle, color: headerColor, size: 28),
            buttonText: Text(
              "Select Tags",
              style: TextStyle(fontSize: 18),
            ),
            title: Text(
              "Tags",
              style: TextStyle(fontSize: 21),
            ),
            items: _items,
            validator: (values) {
              if (values == null || values.isEmpty) {
                return "Required";
              }
              if (values.length > 3) {
                return "You can only select 3 tags";
              }
              return null;
            },
            selectedColor: headerColor,
            checkColor: Colors.white,
            selectedItemsTextStyle:
                TextStyle(color: Colors.white, fontSize: 16),
            onConfirm: (values) {
              if (values.length > 3) {
                values.removeRange(3, values.length);
              }
              setState(() {
                _selectedTags = values.cast<dynamic>();
                if (_selectedTags.isNotEmpty) {
                  widget.listing!.sTags = _selectedTags.cast<String>();
                } else {
                  widget.listing!.sTags = [];
                }
              });
              widget.callback!(widget.listing!);
            },
            onSelectionChanged: (values) {
              values.length > 3
                  ? Flushbar(
                      backgroundColor: headerColor,
                      message: "You can only select 3 tags",
                      duration: Duration(seconds: 3),
                    ).show(context)
                  : null;
            },
            searchIcon: Icon(Icons.search, color: Colors.grey[800]),
            chipDisplay: MultiSelectChipDisplay(
              onTap: (value) {
                setState(() {
                  _selectedTags.remove(value);
                  if (_selectedTags.isNotEmpty) {
                    widget.listing!.sTags = _selectedTags.cast<String>();
                  } else {
                    widget.listing!.sTags = [];
                  }
                });
                widget.callback!(widget.listing!);
              },
            ),
          ),
        ),
      ],
    );
  }

  bool isConfirmEnabled() {
    return _selectedTags.length <= 3;
  }

  submitListing() {
    this.widget.callback!(this.widget.listing!);
    int index = propTypes.indexOf(this.widget.listing!.sPropertyType!);
    this.widget.callbackSelectedIndex!(index + 1);
  }

  bool isValidEmail(String value) {
    bool result = RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(value);
    return result;
  }
}
