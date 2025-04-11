import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/containers/components/chat/message_screen.component.dart';
import 'package:zipcular/containers/components/customer_profile/customer_profile.component.dart';
import 'package:zipcular/containers/main_screen/listings/listing-view/listing_preview.component.dart';
import 'package:zipcular/models/chat/chat.model.dart';
import 'package:zipcular/models/chat/chat_validation.model.dart';
import 'package:zipcular/models/common/response-service.model.dart';
import 'package:zipcular/models/listing/search/listing.dart';
import 'package:zipcular/models/referal/customer.model.dart';
import 'package:zipcular/repository/facade/listing.facade.dart';
import 'package:zipcular/repository/facade/saves.facade.dart';
import 'package:zipcular/repository/provider/chat.provider.dart';
import 'package:zipcular/repository/provider/network.provider.dart';
import 'package:zipcular/repository/provider/user.provider.dart';

class SlidingPanel extends StatefulWidget {
  CustomerModel customer;
  ScrollController scrollController;
  PanelController panelController;
  Listing listing;
  bool removeTop;
  bool showPanelAccess;
  SlidingPanel(
      {Key? key,
      CustomerModel? customer,
      ScrollController? scrollController,
      PanelController? panelController,
      Listing? listing,
      bool? removeTop,
      bool? showPanelAccess})
      : customer = customer!,
        scrollController = scrollController!,
        panelController = panelController!,
        listing = listing!,
        removeTop = removeTop!,
        showPanelAccess = showPanelAccess!,
        super(key: key);

  @override
  State<SlidingPanel> createState() => _SlidingPanelState();
}

class _SlidingPanelState extends State<SlidingPanel> {
  bool loadingChat = false;

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
    return _panel();
  }

  Widget _panel() {
    return ListView(
      physics:
          AlwaysScrollableScrollPhysics(), // PanelScrollPhysics(controller: widget.panelController),
      controller: widget.scrollController,
      children: <Widget>[
        Visibility(
          visible: widget.removeTop == false,
          child: SizedBox(
            height: 20.0,
          ),
        ),
        Center(
          child: Container(
            width: 30,
            height: 5,
            decoration: BoxDecoration(
                color: Colors.grey[500],
                borderRadius: BorderRadius.circular(12.0)),
          ),
        ),
        SizedBox(
          height: 30.0,
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomerProfile(
                  customer: widget.customer,
                  routing: false,
                  callback: (value) {},
                ),
              ),
            );
          },
          child: Container(
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
            height: 120,
            width: 120,
            child: CircleAvatar(
              backgroundColor: Colors.grey[200],
              radius: 70,
              child: ClipOval(
                child: widget.customer.sProfilePicture!.isEmpty
                    ? Image.asset(
                        'assets/images/friend1.jpg',
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        widget.customer.sProfilePicture!,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 15.0,
        ),
        Center(
          child: Text(
            widget.customer.sFirstName! + " " + widget.customer.sLastName!,
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 24.0,
            ),
          ),
        ),
        SizedBox(
          height: 60.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _button(
              "Listings",
              Icons.home_work,
              false,
              headerColor,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomerProfile(
                      routing: false,
                      customer: widget.customer,
                      callback: (value) {},
                    ),
                  ),
                );
              },
              false,
            ),
            Visibility(
              visible: widget.customer.sStatus == NETWORK_UNCONNECTED ||
                  widget.customer.sStatus == NETWORK_REQUESTOUT ||
                  widget.customer.sStatus == NETWORK_CONNECTED ||
                  widget.customer.sStatus == NETWORK_BLOCKED ||
                  widget.customer.sStatus == NETWORK_BLOCKEDIN,
              child: Consumer<NetworkProvider>(
                builder: (context, networkProvider, _) {
                  return _button(
                    getStatus(),
                    getIcon(),
                    false,
                    headerColor,
                    () async {
                      String action = '';
                      switch (widget.customer.sStatus) {
                        case NETWORK_UNCONNECTED:
                          action = 'sendRequest';
                          break;
                        case NETWORK_REQUESTOUT:
                          action = 'cancelRequest';
                          break;
                      }
                      await connectionAction(action, networkProvider);
                    },
                    widget.customer.sStatus == NETWORK_CONNECTED ||
                        widget.customer.sStatus == NETWORK_BLOCKED ||
                        widget.customer.sStatus == NETWORK_BLOCKEDIN,
                  );
                },
              ),
            ),
            Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                final conversations = chatProvider.conversations;
                return _button(
                  "Chat",
                  Icons.chat,
                  loadingChat,
                  headerColor,
                  () async {
                    try {
                      ChatUser chat = getChatInformation(conversations);
                      ChatValidation? validateChat = await validateAccess(
                          widget.customer.sInvitationCode!, '', 'chat');
                      if (validateChat!.bContinue == true) {
                        setState(() {
                          loadingChat = false;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MessagesScreen(
                              chat: chat,
                              callback: (value) {},
                            ),
                          ),
                        ).then((value) async => {
                              await chatProvider
                                  .fetchConversationsFromDatabase()
                            });
                      } else {
                        setState(() {
                          loadingChat = false;
                        });
                        final flush = Flushbar(
                          message: validateChat.sDescription,
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
                    } catch (e) {
                      setState(() {
                        loadingChat = false;
                      });
                    }
                  },
                  false,
                );
              },
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
          margin: EdgeInsets.only(left: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 1.0),
                    child: Text(
                      "Listings: ",
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
                    margin: EdgeInsets.only(top: 1.0),
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
                    margin: EdgeInsets.only(top: 1.0),
                    child: Text(
                      "Joined On: ",
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
                  Text(
                    "Languages: ",
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 15.0,
                        color: Colors.grey[700]),
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
              )
            ],
          ),
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
        Visibility(
          visible: widget.showPanelAccess == true,
          child: Center(
            child: Text(
              "Properties Listed",
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 24.0,
              ),
            ),
          ),
        ),
        Visibility(
          visible: widget.showPanelAccess == true,
          child: SizedBox(
            height: 15.0,
          ),
        ),
        Visibility(
          visible: widget.showPanelAccess == true,
          child: Container(
            margin: const EdgeInsets.only(left: 10, right: 10, bottom: 170),
            child: widget.customer.sProperties!.length > 0
                ? Flex(direction: Axis.vertical, children: [
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
                              await SavesFacade().addFavoriteLising(val.item1);
                          if (response.hasConnection == false) {
                            final flush = Flushbar(
                              message: 'No Internet Connection',
                              flushbarStyle: FlushbarStyle.FLOATING,
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
                          ResponseService response = await SavesFacade()
                              .deleteFavoriteLising(val.item1);
                          if (response.hasConnection == false) {
                            final flush = Flushbar(
                              message: 'No Internet Connection',
                              flushbarStyle: FlushbarStyle.FLOATING,
                              margin: EdgeInsets.all(8.0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
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
                : Text(
                    "No Properties Listed",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500]),
                  ),
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
      ],
    );
  }

  Widget _button(String label, IconData icon, bool loading, Color color,
      void Function()? onTap, bool disable) {
    return GestureDetector(
      onTap: disable == true ? null : onTap,
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16.0),
            child: !loading
                ? Icon(
                    icon,
                    color: Colors.white,
                    size: 25,
                  )
                : Container(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                    width: 25,
                    height: 25),
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

  connectionAction(String action, NetworkProvider networkProvider) async {
    // Send Service
    await networkProvider.userAction(widget.customer, action, false);

    // Update Title
    String title = '';
    if (action == 'sendRequest') {
      title = "Connection Request Sent";
    } else if (action == 'cancelRequest') {
      setState(() {
        widget.customer.sStatus = NETWORK_UNCONNECTED;
      });
      title = "Connection Request Cancelled";
    }

    // Show Flushbar
    final flush = Flushbar(
      message: title,
      flushbarStyle: FlushbarStyle.FLOATING,
      margin: EdgeInsets.all(8.0),
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      icon: Icon(
        Icons.info_outline,
        size: 28.0,
        color: Colors.white,
      ),
      duration: Duration(seconds: 2),
      leftBarIndicatorColor: Colors.green,
    );
    flush.show(context);
  }

  getStatus() {
    switch (widget.customer.sStatus) {
      case NETWORK_REQUESTOUT:
        return 'Cancel Request';
      case NETWORK_UNCONNECTED:
        return 'Connect';
      case NETWORK_CONNECTED:
        return 'Connected';
      case NETWORK_BLOCKED:
        return 'Blocked';
      case NETWORK_BLOCKEDIN:
        return 'Blocked';
    }
  }

  getIcon() {
    switch (widget.customer.sStatus) {
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

  validateAccess(
      String sInvitationCode, String sLystingId, String sChannel) async {
    ResponseService response = await ListingFacade()
        .validateAccess(sInvitationCode, sLystingId, sChannel, 'networking');

    if (response.bSuccess == true) {
      final result = response.data as ChatValidation;
      return result;
    } else {
      return null;
    }
  }

  getChatInformation(List<ChatUser> conversations) {
    setState(() {
      loadingChat = true;
    });
    // Get element from chat provider
    late ChatUser? chat = null;
    if (conversations.length > 0) {
      if (conversations
          .any((element) => element.sLystingId == widget.listing.sSearch)) {
        chat = conversations.firstWhere(
            (element) => element.sLystingId == widget.listing.sSearch);
      }
    }
    if (chat == null) {
      chat = new ChatUser(
          sLystingId: widget.listing.sSearch,
          bIsFavorite: false,
          bIsSender: true,
          sChatId: '',
          sChatMessageType: 'text',
          sLastMessageContent: '',
          sLastMessageCreatedTime: 0,
          sLystingName: widget.listing.sPropertyAddress,
          sLystingProfilePicture: widget.listing.sResourcesUrl!.length > 0
              ? widget.listing.sResourcesUrl![0]
              : '',
          sMessageCategory: 'listing',
          sMessageSubCategory: 'buying',
          sMessageStatus: "viewed",
          sUserInvitationCode: widget.listing.sInvitationCode,
          sUserProfilePicture: widget.customer.sProfilePicture,
          bIsReported: false,
          bIsReportedByMe: false);
    }
    return chat;
  }
}
