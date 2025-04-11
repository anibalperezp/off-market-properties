import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/models/common/response-service.model.dart';
import 'package:zipcular/repository/facade/listing.facade.dart';
import '../../../models/listing/draft.dart';
import '../../widgets/add_house/wizard/stpes/creation_wizard_house.component.dart';

class DraftCard extends StatefulWidget {
  ValueChanged<String> callbackRemoveListing;
  Draft draft;
  DraftCard(
      {Key? key, Draft? draft, ValueChanged<String>? callbackRemoveListing})
      : draft = draft!,
        callbackRemoveListing = callbackRemoveListing!,
        super(key: key);

  @override
  State<DraftCard> createState() => _DraftCardState();
}

class _DraftCardState extends State<DraftCard> {
  bool loadingRemove = false;
  bool loadingEdit = false;
  BuildContext? dialogContext;
  final propTypes = [
    'Single Family',
    'Apartment',
    'Condo',
    'Townhome',
    'Lot',
    'Multi-Unit Complex'
  ];

  @override
  Widget build(BuildContext context) {
    Widget widgetReturn = Container();
    try {
      widgetReturn = Card(
        elevation: 13.0,
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Container(
          height: 80,
          padding: EdgeInsets.only(left: 10, right: 10),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(5.0)),
          child: ListTile(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              leading: Container(
                padding: EdgeInsets.only(right: 12.0),
                decoration: new BoxDecoration(
                    border: new Border(
                        right: new BorderSide(
                            width: 1.0, color: Colors.grey[700]!))),
                child: GestureDetector(
                    onTap: () async {
                      await requestListing();
                    },
                    child: loadingEdit == true
                        ? Container(
                            margin: EdgeInsets.only(top: 2),
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(buttonsColor),
                              strokeWidth: 2,
                            ))
                        : Icon(Icons.edit, color: Colors.grey[800])),
              ),
              title: Text(
                widget.draft.sPropertyType!,
                style:
                    TextStyle(color: buttonsColor, fontWeight: FontWeight.bold),
              ),
              subtitle: Row(
                children: <Widget>[
                  Icon(Icons.location_on, color: Colors.red[800], size: 15.0),
                  Text(
                      widget.draft.sPropertyAddress!.length > 35
                          ? widget.draft.sPropertyAddress!.substring(0, 35) +
                              '...'
                          : widget.draft.sPropertyAddress!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]))
                ],
              ),
              trailing: loadingRemove == true
                  ? Container(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(headerColor),
                      ))
                  : GestureDetector(
                      onTap: () {
                        showDialogComps(context, 'Alert',
                            'Are you sure you want to delete this draft?');
                      },
                      child:
                          Icon(Icons.delete, color: headerColor, size: 30.0))),
        ),
      );
    } catch (e) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      });
    }
    return widgetReturn;
  }

  deleteDraft(String sSearch, String sLogicStatus) async {
    setState(() {
      loadingRemove = true;
    });

    ResponseService response =
        await ListingFacade().deleteListing(sSearch, sLogicStatus);
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
    } else {
      widget.callbackRemoveListing(sSearch);
    }
    setState(() {
      loadingRemove = false;
    });
  }

  showDialogComps(BuildContext context, String title, String content) {
    Widget noButton = TextButton(
        child: Text("No",
            style: TextStyle(
                color: buttonsColor,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.pop(dialogContext!);
        });
    Widget yesButton = TextButton(
        child: Text("Yes",
            style: TextStyle(
                color: buttonsColor,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.pop(dialogContext!);
          deleteDraft(widget.draft.uLystingId!, widget.draft.sLogicStatus!);
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

  requestListing() async {
    setState(() {
      loadingEdit = true;
    });
    try {
      ResponseService response = await ListingFacade().getDraft(
          this.widget.draft.sZipCode!,
          this.widget.draft.sPropertyAddress!,
          '',
          this.widget.draft.sPropertyType!);

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
        setState(() {
          loadingEdit = false;
        });
        int index = propTypes.indexOf(response.data.sPropertyType);

        Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              alignment: Alignment.topCenter,
              duration: Duration(milliseconds: 500),
              child: CreationWizard(
                  title: 'Listing',
                  listing: response.data,
                  enableComponents: false,
                  fromDraft: true,
                  cleanWizardOffside: false,
                  validAddress: true,
                  selectedIndex: index + 1),
            )).then((value) {
          widget.callbackRemoveListing('');
        }).catchError((error) {});
      }

      setState(() {
        loadingEdit = false;
      });
    } catch (e) {
      await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
    }
  }
}
