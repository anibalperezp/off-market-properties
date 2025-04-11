import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/containers/main_screen/listings/listing-view/listing_preview.component.dart';
import 'package:zipcular/models/common/response-service.model.dart';
import 'package:zipcular/models/referal/customer.model.dart';
import 'package:zipcular/repository/facade/saves.facade.dart';
import 'package:zipcular/repository/provider/network.provider.dart';

class CustomerProfile extends StatefulWidget {
  final CustomerModel customer;
  final bool routing;
  final ValueChanged<bool> callback;

  CustomerProfile(
      {Key? key,
      CustomerModel? customer,
      bool? routing,
      ValueChanged<bool>? callback})
      : customer = customer!,
        routing = routing!,
        callback = callback!,
        super(key: key);

  @override
  State<CustomerProfile> createState() => _CustomerProfileState();
}

class _CustomerProfileState extends State<CustomerProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: headerColor,
        toolbarHeight: 45,
        title: Text('User Profile', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.chevron_left_rounded, color: Colors.white),
          onPressed: () {
            if (widget.routing == false) {
              Navigator.pop(context);
            } else {
              widget.callback(this.widget.routing);
            }
          },
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 30.0,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(100),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.6),
                      Colors.white.withOpacity(0.9),
                    ],
                  ),
                ),
                height: 140,
                width: 140,
                child: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  radius: 70,
                  child: ClipOval(
                    child: widget.customer.sProfilePicture!.isEmpty
                        ? Image.asset(
                            'assets/images/friend1.jpg',
                            height: 120,
                            width: 120,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            widget.customer.sProfilePicture!,
                            height: 120,
                            width: 120,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              Center(
                child: Text(
                  widget.customer.sFirstName! +
                      " " +
                      widget.customer.sLastName!,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 24.0,
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Consumer<NetworkProvider>(
                builder: (context, networkProvider, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Visibility(
                        visible: widget.customer.sStatus == NETWORK_UNCONNECTED,
                        child: _button(
                          "Connect",
                          getIcon(),
                          headerColor,
                          () async {
                            await networkProvider.userAction(
                                widget.customer, 'sendRequest', true);
                            setState(() {
                              widget.customer.sStatus = NETWORK_REQUESTOUT;
                            });
                            final flush = Flushbar(
                              message: "Requested Sent!",
                              flushbarStyle: FlushbarStyle.FLOATING,
                              margin: EdgeInsets.all(8.0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              icon: Icon(
                                Icons.info_outline,
                                size: 28.0,
                                color: Colors.white,
                              ),
                              duration: Duration(seconds: 2),
                              leftBarIndicatorColor: Colors.green,
                            );
                            flush.show(context);
                          },
                        ),
                      ),
                      Visibility(
                        visible: widget.customer.sStatus == NETWORK_REQUESTIN,
                        child: _button(
                          "Accept",
                          getIcon(),
                          headerColor,
                          () async {
                            await networkProvider.userAction(
                                widget.customer, 'acceptRequest', true);
                            setState(() {
                              widget.customer.sStatus = NETWORK_CONNECTED;
                            });
                            final flush = Flushbar(
                              message: "New Connection Add!",
                              flushbarStyle: FlushbarStyle.FLOATING,
                              margin: EdgeInsets.all(8.0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              icon: Icon(
                                Icons.info_outline,
                                size: 28.0,
                                color: Colors.white,
                              ),
                              duration: Duration(seconds: 2),
                              leftBarIndicatorColor: Colors.green,
                            );
                            flush.show(context);
                          },
                        ),
                      ),
                      Visibility(
                        visible: widget.customer.sStatus == NETWORK_REQUESTIN,
                        child: _button(
                          "Cancel",
                          Icons.cancel,
                          headerColor,
                          () async {
                            await networkProvider.userAction(
                                widget.customer, 'cancelRequest', true);
                            setState(() {
                              widget.customer.sStatus = NETWORK_UNCONNECTED;
                            });
                            final flush = Flushbar(
                              message: "Connection Request Canceled!",
                              flushbarStyle: FlushbarStyle.FLOATING,
                              margin: EdgeInsets.all(8.0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              icon: Icon(
                                Icons.info_outline,
                                size: 28.0,
                                color: Colors.white,
                              ),
                              duration: Duration(seconds: 2),
                              leftBarIndicatorColor: Colors.green,
                            );
                            flush.show(context);
                          },
                        ),
                      ),
                      Visibility(
                        visible:
                            widget.customer.sStatus == NETWORK_REQUESTOUT ||
                                widget.customer.sStatus == NETWORK_CONNECTED,
                        child: _button(
                          "Remove",
                          Icons.cancel,
                          headerColor,
                          () async {
                            String action =
                                widget.customer.sStatus == NETWORK_REQUESTOUT
                                    ? 'cancelConnection'
                                    : 'blockConnection';
                            setState(() {
                              widget.customer.sStatus = NETWORK_UNCONNECTED;
                            });
                            await networkProvider.userAction(
                                widget.customer, action, true);
                            final flush = Flushbar(
                              message: "Connection Canceled Successfully!",
                              flushbarStyle: FlushbarStyle.FLOATING,
                              margin: EdgeInsets.all(8.0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              icon: Icon(
                                Icons.info_outline,
                                size: 28.0,
                                color: Colors.white,
                              ),
                              duration: Duration(seconds: 2),
                              leftBarIndicatorColor: Colors.green,
                            );
                            flush.show(context);
                          },
                        ),
                      ),
                      Visibility(
                        visible: widget.customer.sStatus == NETWORK_BLOCKED ||
                            widget.customer.sStatus == NETWORK_BLOCKEDIN,
                        child: _button(
                          "Unblock",
                          getIcon(),
                          headerColor,
                          () async {
                            await networkProvider.userAction(
                                widget.customer, 'unBlockConnection', true);
                            setState(() {
                              widget.customer.sStatus = NETWORK_UNCONNECTED;
                            });
                            final flush = Flushbar(
                              message: "Connection UnBlocked Successfully!",
                              flushbarStyle: FlushbarStyle.FLOATING,
                              margin: EdgeInsets.all(8.0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              icon: Icon(
                                Icons.info_outline,
                                size: 28.0,
                                color: Colors.white,
                              ),
                              duration: Duration(seconds: 2),
                              leftBarIndicatorColor: Colors.green,
                            );
                            flush.show(context);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(
                height: 30.0,
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 1,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12.0)),
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              Container(
                margin: EdgeInsets.only(left: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(left: 20, top: 1.0),
                          child: Text(
                            "Listings:",
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 15.0,
                                color: Colors.grey[700]),
                          ),
                        ),
                        SizedBox(
                          width: 2.0,
                        ),
                        Text(
                          widget.customer.nProperties.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0,
                              color: headerColor),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(left: 20, top: 1.0),
                          child: Text(
                            "Connections: ",
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 15.0,
                                color: Colors.grey[700]),
                          ),
                        ),
                        SizedBox(
                          width: 2.0,
                        ),
                        Text(
                          widget.customer.nConnections.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0,
                              color: headerColor),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(left: 20, top: 1.0),
                          child: Text(
                            "Joined On:",
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 15.0,
                                color: Colors.grey[700]),
                          ),
                        ),
                        SizedBox(
                          width: 2.0,
                        ),
                        Text(
                          widget.customer.sCreatedDate!.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0,
                              color: headerColor),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(left: 20, top: 1.0),
                          child: Text(
                            "Languages: ",
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 15.0,
                                color: Colors.grey[700]),
                          ),
                        ),
                        SizedBox(
                          width: 2.0,
                        ),
                        Text(
                          widget.customer.sLanguageSpeak!.isEmpty
                              ? "Not Provided."
                              : widget.customer.sLanguageSpeak!,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0,
                              color: headerColor),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 1,
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12.0)),
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20, top: 1.0),
                      child: Text(
                        "Properties Listed",
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 5),
                      child: widget.customer.sProperties!.length > 0
                          ? Flex(
                              direction: Axis.vertical,
                              verticalDirection: VerticalDirection.down,
                              children: [
                                  ListingPreview(
                                    appyScroll: true,
                                    callbackOpenProfile: (value) {
                                      //Call sliding_up_panel2
                                    },
                                    showProfile: false,
                                    isPreviewFavorite: true,
                                    isEditMode: false,
                                    itemsData: widget.customer.sProperties!,
                                    onCallback: (val) async {
                                      if (val.item2 == true) {
                                        ResponseService response =
                                            await SavesFacade()
                                                .addFavoriteLising(val.item1);
                                        if (response.hasConnection == false) {
                                          final flush = Flushbar(
                                            message: 'No Internet Connection',
                                            flushbarStyle:
                                                FlushbarStyle.FLOATING,
                                            margin: EdgeInsets.all(8.0),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(8.0),
                                            ),
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
                                      } else {
                                        ResponseService response =
                                            await SavesFacade()
                                                .deleteFavoriteLising(
                                                    val.item1);
                                        if (response.hasConnection == false) {
                                          final flush = Flushbar(
                                            message: 'No Internet Connection',
                                            flushbarStyle:
                                                FlushbarStyle.FLOATING,
                                            margin: EdgeInsets.all(8.0),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8.0)),
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
                                      }
                                    },
                                    callbackRemoveListing: (val) async {},
                                  )
                                ])
                          : Container(
                              margin: EdgeInsets.only(left: 20, top: 10),
                              child: Text(
                                "No Properties Listed",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[500]),
                              ),
                            ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  getIcon() {
    switch (widget.customer.sStatus) {
      case NETWORK_REQUESTIN:
        return Icons.check;
      case NETWORK_REQUESTOUT:
        return Icons.cancel;
      case NETWORK_UNCONNECTED:
        return Icons.add;
      case NETWORK_CONNECTED:
        return Icons.check;
      case NETWORK_BLOCKED:
        return Icons.block;
      case NETWORK_BLOCKEDIN:
        return Icons.block;
    }
  }

  Widget _button(
      String label, IconData icon, Color color, void Function()? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Icon(
              icon,
              color: Colors.white,
              size: 25,
            ),
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.15),
                blurRadius: 8.0,
              )
            ]),
          ),
          SizedBox(
            height: 12.0,
          ),
          Text(label),
        ],
      ),
    );
  }
}
