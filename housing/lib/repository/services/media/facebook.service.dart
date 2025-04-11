import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:zipcular/repository/services/prod/user_repository.dart';

class FacebookService {
  UserRepository _userRepository = new UserRepository();

  /// FACEBOOK AUTH
  loginFacebook() async {
    LoginResult result = await FacebookAuth.instance.login(permissions: [
      'email',
      'public_profile',
      'groups_access_member_info',
      'pages_show_list',
      'pages_manage_posts',
      'publish_to_groups',
      'pages_read_engagement'
    ]);
    //by default we request the email and the public profile
    //or FacebookAuth.i.login()
    if (result.status == LoginStatus.success) {
      // you are logged
      final AccessToken accessToken = result.accessToken!;
      return accessToken;
    } else {
      print(result.status);
      print(result.message);
    }
    return null;
  }

  /// FACEBOOK GRAPH API
  ///
  /// Get user groups
  /// https://developers.facebook.com/docs/graph-api/reference/user/groups/
  Future<List<Map<String, dynamic>>> getUserGroups(String accessToken) async {
    final vFacebook = await _userRepository.readKey('vFacebook');
    final subdomain = '/me/groups';
    final url = Uri.https(
        'graph.facebook.com', subdomain, {'access_token': accessToken});
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<Map<String, dynamic>> groups =
          List<Map<String, dynamic>>.from(data['data']);
      return groups;
    } else {
      print('Error retrieving user groups: ${response.body}');
      return [];
    }
  }

  ///
  ///
  /// Post to Facebook group
  /// Just Message
  /// https://developers.facebook.com/docs/graph-api/reference/v13.0/group/feed
  Future<bool> postToFacebookGroup(String accessToken, String groupId,
      String message, String link, String image) async {
    final vFacebook = await _userRepository.readKey('vFacebook');
    final subdomain = '/v' + vFacebook + '/' + groupId + '/feed';

    final url = Uri.https(
        'graph.facebook.com', subdomain, {'access_token': accessToken});

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'message': message,
        //'link': link.isEmpty ? 'https://zeamless.app.link/4U1m2GePJBb' : link,
        'link': image
      },
    );

    if (response.statusCode == 200) {
      print('Posted to Facebook group successfully.');
      return true;
    } else {
      print('Error posting to Facebook group: ${response.body}');
      return false;
    }
  }

  ///
  ///
  /// Post to Facebook page
  /// Message and referral link
  /// https://developers.facebook.com/docs/graph-api/reference/v13.0/page/feed
  Future<void> postListingToFacebook(
      String accessToken, String message, String link) async {
    final url = Uri.parse('https://graph.facebook.com/v13.0/me/feed');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'message': message,
        'link': link,
        'access_token': accessToken,
      },
    );

    if (response.statusCode == 200) {
      print('Listing posted successfully on Facebook.');
    } else {
      print('Error posting listing on Facebook: ${response.body}');
    }
  }

  ///
  ///
  /// Post to Facebook page Image
  /// Message, referral link and image
  /// https://developers.facebook.com/docs/graph-api/reference/v13.0/page/feed
  // Future<bool> postListingImageToGroup(String accessToken, String message, String imagePath, String link) async {
  //   final response = await http.post(
  //     Uri.parse("https://graph.facebook.com/v13.0/$groupId/photos"),
  //     headers: {
  //       "Authorization": "Bearer $_accessToken",
  //     },
  //     body: {
  //       "message": message,
  //       "link": link, // Add the link parameter here
  //     },
  //     files: [
  //       http.MultipartFile(
  //         'source',
  //         http.ByteStream(Stream.castFrom(File(imagePath).openRead())),
  //         await File(imagePath).length(),
  //         filename: basename(imagePath),
  //         contentType: MediaType('image', 'jpeg'), // Adjust as needed
  //       ),
  //     ],
  //   );

  //   if (response.statusCode == 200) {
  //     print("Posted image with link to group successfully!");
  //   } else {
  //     print("Failed to post image with link to group. Error: ${response.body}");
  //   }
  // }
}
