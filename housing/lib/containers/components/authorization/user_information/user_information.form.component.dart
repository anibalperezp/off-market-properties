import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:zipcular/commons/common.localization.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/containers/components/authorization/login/animation.login.component.dart';
import 'package:zipcular/containers/widgets/common/button_group_spaced.dart';
import 'package:zipcular/models/common/response-service.model.dart';
import 'package:zipcular/models/listing/search/place.dart';
import 'package:zipcular/models/user/user.dart';
import 'package:zipcular/repository/facade/user.facade.dart';
import 'package:zipcular/repository/services/prod/google.service.dart';
import 'package:zipcular/repository/store/auth_view/user_update/user_update_bloc.dart';
import 'package:zipcular/repository/store/auth_view/user_update/user_update_event.dart';
import 'package:zipcular/repository/store/auth_view/user_update/user_update_state.dart';

class UserInformationPartial extends StatefulWidget {
  final User user;
  final String email;
  UserInformationPartial({Key? key, User? user, String? email})
      : user = user!,
        email = email!,
        super(key: key);

  @override
  State<UserInformationPartial> createState() => _UserInformationPartialState();
}

class _UserInformationPartialState extends State<UserInformationPartial> {
  GoogleServs servs = new GoogleServs();
  bool isLoading = false;
  bool enableLocation = true;
  bool enableButton = false;
  bool loadingMarket = false;
  TextEditingController? _areaController;
  List<String>? roleInMarket = List.empty(growable: true);
  double sLatitud = 0;
  double sLongitud = 0;
  int sZipCode = 0;
  String area = "";
  String sMarketArea = "";
  String sMarketAreaToShow = "";
  String sFirstName = "";
  String sLastName = "";
  String sCustomerType = "";
  final _formKey = GlobalKey<FormState>();
  BuildContext? dialogContext;
  var region;

  @override
  void initState() {
    _areaController = TextEditingController(
        text: widget.user.sMarketArea != '' ? widget.user.sMarketArea : '');
    super.initState();
  }

  @override
  void dispose() {
    _areaController!.dispose();
    super.dispose();
  }

  void _onStateChanged(bool newValue) {
    setState(() {
      loadingMarket = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserUpdateBloc, UserUpdateState>(
      listener: (context, state) {},
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Padding(
                  padding:
                      EdgeInsets.only(right: 20, left: 20, top: 40, bottom: 40),
                  child: LoginAnimation(
                      1.6,
                      Container(
                        margin: EdgeInsets.only(top: 0),
                        child: Center(
                          child: Text(
                            "Final Step!",
                            style: TextStyle(
                                color: headerColor,
                                fontSize: 30,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: Column(
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: LoginAnimation(
                            1.8,
                            Text('Enter your market area (County):',
                                style: TextStyle(
                                    color: Color.fromRGBO(65, 64, 66, 1),
                                    fontSize: 16)))),
                    LoginAnimation(
                        1.8,
                        Container(
                            padding: EdgeInsets.only(
                                top: 1, right: 1, left: 10, bottom: 15),
                            child: TypeAheadFormField(
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                enabled: true,
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: this._areaController,
                                  cursorColor: Colors.grey[800],
                                  style: TextStyle(color: Colors.grey[800]),
                                  decoration: InputDecoration(
                                    suffixIcon: loadingMarket == false
                                        ? Icon(Icons.location_on,
                                            color: Colors.grey[700], size: 28)
                                        : Container(
                                            height: 12,
                                            width: 12,
                                            child: Image.asset(
                                                'assets/images/loading-giphy.gif',
                                                height: 10,
                                                width: 10,
                                                fit: BoxFit.cover)),
                                    fillColor: buttonsColor,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 3,
                                        color: Colors.grey[400]!,
                                      ), //<-- SEE HERE
                                      borderRadius: BorderRadius.circular(50.0),
                                    ),
                                    hintStyle: TextStyle(color: buttonsColor),
                                    labelText: 'County Search',
                                    labelStyle: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                    errorStyle: TextStyle(
                                        color: headerColor, fontSize: 13),
                                  ),
                                ),
                                suggestionsCallback: (pattern) async {
                                  if (pattern.length > 0) {
                                    this.enableLocation = await requestLocation(
                                        this.enableLocation);
                                    if (this.enableLocation) {
                                      this.region = await regionData();
                                    }

                                    _onStateChanged(true);
                                    String regionString = this.region == null
                                        ? 'Texas'
                                        : this.region[0].administrativeArea;
                                    ResponseService response =
                                        await UserFacade().searchMarketArea(
                                            pattern, regionString);

                                    if (response.hasConnection == false) {
                                      final flush = Flushbar(
                                        message: 'No Internet Connection',
                                        flushbarStyle: FlushbarStyle.FLOATING,
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
                                    _onStateChanged(false);
                                    return response.data != null
                                        ? response.data
                                        : List.empty(growable: true);
                                  } else {
                                    // _onStateChanged(false);
                                    return List.empty(growable: true);
                                  }
                                },
                                // itemBuilder:
                                //     (BuildContext context, Place suggestion) {
                                //   return ListTile(
                                //     title: Text(suggestion.sCustomerView!),
                                //   );
                                // },
                                itemBuilder:
                                    (BuildContext context, Object? suggestion) {
                                  if (suggestion is Place) {
                                    Place place = suggestion;
                                    // Rest of your code here
                                    return ListTile(
                                      title: Text(place.sCustomerView!),
                                    );
                                  } else {
                                    // Handle the case where the object is not a Place
                                    return SizedBox.shrink();
                                  }
                                },
                                transitionBuilder: (BuildContext context,
                                    Widget suggestionsBox,
                                    AnimationController? controller) {
                                  return suggestionsBox;
                                },
                                onSuggestionSelected: (Object? suggestion) {
                                  if (suggestion is Place) {
                                    Place place = suggestion;
                                    this._areaController!.text =
                                        place.sCustomerView!;
                                    setState(
                                      () {
                                        this.area = this._areaController!.text;
                                        this.sMarketArea =
                                            place.sConcatenationContent!;
                                        this.sMarketAreaToShow =
                                            place.sCustomerView!;
                                      },
                                    );
                                  }
                                },
                                validator: (value) {
                                  if (this.area.isEmpty) {
                                    return 'Required';
                                  }
                                  return null;
                                }))),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: LoginAnimation(
                        1.8,
                        Text(
                          'Provide your full name:',
                          style: TextStyle(
                              color: Color.fromRGBO(65, 64, 66, 1),
                              fontSize: 16),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    LoginAnimation(
                        1.8,
                        Container(
                          padding: EdgeInsets.only(
                              top: 1, right: 1, left: 10, bottom: 1),
                          child: TextFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z_ ]')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                this.sFirstName = value;
                              });
                            },
                            onFieldSubmitted: (value) {
                              FocusScopeNode currentFocus =
                                  FocusScope.of(context);
                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }
                            },
                            validator: (String? value) {
                              if (value!.length == 0) {
                                return 'Required';
                              }
                              return null;
                            },
                            style: TextStyle(color: Colors.grey[800]),
                            decoration: InputDecoration(
                              fillColor: buttonsColor,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 3,
                                  color: Colors.grey[400]!,
                                ), //<-- SEE HERE
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              hintStyle: TextStyle(color: buttonsColor),
                              labelText: 'First Name',
                              labelStyle: TextStyle(
                                color: Colors.grey[600],
                              ),
                              errorStyle:
                                  TextStyle(color: headerColor, fontSize: 13),
                            ),
                          ),
                        )),
                    SizedBox(
                      height: 20,
                    ),
                    LoginAnimation(
                        1.8,
                        Container(
                          padding: EdgeInsets.only(
                              top: 1, right: 1, left: 10, bottom: 20),
                          child: TextFormField(
                            onFieldSubmitted: (value) {
                              FocusScopeNode currentFocus =
                                  FocusScope.of(context);
                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z_ ]')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                this.sLastName = value;
                              });
                            },
                            validator: (String? value) {
                              if (value!.length == 0) {
                                return 'Required';
                              }
                              return null;
                            },
                            style: TextStyle(color: Colors.grey[800]),
                            decoration: InputDecoration(
                              fillColor: buttonsColor,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 3,
                                  color: Colors.grey[400]!,
                                ), //<-- SEE HERE
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              hintStyle: TextStyle(color: buttonsColor),
                              labelText: 'Last Name',
                              labelStyle: TextStyle(
                                color: Colors.grey[600],
                              ),
                              errorStyle:
                                  TextStyle(color: headerColor, fontSize: 13),
                            ),
                          ),
                        )),
                    SizedBox(
                      height: 25,
                    ),
                    LoginAnimation(
                        1.8,
                        Text('What is your main focus?',
                            style: TextStyle(
                                color: Color.fromRGBO(65, 64, 66, 1),
                                fontSize: 16))),
                    SizedBox(
                      height: 15,
                    ),
                    LoginAnimation(
                      1.8,
                      Container(
                        padding: EdgeInsets.only(
                            top: 0, right: 0, left: 0, bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ButtonGroupSpaced(
                          oneOnly: true,
                          selectedColor: headerColor,
                          selectedTextColor: Colors.white,
                          selectedItems: roleInMarket,
                          items: ['Selling', 'Buying'],
                          callback: (val) {
                            setState(() {
                              roleInMarket = val;
                              enableButton = true;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    LoginAnimation(
                      2,
                      GestureDetector(
                        onTap: () async {
                          if (this.sMarketArea.isNotEmpty &&
                              this.sFirstName.isNotEmpty &&
                              this.sLastName.isNotEmpty &&
                              this.roleInMarket!.length > 0) {
                            FocusScopeNode currentFocus =
                                FocusScope.of(context);

                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }
                            setState(() {
                              this.isLoading = true;
                              this.sCustomerType = roleInMarket![0];
                            });

                            User user = new User(
                                sCustomerType: sCustomerType == 'Selling'
                                    ? 'Disposition Agent'
                                    : 'Investor',
                                sAccountStatus: widget.user.sAccountStatus,
                                sFirstName: this.sFirstName,
                                sLastName: this.sLastName,
                                sEmail: widget.user.sEmail,
                                sPhoneNumber: widget.user.sPhoneNumber,
                                sProfilePicture: widget.user.sProfilePicture,
                                sSuscriptionType: widget.user.sSuscriptionType,
                                sMarketArea: sMarketArea,
                                sCreatedDate: widget.user.sCreatedDate,
                                sMarketAreaToShow: sMarketAreaToShow,
                                sInvitationCode: widget.user.sInvitationCode,
                                sBranchCode: widget.user.sBranchCode,
                                sLanguageSpeak: widget.user.sLanguageSpeak,
                                vfacebook: widget.user.vfacebook,
                                bReferralAvailable:
                                    widget.user.bReferralAvailable,
                                nConnections: widget.user.nConnections,
                                nRequests: widget.user.nRequests,
                                bIsIsland: widget.user.bIsIsland,
                                bUpdateApp: widget.user.bUpdateApp,
                                sSystemTags: widget.user.sSystemTags,
                                bReviewed: widget.user.bReviewed);
                            bool result = await updateUser(user);
                            if (result == true) {
                              context
                                  .read<UserUpdateBloc>()
                                  .add(UserUpdateSubmitted());
                            } else {
                              setState(() {
                                this.isLoading = false;
                              });
                              showDialogAlert(context);
                            }
                          }
                        },
                        child: this.isLoading
                            ? Container(
                                height: 35,
                                width: 35,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        headerColor)))
                            : Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: this.sMarketArea.isNotEmpty &&
                                          this.sFirstName.isNotEmpty &&
                                          this.sLastName.isNotEmpty &&
                                          this.roleInMarket!.length > 0
                                      ? headerColor
                                      : Colors.grey[800],
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Center(
                                  child: Text(
                                    "Continue",
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  updateUser(User user) async {
    var currentLocation;
    if (this.enableLocation) {
      currentLocation = await getCurrentLocation();
    }
    sLatitud = currentLocation != null ? currentLocation.latitude : 37.4226711;
    sLongitud =
        currentLocation != null ? currentLocation.longitude : -122.0849872;
    sZipCode = int.tryParse(
        this.region != null ? this.region[0].postalCode : '77573')!;

    ResponseService response = await UserFacade().updateUser(user, widget.email,
        sLatitud.toString(), sLongitud.toString(), sZipCode.toString());

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

    return response.data || false;
  }

  showDialogAlert(BuildContext context) {
    Widget continueButton = TextButton(
      child: Text("Ok",
          style: TextStyle(
              color: buttonsColor, fontSize: 15, fontWeight: FontWeight.bold)),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('Please try again...'),
      content: Text(
          'An error has occurred while trying to adding user information. Please try again in a moment.'),
      actions: [
        continueButton,
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          dialogContext = context;
          return alert;
        });
  }
}
