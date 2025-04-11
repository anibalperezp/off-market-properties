import 'dart:io';
import 'dart:typed_data';
import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/containers/widgets/add_house/wizard/stpes/marketing/marketing.component.dart';
import 'package:zipcular/containers/widgets/add_house/wizard/stpes/property-type/property-type.component.dart';
import 'package:zipcular/containers/widgets/add_house/wizard/stpes/sale-tab/sale_info.component.dart';
import 'package:zipcular/models/common/response-service.model.dart';
import 'package:zipcular/models/listing/search/listing.dart';
import 'package:zipcular/repository/facade/listing.facade.dart';
import 'package:zipcular/repository/facade/upload_media.facade.dart';
import 'package:zipcular/repository/services/prod/google.service.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';
import '../../../repository/services/prod/upload_media.service.dart';
import '../../widgets/add_house/wizard/stpes/amenities.component.dart';
import '../../widgets/add_house/wizard/stpes/comps.component.dart';
import '../../widgets/add_house/wizard/stpes/deal-tab/deal.component.dart';
import '../../widgets/add_house/wizard/stpes/images_gallery.component.dart';
import '../../widgets/add_house/wizard/stpes/information-tab/info.component.dart';
import '../../widgets/common/cool_stepper/cool_step.component.dart';
import '../../widgets/common/cool_stepper/cool_stepper.component.dart';
import '../../widgets/common/cool_stepper/cool_stepper_config.component.dart';

class UpdateListing extends StatefulWidget {
  UpdateListing({Key? key, this.title, this.listingObj, this.selectedIndex})
      : super(key: key);

  Listing? listingObj;
  String? title;
  int? selectedIndex;

  @override
  _UpdateListingState createState() => _UpdateListingState();
}

class _UpdateListingState extends State<UpdateListing> {
  final _formPropertyType = GlobalKey<FormState>();
  final _formMarketing = GlobalKey<FormState>();
  final _formInfoKey = GlobalKey<FormState>();
  final _formSaleKey = GlobalKey<FormState>();
  final _formDealKey = GlobalKey<FormState>();
  GoogleServs servs = new GoogleServs();
  UploadMediaService uploadService = new UploadMediaService();
  UserRepository userRepository = new UserRepository();
  int currentStep = 0;
  bool hasComps = false;
  bool keepPrivate = true;
  bool useContactInfo = false;
  BuildContext? dialogContext;
  bool validAddress = true;
  bool loadingNextStep = false;
  bool cleanWizard = false;
  bool refreshData = false;
  bool isUpdateListingDialog = false;
  String message = "";
  int uploadImageCount = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<CoolStep> steps = List.empty(growable: true);
    steps.add(
      //LISTING TYPE
      CoolStep(
        title: "Property Type",
        subtitle: "Select the option that best describe your property.",
        content: Form(
            key: _formPropertyType,
            child: PropertyTypeTab(
                validAddress: validAddress,
                listing: widget.listingObj!,
                enabled: false,
                selectedIndex: this.widget.selectedIndex!,
                callbackRefreshData: (value) {
                  setState(() {
                    this.refreshData = value;
                  });
                },
                callback: (val) {
                  setState(() {
                    this.widget.listingObj = val;
                  });
                },
                callbackDispose: (value) {
                  if (value) {
                    Navigator.of(context).pop(true);
                  }
                },
                callbackCleanWizard: (value) {
                  setState(() {
                    this.validAddress = false;
                    this.cleanWizard = true;
                  });
                },
                callbackSelectedIndex: (value) {
                  setState(() {
                    this.widget.selectedIndex = value;
                  });
                },
                callbackValidAddress: (value) {
                  setState(() {
                    this.validAddress = value;
                  });
                },
                callbackLoadingNextStep: (value) {
                  setState(() {
                    this.loadingNextStep = value;
                  });
                })),
        validation: () {
          bool valid = _formPropertyType.currentState!.validate();
          if (!valid || widget.selectedIndex == -1) {
            return "Please fill out required fields.";
          }
          if (validAddress == false) {
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
              listing: widget.listingObj!,
              selectedIndex: this.widget.selectedIndex!,
              callbackSelectedIndex: (value) {
                setState(() {
                  this.widget.selectedIndex = value;
                });
              },
              callback: (val) {
                setState(() {
                  this.widget.listingObj = val;
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
                  listing: widget.listingObj!,
                  selectedIndex: this.widget.selectedIndex!,
                  callback: (val) {
                    setState(() {
                      this.widget.listingObj = val;
                    });
                  },
                  callbackContactInfo: (val) {
                    setState(() {
                      this.useContactInfo = val;
                    });
                  },
                  callbackSelectedIndex: (value) {
                    setState(() {
                      this.widget.selectedIndex = value;
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
            listing: widget.listingObj!,
            selectedIndex: this.widget.selectedIndex!,
            enabled: true,
            callback: (val) {
              setState(() {
                this.widget.listingObj = val;
              });
            },
            callbackSelectedIndex: (value) {
              setState(() {
                this.widget.selectedIndex = value;
              });
            },
          ),
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
              listing: widget.listingObj!,
              selectedIndex: this.widget.selectedIndex!,
              callbackSelectedIndex: (value) {
                setState(() {
                  this.widget.selectedIndex = value;
                });
              },
              callback: (val) => setState(() => this.widget.listingObj = val)),
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
                listing: widget.listingObj!,
                selectedIndex: widget.selectedIndex!,
                callbackSelectedIndex: (value) {
                  setState(() {
                    this.widget.selectedIndex = value;
                  });
                },
                callback: (val) {
                  setState(() {
                    widget.listingObj!.sAmenities = val;
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
                listing: widget.listingObj!,
                selectedIndex: widget.selectedIndex!,
                callbackSelectedIndex: (value) {
                  setState(() {
                    this.widget.selectedIndex = value;
                  });
                },
                callback: (val) {
                  setState(() {
                    widget.listingObj = val;
                  });
                }),
            validation: () {
              return null;
            }));

    steps.add(
      //UPLOAD IMAGES
      CoolStep(
        title: "Add Photos",
        subtitle: "Choose up to 30 photos from your gallery.",
        content: ImagesGallery(
            listing: this.widget.listingObj!,
            callbackSelectedIndex: (value) {
              setState(() {
                this.widget.selectedIndex = value;
              });
            },
            callback: (val) {
              setState(() {
                this.widget.listingObj = val;
              });
            }),
        validation: () {
          if (this.widget.listingObj?.imagesAssets!.length == 0) {
            showDialogAlert(
                context, 'Please select at least one image!', 'Warning');
            return "Please fill out required fields.";
          }
          return null;
        },
      ),
    );

    final stepper = CoolStepper(
      cleanWizard: cleanWizard,
      showErrorSnackbar: true,
      validAddress: validAddress,
      refreshData: refreshData,
      onCompleted: () {},
      listing: widget.listingObj!,
      callback: (val) => setState(() {
        this.currentStep = val;
      }),
      callbackHasComps: (value) => setState(() {
        widget.listingObj!.bComparableAvailable = value;
      }),
      callbackListing: (val) => setState(() {
        if (this.cleanWizard == true) {
          val.sPropertyType = this.widget.listingObj!.sPropertyType;
          this.useContactInfo = false;
        }
        this.widget.listingObj = val;
        this.cleanWizard = false;
      }),
      callbackRefreshData: (val) {
        setState(() {
          this.widget.listingObj = val;
          this.refreshData = false;
        });
      },
      loadingNextStep: loadingNextStep,
      hasComps: this.widget.listingObj!.bComparableAvailable!,
      steps: steps,
      config: CoolStepperConfig(
          headerColor: Colors.grey[900]!,
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
                this.currentStep <= 0
                    ? Container()
                    : GestureDetector(
                        onTap: () async {
                          final test = await showDialog(
                              context: context,
                              builder: (context) => new AlertDialog(
                                      title: new Text('Submit Changes',
                                          style: TextStyle(
                                              color: buttonsColor,
                                              fontSize: 20)),
                                      content: new Text(
                                          'Are you sure you want to submit changes?',
                                          style: TextStyle(
                                              color: buttonsColor,
                                              fontSize: 18)),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: new Text('No',
                                              style: TextStyle(
                                                  color: buttonsColor,
                                                  fontSize: 16)),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.of(context).pop(true);
                                          },
                                          child: new Text('Yes',
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 16)),
                                        )
                                      ]));
                          if (test == true) {
                            Tuple2<String, String> result =
                                await updateListing();
                            await userRepository.writeToken(
                                'loadMyListings', 'true');

                            if (result == null) {
                              Navigator.pop(context, true);
                            } else {
                              showDialogUpdateAlert(
                                  context, result.item1, result.item2);
                            }
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
                            child: Text('Submit',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
              ],
            )
          ],
          title: Text(widget.title!, style: TextStyle(color: Colors.white)),
          backgroundColor: headerColor,
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () async {
              final test = await showDialog(
                context: context,
                builder: (context) => new AlertDialog(
                  title: new Text('Important',
                      style: TextStyle(color: buttonsColor, fontSize: 20)),
                  content: new Text('Are you sure you want to go back?',
                      style: TextStyle(color: buttonsColor, fontSize: 18)),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(1),
                      child: new Text('No',
                          style: TextStyle(color: buttonsColor, fontSize: 16)),
                    ),
                    Visibility(
                        visible: this.currentStep > 1,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(2);
                          },
                          child: new Text('Submit Changes',
                              style:
                                  TextStyle(color: headerColor, fontSize: 16)),
                        )),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(3);
                      },
                      child: new Text('Yes',
                          style: TextStyle(color: Colors.red, fontSize: 16)),
                    ),
                  ],
                ),
              );
              if (test == 1) {
              } else if (test == 2) {
                Tuple2<String, String> result = await updateListing();
                await userRepository.writeToken('loadMyListings', 'true');
                if (result == null) {
                  Navigator.pop(context, true);
                } else {
                  showDialogUpdateAlert(context, result.item1, result.item2);
                }
              } else {
                Navigator.pop(context, true);
              }
            },
          ),
        ),
        body: this.isUpdateListingDialog == false
            ? Container(
                padding: Platform.isIOS
                    ? EdgeInsets.only(bottom: 30)
                    : EdgeInsets.only(bottom: 10),
                child: stepper)
            : Center(
                child: Container(
                  margin: EdgeInsets.only(bottom: 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  height: MediaQuery.of(context).size.height * 0.25,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(this.message,
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 20)),
                      SizedBox(height: 30),
                      Container(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              new AlwaysStoppedAnimation<Color>(headerColor),
                        ),
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text(
              'Information',
              style: TextStyle(color: buttonsColor, fontSize: 20),
            ),
            content: new Text(
              'Are you sure you want to go back?',
              style: TextStyle(color: buttonsColor, fontSize: 18),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text(
                  'No',
                  style: TextStyle(color: buttonsColor, fontSize: 16),
                ),
              ),
              Visibility(
                visible: this.currentStep >= 1,
                child: TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(true);
                  },
                  child: new Text(
                    'Submit',
                    style: TextStyle(color: headerColor, fontSize: 16),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: new Text(
                  'Yes',
                  style: TextStyle(color: Colors.red, fontSize: 16),
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

  //Dialog Update Changes
  showDialogUpdateAlert(
    BuildContext context,
    String title,
    String content,
  ) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Okay",
          style: TextStyle(
              color: buttonsColor, fontSize: 15, fontWeight: FontWeight.bold)),
      onPressed: () {
        Navigator.pop(dialogContext!);
        Navigator.of(context).pop(true);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [cancelButton],
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

  //Dialog Update Changes
  updateListing() async {
    setState(() {
      this.isUpdateListingDialog = true;
      this.message = "Updating Listing...";
    });

    bool hasImages = false;
    if (this.widget.listingObj!.imagesAssets != null &&
        this.widget.listingObj!.imagesAssets!.length > 0) {
      hasImages = true;
    }

    if (hasImages) {
      try {
        for (File asset in widget.listingObj!.imagesAssets!) {
          setState(() {
            this.message = "Upload Image " +
                uploadImageCount.toString() +
                " of " +
                widget.listingObj!.imagesAssets!.length.toString();
          });
          String url = 'US/' + widget.listingObj!.sSearch!.replaceAll('#', '/');
          ResponseService responseURL =
              await UploadMediaFacade().presignPhotoListing(url);

          Uint8List imageData = await asset.readAsBytes();

          imageData = await uploadService.compressList(imageData);

          if (responseURL.data != null) {
            await uploadService.uploadImage(
                baseBucket, responseURL.data, imageData);
            widget.listingObj!.sResourcesUrl
                .add(baseBucketSubmitMedia + responseURL.data.url);
            setState(() {
              this.uploadImageCount++;
            });
          }
        }
      } catch (e) {
        await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      }

      setState(() {
        this.message = '';
        this.uploadImageCount = 1;
      });
    }

    setState(() {
      this.message = "Updating Listing...";
    });

    ResponseService response =
        await ListingFacade().updateLysting(widget.listingObj!, hasImages);

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
      this.message = '';
      this.uploadImageCount = 1;
      this.isUpdateListingDialog = false;
    });

    if (response.bSuccess!) {
      if (response.data.sHeader != null && response.data.sDescription != null) {
        return Tuple2(response.data.sHeader as String,
            response.data.sDescription as String);
      } else {
        return Tuple2('Information', 'Successfully Updated Listing');
      }
    }
  }
}
