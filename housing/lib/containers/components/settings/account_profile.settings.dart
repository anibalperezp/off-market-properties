import 'dart:io';
import 'dart:typed_data';

import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:zipcular/models/common/response-service.model.dart';
import 'package:zipcular/repository/facade/common.facade.dart';
import 'package:zipcular/repository/facade/upload_media.facade.dart';
import 'package:zipcular/repository/facade/user.facade.dart';
import 'package:zipcular/repository/provider/user.provider.dart';
import 'package:zipcular/repository/services/prod/upload_media.service.dart';
import '../../../repository/services/prod/user_repository.dart';

class AccountProfileSettings extends StatefulWidget {
  AccountProfileSettings({Key? key}) : super(key: key);

  @override
  _AccountProfileSettings createState() => _AccountProfileSettings();
}

class _AccountProfileSettings extends State<AccountProfileSettings> {
  BuildContext? dialogContext;
  UserRepository _userRepository = new UserRepository();
  List<String> reasonSelected = List<String>.empty(growable: true);
  final picker = ImagePicker();
  File? _image;
  bool editName = false;
  bool editEmail = false;
  bool editPhone = false;
  bool editPassword = false;
  List<String> options = [
    'App Performane Issues',
    'Found a Better Alternative',
    'Privacy Concerns',
    'Poor Customer Service',
    'Pricing',
    'Other'
  ];
  TextEditingController otherReasonController = TextEditingController();

  //Languages MultiSelect
  final languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Japanese',
    'Chinese',
    'Russian',
    'Portuguese',
    'Tagalo',
    'Vietnamese',
    'Korean',
    'Arabic',
    'Hindi',
    'Farsi'
  ];
  List<dynamic> _items = List.empty(growable: true);
  List<dynamic> _selectedLanguages = List.empty(growable: true);

  @override
  void initState() {
    final sLanguageSpeak =
        Provider.of<UserProvider>(context, listen: false).user.sLanguageSpeak;
    this._selectedLanguages = sLanguageSpeak.isEmpty == true
        ? List.empty(growable: true)
        : sLanguageSpeak.split(',');
    this._items = languages.map((lang) => MultiSelectItem(lang, lang)).toList();
    this.otherReasonController.text = '';
    super.initState();
  }

  @override
  void dispose() {
    this.otherReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text(
          'Account & Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: headerColor,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return Container(
            color: Colors.white,
            child: Stack(
              children: <Widget>[
                SettingsList(
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                  shrinkWrap: true,
                  sections: [
                    CustomSettingsSection(
                      child: GestureDetector(
                        onTap: () async {
                          await _showSelectionDialog();
                        },
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 5),
                              child: Column(
                                children: [
                                  Container(
                                    height: 200,
                                    width: 200,
                                    child: CircleAvatar(
                                      radius: 41.3,
                                      backgroundColor: Colors.white,
                                      child: ClipOval(
                                        child: _image == null
                                            ? userProvider.user.sProfilePicture
                                                    .isNotEmpty
                                                ? Image.network(
                                                    userProvider
                                                        .user.sProfilePicture,
                                                    height: 183,
                                                    width: 183,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.asset(
                                                    'assets/images/friend1.jpg',
                                                    height: 183,
                                                    width: 183,
                                                    fit: BoxFit.cover,
                                                  ) // set a placeholder image when no photo is set
                                            : Image.file(_image!,
                                                height: 183,
                                                width: 183,
                                                fit: BoxFit.cover),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 14),
                                    height: 32,
                                    width: 90,
                                    decoration: BoxDecoration(
                                      color: headerColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Edit Photo',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SettingsSection(
                      title: Text('Account Information',
                          style: TextStyle(color: baseColor, fontSize: 23)),
                      tiles: [
                        SettingsTile(
                          title: Text(
                              userProvider.user.sFirstName +
                                  ' ' +
                                  userProvider.user.sLastName,
                              style: TextStyle(
                                  color: baseColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                          description: Text('Full Name',
                              style: TextStyle(color: baseColor, fontSize: 15)),
                          leading:
                              Icon(Icons.person, color: headerColor, size: 30),
                          // onPressed: (BuildContext b) {
                          //   setState(() {
                          //     editName = !editName;
                          //   });
                          // },
                          // trailing: editName == false
                          //     ? Icon(Icons.edit, color: Colors.grey[600])
                          //     : Icon(Icons.save, color: headerColor),
                          //     enabled: false
                        ),
                        SettingsTile(
                          title: Text(
                            userProvider.user.sPhoneNumber,
                            style: TextStyle(
                                color: baseColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w700),
                          ),
                          description: Text(
                            'Phone Number',
                            style: TextStyle(color: baseColor, fontSize: 15),
                          ),
                          leading:
                              Icon(Icons.phone, color: headerColor, size: 30),
                          // onPressed: (BuildContext b) {
                          //   setState(() {
                          //     editPhone = !editPhone;
                          //   });
                          // },
                          // trailing: editPhone == false
                          //     ? Icon(Icons.edit, color: Colors.grey[600])
                          //     : Icon(Icons.save, color: headerColor),
                          //      enabled: false
                        ),
                        SettingsTile(
                          title: Text(
                            userProvider.user.sEmail,
                            style: TextStyle(
                                color: baseColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w700),
                          ),
                          description: Text(
                            'Email',
                            style: TextStyle(color: baseColor, fontSize: 15),
                          ),
                          leading: Icon(
                            Icons.alternate_email,
                            color: headerColor,
                            size: 30,
                          ),
                          // onPressed: (BuildContext b) {
                          //   setState(() {
                          //     editEmail = !editEmail;
                          //   });
                          // },
                          // trailing: editEmail == false
                          //     ? Icon(Icons.edit, color: Colors.grey[600])
                          //     : Icon(Icons.save, color: headerColor),
                          // enabled: false
                        ),
                        SettingsTile(
                          title: Text(
                            userProvider.user.sMarketArea,
                            style: TextStyle(
                                color: baseColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w700),
                          ),
                          description: Text(
                            'Market Area',
                            style: TextStyle(color: baseColor, fontSize: 15),
                          ),
                          leading: Icon(Icons.location_on,
                              color: headerColor, size: 30),
                        ),
                        SettingsTile(
                          title: MultiSelectBottomSheetField(
                            onSelectionChanged: (p0) {},
                            initialValue: _selectedLanguages,
                            initialChildSize: 0.3,
                            listType: MultiSelectListType.LIST,
                            searchable: true,
                            itemsTextStyle:
                                TextStyle(fontSize: 14, color: baseColor),
                            searchHintStyle:
                                TextStyle(fontSize: 14, color: baseColor),
                            buttonIcon: Icon(Icons.add_circle,
                                color: headerColor, size: 22),
                            buttonText: Text("Speak Languages",
                                style: TextStyle(fontSize: 15)),
                            title: Text("Languages",
                                style: TextStyle(fontSize: 21)),
                            items: _items as List<MultiSelectItem<dynamic>>,
                            selectedColor: headerColor,
                            separateSelectedItems: false,
                            selectedItemsTextStyle:
                                TextStyle(color: headerColor, fontSize: 14),
                            onConfirm: (values) async {
                              String _selectedLanguagesName = '';

                              setState(() {
                                _selectedLanguages = values;
                              });

                              if (_selectedLanguages.isEmpty) {
                                final flush = Flushbar(
                                  message:
                                      'Select at least one language you speak.',
                                  flushbarStyle: FlushbarStyle.FLOATING,
                                  margin: EdgeInsets.all(8.0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
                                  icon: Icon(
                                    Icons.error,
                                    size: 28.0,
                                    color: headerColor,
                                  ),
                                  duration: Duration(seconds: 2),
                                  leftBarIndicatorColor: headerColor,
                                );

                                flush.show(context);
                              } else {
                                if (_selectedLanguages.length == 1) {
                                  _selectedLanguagesName =
                                      _selectedLanguages[0];
                                } else {
                                  values.forEach((element) {
                                    if (element.isNotEmpty) {
                                      _selectedLanguagesName +=
                                          element.toString() + ',';
                                    }
                                  });
                                }
                                ResponseService rService = await UserFacade()
                                    .updateProfile(_selectedLanguagesName, '',
                                        List<String>.empty(growable: true));
                                if (rService.hasConnection == false) {
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
                                } else {
                                  userProvider
                                      .updateLanguage(_selectedLanguagesName);
                                }
                              }
                            },
                            chipDisplay: MultiSelectChipDisplay(
                              onTap: (value) {
                                setState(() {
                                  _selectedLanguages.remove(value);
                                });
                              },
                            ),
                          ),
                          description: Text(
                            '',
                            style: TextStyle(color: baseColor, fontSize: 12),
                          ),
                          leading: Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Icon(
                              Icons.language,
                              color: headerColor,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SettingsSection(
                      title: Text('Notifications',
                          style: TextStyle(color: baseColor, fontSize: 23)),
                      tiles: [
                        SettingsTile.switchTile(
                          activeSwitchColor: headerColor,
                          title: Text(
                            'Opt-in for Email alerts and promotions.',
                            style: TextStyle(color: baseColor, fontSize: 15),
                          ),
                          leading: Icon(Icons.mark_email_read,
                              color: headerColor, size: 30),
                          initialValue: true,
                          enabled: true,
                          onToggle: (bool value) {
                            setState(() {
                              //lockInBackground = value;
                            });
                          },
                        ),
                        SettingsTile.switchTile(
                          activeSwitchColor: headerColor,
                          title: Text('Opt-in for SMS alerts and promotions.',
                              style: TextStyle(color: baseColor, fontSize: 15)),
                          leading:
                              Icon(Icons.sms, color: headerColor, size: 30),
                          initialValue: true,
                          enabled: true,
                          onToggle: (bool value) {
                            setState(() {
                              //editPassword = value;
                            });
                          },
                        ),
                      ],
                    ),
                    SettingsSection(
                      title: Text(
                        'Actions',
                        style: TextStyle(color: baseColor, fontSize: 23),
                      ),
                      tiles: [
                        SettingsTile(
                          onPressed: (context) async {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Delete Account',
                                      style: TextStyle(
                                          color: headerColor, fontSize: 15)),
                                  content: StatefulBuilder(
                                    builder: (BuildContext context,
                                        StateSetter setState) {
                                      return Container(
                                        width: double.maxFinite,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                1.05,
                                        child: Column(
                                          children: [
                                            Text(
                                              'We are sorry for not meeting your expectations. Please share your departure reasons to help us improve our app for future users:',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            // Checkboxes list
                                            Expanded(
                                              child: ListView.builder(
                                                padding:
                                                    EdgeInsets.only(bottom: 0),
                                                shrinkWrap: true,
                                                itemCount: options.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  final option = options[index];
                                                  return CheckboxListTile(
                                                    activeColor: headerColor,
                                                    contentPadding:
                                                        EdgeInsets.all(0),
                                                    controlAffinity:
                                                        ListTileControlAffinity
                                                            .leading,
                                                    title: Text(
                                                      option,
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color:
                                                              Colors.grey[800]),
                                                    ),
                                                    value: this
                                                        .reasonSelected
                                                        .contains(option),
                                                    onChanged: (value) {
                                                      setState(
                                                        () {
                                                          if (this
                                                              .reasonSelected
                                                              .contains(
                                                                  option)) {
                                                            this
                                                                .reasonSelected
                                                                .remove(option);
                                                          } else {
                                                            this
                                                                .reasonSelected
                                                                .add(option);
                                                          }
                                                        },
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text("Cancel",
                                          style: TextStyle(
                                              color: buttonsColor,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold)),
                                      onPressed: () {
                                        setState(() {
                                          this.reasonSelected =
                                              List<String>.empty(
                                                  growable: true);
                                        });
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text(
                                        "Confirm",
                                        style: TextStyle(
                                            color: headerColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: () async {
                                        if (this.reasonSelected.length != 0) {
                                          ResponseService response =
                                              await FacadeCommonService()
                                                  .deleteAccount(
                                                      this.reasonSelected);
                                          if (response.bSuccess!) {
                                            final _storage =
                                                FlutterSecureStorage();
                                            await _storage.deleteAll();
                                          }
                                          Navigator.of(context).pop(true);
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                            ).then(
                              (value) {
                                if (value != null) {
                                  // Delete account
                                  Navigator.of(context).pop(true);
                                }
                              },
                            );
                          },
                          title: Text(
                            'Delete Account',
                            style: TextStyle(
                                fontSize: 16,
                                color: headerColor,
                                fontWeight: FontWeight.w700),
                          ),
                          leading: Icon(Icons.dangerous_rounded,
                              color: headerColor, size: 30),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Future selectOrTakePhoto(ImageSource imageSource) async {
    //Select from gallerry or take a photo
    final pickedFile = await picker.pickImage(source: imageSource);

    if (pickedFile != null) {
      //Crop the image
      CroppedFile imageToUpload = await cropImage(pickedFile.path);
      setState(() {
        _image = File(imageToUpload.path);
      });

      //Upload the image
      UploadMediaService uploadService = new UploadMediaService();
      var response = await UploadMediaFacade().presignPhotoProfile();

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
        Uint8List imageData = await imageToUpload.readAsBytes();

        imageData = await uploadService.compressList(imageData);

        if (response.data != null) {
          await uploadService.uploadImage(
              userProfileBucket, response.data, imageData);
          ResponseService result = await UploadMediaFacade()
              .customerUpdatePhoto(baseUserProfileBucket + response.data.url);
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
          if (result.bSuccess!) {
            final urlImage = baseUserProfileBucket + response.data.url;
            Provider.of<UserProvider>(context, listen: false)
                .updateImageProfile(urlImage);
          }
        }
      }
    } else {
      print('No photo was selected or taken');
    }
  }

  cropImage(String pickedFilePath) async {
    CroppedFile? croppedFile;
    try {
      croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFilePath,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.blue,
              hideBottomControls: true,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(title: 'Cropper'),
          WebUiSettings(
            context: context,
          ),
        ],
      );
    } catch (e) {
      await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
    }
    return croppedFile!;
  }

  Future _showSelectionDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Select photo'),
          children: <Widget>[
            SimpleDialogOption(
              child: Text('From gallery'),
              onPressed: () {
                selectOrTakePhoto(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
            SimpleDialogOption(
              child: Text('Take a photo'),
              onPressed: () {
                selectOrTakePhoto(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
