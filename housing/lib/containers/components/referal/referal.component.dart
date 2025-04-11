import 'package:another_flushbar/flushbar.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:video_player/video_player.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/models/common/response-service.model.dart';
import 'package:zipcular/repository/facade/user.facade.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';

class ReferalScreen extends StatefulWidget {
  String branchCode;
  String invitationCode;
  ReferalScreen(
      {super.key, required this.branchCode, required this.invitationCode});

  @override
  State<ReferalScreen> createState() => _ReferalScreenState();
}

class _ReferalScreenState extends State<ReferalScreen> {
  late BuildContext? dialogContext;
  late String nInvestorInNetwork = '';
  late String nDealsSell = '';
  late String sBiggestChallenge = '';
  late String sAllowEmailToBuyers = '';

  bool generatingReferal = false;
  VideoPlayerController videoPlayerController =
      VideoPlayerController.networkUrl(Uri.parse(
          'https://zeamlesslogo.s3.us-east-2.amazonaws.com/Zeamless_Seller_Incentive_Program.mp4'));
  late ChewieController _chewieController = ChewieController(
    videoPlayerController: videoPlayerController,
  );

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await videoPlayerController.initialize();
      _chewieController = ChewieController(
          videoPlayerController: videoPlayerController,
          showControls: true,
          showControlsOnInitialize: true,
          allowMuting: true,
          deviceOrientationsAfterFullScreen: [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ],
          draggableProgressBar: true,
          looping: false,
          allowFullScreen: true,
          autoPlay: true,
          autoInitialize: true);
    });

    super.initState();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: headerColor,
        toolbarHeight: 45,
        title: Text(""),
      ),
      body: Container(
        padding: const EdgeInsets.all(0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 30.0,
              ),
              Center(
                child: Text("Seller Benefit Program",
                    style: TextStyle(fontSize: 28, color: Colors.grey[700])),
              ),
              SizedBox(
                height: 25.0,
              ),
              Center(
                child: Container(
                  height: MediaQuery.of(context).size.width * 0.6,
                  width: MediaQuery.of(context).size.width,
                  child: Chewie(
                    controller: _chewieController,
                  ),
                ),
              ),

              SizedBox(height: 20.0),
              Center(
                child: Text(
                  "Learn how it works.",
                  style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                ),
              ),
              SizedBox(height: 30.0),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  "Instant Reach: Notify your buyers with three types of notifications every time you post a property.",
                  style: TextStyle(fontSize: 17, color: Colors.grey[700]),
                ),
              ),
              SizedBox(height: 20.0),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  "The Social Magnet: Automatically bring buyers from social media to your network without lifting a finger.",
                  style: TextStyle(fontSize: 17, color: Colors.grey[700]),
                ),
              ),
              SizedBox(height: 20.0),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  "Visibility Boost: Rank higher on Zeamless search results, gain more visibility, and receive more offers.",
                  style: TextStyle(fontSize: 17, color: Colors.grey[700]),
                ),
              ),
              SizedBox(height: 30.0),
              // Implement a button here
              Container(
                child: generatingReferal
                    ? Center(
                        child: Container(
                          height: 30,
                          width: 30,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(headerColor),
                          ),
                        ),
                      )
                    : widget.branchCode.isEmpty
                        ? Center(
                            child: Container(
                              width: 200,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  showDialogAlert(context, 'Request Referal');
                                },
                                child: Text(
                                  "Request Seller Link",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: headerColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: SingleChildScrollView(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(text: widget.branchCode),
                                      ).then(
                                        (value) => {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  "Link copied to clipboard",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                              duration: Duration(seconds: 2),
                                            ),
                                          )
                                        },
                                      );
                                    },
                                    child: Text(
                                      "Copy Link",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: headerColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadiusDirectional.only(
                                                bottomEnd: Radius.circular(0.0),
                                                bottomStart:
                                                    Radius.circular(10),
                                                topEnd: Radius.circular(0.0),
                                                topStart: Radius.circular(10)),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 0),
                                  ElevatedButton(
                                    onPressed: () {},
                                    child: Text(
                                      "https://.../" +
                                          widget.branchCode.split('link/')[1],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[400],
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadiusDirectional.only(
                                          bottomEnd: Radius.circular(10),
                                          bottomStart: Radius.circular(0),
                                          topEnd: Radius.circular(10),
                                          topStart: Radius.circular(0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  generateReferal() async {
    bool generated = false;
    setState(() {
      generatingReferal = true;
    });

    try {
      final BranchUniversalObject branchUniversalObject = BranchUniversalObject(
        canonicalIdentifier: widget.invitationCode,
        title: 'Zeamless App - Referral',
        contentDescription:
            'Use this link to join Zeamless app and get rewarded!',
        imageUrl:
            'https://cdn.branch.io/branch-assets/1683497125718-og_image.png',
        keywords: ['zeamless', 'referral', 'flutter', 'deeplinking'],
        publiclyIndex: true,
        locallyIndex: true,
        contentMetadata: BranchContentMetaData()
          ..addCustomMetadata('referal', widget.invitationCode),
      );

      final BranchLinkProperties linkProperties = BranchLinkProperties(
          channel: 'App',
          feature: 'referral_link',
          campaign: 'app launch',
          stage: 'referal_app');

      BranchResponse response = await FlutterBranchSdk.getShortUrl(
        linkProperties: linkProperties,
        buo: branchUniversalObject,
      );

      if (response.success) {
        generated = true;
        final result = response.result;
        //Send Referal link to databse

        ResponseService rService = await UserFacade()
            .updateProfile('', result, List<String>.empty(growable: true));
        if (rService.hasConnection == false) {
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
          UserRepository _userRepository = UserRepository();
          await _userRepository.writeToken('branchCode', result);
          setState(() {
            generatingReferal = false;
            widget.branchCode = result;
          });
        }
      } else {
        print('Failed to generate referral link: ${response.errorCode}');
        return null;
      }
    } catch (e) {
      setState(() {
        generatingReferal = false;
      });
    }
    return generated;
  }

  saveReferalAnswers() async {
    bool saved = false;
    final response = List<String>.empty(growable: true);
    response.add(nInvestorInNetwork);
    response.add(nDealsSell);
    response.add(sBiggestChallenge);
    response.add(sAllowEmailToBuyers);

    ResponseService rService =
        await UserFacade().updateProfile('', '', response);
    if (rService.hasConnection == false) {
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
      saved = true;
    }
    setState(() {
      nInvestorInNetwork = '';
      nDealsSell = '';
      sBiggestChallenge = '';
      sAllowEmailToBuyers = '';
    });
    return saved;
  }

  showDialogAlert(BuildContext context, String title) {
    Widget cancelButton = TextButton(
      child: Text("Continue",
          style: TextStyle(
              color: buttonsColor, fontSize: 15, fontWeight: FontWeight.bold)),
      onPressed: () async {
        bool saved = await saveReferalAnswers();
        if (saved) {
          await generateReferal();
        }
        Navigator.pop(dialogContext!);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Cancel",
          style: TextStyle(
              color: headerColor, fontSize: 15, fontWeight: FontWeight.bold)),
      onPressed: () {
        setState(() {
          nInvestorInNetwork = '';
          nDealsSell = '';
          sBiggestChallenge = '';
          sAllowEmailToBuyers = '';
        });
        Navigator.pop(dialogContext!);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            children: [
              Text(
                'What is the approximate number of buyers on your network?',
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.number,
                maxLines: 1,
                maxLength: 8,
                onChanged: (value) {
                  setState(() {
                    nInvestorInNetwork = value;
                  });
                },
                decoration: InputDecoration(
                  helperStyle: TextStyle(color: Colors.white),
                  floatingLabelAlignment: FloatingLabelAlignment.start,
                  labelText: "Number of buyers",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Approximately, how many transactions did you successfully close in the last 12 months? ',
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.number,
                maxLines: 1,
                maxLength: 8,
                onChanged: (value) {
                  setState(() {
                    nDealsSell = value;
                  });
                },
                decoration: InputDecoration(
                  helperStyle: TextStyle(color: Colors.white),
                  floatingLabelAlignment: FloatingLabelAlignment.start,
                  labelText: "Number of transactions",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "In a brief sentence, what's a challenge you face in the disposition side of your business that, if solved, would improve your business efficiency and profitability?",
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(height: 10),
              TextField(
                maxLines: 9,
                minLines: 1,
                onChanged: (value) {
                  setState(() {
                    sBiggestChallenge = value;
                  });
                },
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: Colors.white),
                  floatingLabelAlignment: FloatingLabelAlignment.start,
                  labelText: "Leave a comment",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Are you interested in utilizing Zeamless to send property email blasts to your buyers at zero cost? You have EXCLUSIVE rights, only you can access and/or reach your buyers. Feel free to share your viewpoints.',
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(height: 10),
              TextField(
                maxLines: 9,
                minLines: 1,
                onChanged: (value) {
                  setState(() {
                    sAllowEmailToBuyers = value;
                  });
                },
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: Colors.white),
                  floatingLabelAlignment: FloatingLabelAlignment.start,
                  labelText: "Leave a comment",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
      actions: [
        continueButton,
        cancelButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        dialogContext = context;
        return alert;
      },
    );
  }
}
