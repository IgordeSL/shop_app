import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/env.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiresIn;
  String _userId;
  Timer _authTimer;

  String get token => _token;
  String get userId => _userId;

  bool get isAuthenticated =>
      _userId != null &&
      _token != null &&
      _expiresIn != null &&
      (_expiresIn?.isAfter(DateTime.now()) ?? false);

  Future<void> signUp({
    @required String email,
    @required String password,
  }) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${environment['firebaseWebAPIKey']}';

    var response = await http.post(
      url,
      body: json.encode(
        {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
      ),
    );

    var responseData = json.decode(response?.body);

    if (response.statusCode >= 400 ||
        ((responseData['error'] ?? const {})['code'] ?? 0) >= 400) {
      throw HttpException(
        responseData['error']['message'] ?? response.reasonPhrase,
        uri: response.request.url,
      );
    }

    _token = responseData['idToken'];
    _userId = responseData['localId'];
    _expiresIn = DateTime.now().add(
      Duration(
        seconds: int.parse(
          responseData['expiresIn'],
        ),
      ),
    );

    _autoLogout();
    notifyListeners();
    _saveLoginData();
  }

  Future<void> login({
    @required String email,
    @required String password,
  }) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${environment['firebaseWebAPIKey']}';

    var response = await http.post(
      url,
      body: json.encode(
        {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
      ),
    );

    var responseData = json.decode(response?.body);

    if (response.statusCode >= 400 ||
        ((responseData['error'] ?? const {})['code'] ?? 0) >= 400) {
      throw HttpException(
        responseData['error']['message'] ?? response.reasonPhrase,
        uri: response.request.url,
      );
    }

    _token = responseData['idToken'];
    _userId = responseData['localId'];
    _expiresIn = DateTime.now().add(
      Duration(
        seconds: int.parse(
          responseData['expiresIn'],
        ),
      ),
    );

    _autoLogout();
    notifyListeners();
    _saveLoginData();
  }

  void logout() {
    _token = null;
    _userId = null;
    _expiresIn = null;

    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }

    notifyListeners();
    _deleteLoginData();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }

    _authTimer = Timer(
      Duration(
        seconds: _expiresIn.difference(DateTime.now()).inSeconds,
      ),
      logout,
    );
  }

  Future<void> _saveLoginData() async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setString(
      'loginData',
      json.encode({
        'token': _token,
        'expiresIn': _expiresIn.toIso8601String(),
        'userId': _userId,
      }),
    );
  }

  Future<bool> getLoginData() async {
    final preferences = await SharedPreferences.getInstance();

    if (!preferences.containsKey('loginData')) {
      return false;
    }

    final loginData =
        json.decode(preferences.getString('loginData')) as Map<String, dynamic>;

    if (loginData == null) {
      return false;
    }

    final expiryDate = DateTime.parse(loginData['expiresIn']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = loginData['token'];
    _expiresIn = expiryDate;
    _userId = loginData['userId'];

    notifyListeners();
    _autoLogout();

    return true;
  }

  Future<void> _deleteLoginData() async {
    final preferences = await SharedPreferences.getInstance();
    preferences.remove('loginData');
  }
}
