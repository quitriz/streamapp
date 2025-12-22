import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/config.dart';
import 'package:streamit_flutter/models/common/base_response.dart';
import 'package:streamit_flutter/network/rest_apis.dart';
import 'package:streamit_flutter/network/user_agent_utils.dart';
import 'package:streamit_flutter/screens/auth/sign_in.dart';
import 'package:streamit_flutter/utils/common.dart';
import 'package:streamit_flutter/utils/constants.dart';
import 'package:streamit_flutter/utils/woo_commerce/query_string.dart';

import '../main.dart';

enum HttpMethod { GET, POST, DELETE, PUT }

enum ResponseType { FULL_RESPONSE, JSON_RESPONSE, BODY_BYTES, STRING_RESPONSE }

Future<Map<String, String>> buildTokenHeader({
  bool aAuthRequired = true,
  bool requiredNonce = false,
  bool isWebView = false,
}) async {
  Map<String, String> header = {
    HttpHeaders.cacheControlHeader: 'no-cache',
    'Access-Control-Allow-Headers': '*',
    'Access-Control-Allow-Origin': '*',
  };

  String cookieHeader = getStringAsync(COOKIE_HEADER);

  header.putIfAbsent(HttpHeaders.contentTypeHeader, () => 'application/json; charset=utf-8');
  if (cookieHeader.isNotEmpty && aAuthRequired) header.putIfAbsent(HttpHeaders.cookieHeader, () => cookieHeader);
  header.putIfAbsent(HttpHeaders.acceptHeader, () => 'application/json; charset=utf-8');
  if (requiredNonce) header.putIfAbsent('Nonce', () => appStore.wooNonce);
  if (isWebView) {
    header.putIfAbsent('streamit-webview', () => 'true');
    header.putIfAbsent('HTTP_STREAMIT_WEBVIEW', () => 'true');
  }

  try {
    String userAgent = await UserAgentUtils.generateUserAgent();
    header.putIfAbsent(HttpHeaders.userAgentHeader, () => userAgent);
  } catch (e) {
    header.putIfAbsent(HttpHeaders.userAgentHeader, () => 'StreamIt-Flutter/1.0');
  }

  return header;
}

Future<Response> buildHttpResponse(
  String endPoint, {
  Map? body,
  bool aAuthRequired = true,
  HttpMethod method = HttpMethod.GET,
  bool isForWoocommerce = false,
  bool requiredNonce = false,
}) async {
  if (await isNetworkAvailable()) {
    try {
      String url = isForWoocommerce ? _getOAuthURL(method.toString(), endPoint) : '$mBaseUrl$endPoint';

      Map<String, String> headers = await buildTokenHeader(aAuthRequired: aAuthRequired, requiredNonce: requiredNonce);
      Response response;

      if (method == HttpMethod.POST) {
        response = await post(Uri.parse(url), body: body == null ? null : jsonEncode(body), headers: headers);
      } else if (method == HttpMethod.DELETE) {
        response = await delete(Uri.parse(url), headers: headers, body: body == null ? null : jsonEncode(body));
      } else {
        response = await get(Uri.parse(url), headers: headers);
      }

      apiPrint(
        url: url.toString(),
        endPoint: endPoint,
        headers: headers,
        hasRequest: body != null,
        request: jsonEncode(body),
        statusCode: response.statusCode,
        responseBody: response.body,
        methodtype: method.name,
      );

      if (appStore.isLogging && response.statusCode == 403 && !endPoint.startsWith('http')) {
        try {
          var responseBody = jsonDecode(response.body);
          if (responseBody['code'] == "rest_cookie_invalid_nonce" || responseBody['message'] == "Cookie check failed") {
            return await regenerateCookie().then((value) async {
              return await buildHttpResponse(endPoint, method: method, body: body, requiredNonce: requiredNonce, isForWoocommerce: isForWoocommerce, aAuthRequired: aAuthRequired);
            }).catchError((e) {
              throw errorSomethingWentWrong;
            });
          }
        } catch (e) {
          return await regenerateCookie().then((value) async {
            return await buildHttpResponse(endPoint, method: method, body: body, requiredNonce: requiredNonce, isForWoocommerce: isForWoocommerce, aAuthRequired: aAuthRequired);
          }).catchError((e) {
            throw errorSomethingWentWrong;
          });
        }
      }
      return response;
    } on TimeoutException catch (e) {
      log("Time out Error : ${e.toString()}");
      throw timeOutMsg;
    } catch (e) {
      log('Error: $e');
      throw e;
    }
  } else {
    appStore.setLoading(false);
    throw errorInternetNotAvailable;
  }
}

Future handleResponse(Response response, {ResponseType responseType = ResponseType.JSON_RESPONSE, bool isGenre = false}) async {
  if (response.statusCode.isSuccessful()) {
    if ((response.request!.url.path.contains(APIEndPoint.login) || response.request!.url.path.contains(APIEndPoint.socialLogin) || response.request!.url.path.contains(APIEndPoint.registration)) &&
        response.headers.containsKey('set-cookie')) {
      try {
        List<String> cookies = response.headers['set-cookie']!.split(',').where((str) => str.contains('wordpress_logged_in')).toList();

        if (cookies.isNotEmpty) {
          String cookieHeader = cookies.join('; ');
          setValue(COOKIE_HEADER, cookieHeader);
          log('Cookie saved: $cookieHeader');
        }
      } catch (e) {
        log('Cookie extraction error: ${e.toString()}');
      }
    }
    if (responseType == ResponseType.JSON_RESPONSE) {
      if (jsonDecode(response.body.trim()).runtimeType != (List<dynamic>) && jsonDecode(response.body.trim()).runtimeType != bool) {
        Map body = jsonDecode(response.body.trim());
        if (body.containsKey('status') && body['status'].runtimeType == bool && body['data'] != null) {
          if (body['status']) {
            if (isGenre)
              return jsonDecode(response.body);
            else
              return body['data'];
          } else {
            throw body['message'] ?? errorSomethingWentWrong;
          }
        } else {
          return jsonDecode(response.body);
        }
      } else {
        return jsonDecode(response.body);
      }
    } else if (responseType == ResponseType.FULL_RESPONSE) {
      return response;
    } else if (responseType == ResponseType.STRING_RESPONSE) {
      return response.body;
    } else if (responseType == ResponseType.BODY_BYTES) {
      return response.bodyBytes;
    } else {
      return '';
    }
  } else {
    if (!await isNetworkAvailable()) {
      throw errorInternetNotAvailable;
    } else if (response.statusCode == 401) {
      // First, check if response contains "Authorization header not found." message
      Map<String, dynamic>? errorBody;
      try {
        errorBody = jsonDecode(response.body) as Map<String, dynamic>;

        // Check for "Authorization header not found." message
        String? message = errorBody['message']?.toString();
        if (message != null && message.contains('Authorization header not found.')) {
          // Show session expired dialog automatically
          showSessionExpiredDialog();
          // Throw error to propagate up
          throw {"error_type": SessionErrorCode.sessionExpired, "status_code": 401, "message": message};
        }

        if (errorBody.containsKey('error_code') && errorBody['error_code'] == SessionErrorCode.loginLimitExceeded) {
          throw {"error_code": SessionErrorCode.loginLimitExceeded, "message": errorBody['message'] ?? "Login limit exceeded", "status_code": 401};
        }
      } catch (e) {
        // If it's our SESSION_EXPIRED error map, re-throw it to propagate up
        if (e is Map<String, dynamic> && e.containsKey('error_type') && e['error_type'] == SessionErrorCode.sessionExpired) {
          rethrow;
        }
        if (e is Map<String, dynamic> && e.containsKey('error_code') && e['error_code'] == SessionErrorCode.loginLimitExceeded) {
          rethrow;
        }
        // If parsing failed, errorBody will be null and we'll handle it below
      }

      if (errorBody != null) {
        BaseResponseModel res = BaseResponseModel.fromJson(errorBody);
        if (res.code.validate().contains('woocommerce_rest') || res.code.validate().contains('woocommerce_rest')) {
          throw res.message.validate();
        } else {
          throw res.message.validate();
        }
      } else {
        // If parsing failed, try again for BaseResponseModel
        try {
          BaseResponseModel res = BaseResponseModel.fromJson(jsonDecode(response.body));
          if (res.code.validate().contains('woocommerce_rest') || res.code.validate().contains('woocommerce_rest')) {
            throw res.message.validate();
          } else {
            throw {"title": "Token Expired", "status_code": 401};
          }
        } catch (e) {
          // If all parsing fails, check for "Authorization header not found." in raw body
          String responseBody = response.body.toString();
          if (responseBody.contains('Authorization header not found.')) {
            // Show session expired dialog automatically
            showSessionExpiredDialog();
            throw {"error_type": SessionErrorCode.sessionExpired, "status_code": 401, "message": "Authorization header not found."};
          }
          throw {"title": "Token Expired", "status_code": 401};
        }
      }
    } else if (response.statusCode == 422) {
      Map<String, dynamic> body = jsonDecode(response.body.trim());

      if (body.containsKey('code') && body['code'] == SessionErrorCode.streamitLoginLimitExceeded) {
        throw {"code": SessionErrorCode.streamitLoginLimitExceeded, "message": body['message'] ?? "Account Limit Exceeded.", "status_code": 422};
      } else if (body.containsKey('error_code') && body['error_code'] == SessionErrorCode.loginLimitExceeded) {
        throw {"error_code": SessionErrorCode.loginLimitExceeded, "message": body['message'] ?? "Login limit exceeded", "status_code": 422};
      } else {
        throw body['message'] ?? errorSomethingWentWrong;
      }
    } else if (response.statusCode == 403) {
      Map<String, dynamic> body = jsonDecode(response.body.trim());

      if (body.containsKey('code')) {
        switch (body['code']) {
          case SessionErrorCode.streamitLoginLimitExceeded:
            throw {"code": SessionErrorCode.streamitLoginLimitExceeded, "message": body['message'] ?? "Account Limit Exceeded.", "status_code": 403};
          case '[jwt_auth] incorrect_password':
          case 'rest_cookie_invalid_nonce':
            throw "Incorrect email or password. Please try again.";
          case 'streamit_access_denied':
            throw body['message'] ?? "Access Denied.";
          case 'streamit_subscription_expired':
            throw body['message'] ?? "Subscription Expired.";
          default:
            // Check for cookie authentication failures
            if (body['message'] == "Cookie check failed") {
              throw "Authentication failed. Please login again.";
            }
            throw body['message'] ?? errorSomethingWentWrong;
        }
      } else if (body.containsKey('error_code')) {
        switch (body['error_code']) {
          case 'LOGIN_NOT_ALLOWED':
            throw body['message'] ?? "Login not allowed on this platform";
          case SessionErrorCode.loginLimitExceeded:
            throw {"error_code": SessionErrorCode.loginLimitExceeded, "message": body['message'] ?? "Login limit exceeded", "status_code": response.statusCode};
        }
      } else {
        throw errorSomethingWentWrong;
      }
    } else if (response.body.isJson()) {
      jsonDecode(response.body);

      // if (json.containsKey(msg)) {
      //   throw parseHtmlString(json[msg]);
      // } else {
      //   throw errorSomethingWentWrong;
      // }
    } else {
      throw errorSomethingWentWrong;
    }
  }
}

Future<MultipartRequest> postMultiPartRequest(String endPoint) async {
  String url = '$mBaseUrl$endPoint';
  log('URL: $url');
  return MultipartRequest('POST', Uri.parse(url));
}

Future<void> sendMultiPartRequest(MultipartRequest multiPartRequest, {Function(dynamic)? onSuccess, Function(dynamic)? onError}) async {
  Response response = await Response.fromStream(await multiPartRequest.send());

  apiPrint(
    url: multiPartRequest.url.toString(),
    headers: multiPartRequest.headers,
    request: jsonEncode(multiPartRequest.fields),
    hasRequest: true,
    statusCode: response.statusCode,
    responseBody: response.body,
    methodtype: "MultiPart",
  );

  if (response.statusCode.isSuccessful()) {
    onSuccess?.call(response.body);
  } else {
    onError?.call(errorSomethingWentWrong);
  }
}

Future<void> refreshToken({bool? aReloadApp, BuildContext? context}) async {
  log('Refreshing Token $aReloadApp');

  var request = {
    "username": getStringAsync(USER_EMAIL),
    "password": getStringAsync(PASSWORD),
  };

  await token(request).then((res) async {
    log('New token saved');
    if (aReloadApp != null) {
      //
    } else {
      //
    }
  }).catchError((error) {
    log(error);
    if (context != null) {
      SignInScreen().launch(context);
    } else {
      //
    }
  });
}

/// Regenerate cookie for authentication
Future<void> regenerateCookie() async {
  log('Regenerating Cookie');

  var request = {
    "username": getStringAsync(USER_EMAIL),
    "password": getStringAsync(PASSWORD),
  };

  await token(request);
}

/// for passing woo commerce parameters
String _getOAuthURL(String requestMethod, String endpoint) {
  var consumerKey = getStringAsync(SharePreferencesKey.WOO_CONSUMER_KEY);
  var consumerSecret = getStringAsync(SharePreferencesKey.WOO_CONSUMER_SECRET);

  var tokenSecret = "";
  var url = mBaseUrl + endpoint;

  var containsQueryParams = url.contains("?");

  if (url.startsWith("https") || url.startsWith("http")) {
    return url + (containsQueryParams == true ? "&consumer_key=" + consumerKey + "&consumer_secret=" + consumerSecret : "?consumer_key=" + consumerKey + "&consumer_secret=" + consumerSecret);
  } else {
    var rand = new Random();
    var codeUnits = new List.generate(10, (index) {
      return rand.nextInt(26) + 97;
    });

    var nonce = new String.fromCharCodes(codeUnits);
    int timestamp = new DateTime.now().millisecondsSinceEpoch ~/ 1000;

    var method = requestMethod;
    var parameters = "oauth_consumer_key=$consumerKey" + "&oauth_nonce=$nonce" + "&oauth_signature_method=HMAC-SHA1&oauth_timestamp=$timestamp" + "&oauth_version=1.0&";

    if (containsQueryParams == true) {
      parameters = parameters + url.split("?")[1];
    } else {
      parameters = parameters.substring(0, parameters.length - 1);
    }

    Map<dynamic, dynamic> params = QueryString.parse(parameters);
    Map<dynamic, dynamic> treeMap = new SplayTreeMap<dynamic, dynamic>();
    treeMap.addAll(params);

    String parameterString = "";

    for (var key in treeMap.keys) {
      parameterString = parameterString + Uri.encodeQueryComponent(key) + "=" + treeMap[key] + "&";
    }

    parameterString = parameterString.substring(0, parameterString.length - 1);

    var baseString = method + "&" + Uri.encodeQueryComponent(containsQueryParams == true ? url.split("?")[0] : url) + "&" + Uri.encodeQueryComponent(parameterString);

    var signingKey = consumerSecret + "&" + tokenSecret;
    var hmacSha1 = new crypto.Hmac(crypto.sha1, utf8.encode(signingKey)); // HMAC-SHA1
    var signature = hmacSha1.convert(utf8.encode(baseString));

    var finalSignature = base64Encode(signature.bytes);

    var requestUrl = "";

    if (containsQueryParams == true) {
      requestUrl = url.split("?")[0] + "?" + parameterString + "&oauth_signature=" + Uri.encodeQueryComponent(finalSignature);
    } else {
      requestUrl = url + "?" + parameterString + "&oauth_signature=" + Uri.encodeQueryComponent(finalSignature);
    }

    return requestUrl;
  }
}

void apiPrint({
  String url = "",
  String endPoint = "",
  Map<String, String>? headers,
  String? request,
  Map<String, String>? multipartRequest,
  int statusCode = 0,
  String responseBody = "",
  String methodtype = "",
  bool hasRequest = false,
}) {
  log("───────────────────────────────────────────────────────────────────────────────────────────────────────");
  log("\u001b[93m Url: \u001B[39m $url");
  log("\u001b[93m Header: \u001B[39m \u001b[96m$headers\u001B[39m");
  if (request != null) {
    log("\u001b[93m Request: \u001B[39m \u001b[96m$request\u001B[39m");
  }
  if (multipartRequest != null) {
    log("\u001b[95m Multipart Request: \u001B[39m");
    multipartRequest.forEach((key, value) {
      log("\u001b[96m$key:\u001B[39m $value\n");
    });
  }
  log("${statusCode.isSuccessful() ? "\u001b[32m" : "\u001b[31m"}");
  log('Response ($methodtype) $statusCode: $responseBody');
  log("\u001B[0m");
  log("───────────────────────────────────────────────────────────────────────────────────────────────────────");
}
