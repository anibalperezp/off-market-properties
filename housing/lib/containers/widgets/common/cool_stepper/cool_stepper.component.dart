import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:zipcular/commons/analytics.service.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import '../../../../models/listing/search/listing.dart';
import 'cool_step.component.dart';
import 'cool_stepper_config.component.dart';
import 'cool_stepper_view.component.dart';

class CoolStepper extends StatefulWidget {
  final List<CoolStep>? steps;
  final VoidCallback? onCompleted;
  final EdgeInsetsGeometry? contentPadding;
  final CoolStepperConfig? config;
  final bool? showErrorSnackbar;
  final ValueChanged<int>? callback;
  final ValueChanged<bool>? callbackHasComps;
  final bool? hasComps;
  final bool? validAddress;
  final Listing? listing;
  final bool? loadingNextStep;
  final ValueChanged<Listing>? callbackListing;
  final ValueChanged<Listing>? callbackRefreshData;
  final bool? refreshData;
  final bool? cleanWizard;

  CoolStepper(
      {Key? key,
      this.steps,
      this.onCompleted,
      this.listing,
      this.contentPadding = const EdgeInsets.symmetric(horizontal: 20.0),
      this.config = const CoolStepperConfig(),
      this.showErrorSnackbar = false,
      this.callback,
      this.callbackHasComps,
      this.hasComps,
      this.validAddress,
      this.loadingNextStep,
      this.callbackListing,
      this.callbackRefreshData,
      this.refreshData,
      this.cleanWizard})
      : super(key: key);

  @override
  _CoolStepperState createState() => _CoolStepperState();
}

class _CoolStepperState extends State<CoolStepper> {
  PageController _controller = PageController();
  int currentStep = 0;
  bool loadingDraft = false;
  BuildContext? dialogContext;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> switchToPage(int page) async {
    await _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  bool _isFirst(int index) {
    return index == 0;
  }

  bool _isLast(int index) {
    return widget.steps!.length - 1 == index;
  }

  Future<void> onStepNext() async {
    final validation = widget.steps![currentStep].validation();

    if (validation == null) {
      if (!_isLast(currentStep)) {
        if (currentStep == 5) {
          if (this.widget.hasComps!) {
            setState(() {
              currentStep++;
            });

            this.widget.callbackListing!(this.widget.listing!);
            this.widget.callback!(this.currentStep);
            FocusScope.of(context).unfocus();
            await switchToPage(currentStep);
            await AnalitysService().setCurrentScreen(
                'on_wizzard_' + (currentStep + 1).toString() + '_step',
                'CoolStepper');
          } else {
            showDialogComps(context, 'Comparable Sales',
                'Do you have comparable sales for the last 6 months?');
          }
        } else {
          setState(() {
            currentStep++;
          });

          this.widget.callbackListing!(this.widget.listing!);
          this.widget.callback!(this.currentStep);
          FocusScope.of(context).unfocus();
          switchToPage(currentStep);
          await AnalitysService().setCurrentScreen(
              'on_wizzard_' + (currentStep + 1).toString() + '_step',
              'CoolStepper');
        }
      } else {
        widget.onCompleted!();
      }
    } else {
      if (widget.showErrorSnackbar!) {
        final flush = Flushbar(
          message: validation,
          flushbarStyle: FlushbarStyle.FLOATING,
          margin: EdgeInsets.all(8.0),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          icon: Icon(
            Icons.info_outline,
            size: 28.0,
            color: headerColor,
          ),
          duration: Duration(seconds: 2),
          leftBarIndicatorColor: headerColor,
        );
        flush.show(context);
      }
    }
  }

  Future<void> onStepBack() async {
    if (!_isFirst(currentStep)) {
      if (currentStep == 7) {
        if (this.widget.hasComps!) {
          setState(() {
            currentStep--;
          });
        } else {
          setState(() {
            currentStep = currentStep - 2;
          });
        }
      } else {
        setState(() {
          currentStep--;
        });
      }
      switchToPage(currentStep);
      await AnalitysService().setCurrentScreen(
          'on_wizzard_' + (currentStep + 1).toString() + '_step',
          'CoolStepper');
      this.widget.callback!(this.currentStep);
      this.widget.callbackListing!(this.widget.listing!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Expanded(
      child: PageView(
        controller: _controller,
        physics: NeverScrollableScrollPhysics(),
        children: widget.steps!.map((step) {
          return CoolStepperView(
            step: step,
            contentPadding: widget.contentPadding!,
            config: widget.config!,
          );
        }).toList(),
      ),
    );

    final counter = Container(
      child: Text(
        "${currentStep + 1} ${widget.config!.ofText ?? 'Of'} ${widget.steps!.length}",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
      ),
    );

    String getNextLabel() {
      String nextLabel;
      if (_isLast(currentStep)) {
        nextLabel = widget.config!.finalText ?? 'FINISH';
      } else {
        if (widget.config!.nextTextList != null) {
          nextLabel = widget.config!.nextTextList![currentStep];
        } else {
          nextLabel = widget.config!.nextText ?? 'NEXT';
        }
      }
      return nextLabel;
    }

    String getPrevLabel() {
      String backLabel;
      if (_isFirst(currentStep)) {
        backLabel = '';
      } else {
        if (widget.config!.backTextList != null) {
          backLabel = widget.config!.backTextList![currentStep - 1];
        } else {
          backLabel = widget.config!.backText ?? 'PREV';
        }
      }
      return backLabel;
    }

    final buttons = Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TextButton(
            onPressed: onStepBack,
            child: Text(
              getPrevLabel(),
              style: TextStyle(color: buttonsColor, fontSize: 18),
            ),
          ),
          counter,
          widget.loadingNextStep == true
              ? Container(
                  padding: EdgeInsets.only(right: 15),
                  height: 20,
                  width: 35,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: headerColor,
                  ))
              : TextButton(
                  onPressed: () {
                    if (this.widget.validAddress == true) {
                      onStepNext();
                    }
                  },
                  child: Text(
                    getNextLabel(),
                    style: TextStyle(
                        color: this.widget.validAddress == false
                            ? Colors.grey[400]
                            : headerColor,
                        fontSize: 18),
                  ),
                ),
        ],
      ),
    );
    if (this.widget.refreshData == true) {
      Future.delayed(Duration.zero).then((value) {
        this.widget.callbackRefreshData!(this.widget.listing!);
      });
    }
    if (this.widget.cleanWizard == true) {
      Future.delayed(Duration.zero).then((value) {
        final listingObj = new Listing(
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
            sTags: [],
            sLystingCategory: '');
        this.widget.callbackListing!(listingObj);
      });
    }
    return Container(
      child: Column(
        children: [content, buttons],
      ),
    );
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
            currentStep = 7;
          });
          this.widget.callbackListing!(this.widget.listing!);
          this.widget.callback!(this.currentStep);
          this.widget.callbackHasComps!(false);
          FocusScope.of(context).unfocus();
          switchToPage(currentStep);
          Navigator.pop(dialogContext!);
        });
    Widget yesButton = TextButton(
        child: Text("Yes",
            style: TextStyle(
                color: buttonsColor,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        onPressed: () {
          setState(() {
            currentStep++;
          });
          this.widget.callbackListing!(this.widget.listing!);
          this.widget.callback!(this.currentStep);
          this.widget.callbackHasComps!(true);
          FocusScope.of(context).unfocus();
          switchToPage(currentStep);
          Navigator.pop(dialogContext!);
        });

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [noButton, yesButton],
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
}
