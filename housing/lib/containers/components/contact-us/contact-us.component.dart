import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zipcular/commons/main.constants.global.dart';

class ContactUs extends StatefulWidget {
  ContactUs({Key? key}) : super(key: key);

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _makePhoneCall(String phone) async {
    if (await canLaunchUrl(Uri.parse("tel://$phone"))) {
      await launchUrl(Uri.parse("tel://$phone"));
    } else {
      throw 'Could not launch phone call';
    }
  }

  Future<void> _sendEmail(String email) async {
    final String mailto = 'mailto:$email';
    if (await canLaunchUrl(Uri.parse(mailto))) {
      await launchUrl(Uri.parse(mailto));
    } else {
      throw 'Could not launch email';
    }
  }

  Future<void> _showChatbotDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chat with us'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This feature coming soon.'),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: headerColor,
                fixedSize: Size.fromWidth(100),
                padding: EdgeInsets.all(10),
              ),
              child: Text("Okay"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: headerColor,
        toolbarHeight: 45,
        title: Text('Contact Us'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: 25.0,
              ),
              Image.asset(
                'assets/images/help3.png',
                height: 185,
                fit: BoxFit.cover,
              ),
              SizedBox(
                height: 50.0,
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.phone),
                  title: Text('Phone Number'),
                  subtitle: Text('+1-832-856-0654'),
                  onTap: () => _makePhoneCall('+1-832-856-0654'),
                ),
              ),
              SizedBox(
                height: 12.0,
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.email),
                  title: Text('Email'),
                  subtitle: Text('support@zipcular.com'),
                  onTap: () => _sendEmail('support@zipcular.com'),
                ),
              ),
              SizedBox(
                height: 12.0,
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.chat),
                  title: Text('Chat With Us'),
                  onTap: () => _showChatbotDialog(context),
                ),
              ),
              SizedBox(
                height: 12.0,
              ),
              Card(
                  child: Container(
                height: 150,
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Social Media', style: TextStyle(fontSize: 18)),
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                              onTap: () async {
                                final Uri _url = Uri.parse(
                                    'https://www.facebook.com/zeamless');
                                if (await canLaunchUrl(_url)) {
                                  await launchUrl(_url);
                                } else {
                                  // can't launch url
                                }
                              },
                              child: Icon(
                                FontAwesomeIcons.facebook,
                                color: Colors.blue,
                                size: 30,
                              )),
                          SizedBox(
                            width: 30,
                          ),
                          GestureDetector(
                              onTap: () async {
                                final Uri _url = Uri.parse(
                                    'https://twitter.com/zeamlessapp');
                                if (await canLaunchUrl(_url)) {
                                  await launchUrl(_url);
                                } else {
                                  // can't launch url
                                }
                              },
                              child: Icon(
                                FontAwesomeIcons.twitter,
                                color: Colors.blue,
                                size: 30,
                              )),
                          SizedBox(
                            width: 30,
                          ),
                          GestureDetector(
                              onTap: () async {
                                final Uri _url = Uri.parse(
                                    'https://linkedin.com/zeamlessapp');
                                if (await canLaunchUrl(_url)) {
                                  await launchUrl(_url);
                                } else {
                                  // can't launch url
                                }
                              },
                              child: Icon(
                                FontAwesomeIcons.linkedin,
                                color: Colors.blue[700],
                                size: 30,
                              )),
                          SizedBox(
                            width: 30,
                          ),
                          GestureDetector(
                              onTap: () async {
                                final Uri _url =
                                    Uri.parse('https://www.youtube.com');
                                if (await canLaunchUrl(_url)) {
                                  await launchUrl(_url);
                                } else {
                                  // can't launch url
                                }
                              },
                              child: Icon(
                                FontAwesomeIcons.youtube,
                                color: Colors.red,
                                size: 30,
                              )),
                        ],
                      )
                    ]),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
