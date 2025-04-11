import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/containers/components/chat/message_screen.component.dart';
import 'package:zipcular/containers/components/customer_profile/customer_profile.component.dart';
import 'package:zipcular/models/chat/chat.model.dart';
import 'package:zipcular/models/chat/chat_validation.model.dart';
import 'package:zipcular/models/common/response-service.model.dart';
import 'package:zipcular/models/referal/customer.model.dart';
import 'package:zipcular/repository/facade/listing.facade.dart';
import 'package:zipcular/repository/provider/chat.provider.dart';
import 'package:zipcular/repository/provider/network.provider.dart';
import 'package:zipcular/repository/provider/user.provider.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';

class CardNetwork extends StatefulWidget {
  CustomerModel customer;
  CardNetwork({Key? key, CustomerModel? customer})
      : customer = customer!,
        super(key: key);

  @override
  State<CardNetwork> createState() => _CardNetworkState();
}

class _CardNetworkState extends State<CardNetwork> {
  bool loadingChat = false;
  bool loadingAction = false;
  bool loadingCancel = false;
  bool loadingBlock = false;
  UserRepository _userRepoService = new UserRepository();
  BuildContext? dialogContext;

  @override
  void initState() {
    super.initState();
  }

  getConnectionStatus() {
    String connectionStatus = '';
    switch (widget.customer.sStatus) {
      case NETWORK_REQUESTIN:
        connectionStatus = 'Accept';
        break;
      case NETWORK_BLOCKED:
        connectionStatus = 'Unblock';
        break;
      case NETWORK_BLOCKEDIN:
        connectionStatus = 'Unblock';
        break;
      case NETWORK_CONNECTED:
        connectionStatus = 'Remove';
        break;
      case NETWORK_REQUESTOUT:
        connectionStatus = 'Remove';
        break;
    }
    return connectionStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 13.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            height: 110,
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 35),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: ListTile(
              onTap: () async {
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
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              leading: Container(
                padding: EdgeInsets.only(right: 12.0),
                decoration: new BoxDecoration(
                    border: new Border(
                        right: new BorderSide(
                            width: 1.0, color: Colors.grey[700]!))),
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
                  height: 60,
                  width: 60,
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    radius: 70,
                    child: ClipOval(
                      child: widget.customer.sProfilePicture!.isEmpty
                          ? Image.asset(
                              'assets/images/friend1.jpg',
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              widget.customer.sProfilePicture!,
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
              ),
              title: Text(
                widget.customer.sFirstName! + ' ' + widget.customer.sLastName!,
                style: TextStyle(
                    color: buttonsColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              subtitle: Column(children: [
                Row(
                  children: <Widget>[
                    Icon(Icons.home, color: Colors.red[800], size: 17.0),
                    SizedBox(width: 5),
                    Text(
                      widget.customer.nProperties.toString() +
                          ' Properties Listed',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: <Widget>[
                    Icon(Icons.people, color: Colors.red[800], size: 17.0),
                    SizedBox(width: 5),
                    Text(
                      widget.customer.nConnections.toString() + ' Connections',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ]),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Consumer<ChatProvider>(
                    builder: (context, chatProvider, _) {
                      final conversations = chatProvider.conversations;
                      return GestureDetector(
                        onTap: () async {
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
                            final flush = Flushbar(
                              message: validateChat.sDescription,
                              flushbarStyle: FlushbarStyle.FLOATING,
                              margin: EdgeInsets.all(8.0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              icon: Icon(
                                Icons.info_outline,
                                size: 28.0,
                                color: Theme.of(context).primaryColor,
                              ),
                              duration: Duration(seconds: 2),
                              leftBarIndicatorColor:
                                  Theme.of(context).primaryColor,
                            );
                            flush.show(context);
                          }
                        },
                        child: loadingChat == true
                            ? Container(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      headerColor),
                                ),
                              )
                            : Icon(
                                Icons.chat,
                                color: headerColor,
                                size: 30.0,
                              ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 5),
          Container(
            height: 50,
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Consumer<NetworkProvider>(
              builder: (context, networkProvider, _) {
                return Row(
                  mainAxisAlignment:
                      widget.customer.sStatus == NETWORK_BLOCKED ||
                              widget.customer.sStatus == NETWORK_BLOCKEDIN
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.spaceAround,
                  children: [
                    Visibility(
                      visible: widget.customer.sStatus == NETWORK_CONNECTED ||
                              widget.customer.sStatus == NETWORK_REQUESTOUT
                          ? true
                          : false,
                      child: Container(
                        width: MediaQuery.of(context).size.width / 3.5,
                        height: 50,
                        child: TextButton(
                          onPressed: () async {
                            String action = '';

                            switch (widget.customer.sStatus) {
                              case NETWORK_CONNECTED:
                                action = 'cancelConnection';
                                break;
                              case NETWORK_REQUESTOUT:
                                action = 'cancelRequest';
                                break;
                            }
                            await networkProvider.userAction(
                                widget.customer, action, false);
                          },
                          child: !loadingAction
                              ? Text(
                                  getConnectionStatus(),
                                  style: TextStyle(
                                      color: buttonsColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                )
                              : Container(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        buttonsColor),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: widget.customer.sStatus == NETWORK_REQUESTIN ||
                              widget.customer.sStatus == NETWORK_BLOCKED ||
                              widget.customer.sStatus == NETWORK_BLOCKEDIN
                          ? true
                          : false,
                      child: Container(
                        width: MediaQuery.of(context).size.width / 3.5,
                        height: 50,
                        child: TextButton(
                          onPressed: () async {
                            String action = '';

                            switch (widget.customer.sStatus) {
                              case NETWORK_REQUESTIN:
                                action = 'acceptRequest';
                                break;
                              case NETWORK_BLOCKED:
                                action = 'unBlockConnection';
                                break;
                              case NETWORK_BLOCKEDIN:
                                action = 'unBlockConnection';
                                break;
                            }
                            await networkProvider.userAction(
                                widget.customer, action, false);
                            await Provider.of<UserProvider>(context,
                                    listen: false)
                                .fetchUserFromDatabase();

                            showMessage(action);
                          },
                          child: !loadingAction
                              ? Text(
                                  getConnectionStatus(),
                                  style: TextStyle(
                                      color: buttonsColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                )
                              : Container(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        buttonsColor),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: widget.customer.sStatus == NETWORK_REQUESTIN
                          ? true
                          : false,
                      child: Container(
                        width: MediaQuery.of(context).size.width / 3.5,
                        height: 50,
                        child: TextButton(
                          onPressed: () {
                            showActionDialog(
                                context,
                                'Cancel',
                                'Are you sure you want to cancel ' +
                                    widget.customer.sFirstName! +
                                    ' ' +
                                    widget.customer.sLastName! +
                                    '?',
                                'cancelRequest',
                                networkProvider);
                          },
                          child: !loadingCancel
                              ? Text(
                                  'Cancel',
                                  style: TextStyle(
                                      color: buttonsColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                )
                              : Container(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        buttonsColor),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    // Block button
                    Visibility(
                      visible: widget.customer.sStatus == NETWORK_BLOCKED ||
                              widget.customer.sStatus == NETWORK_BLOCKEDIN
                          ? false
                          : true,
                      child: Container(
                        width: MediaQuery.of(context).size.width / 3.5,
                        height: 50,
                        child: TextButton(
                          onPressed: () {
                            showActionDialog(
                                context,
                                'Block',
                                'Are you sure you want to block ' +
                                    widget.customer.sFirstName! +
                                    ' ' +
                                    widget.customer.sLastName! +
                                    '?',
                                'blockConnection',
                                networkProvider);
                          },
                          child: !loadingBlock
                              ? Text(
                                  'Block',
                                  style: TextStyle(
                                      color: buttonsColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                )
                              : Container(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        buttonsColor),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  actionUser(String action, NetworkProvider networkProvider) async {
    setState(() {
      if (action == 'blockConnection') {
        loadingBlock = true;
      } else if (action == 'cancelRequest') {
        loadingCancel = true;
      } else {
        loadingAction = true;
      }
    });

    await networkProvider.userAction(widget.customer, action, false);

    showMessage(action);

    setState(() {
      loadingBlock = false;
      loadingCancel = false;
      loadingAction = false;
    });
  }

  showMessage(String action) {
    String result = '';

    if (action == 'blockConnection') {
      result = 'blocked';
    } else if (action == 'cancelRequest') {
      result = 'canceled';
    } else if (action == 'acceptRequest') {
      result = 'accepted';
    } else if (action == 'cancelConnection') {
      result = 'removed';
    } else if (action == 'unBlockConnection') {
      result = 'unblocked';
    }

    final flush = Flushbar(
      message: "User " + result + " successfully",
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

  showActionDialog(BuildContext context, String title, String content,
      String action, NetworkProvider networkProvider) {
    Widget noButton = TextButton(
        child: Text(
          "No",
          style: TextStyle(
              color: buttonsColor, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          Navigator.pop(dialogContext!);
        });
    Widget yesButton = TextButton(
        child: Text("Yes",
            style: TextStyle(
                color: buttonsColor,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        onPressed: () async {
          Navigator.pop(dialogContext!);
          actionUser(action, networkProvider);
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

  getChatInformation(List<ChatUser> conversations) {
    setState(() {
      loadingChat = true;
    });
    // Get element from chat provider
    late ChatUser? chat = null;
    if (conversations.length > 0) {
      if (conversations.any((element) =>
          element.sLystingId!.isEmpty == true &&
          element.sUserInvitationCode == widget.customer.sInvitationCode &&
          element.sMessageCategory == 'networking')) {
        chat = conversations.firstWhere((element) =>
            element.sLystingId!.isEmpty == true &&
            element.sUserInvitationCode == widget.customer.sInvitationCode &&
            element.sMessageCategory == 'networking');
      }
    }
    if (chat == null) {
      chat = new ChatUser(
          sLystingId: 'networking',
          bIsFavorite: false,
          bIsSender: true,
          sChatId: '',
          sChatMessageType: 'text',
          sLastMessageContent: '',
          sLastMessageCreatedTime: 0,
          sLystingName:
              widget.customer.sFirstName! + ' ' + widget.customer.sLastName!,
          sLystingProfilePicture: widget.customer.sProfilePicture!.isNotEmpty
              ? widget.customer.sProfilePicture!
              : '',
          sMessageCategory: 'networking',
          sMessageSubCategory: 'other',
          sMessageStatus: "viewed",
          sUserInvitationCode: widget.customer.sInvitationCode,
          sUserProfilePicture: widget.customer.sProfilePicture!.isNotEmpty
              ? widget.customer.sProfilePicture!
              : '',
          bIsReported: false,
          bIsReportedByMe: false);
    }
    return chat;
  }
}
