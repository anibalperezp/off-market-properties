import 'package:flutter/material.dart';

///
//Variables
const kTextColor = Color(0xFF535353);
const kDefaultPaddin = 5.0;
const baseColor = Colors.black; //Color.fromRGBO(46, 65, 114, 1);
const headerColor = Color.fromRGBO(220, 53, 38, 1);
const buttonsColor = Color.fromRGBO(38, 42, 52, 1);
const backgroundColor = Color.fromRGBO(24, 26, 31, 1);
const chatTitleColor = Color.fromRGBO(115, 115, 115, 1);
const chatMessageColor = Color.fromRGBO(84, 84, 84, 1);
const chatDarkTitleColor = Color.fromRGBO(29, 28, 29, 1);
const chatDarkMessageColor = Color.fromRGBO(15, 15, 15, 1);
const baseButtonColor = Colors.black;

///
const kPrimaryOFU = 'XXXX-XXXXXX-XXXX-XXX';

///
///
const baseUrl = 'XXXXXXXXX.execute-api.us-east-2.amazonaws.com';

///
// CHAT
///
const baseUrlChat = 'https://XXXXXXXXX.execute-api.us-east-2.amazonaws.com';
const baseUrlChatWebSocket =
    'wss://XXXXXXXXX.execute-api.us-east-2.amazonaws.com/prod';

///
/// BUCKET
///
const baseBucketSubmitMedia = 'https://XXXXXXXXXXX.cloudfront.net';
const baseBucket = 'https://XXXXXXXXXXXX.s3-accelerate.amazonaws.com';
const userProfileBucket = 'https://XXXXXXXXXXXXX.s3-accelerate.amazonaws.com';
const baseUserProfileBucket = 'https://XXXXXXXXXXXXXXXXXX.cloudfront.net';
const splashBucket = 'https://XXXXXXXXXXXX.s3.us-east-2.amazonaws.com';
//ROUTES
///
///
///
//Listing
const GET_PRESIGNED_URL = '/prod/lysting/getpresignedurl';
const LISTING_CREATE = '/prod/lysting/create';
const LISTING_SUBMIT_MEDIA = '/prod/lysting/submitmedia';
const LISTING_GET_ALL = '/prod/lysting/getalllystings';
const LISTING_VALIDATE = '/prod/lysting/validate';
const SEARCH_LISTINGS = '/prod/lysting/search';
const LISTING_POST = '/prod/lysting/approve';
const CUSTOMER_LISTING = '/prod/lysting/get';
const LISTING_UPDATE = '/prod/customer/lysting/update';
const LISTING_CUSTOMER_PROFILE = '/prod/lysting/customer/profile';
const LISTING_SOCIAL_SHARE_UPDATE = '/prod/lysting/approve/share';
const LISTING_PREVIEW_SOCIAL_SHARE = '/prod/lysting/share';
//Listing
///
///
///
//Draft
const DRAFT_CREATE = '/prod/lysting/create/draft';
const DRAFT_GET = '/prod/lysting/get/draft';
const DRAFT_GET_ALL = '/prod/customer/lysting/getall/drafts';
//Draft
///
///
///
//Filter
const FILTER_APPLY = '/prod/customer/filter/apply';
const FILTER_DEFAULT = '/prod/customer/filter/getdefaultfilter';
//Filter
///
///
//Favorites
const FAVORITE_GET_ALL = '/prod/customer/favorite/getall';
const FAVORITE_ADD = '/prod/customer/favorite/add';
const FAVORITE_DELETE = '/prod/customer/favorite/delete';
//Favorites
///
///
//MyLisings
const CUSTOMER_LISTINGS = '/prod/customer/lysting/getall';
const CUSTOMER_LISTING_DELETE = '/prod/customer/lysting/delete';
const CUSTOMER_LISTING_CHANGE_STATUS = '/prod/customer/lysting/update/status';
const ALLOW_CALL_EMAIL = '/prod/lysting/get/parameter';
const SEND_EMAIL = '/prod/customer/lysting/sendEmail';
const CUSTOMER_VALIDATE = '/prod/lysting/get/validatecontact';
const GET_EMAIL = '/prod/lysting/get/email';
//MyLisings
///
///
///
//Authorization
const LOGIN = '/prod/auth/login';
const REGISTER = '/prod/auth/register';
const GETAPNR = '/prod/customer/device/saveapnr';
const FORGOT_PASS = '/prod/auth/forgotpassword';
const FORGOT_PASS_CONFIRMATION = '/prod/auth/forgotpassword/confirm';
const REFRESH_TOKEN = '/prod/seo/auth/refresh';
const DELETE_ACCOUNT = '/prod/customer/info/delete';
//Authorization
///
///
///
//OTP
const CONFIRM_USER_OTP = '/prod/auth/register/confirmation';
const RESEND_USER_OTP = '/prod/auth/register/resendcode';
const CONFIRM_EMAIL_OTP = '/prod/auth/verifyemail/verification';
const RESEND_EMAIL_OTP = '/prod/auth/verifyemail/sendcode';
//OTP
///
///
///
//USER
const USER_GET = '/prod/customer/info/getcustomer';
const USER_SAVE_REVIEW = '/prod/customer/review';
const USER_UPDATE = '/prod/customer/info/update';
const USER_SEARCH_MARKET = '/prod/customer/info/marketarea';
const USER_PRESIGNED_PHOTO_PROFILE = '/prod/customer/profile/photo';
const USER_UPDATE_PHOTO = '/prod/customer/profile/photo/update';
const USER_CUSTOMER_PROFILE = '/prod/customer/profile/parameters';

// USER NETWORK ------------------------------------------------
const USER_CONNECTIONS = '/prod/customer/profile/network/get';
const USER_NEW_REQUESTS = '/prod/customer/profile/network/request/in';
const USER_BLOCKS = '/prod/customer/profile/network/block/get';
const USER_REQUEST_SEND = '/prod/customer/profile/network/request';
const USER_REQUEST_CANCEL = '/prod/customer/profile/network/request/cancel';
const USER_REQUEST_ACCEPT = '/prod/customer/profile/network/request/accept';
const USER_CONNECTION_CANCEL = '/prod/customer/profile/network/cancel';
const USER_CONNECTION_BLOCK = '/prod/customer/profile/network/block';
const USER_CONNECTION_UNBLOCK = '/prod/customer/profile/network/block/cancel';
// USER NETWORK ------------------------------------------------
//USER
///
///
///
//ChatUser
const CHAT_HIST = '/prod/chat/getchathistory';
const CHAT_MESSAGES = '/prod/chat/getchat';
const DELETE_CHAT = '/prod/chat/deletechat';
const DELETE_MESSAGE = '/prod/chat/deletemessage';
const CHAT_UPDATE = '/prod/chat/update';

///
///
///
//COMMON
const CUSTOMER_REVIEW = 'prod/customer/review';
const CUSTOMER_NOTIFICATIONS = 'prod/customer/notifications/getall';
const CUSTOMER_NOTIFICATIONS_UPDATE = 'prod/customer/notifications/update';
const CUSTOMER_NOTIFICATIONS_PENDING_VIEW =
    'prod/customer/notifications/notseen';

///
///
///
//sAUTH
const AUTH_PHONE = 'phone_val'; //(next step validate phone)
const AUTH_EMAIL = 'email_val'; //(next step validate email)
const CONFIRM_THROUGH_EMAIL =
    'confirm_through_email'; //(next step CONFIRM USER email)
const CONFIRM_THROUGH_PHONE =
    'confirm_through_phone'; //(next step CONFIRM USER email)
const AUTH_USER_INFO = 'userinf_val'; //( next step put user info)
const AUTH_SUCCESS = 'success'; //(next step map)
const AUTH_LOGIN = 'login'; //(next step login)
const AUTH_RESEND_PHONE =
    'resend_phone_code'; //(next step resend validate phone code)
const AUTH_VERIFICATION_PHONE_CODE =
    'inv_ver_phocod'; //(next step resend validate or reenter phone code)
const AUTH_USER_NOT_CREATED = 'user_not_created'; //(next step register again)
const AUTH_VERIFICATION_CODE_FORGOT_PASSWORD =
    'verified_code_forgotpass'; //(next step create new pass)
const AUTH_FORGOT_PASS_ERROR =
    'forgot_pass_err'; //(next step resend or re-insert forgot pass code)
const AUTH_RESEND_EMAIL_CODE =
    'resend_email_code'; //(next step resend validate email  code)
const AUTH_MAINTAINANCE_MODE = 'Maintenance_Mode'; //(next step maintainance)
const NO_CONNECTION =
    'no_connection'; //(next step resend validate or reenter email code)
const FORCE_UPDATE = 'force_update'; //(next step force update)

const INVALID_CONFIRMED_CODE = 'inv_confirm_code';
const RESEND_CONFIRMED_CODE = 'resend_confirm_code';
const QUICK_ACCESS_USER = 'quick_access_user';
const QUICK_ACCESS_LISTING = 'quick_access_listing';

//
//NETWORK
const NETWORK_UNCONNECTED = 'Unconnected';
const NETWORK_CONNECTED = 'Connected';
const NETWORK_REQUESTOUT = 'RequestOut';
const NETWORK_REQUESTIN = 'RequestIn';
const NETWORK_BLOCKED = 'Blocked';
const NETWORK_BLOCKEDIN = 'BlockedIn';
