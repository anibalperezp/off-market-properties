import 'dart:io';
import 'dart:typed_data';
import 'package:another_flushbar/flushbar.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zipcular/commons/analytics.service.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/models/common/response-service.model.dart';
import 'package:zipcular/models/listing/search/listing.dart';
import 'package:zipcular/repository/facade/listing.facade.dart';
import 'package:zipcular/repository/facade/upload_media.facade.dart';
import 'package:zipcular/repository/services/prod/upload_media.service.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';

class Congratulation extends StatefulWidget {
  Congratulation(
      {Key? key, this.listing, this.zipCode, this.sLongitud, this.sLatitud})
      : super(key: key);
  Listing? listing;
  String? zipCode;
  double? sLatitud, sLongitud;
  @override
  _CongratulationState createState() => _CongratulationState();
}

class _CongratulationState extends State<Congratulation> {
  bool _isloading = false;
  bool _isButtonDisabled = false;
  ConfettiController? _confettiControllerCenter;
  bool goMarket = false;
  BuildContext? dialogContext;
  bool uploadingPhotos = false;
  Listing newListing = new Listing();
  UploadMediaService uploadService = new UploadMediaService();
  int uploadImageCount = 0;
  UserRepository userRepository = new UserRepository();
  String currentShareLink = '';

  @override
  void initState() {
    if (this.widget.listing!.sZipCode!.isEmpty) {
      this.widget.listing!.sZipCode = this.widget.zipCode;
    }
    if (this.widget.listing!.sLongitud == 0) {
      this.widget.listing!.sLongitud = this.widget.sLongitud;
    }
    if (this.widget.listing!.sLatitud == 0) {
      this.widget.listing!.sLatitud = this.widget.sLatitud;
    }

    _confettiControllerCenter =
        ConfettiController(duration: const Duration(seconds: 2));
    initialData();
    super.initState();
  }

  @override
  void dispose() {
    _confettiControllerCenter!.dispose();
    super.dispose();
  }

  processInsertion() async {
    setState(() {
      _isloading = true;
      _isButtonDisabled = true;
    });
    try {
      ResponseService response =
          await ListingFacade().createlysting(widget.listing!);
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
        final url = response.data.sDescription;

        setState(() {
          uploadingPhotos = true;
        });
        if (response.data.bContinue) {
          for (File asset in widget.listing!.imagesAssets!) {
            var responseURL =
                await UploadMediaFacade().presignPhotoListing(url as String);
            Uint8List imageData = await asset.readAsBytes();
            imageData = await uploadService.compressList(imageData);
            if (responseURL.data != null) {
              await uploadService.uploadImage(
                  baseBucket, responseURL.data, imageData);
              widget.listing!.sResourcesUrl
                  .add(baseBucketSubmitMedia + responseURL.data.url);
              if (widget.listing!.sResourcesUrl.length > 0) {
                await ListingFacade().submitMedia(
                    response.data.sHeader, widget.listing!.sResourcesUrl);
              }
              setState(() {
                uploadImageCount++;
              });
            }
          }
        }
        await ListingFacade().approveListing(response.data.sHeader);

        await createSocialShare(response.data.sHeader);

        setState(() {
          goMarket = true;
        });
        setState(() {
          if (goMarket) {
            _confettiControllerCenter!.play();
            showDialogAlert(context, "Go to the Market!");
          }
        });
      } else {
        createListingDialog(
            context, response.data.sHeader, response.data.sDescription);
      }
    } catch (e) {
      await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      setState(() {
        goMarket = true;
      });
      setState(() {
        if (goMarket) {
          _confettiControllerCenter!.play();
          showDialogAlert(context, "Go to the Market!");
        }
      });
    }
  }

  createSocialShare(String sSeachListingId) async {
    final oCcy = new NumberFormat("#,###", "en_US");
    final title =
        widget.listing!.sTypeOfSell! + ' - ' + widget.listing!.sPropertyType!;
    String description = '';
    String address = widget.listing!.sPropertyAddress!;
    String price = "Asking: \$${oCcy.format(widget.listing!.nFirstPrice)}";
    switch (widget.listing!.sPropertyType!) {
      case 'Single Family':
        description = widget.listing!.nBedrooms.toString() +
            ' Beds, ' +
            widget.listing!.nBathrooms.toString() +
            ' Baths, ' +
            widget.listing!.nSqft.toString() +
            ' sqft';
        break;
      case 'Apartment':
        description = widget.listing!.nBedrooms.toString() +
            ' Beds, ' +
            widget.listing!.nBathrooms.toString() +
            ' Baths, ' +
            widget.listing!.nSqft.toString() +
            ' sqft';
        break;
      case 'Condo':
        description = widget.listing!.nBedrooms.toString() +
            ' Beds, ' +
            widget.listing!.nBathrooms.toString() +
            ' Baths, ' +
            widget.listing!.nSqft.toString() +
            ' sqft';
        break;
      case 'Townhome':
        description = widget.listing!.nBedrooms.toString() +
            ' Beds, ' +
            widget.listing!.nBathrooms.toString() +
            ' Baths, ' +
            widget.listing!.nSqft.toString() +
            ' sqft';
        break;
      case 'Lot':
        description = widget.listing!.sLotSize!;
        break;
      case 'Multi-Unit Complex':
        description = widget.listing!.nNumberofUnits.toString() +
            ' Units, ' +
            widget.listing!.nSqft!.toString() +
            ' sqft';
        break;
    }

    final invitationCode = await userRepository.readKey('invitationCode');
    try {
      BranchContentMetaData metadata = BranchContentMetaData();
      metadata = BranchContentMetaData()
        ..addCustomMetadata('sSearch', sSeachListingId)
        ..addCustomMetadata('referal', invitationCode);

      // Setting image
      String image = widget.listing!.sResourcesUrl[0];

      // Creating BranchUniversalObject to share
      BranchUniversalObject branchUniversalObject = BranchUniversalObject(
          canonicalIdentifier: sSeachListingId,
          title: 'Great deal at Zeamless App. ' + price + '. ' + title,
          contentDescription: title +
              '\n' +
              price +
              '. At ' +
              address +
              '\n' +
              description +
              '\n' +
              'Check it out!',
          imageUrl: image,
          keywords: ['zeamless', 'social_app', 'real_estate', 'deep_linking'],
          publiclyIndex: true,
          locallyIndex: true,
          contentMetadata: metadata);

      final BranchLinkProperties linkProperties = BranchLinkProperties(
          channel: 'App',
          feature: 'sharing_listing',
          campaign: 'promotion',
          stage: 'new_share');

      final BranchResponse response = await FlutterBranchSdk.getShortUrl(
        linkProperties: linkProperties,
        buo: branchUniversalObject,
      );

      FlutterBranchSdk.clearPartnerParameters();

      if (response.success) {
        await ListingFacade()
            .updateSocialShare(sSeachListingId, response.result);
        setState(() {
          this.currentShareLink = response.result!;
        });
      }
    } catch (e) {
      await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
    }
  }

  shareOnFacebook() async {
    try {
      String quote = 'Your Page Title'; // getListingDescription();
      String urlToShare = currentShareLink.isNotEmpty
          ? currentShareLink
          : 'https://zeamless.app.link/4U1m2GePJBb';
      var url = Uri.https('www.facebook.com', '/dialog/feed', {
        'app_id': '220621334051031',
        'display': 'page',
        'caption': quote,
        'name': quote,
        'description': 'Some description here',
        "link": urlToShare,
        'quote': quote
      });
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error sharing content: $e');
    }
  }

  showDialogAlert(BuildContext context, String title) {
    Widget continueButton = TextButton(
      child:
          Text("Continue", style: TextStyle(color: headerColor, fontSize: 15)),
      onPressed: () {
        Navigator.pop(dialogContext!);
        Navigator.of(context).pop(true);
      },
    );
    Widget shareButton = TextButton(
      child: Text("Post To Facebook Group",
          style: TextStyle(color: Colors.blue, fontSize: 15)),
      onPressed: () async {
        Navigator.pop(dialogContext!);
        await shareOnFacebook();
        Navigator.of(context).pop(true);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Center(child: Text(title)),
      content: Text('Would you like to continue to check your ' +
          '"' +
          widget.listing!.sPropertyType! +
          '"' +
          ' new listing in the Market?'),
      actions: [shareButton, continueButton],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        dialogContext = context;
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.13),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ConfettiWidget(
            confettiController: _confettiControllerCenter!,
            blastDirectionality: BlastDirectionality.explosive,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            gravity: 0.05,
            shouldLoop: true,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple
            ],
          ),
          Visibility(
            visible: goMarket == false,
            child: Center(
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
                height: MediaQuery.of(context).size.height * 0.49,
                width: MediaQuery.of(context).size.width * 0.8,
                child: _isloading
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              uploadingPhotos == false
                                  ? 'Creating your listing...'
                                  : 'Uploading ' +
                                      uploadImageCount.toString() +
                                      '/' +
                                      widget.listing!.imagesAssets!.length
                                          .toString() +
                                      ' photos.',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 20)),
                          SizedBox(height: 30),
                          Container(
                              height: 30,
                              width: 30,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    headerColor),
                              ))
                        ],
                      )
                    : Column(
                        children: <Widget>[
                          SizedBox(height: 25),
                          Text("Almost There!!",
                              style: TextStyle(
                                  fontSize: 28,
                                  color: Color.fromRGBO(65, 64, 66, 1)),
                              textAlign: TextAlign.center),
                          SizedBox(height: 30),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                  "Your listing is now a few minutes away from going live. Will send you a confirmation email as soon as it gets approved. You can also check your listing's status on the Listing Manager Tab",
                                  style: TextStyle(
                                      fontSize: 19, color: Colors.grey[600]),
                                  textAlign: TextAlign.center)),
                          SizedBox(height: 35),
                          ElevatedButton(
                            style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.grey[300]!),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        headerColor),
                                padding: MaterialStateProperty.all<
                                    EdgeInsetsGeometry>(EdgeInsets.all(10)),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  side:
                                      BorderSide(color: Colors.white, width: 1),
                                  borderRadius: BorderRadius.circular(14.0),
                                ))),
                            onPressed: _isButtonDisabled
                                ? null
                                : () async {
                                    await AnalitysService().sendAnalyticsEvent(
                                        'wizard_submit_click', {
                                      "screen_view": "wizard_screen",
                                      "item_id": 'empty',
                                      'item_type': 'button'
                                    });
                                    processInsertion();
                                  },
                            child: Text('Submit',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white)),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  createListingDialog(BuildContext context, String title, String content) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Okay"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Center(child: Text(title)),
      content: Text(content),
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
      this.newListing = new Listing(
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
