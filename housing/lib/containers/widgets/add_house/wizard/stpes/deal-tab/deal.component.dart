import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/models/listing/search/listing.dart';
import 'package:intl/intl.dart';

class DealTab extends StatefulWidget {
  DealTab(
      {Key? key,
      this.listing,
      this.selectedIndex,
      this.callback,
      this.callbackSelectedIndex})
      : super(key: key);

  Listing? listing;
  int? selectedIndex;
  ValueChanged<Listing>? callback;
  ValueChanged<int>? callbackSelectedIndex;

  @override
  _DealTabState createState() => _DealTabState();
}

class _DealTabState extends State<DealTab> {
  final propTypes = [
    'Single Family',
    'Apartment',
    'Condo',
    'Townhome',
    'Lot',
    'Multi-Unit Complex'
  ];
  var formatter = new NumberFormat("#,###,###", "en_US");
  String earnestMoney = '0';
  String sEarnestMoneyMoneyController = '';
  String sIsOwnerController = '';
  String sListingCategoryController = '';
  final format = DateFormat("yyyy-MM-dd HH:mm");
  final TextEditingController _additionalTermController =
      TextEditingController();
  final TextEditingController _salesPitchController =
      new TextEditingController();
  final TextEditingController _propertyDescriptionController =
      TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _nEarnestMoneyController =
      TextEditingController();
  final FocusNode _textFieldHeadLineFocusNode = FocusNode();
  final FocusNode _textFieldPropDescFocusNode = FocusNode();
  final FocusNode _textFieldEarnestMoneyFocusNode = FocusNode();
  final FocusNode _textFieldDisclaimerFocusNode = FocusNode();

  @override
  void initState() {
    this.earnestMoney = widget.listing!.nEarnestMoney == null
        ? '0'
        : widget.listing!.nEarnestMoney.toString();
    this._nEarnestMoneyController.text =
        this.earnestMoney == '0' || this.earnestMoney.isEmpty
            ? ''
            : "\$${this.formatter.format(this.widget.listing!.nEarnestMoney)}";
    this._salesPitchController.text = this.widget.listing!.sTitle!;
    this._propertyDescriptionController.text =
        this.widget.listing!.sPropertyDescription!;
    this._additionalTermController.text = widget.listing!.sAdditionalDealTerms!;
    this._dateController.text = widget.listing!.sShowingDateTime!;
    this.sEarnestMoneyMoneyController = widget.listing!.sEarnestMoneyTerms!;
    this.sIsOwnerController = widget.listing!.sIsOwner!;
    this.sListingCategoryController = widget.listing!.sLystingCategory!;
    super.initState();
  }

  @override
  void didUpdateWidget(DealTab oldWidget) {
    this.widget.listing = oldWidget.listing;
    this.widget.listing!.sTitle = this._salesPitchController.text ?? '';
    this.widget.listing!.sPropertyDescription =
        this._propertyDescriptionController.text ?? '';
    this.widget.listing!.sAdditionalDealTerms =
        this._additionalTermController.text ?? '';
    this.widget.listing!.nEarnestMoney = int.parse(this.earnestMoney);
    this.widget.listing!.sShowingDateTime =
        this._dateController.text.isEmpty ? '' : this._dateController.text;
    this.widget.listing!.sEarnestMoneyTerms =
        this.sEarnestMoneyMoneyController.isEmpty
            ? ''
            : this.sEarnestMoneyMoneyController;
    this.widget.listing!.sIsOwner =
        this.sIsOwnerController.isEmpty ? '' : this.sIsOwnerController;
    this.widget.listing!.sLystingCategory = this.sListingCategoryController;

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    this._salesPitchController.dispose();
    this._propertyDescriptionController.dispose();
    this._additionalTermController.dispose();
    this._dateController.dispose();
    this._nEarnestMoneyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //Default
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: TextFormField(
            focusNode: _textFieldHeadLineFocusNode,
            toolbarOptions: ToolbarOptions(
              copy: true,
              cut: true,
              paste: true,
              selectAll: true,
            ),
            onFieldSubmitted: (v) {
              unfocusField();
              submitListing();
            },
            autocorrect: true,
            controller: this._salesPitchController,
            decoration: InputDecoration(
              hintText: 'Please do not include contact information',
              labelText: 'Listing Headline (Optional)',
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
            ),
            minLines: 1,
            maxLines: 6,
            textInputAction: TextInputAction.next,
            onChanged: (value) {
              setState(() {
                this.widget.listing!.sTitle = this._salesPitchController.text;
                submitListing();
              });
            },
            validator: (String? value) {
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: TextFormField(
            focusNode: _textFieldPropDescFocusNode,
            toolbarOptions: ToolbarOptions(
              copy: true,
              cut: true,
              paste: true,
              selectAll: true,
            ),
            onFieldSubmitted: (v) {
              unfocusField();
              this.widget.callback!(this.widget.listing!);
            },
            minLines: 1,
            maxLines: 6,
            autocorrect: true,
            maxLength: 3000,
            textInputAction: TextInputAction.next,
            controller: this._propertyDescriptionController,
            decoration: InputDecoration(
              hintText: 'Please do not include contact information',
              labelText: 'Property Description (Optional)',
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
            ),
            onChanged: (value) {
              setState(() {
                this.widget.listing!.sPropertyDescription =
                    this._propertyDescriptionController.text;
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

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: TextFormField(
            focusNode: _textFieldEarnestMoneyFocusNode,
            controller: this._nEarnestMoneyController,
            inputFormatters: [
              CurrencyInputFormatter(
                  thousandSeparator: ThousandSeparator.Comma,
                  leadingSymbol: CurrencySymbols.DOLLAR_SIGN,
                  mantissaLength: 0)
            ],
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            onFieldSubmitted: (value) {
              if (value.isEmpty || value == '\$') {
                widget.listing!.nEarnestMoney = 0;
                this.earnestMoney = '0';
              } else {
                widget.listing!.nEarnestMoney = int.tryParse(
                    this.earnestMoney.replaceAll('\$', '').replaceAll(',', ''));
              }
              unfocusField();
              submitListing();
            },
            maxLength: 8,
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
              labelText: 'Earnest Money Deposit (Optional)',
            ),
            onChanged: (value) {
              setState(() {
                if (value.isEmpty || value == '\$') {
                  widget.listing!.nEarnestMoney = 0;
                  this.earnestMoney = '0';
                } else {
                  this.earnestMoney =
                      value.replaceAll('\$', '').replaceAll(',', '');
                  widget.listing!.nEarnestMoney = int.tryParse(earnestMoney);
                }
                submitListing();
              });
            },
            validator: (String? value) {
              if (widget.listing!.nEarnestMoney == null) {
                widget.listing!.nEarnestMoney = 0;
              }

              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: DropdownSearch<String>(
              items: ['Non Refundable', 'No Earnest Money'],
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
                  labelText: "Earnest Money Deposit Terms",
                  hintText: "This is required",
                  filled: true,
                ),
              ),
              onChanged: (String? newValue) {
                unfocusField();
                setState(() {
                  this.sEarnestMoneyMoneyController = newValue!;
                  submitListing();
                });
              },
              autoValidateMode: AutovalidateMode.onUserInteraction,
              validator: (String? value) {
                if (value!.isEmpty) {
                  return 'Required';
                }
                return null;
              },
              selectedItem: this.sEarnestMoneyMoneyController),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Focus(
            descendantsAreFocusable: true,
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                submitListing();
              }
            },
            child: TextFormField(
              focusNode: _textFieldDisclaimerFocusNode,
              controller: _additionalTermController,
              onFieldSubmitted: (v) {
                unfocusField();
                submitListing();
              },
              minLines: 1,
              maxLines: 6,
              toolbarOptions: ToolbarOptions(
                copy: true,
                cut: true,
                paste: true,
                selectAll: true,
              ),
              autocorrect: true,
              maxLength: 3000,
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
                labelText: 'Your Conditions & Disclaimers (Optional)',
                hintText: "Please do not include contact information",
              ),
              onChanged: (value) {
                setState(() {
                  widget.listing!.sAdditionalDealTerms =
                      _additionalTermController.text;
                });
              },
              onEditingComplete: () {
                unfocusField();
              },
              validator: (String? value) {
                return null;
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: DropdownSearch<String>(
              items: ['Yes', 'No'],
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
                  labelText:
                      "Do you or your company own this property? (Optional)",
                  hintText: "Yes or No",
                  filled: true,
                ),
              ),
              onChanged: (String? newValue) {
                unfocusField();
                setState(() {
                  this.sIsOwnerController = newValue!;
                  submitListing();
                });
              },
              validator: (String? value) {
                return null;
              },
              selectedItem: this.sIsOwnerController),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: DropdownSearch<String>(
              autoValidateMode: AutovalidateMode.onUserInteraction,
              items: ['Off market', 'Listed in the MLS'],
              popupProps: PopupProps.bottomSheet(
                bottomSheetProps: BottomSheetProps(
                  elevation: 16,
                  backgroundColor: Colors.white,
                ),
              ),
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  fillColor: Colors.white,
                  labelText: "What is the market status?",
                  hintText: "This is required",
                  filled: true,
                ),
              ),
              onChanged: (String? newValue) {
                unfocusField();
                setState(
                  () {
                    this.sListingCategoryController = newValue!;
                    submitListing();
                  },
                );
              },
              validator: (String? value) {
                if (value!.isEmpty) {
                  return 'Required';
                }
                return null;
              },
              selectedItem: this.sListingCategoryController),
        ),

        //Multi-Unit Complex
        Visibility(
          visible: this.widget.selectedIndex != 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: DateTimeField(
              controller: _dateController,
              decoration: InputDecoration(
                fillColor: headerColor,
                labelText: 'Property Showing Date (Optional)',
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
              ),
              format: format,
              onChanged: (value) {
                setState(() {
                  widget.listing!.sShowingDateTime =
                      new DateFormat("MM/dd/yy HH: mm a").format(value!);
                  submitListing();
                });
              },
              validator: (value) {
                return null;
              },
              onShowPicker: (context, currentValue) async {
                final date = await showDatePicker(
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: ColorScheme.light(
                            primary: headerColor,
                          ),
                        ),
                        child: child!,
                      );
                    },
                    context: context,
                    firstDate: DateTime.now(),
                    initialDate: currentValue ?? DateTime.now(),
                    lastDate: DateTime(DateTime.now().year + 1));
                if (date != null) {
                  final time = await showTimePicker(
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: ColorScheme.light(
                            primary: headerColor,
                          ),
                        ),
                        child: child!,
                      );
                    },
                    context: context,
                    initialTime:
                        TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                  );
                  return DateTimeField.combine(date, time);
                } else {
                  return currentValue;
                }
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

  unfocusField() {
    _textFieldHeadLineFocusNode.unfocus();
    _textFieldPropDescFocusNode.unfocus();
    _textFieldEarnestMoneyFocusNode.unfocus();
    _textFieldDisclaimerFocusNode.unfocus();
  }

  showDialogAlert(BuildContext context, String title, String type) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Okay",
          style: TextStyle(
              color: headerColor, fontSize: 15, fontWeight: FontWeight.bold)),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
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
        return alert;
      },
    );
  }
}
