import 'dart:io';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/containers/widgets/add_house/wizard/stpes/marketing/marketing.component.dart';
import 'package:zipcular/containers/widgets/add_house/wizard/stpes/property-type/property-type.component.dart';
import 'package:zipcular/containers/widgets/add_house/wizard/stpes/sale-tab/sale_info.component.dart';
import 'package:zipcular/containers/widgets/common/cool_stepper/cool_step.component.dart';
import 'package:zipcular/containers/widgets/common/cool_stepper/cool_stepper.component.dart';
import 'package:zipcular/containers/widgets/common/cool_stepper/cool_stepper_config.component.dart';
import 'package:zipcular/models/common/response-service.model.dart';
import 'package:zipcular/models/listing/search/listing.dart';
import 'package:zipcular/repository/facade/listing.facade.dart';
import 'package:zipcular/repository/services/prod/google.service.dart';
import 'amenities.component.dart';
import 'comps.component.dart';
import 'congratulation.component.dart';
import 'deal-tab/deal.component.dart';
import 'images_gallery.component.dart';
import 'information-tab/info.component.dart';

class CreationWizard extends StatefulWidget {
  CreationWizard(
      {Key? key,
      this.title,
      this.listing,
      this.fromDraft,
      this.cleanWizardOffside,
      this.enableComponents,
      this.validAddress,
      this.selectedIndex})
      : super(key: key);

  String? title;
  Listing? listing;
  bool? fromDraft;
  bool? cleanWizardOffside;
  bool? enableComponents;
  bool? validAddress;
  int? selectedIndex;

  @override
  _CreationWizardState createState() => _CreationWizardState();
}

class _CreationWizardState extends State<CreationWizard> {
  final _formMarketing = GlobalKey<FormState>();
  final _formPropertyType = GlobalKey<FormState>();
  final _formInfoKey = GlobalKey<FormState>();
  final _formSaleKey = GlobalKey<FormState>();
  final _formDealKey = GlobalKey<FormState>();
  GoogleServs servs = new GoogleServs();
  Listing listingObj = new Listing();

  String sZipCode = '';
  int currentStep = 0;
  bool hasComps = false;
  bool keepPrivate = true;
  bool useContactInfo = false;
  BuildContext? dialogContext;
  bool loadingNextStep = false;
  bool cleanWizard = false;
  bool refreshData = false;
  bool loadingExit = false;
  double? sLatitud, sLongitud = 0;
  bool validMirrorAddress = false;

  @override
  void initState() {
    setState(() {
      this.listingObj = widget.listing!;
    });
    if (widget.cleanWizardOffside == true) {
      initialData();
    }
    super.initState();
  }

  @override
  void didUpdateWidget(CreationWizard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (this.currentStep == 0 && this.validMirrorAddress == true) {
      this.widget.validAddress = this.validMirrorAddress;
    }
    if (this.currentStep >= 1 &&
        (this.widget.validAddress == false ||
            oldWidget.validAddress == false)) {
      setState(() {
        this.widget.validAddress = true;
        if (this.listingObj.sZipCode!.isNotEmpty) {
          this.sZipCode = this.listingObj.sZipCode!;
        }
        if (this.listingObj.sLatitud != 0) {
          this.sLatitud = this.listingObj.sLatitud;
        }
        if (this.listingObj.sLongitud != 0) {
          this.sLongitud = this.listingObj.sLongitud;
        }
      });
      if (widget.selectedIndex == 0) {
        onStepIndex();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<CoolStep> steps = List.empty(growable: true);

    steps.add(
      //PROPERTY TYPE
      CoolStep(
        title: "Property Type",
        subtitle: "Select the option that best describe your property.",
        content: Form(
            key: _formPropertyType,
            child: PropertyTypeTab(
              validAddress: widget.validAddress!,
              listing: this.listingObj,
              enabled: widget.enableComponents!,
              fromDraft: this.widget.fromDraft!,
              selectedIndex: this.widget.selectedIndex!,
              callbackRefreshData: (value) {
                setState(() {
                  this.refreshData = value;
                });
              },
              callback: (val) {
                if (val.sPropertyType!.isNotEmpty) {
                  setState(() {
                    if (val.sZipCode!.isNotEmpty) {
                      this.sZipCode = val.sZipCode!;
                    }
                    if (this.listingObj.sLatitud != 0) {
                      this.sLatitud = this.listingObj.sLatitud;
                    }
                    if (this.listingObj.sLongitud != 0) {
                      this.sLongitud = this.listingObj.sLongitud;
                    }
                    this.listingObj = val;
                  });
                }
              },
              callbackDispose: (value) {
                if (value) {
                  Navigator.of(context).pop(true);
                }
              },
              callbackCleanWizard: (value) {
                setState(() {
                  if (this.listingObj.sPropertyType!.isNotEmpty) {
                    this.widget.validAddress = false;
                    this.validMirrorAddress = false;
                    this.cleanWizard = true;
                  }
                });
              },
              callbackSelectedIndex: (value) {
                setState(() {
                  this.widget.selectedIndex = value;
                });
              },
              callbackValidAddress: (value) {
                setState(() {
                  this.widget.validAddress = value;
                  if (value) {
                    this.validMirrorAddress = true;
                  }
                });
              },
              callbackLoadingNextStep: (value) {
                setState(() {
                  this.loadingNextStep = value;
                });
              },
            )),
        validation: () {
          bool valid = _formPropertyType.currentState!.validate();
          if (!valid || widget.selectedIndex == 0) {
            return "Please fill out required fields.";
          }
          if (this.widget.validAddress == false) {
            return "Please enter a valid address.";
          }
          return null;
        },
      ),
    );

    steps.add(
      //MARKETING
      CoolStep(
        title: 'Marketing',
        subtitle: '',
        content: Form(
          key: _formMarketing,
          child: Marketing(
              listing: this.listingObj,
              selectedIndex: this.widget.selectedIndex!,
              callbackSelectedIndex: (value) {
                setState(() {
                  this.widget.selectedIndex = value;
                });
              },
              callback: (val) {
                setState(() {
                  if (this.widget.validAddress == false) {
                    this.widget.validAddress = true;
                  }
                  this.listingObj = val;
                });
              }),
        ),
        validation: () {
          return null;
        },
      ),
    );

    steps.add(
      //LISTING SALE
      CoolStep(
          title: "Listing Information",
          subtitle:
              "Categorize your listing by choosing from the following options.",
          content: Form(
              key: _formSaleKey,
              child: SaleTab(
                  useContactInfo: useContactInfo,
                  listing: this.listingObj,
                  selectedIndex: this.widget.selectedIndex!,
                  callback: (val) {
                    setState(() {
                      this.listingObj = val;
                    });
                  },
                  callbackSelectedIndex: (value) {
                    setState(() {
                      this.widget.selectedIndex = value;
                    });
                  },
                  callbackContactInfo: (val) {
                    setState(() {
                      this.useContactInfo = val;
                      this.widget.validAddress = true;
                    });
                  },
                  enabled: false)),
          validation: () {
            bool valid = _formSaleKey.currentState!.validate();
            if (!valid) {
              return "Please fill out required fields.";
            }
            return null;
          }),
    );

    steps.add(
      //LISTING INFORMATION
      CoolStep(
        title: "Property Information",
        subtitle: "Fill out property details.",
        content: Form(
          key: _formInfoKey,
          child: InfoTab(
              listing: this.listingObj,
              selectedIndex: this.widget.selectedIndex!,
              enabled: true,
              callbackSelectedIndex: (value) {
                setState(() {
                  this.widget.selectedIndex = value;
                });
              },
              callback: (val) => setState(() {
                    if (this.widget.validAddress == false) {
                      this.widget.validAddress = true;
                    }
                    this.listingObj = val;
                  })),
        ),
        validation: () {
          bool valid = _formInfoKey.currentState!.validate();
          if (!valid) {
            return "Please fill out required fields.";
          }
          // Remove coment
          return null;
        },
      ),
    );

    steps.add(
      //LISTING DEAL INFORMATION
      CoolStep(
        title: "Additional Information",
        subtitle: "**********Text**********",
        content: Form(
          key: _formDealKey,
          child: DealTab(
              listing: this.listingObj,
              selectedIndex: this.widget.selectedIndex!,
              callbackSelectedIndex: (value) {
                setState(() {
                  this.widget.selectedIndex = value;
                });
              },
              callback: (val) => setState(() {
                    if (this.widget.validAddress == false) {
                      this.widget.validAddress = true;
                    }
                    this.listingObj = val;
                  })),
        ),
        validation: () {
          if (!_formDealKey.currentState!.validate()) {
            return "Please fill out required fields.";
          }
          return null;
        },
      ),
    );

    steps.add(
        //AMENITIES
        CoolStep(
            title: "Amenities",
            subtitle: "Select all amenities that apply to this property.",
            content: Amenities(
                listing: this.listingObj,
                selectedIndex: widget.selectedIndex!,
                callbackSelectedIndex: (value) {
                  setState(() {
                    this.widget.selectedIndex = value;
                  });
                },
                callback: (val) {
                  setState(() {
                    this.listingObj.sAmenities = val;
                  });
                }),
            validation: () {
              return null;
            }));

    steps.add(
        //COMPS
        CoolStep(
            title: "COMPARABLES",
            subtitle: "Provide a maximun of 5 comparable listings.",
            content: CompsView(
                listing: this.listingObj,
                selectedIndex: widget.selectedIndex!,
                callbackSelectedIndex: (value) {
                  setState(() {
                    this.widget.selectedIndex = value;
                  });
                },
                callback: (val) => setState(() {
                      if (this.widget.validAddress == false) {
                        this.widget.validAddress = true;
                      }
                      this.listingObj = val;
                    })),
            validation: () {
              return null;
            }));

    steps.add(
      //UPLOAD IMAGES
      CoolStep(
        title: "Add Photos",
        subtitle: "Choose up to 30 photos from your gallery.",
        content: ImagesGallery(
            listing: this.listingObj,
            callbackSelectedIndex: (value) {
              setState(() {
                this.widget.selectedIndex = value;
              });
            },
            callback: (val) {
              setState(() {
                if (this.widget.validAddress == false) {
                  this.widget.validAddress = true;
                }
                this.listingObj = val;
              });
            }),
        validation: () {
          if (this.listingObj.imagesAssets!.length == 0) {
            showDialogAlert(
                context, 'Please select at least one image!', 'Warning');
            return "Please fill out required fields.";
          }
          return null;
        },
      ),
    );

    steps.add(
        //LISTING COMPLETED
        CoolStep(
      title: "Complete Posting",
      subtitle:
          "By posting, you confirm this listing complies with zipcular Policies and all applicable laws.",
      content: Congratulation(
          listing: this.listingObj,
          zipCode: this.sZipCode,
          sLatitud: this.sLatitud ?? 0,
          sLongitud: this.sLongitud ?? 0),
      validation: () {
        return null;
      },
    ));

    final stepper = CoolStepper(
      cleanWizard: cleanWizard,
      showErrorSnackbar: true,
      validAddress: this.widget.validAddress,
      refreshData: refreshData,
      onCompleted: () {
        print("Steps completed!");
      },
      listing: this.listingObj,
      callback: (val) => setState(() {
        this.currentStep = val;
      }),
      callbackHasComps: (value) => setState(() {
        this.listingObj.bComparableAvailable = value;
      }),
      callbackListing: (val) {
        setState(() {
          if (this.cleanWizard == true) {
            this.useContactInfo = false;
            this.listingObj = val;
          }
          if (this.listingObj.sPropertyType!.isNotEmpty) {
            val.sPropertyType = this.listingObj.sPropertyType;
          }
          this.listingObj = val;
          this.cleanWizard = false;
        });
      },
      callbackRefreshData: (val) {
        if (this.listingObj.sPropertyType!.isNotEmpty) {
          setState(() {
            this.listingObj = val;
            this.refreshData = false;
          });
        }
      },
      loadingNextStep: loadingNextStep,
      hasComps: this.listingObj.bComparableAvailable,
      steps: steps,
      config: CoolStepperConfig(
          headerColor: Colors.grey[900],
          icon: Icon(Icons.inbox, color: Colors.grey[900]),
          titleTextStyle: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
          subtitleTextStyle: TextStyle(
              color: Colors.grey[200],
              fontWeight: FontWeight.bold,
              fontSize: 15),
          nextText: "Next",
          backText: "Back",
          finalText: "",
          isHeaderEnabled: true),
    );

    return new WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            Row(
              children: [
                this.currentStep <= 1
                    ? Container()
                    : GestureDetector(
                        onTap: () async {
                          final test = await showDialog(
                            context: context,
                            builder: (context) => new AlertDialog(
                              title: new Text('Save Draft',
                                  style: TextStyle(
                                      color: buttonsColor, fontSize: 20)),
                              content: new Text(
                                  'Are you sure you want to save this listing as draft?',
                                  style: TextStyle(
                                      color: buttonsColor, fontSize: 18)),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: new Text('No',
                                      style: TextStyle(
                                          color: buttonsColor, fontSize: 16)),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    setState(() {
                                      this.loadingExit = true;
                                    });
                                    await createDraft();
                                    Navigator.of(context).pop(true);
                                  },
                                  child: this.loadingExit == false
                                      ? Text('Yes',
                                          style: TextStyle(
                                              color: headerColor, fontSize: 16))
                                      : Container(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                new AlwaysStoppedAnimation<
                                                    Color>(headerColor),
                                          )),
                                )
                              ],
                            ),
                          );
                          if (test == true) {
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 5),
                          padding: EdgeInsets.only(left: 10, right: 10),
                          height: 35,
                          decoration: BoxDecoration(
                            color: headerColor,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.white,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Save Draft',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      )
              ],
            )
          ],
          title: Text(widget.title!, style: TextStyle(color: Colors.white)),
          backgroundColor: headerColor,
          toolbarHeight: 45,
          leading: IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () async {
              final test = await showDialog(
                context: context,
                builder: (context) => new AlertDialog(
                  title: new Text('Important',
                      style: TextStyle(color: buttonsColor, fontSize: 20)),
                  content: new Text(
                      'Are you sure you want to stop creating this listing?',
                      style: TextStyle(color: buttonsColor, fontSize: 18)),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: new Text('No',
                          style: TextStyle(color: buttonsColor, fontSize: 16)),
                    ),
                    Visibility(
                        visible: this.currentStep > 2,
                        child: TextButton(
                          onPressed: () async {
                            await createDraft();
                            Navigator.of(context).pop(true);
                          },
                          child: new Text('Save Draft',
                              style:
                                  TextStyle(color: headerColor, fontSize: 16)),
                        )),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          this.loadingExit = true;
                        });
                        Navigator.of(context).pop(true);
                      },
                      child: this.loadingExit == false
                          ? Text('Yes',
                              style:
                                  TextStyle(color: headerColor, fontSize: 16))
                          : Container(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    headerColor),
                              ),
                            ),
                    ),
                  ],
                ),
              );
              if (test == true) {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: Container(
          padding: Platform.isIOS
              ? EdgeInsets.only(bottom: 30)
              : EdgeInsets.only(bottom: 10),
          child: stepper,
        ),
      ),
    );
  }

  createDraft() async {
    // Init variables
    this.listingObj.sLongitud = this.listingObj.sLongitud != 0
        ? this.listingObj.sLongitud
        : this.sLongitud;
    this.listingObj.sLatitud = this.listingObj.sLatitud != 0
        ? this.listingObj.sLatitud
        : this.sLatitud;
    this.listingObj.sZipCode = this.listingObj.sZipCode!.isNotEmpty
        ? this.listingObj.sZipCode
        : this.sZipCode;
    // Create Draft Service
    ResponseService response =
        await ListingFacade().createDraft(this.listingObj);

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

    setState(() {
      this.loadingExit = false;
    });
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Important',
                style: TextStyle(color: buttonsColor, fontSize: 20)),
            content: new Text(
                'Are you sure you want to stop creating this listing?',
                style: TextStyle(color: buttonsColor, fontSize: 18)),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No',
                    style: TextStyle(color: buttonsColor, fontSize: 16)),
              ),
              Visibility(
                  visible: this.currentStep >= 1,
                  child: TextButton(
                    onPressed: () async {
                      setState(() {
                        this.loadingExit = true;
                      });
                      ResponseService response =
                          ListingFacade().createDraft(this.listingObj);

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

                      Navigator.of(context).pop(true);
                      Navigator.pop(context);
                    },
                    child: new Text('Save Draft',
                        style: TextStyle(color: headerColor, fontSize: 16)),
                  )),
              TextButton(
                onPressed: () {
                  setState(() {
                    this.loadingExit = true;
                  });
                  Navigator.of(context).pop(true);
                },
                child: this.loadingExit == false
                    ? Text('Yes',
                        style: TextStyle(color: headerColor, fontSize: 16))
                    : Container(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              new AlwaysStoppedAnimation<Color>(headerColor),
                        ),
                      ),
              ),
            ],
          ),
        )) ??
        false;
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
        title: Text(type), content: Text(title), actions: [cancelButton]);
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  onStepIndex() {
    final propTypes = [
      'Single Family',
      'Apartment',
      'Condo',
      'Townhome',
      'Lot',
      'Multi-Unit Complex'
    ];
    int index = propTypes.indexOf(this.listingObj.sPropertyType!);
    setState(() {
      this.widget.selectedIndex = index + 1;
    });
  }

  initialData() {
    setState(() {
      this.listingObj = new Listing(
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
