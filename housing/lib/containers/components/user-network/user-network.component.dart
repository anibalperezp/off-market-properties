import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/containers/components/user-network/list-network.component.dart';
import 'package:zipcular/models/referal/customer.model.dart';
import 'package:zipcular/repository/provider/network.provider.dart';
import 'package:zipcular/repository/provider/user.provider.dart';

class UserNetworkComponent extends StatefulWidget {
  UserNetworkComponent({Key? key}) : super(key: key);

  @override
  State<UserNetworkComponent> createState() => _UserNetworkComponentState();
}

class _UserNetworkComponentState extends State<UserNetworkComponent>
    with TickerProviderStateMixin {
  bool loading = false;
  String selectedFilters = 'Connections';
  List<String> filters = ['Connections', 'New Requests', 'Blocked'];
  List<CustomerModel> network = List<CustomerModel>.empty(growable: true);

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
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        title: Text(
          'My Network',
          style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat'),
        ),
        backgroundColor: headerColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Consumer<NetworkProvider>(
        builder: (context, networkProvider, _) {
          switch (selectedFilters) {
            case 'Connections':
              network = networkProvider.connections.cast<CustomerModel>();
              break;

            case 'New Requests':
              network = networkProvider.requests.cast<CustomerModel>();
              break;

            case 'Blocked':
              network = networkProvider.blocks.cast<CustomerModel>();
              break;
          }
          return Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  // Filter Chip
                  Container(
                    margin: EdgeInsets.only(left: 15, top: 8, bottom: 4),
                    alignment: Alignment.centerLeft,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          for (var filter in filters)
                            Container(
                              margin: EdgeInsets.only(right: 7),
                              child: FilterChip(
                                padding: EdgeInsets.symmetric(horizontal: 2),
                                checkmarkColor: Colors.white,
                                selectedColor: selectedFilters == filter
                                    ? headerColor
                                    : Colors.grey[400],
                                selected: selectedFilters == filter,
                                backgroundColor: Colors.yellow[100],
                                label: Text(filter,
                                    style: TextStyle(
                                        color: selectedFilters == filter
                                            ? Colors.white
                                            : Colors.black)),
                                onSelected: (bool value) async {
                                  switch (filter) {
                                    case 'Connections':
                                      await getConnections(filter);
                                      setState(() {
                                        selectedFilters = filter;
                                      });
                                      break;

                                    case 'New Requests':
                                      await getConnections(filter);
                                      setState(() {
                                        selectedFilters = filter;
                                      });
                                      break;

                                    case 'Blocked':
                                      await getConnections(filter);
                                      setState(() {
                                        selectedFilters = filter;
                                      });
                                      break;
                                  }
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    child: NetworkUserList(
                        customersNetwork: network,
                        loading: loading,
                        networkType: selectedFilters,
                        callbackRemoveListing: (value) {}),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  getConnections(String type) async {
    setState(() {
      loading = true;
    });
    switch (type) {
      case 'Connections':
        await Provider.of<NetworkProvider>(context, listen: false)
            .fetchConnectionsFromDatabase();
        break;

      case 'New Requests':
        await Provider.of<NetworkProvider>(context, listen: false)
            .fetchNewRequestFromDatabase();
        break;

      case 'Blocked':
        await Provider.of<NetworkProvider>(context, listen: false)
            .fetchBlocksFromDatabase();
        break;
    }

    setState(() {
      loading = false;
    });
  }
}
