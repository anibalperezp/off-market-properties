import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/currency_input_formatter.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/models/expandable/expandable_item.dart';
import '../../../../../models/listing/search/listing.dart';
import '../../../../../models/listing/search/listing_comp_info.dart';

class CompsView extends StatefulWidget {
  CompsView(
      {Key? key,
      this.listing,
      this.callback,
      this.selectedIndex,
      this.callbackSelectedIndex})
      : super(key: key);

  Listing? listing;
  ValueChanged<Listing>? callback;
  ValueChanged<int>? callbackSelectedIndex;
  int? selectedIndex;

  @override
  State<CompsView> createState() => _CompsViewState();
}

class _CompsViewState extends State<CompsView> {
  final propTypes = [
    'Single Family',
    'Apartment',
    'Condo',
    'Townhome',
    'Lot',
    'Multi-Unit Complex'
  ];

  List<ExpandableItem> _data = List.empty(growable: true);
  BuildContext? dialogContext;
  bool loading = false;
  String address = '';
  String price = '0';
  String url = '';
  bool isValidUrl = false;

  @override
  void initState() {
    _data = getDataFromComps();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(CompsView oldWidget) {
    if (oldWidget.listing!.sCompsInfo.length !=
        this.widget.listing!.sCompsInfo.length) {
      setState(() {
        this.widget.listing = oldWidget.listing;
      });
      if (oldWidget.listing!.sCompsInfo.length > 0) {
        oldWidget.listing!.sCompsInfo.forEach((comp) {
          _data.add(ExpandableItem(
              headerText: comp.sCompAddress,
              expandedText: comp.sCompLink,
              priceText: comp.nCompPrice,
              isExpanded: false));
        });
      } else {
        _data.clear();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  getDataFromComps() {
    if (this.widget.listing!.sCompsInfo.length > 0) {
      this.widget.listing!.sCompsInfo.forEach((comp) {
        _data.add(ExpandableItem(
            headerText: comp.sCompAddress,
            expandedText: comp.sCompLink,
            priceText: comp.nCompPrice,
            isExpanded: false));
      });
    } else {
      _data.clear();
    }
    return _data;
  }

  addComp() {
    if (this.widget.listing!.sCompsInfo.length < 5) {
      setState(() {
        this.widget.listing!.sCompsInfo.add(ListingCompInfo(
            nCompPrice: price, sCompAddress: address, sCompLink: url));
        _data.add(ExpandableItem(
            headerText: address,
            priceText: price,
            expandedText: url,
            isExpanded: false));
        this.address = '';
        this.price = '';
        this.url = '';
        // moneyController.updateValue(0);
      });
      this.widget.callback!(this.widget.listing!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(bottom: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 5,
            ),
            Visibility(
                visible: this.widget.listing!.sCompsInfo.length > 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Comparables List',
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    IconButton(
                      icon:
                          Icon(Icons.add_circle, color: buttonsColor, size: 30),
                      onPressed: () {
                        showDialogComps(context, 'Add Comparable', '');
                      },
                    )
                  ],
                )),
            Visibility(
                child: InkWell(
                  onTap: () {
                    showDialogComps(context, 'Add Comparable', '');
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 55,
                    decoration: BoxDecoration(
                      color: headerColor,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                            color: Color.fromRGBO(169, 176, 185, 0.42),
                            spreadRadius: 0,
                            blurRadius: 8,
                            offset: Offset(0, 2)),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Add Comps',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ),
                ),
                visible: this.widget.listing!.sCompsInfo.length == 0),
            SizedBox(
              height: 5,
            ),
            ExpansionPanelList(
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  _data[index].isExpanded = !isExpanded;
                });
              },
              children: _data.map<ExpansionPanel>((ExpandableItem item) {
                return ExpansionPanel(
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return ListTile(
                      title: Text('Address: ' + item.headerText,
                          style: TextStyle(color: Colors.grey[800])),
                    );
                  },
                  body: ListTile(
                      title: Text('Price: ' + '\$${item.priceText}',
                          style:
                              TextStyle(color: Colors.grey[700], fontSize: 16)),
                      subtitle: Text('URL: ' + item.expandedText),
                      trailing: const Icon(Icons.delete, color: Colors.red),
                      onTap: () {
                        setState(() {
                          _data.removeWhere((ExpandableItem currentItem) =>
                              item == currentItem);
                          this
                              .widget
                              .listing!
                              .sCompsInfo
                              .cast<ListingCompInfo>()
                              .removeWhere((ListingCompInfo currentItem) =>
                                  item.headerText == currentItem.sCompAddress);
                        });
                        int index = propTypes
                            .indexOf(this.widget.listing!.sPropertyType!);
                        this.widget.callbackSelectedIndex!(index + 1);
                        this.widget.callback!(this.widget.listing!);
                      }),
                  isExpanded: item.isExpanded,
                );
              }).toList(),
            ),
          ],
        ));
  }

  showDialogComps(BuildContext context, String title, String content) {
    // set up the buttons
    Widget noButton = TextButton(
        child: Text("No",
            style: TextStyle(
                color: buttonsColor,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        onPressed: () {
          setState(() {
            this.isValidUrl = false;
            this.address = '';
            this.price = '';
            this.url = '';
            this.isValidUrl = false;
          });
          Navigator.pop(dialogContext!);
        });
    Widget yesButton = TextButton(
        child: loading == false
            ? Text("Save",
                style: TextStyle(
                    color: buttonsColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold))
            : CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(buttonsColor),
              ),
        onPressed: () {
          if (this.address.isNotEmpty &&
              (this.url.contains('redfin') ||
                  this.url.contains('zillow') ||
                  this.url.contains('realtor') ||
                  this.url.contains('trulia'))) {
            addComp();
            setState(() {
              this.isValidUrl = false;
              this.address = '';
              this.price = '';
              this.url = '';
            });

            Navigator.pop(dialogContext!);
          } else {
            var messageError = '';
            if (this.address.isEmpty) {
              messageError = 'Please enter an address';
            } else {
              messageError = 'Please enter a valid URL';
            }
            final flush = Flushbar(
              message: messageError,
              flushbarStyle: FlushbarStyle.FLOATING,
              margin: EdgeInsets.all(8.0),
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              icon: Icon(
                Icons.info_outline,
                size: 28.0,
                color: Theme.of(context).primaryColor,
              ),
              duration: Duration(seconds: 2),
              leftBarIndicatorColor: Theme.of(context).primaryColor,
            );
            flush.show(context);
          }
        });

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Container(
          height: MediaQuery.of(context).size.width / 1.3,
          width: MediaQuery.of(context).size.width / 1.4,
          child: SingleChildScrollView(
              child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onFieldSubmitted: (value) {
                  this.address = value;
                },
                minLines: 1,
                maxLines: 2,
                maxLength: 70,
                autocorrect: true,
                decoration: InputDecoration(
                  labelText: 'Address',
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
                textInputAction: TextInputAction.next,
                onChanged: (value) {
                  setState(() {
                    this.address = value;
                  });
                },
                onEditingComplete: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);

                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                },
                validator: (String? value) {
                  if (value!.isEmpty == true || value.length < 5) {
                    return 'Address Required';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 25,
              ),
              TextFormField(
                inputFormatters: [
                  CurrencyInputFormatter(
                      leadingSymbol: CurrencySymbols.DOLLAR_SIGN,
                      mantissaLength: 3)
                ],
                onFieldSubmitted: (v) {
                  this.price = v;
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                },
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.numberWithOptions(decimal: false),
                //controller: moneyController,
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
                  labelText: 'Sold Price',
                ),
                maxLength: 11,
                onChanged: (value) {
                  setState(() {
                    if (value.isEmpty || value == '\$') {
                      this.price = '0';
                    } else {
                      this.price = value;
                    }
                  });
                },
                validator: (value) {
                  return null;
                },
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onFieldSubmitted: (value) {
                  this.url = value.toLowerCase();
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(
                      "[a-z0-9/\.\,\!\?\:\;\-\_\@]")), // Only allow lowercase letters
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    // Convert to lowercase
                    return newValue.copyWith(text: newValue.text.toLowerCase());
                  }),
                ],
                autocorrect: true,
                minLines: 2,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Property Web Link',
                  hintText: 'Only redfin, zillow, realtor or trulia links',
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
                textInputAction: TextInputAction.next,
                onEditingComplete: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);

                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                },
                onChanged: (value) {
                  setState(() {
                    this.url = value.toLowerCase();
                  });
                },
                validator: (String? value) {
                  if (value!.isEmpty == true) {
                    return 'Required';
                  } else if (value.isEmpty == false) {
                    bool validUTL =
                        Uri.tryParse(value)?.hasAbsolutePath ?? false;
                    if (!validUTL) {
                      return 'Please enter a valid Web Link';
                    } else if (validUTL &&
                        (value.contains('redfin') ||
                            value.contains('zillow') ||
                            value.contains('realtor') ||
                            value.contains('trulia'))) {
                      this.isValidUrl = true;
                      return null;
                    } else {
                      return 'Invalid Realstate Website.';
                    }
                  }
                  return null;
                },
              ),
            ],
          ))),
      actions: [noButton, yesButton],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        dialogContext = context;
        return alert;
      },
    ).then((value) => {
          this.widget.callbackSelectedIndex!(
              propTypes.indexOf(this.widget.listing!.sPropertyType!))
        });
  }
}
