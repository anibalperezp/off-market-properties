import 'package:flutter/widgets.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/models/common/response-service.model.dart';
import 'package:zipcular/models/referal/customer.model.dart';
import 'package:zipcular/repository/facade/user.facade.dart';

class NetworkProvider extends ChangeNotifier {
  List<dynamic> suggestions = [];
  List<dynamic> connections = [];
  List<dynamic> requests = [];
  List<dynamic> blocks = [];
  int suggestionsCounter = 0;
  int connectionsCounter = 0;
  int requestsCounter = 0;
  int blocksCounter = 0;

  Future<void> fetchConnectionsFromDatabase() async {
    this.connections.clear();
    this.connectionsCounter = 0;
    ResponseService result = await UserFacade().connections();
    if (result.bSuccess!) {
      if (result.data != null) {
        // Counters
        this.connectionsCounter = result.data.length;
        // Lists
        this.connections = result.data;
      }
    }
    notifyListeners();
  }

  Future<void> fetchNewRequestFromDatabase() async {
    this.requests.clear();
    this.requestsCounter = 0;
    ResponseService result = await UserFacade().newRequests();
    if (result.bSuccess!) {
      if (result.data != null) {
        this.requestsCounter = result.data.length;
        // Lists
        this.requests = result.data;
      }
    }
    notifyListeners();
  }

  Future<void> fetchBlocksFromDatabase() async {
    this.blocks.clear();
    this.blocksCounter = 0;
    ResponseService result = await UserFacade().blocks();
    if (result.bSuccess!) {
      if (result.data != null) {
        // Counters
        this.blocksCounter = result.data.length;
        // Lists
        this.blocks = result.data;
      }
    }
    notifyListeners();
  }

  _networkCount() {
    if (suggestions.length > 0) {
      this.suggestionsCounter = suggestions.length;
    } else {
      this.suggestionsCounter = 0;
    }
    if (connections.length > 0) {
      this.connectionsCounter = connections.length;
    } else {
      this.connectionsCounter = 0;
    }
    if (requests.length > 0) {
      this.requestsCounter = requests.length;
    } else {
      this.requestsCounter = 0;
    }
    if (blocks.length > 0) {
      this.blocksCounter = blocks.length;
    } else {
      this.blocksCounter = 0;
    }
    notifyListeners();
  }

  _removeUserFromNetwork(CustomerModel cM) {
    if (connections.length > 0) {
      this.connections.removeWhere(
          (element) => element.sInvitationCode == cM.sInvitationCode!);
    }
    if (requests.length > 0) {
      this.requests.removeWhere(
          (element) => element.sInvitationCode == cM.sInvitationCode!);
    }
    if (blocks.length > 0) {
      this.blocks.removeWhere(
          (element) => element.sInvitationCode == cM.sInvitationCode!);
    }
  }

  Future<void> userAction(
      CustomerModel cM, String sAction, bool isIsland) async {
    _removeUserFromNetwork(cM);
    switch (sAction) {
      case 'blockConnection':
        cM.sStatus = NETWORK_BLOCKED;
        await UserFacade().UserBlockConnection(cM.sInvitationCode!);
        this.blocks.add(cM);
        this.blocksCounter = blocks.length;
        break;
      case 'unBlockConnection':
        cM.sStatus = NETWORK_UNCONNECTED;
        await UserFacade().UserUnBlockConnection(cM.sInvitationCode!);
        this.suggestions.add(cM);
        this.suggestionsCounter = suggestions.length;
        break;
      case 'cancelConnection':
        cM.sStatus = NETWORK_UNCONNECTED;
        await UserFacade().UserConnectionCancel(cM.sInvitationCode!);
        this.suggestions.add(cM);
        this.suggestionsCounter = suggestions.length;
        break;
      case 'cancelRequest':
        cM.sStatus = NETWORK_UNCONNECTED;
        await UserFacade().UserRequestCancel(cM.sInvitationCode!);
        this.suggestions.add(cM);
        this.suggestionsCounter = suggestions.length;
        break;
      case 'acceptRequest':
        cM.sStatus = NETWORK_CONNECTED;
        await UserFacade().UserRequestAccept(cM.sInvitationCode!);
        this.connections.add(cM);
        this.connectionsCounter = connections.length;
        break;
      case 'sendRequest':
        cM.sStatus = NETWORK_REQUESTOUT;
        await UserFacade().UserRequestSend(cM.sInvitationCode!);
        this.requests.add(cM);
        this.requestsCounter = requests.length;
        break;
    }
    _networkCount();
    notifyListeners();
  }
}
