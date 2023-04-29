import 'dart:convert';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart' as http;

import '../main.dart';

class LoginAuth {
  String accessToken;
  DateTime accessTokenExpiration;
  String refreshToken;
  final String username;

  LoginAuth(
      {required this.accessToken,
      required this.accessTokenExpiration,
      required this.refreshToken,
      required this.username});

  static Future<LoginAuth> login(String email, String password) async {
    final resp = await http.post(
      Uri.parse('$endpoint/auth/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );
    var login = LoginAuth.fromJson(jsonDecode(resp.body));
    await SessionManager().set("loginAuth", login);
    return login;
  }

  factory LoginAuth.fromJson(Map<String, dynamic> json) {
    print(jsonEncode(json));
    return LoginAuth(
        accessToken: json['tokens']['access']['token'],
        accessTokenExpiration:
            DateTime.parse(json['tokens']['access']['expires']),
        refreshToken: json['tokens']['refresh']['token'],
        username: json['user']['name']);
  }

  factory LoginAuth.fromSession(Map<String, dynamic> session) {
    return LoginAuth(
        accessToken: session['accessToken'],
        accessTokenExpiration: DateTime.parse(session['accessTokenExpiration']),
        refreshToken: session['refreshToken'],
        username: session['username']);
  }

  Future<String> generateAccessToken() async {
    final response = await http.post(Uri.parse('$endpoint/auth/refresh-tokens'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'refreshToken': refreshToken,
        }));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON and set new vars.
      Map<String, dynamic> json = jsonDecode(response.body);
      accessToken = json['access']['token'];
      accessTokenExpiration = DateTime.parse(json['access']['expires']);
      refreshToken = json['refresh']['token'];
      SessionManager().set("loginAuth", this);
      return accessToken;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load tokens');
    }
  }

  Future<String> getAccessToken() async {
    if (accessTokenExpiration.millisecondsSinceEpoch >
        DateTime.now().millisecondsSinceEpoch) {
      // generate new access token
      await generateAccessToken();
    }
    return accessToken;
  }

  Future<void> logout() async {
    await SessionManager().remove("loginAuth");
  }

  Map<String, String> toJson() {
    return {
      "accessToken": accessToken,
      "refreshToken": refreshToken,
      "accessTokenExpiration": accessTokenExpiration.toIso8601String(),
      "username": username
    };
  }
}
