import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:flutter/widgets.dart';
import 'package:shop_app/env.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageURL;
  bool _favorite;

  bool get favorite => this._favorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageURL,
    favorite = false,
  }) : this._favorite = favorite;

  Product.empty()
      : id = null,
        title = null,
        description = null,
        price = null,
        imageURL = null,
        _favorite = false;

  toggleFavorite(
    bool value, {
    @required String token,
    @required String userId,
  }) async {
    this._favorite = value;
    notifyListeners();

    final String url =
        '${enviroment['firebaseUrl']}/userFavorites/$userId/$id.json?auth=$token';

    try {
      var response = await http.put(url, body: json.encode(value));

      if (response.statusCode >= 400)
        throw HttpException(
          'Error ${response.statusCode}: ${response.reasonPhrase}',
          uri: Uri.dataFromString(url),
        );
    } catch (error) {
      this._favorite = !value;
      notifyListeners();

      print('[Product.favorite (set)] $error');
      throw error;
    }
  }

  copyWith({
    String id,
    String title,
    String description,
    double price,
    String imageURL,
    bool favorite,
  }) =>
      Product(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        price: price ?? this.price,
        imageURL: imageURL ?? this.imageURL,
        favorite: favorite ?? this._favorite,
      );
}
