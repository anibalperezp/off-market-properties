import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/containers/components/user-network/card-networ.component.dart';
import 'package:zipcular/models/referal/customer.model.dart';

class NetworkUserList extends StatefulWidget {
  List<CustomerModel> customersNetwork;
  String networkType;
  bool loading;
  ValueChanged<String> callbackRemoveListing;
  NetworkUserList(
      {Key? key,
      List<CustomerModel>? customersNetwork,
      bool? loading,
      ValueChanged<String>? callbackRemoveListing,
      String? networkType})
      : customersNetwork = customersNetwork!,
        loading = loading!,
        callbackRemoveListing = callbackRemoveListing!,
        networkType = networkType!,
        super(key: key);

  @override
  _NetworkUserListState createState() => _NetworkUserListState();
}

class _NetworkUserListState extends State<NetworkUserList> {
  bool loadingRemove = false;

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
    return widget.loading == true
        ? Container(
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: headerColor,
              ),
            ))
        : widget.customersNetwork.length == 0
            ? Container(
                margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height / 3),
                child: EmptyWidget(
                  image: null,
                  hideBackgroundAnimation: true,
                  packageImage: PackageImage.Image_3,
                  title: 'There are not ' +
                      widget.networkType +
                      ' in your network.',
                  subTitle: '',
                  titleTextStyle: TextStyle(
                    fontSize: 18,
                    color: baseColor,
                    fontWeight: FontWeight.w500,
                  ),
                  subtitleTextStyle: TextStyle(
                    fontSize: 16,
                    color: Color(0xffabb8d6),
                  ),
                ),
              )
            : ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: widget.customersNetwork.length,
                itemBuilder: (BuildContext context, int index) {
                  return CardNetwork(customer: widget.customersNetwork[index]);
                },
              );
  }
}
