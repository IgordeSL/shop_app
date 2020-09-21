import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:shop_app/env.dart';
import 'package:shop_app/providers/product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _items;
  List<Product> get items => _items.toList();

  List<Product> get favoriteItems =>
      _items.where((product) => product.favorite).toList();

  String _token;
  String _userId;

  set token(String value) {
    _token = value;
  }

  set userId(String value) {
    _userId = value;
  }

  Products({
    @required String token,
    @required String userId,
    List<Product> items,
  })  : _token = token,
        _userId = userId,
        _items = items ?? <Product>[];

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> fetchProducts({bool filterByUser = false}) async {
    try {
      final filterText =
          filterByUser ? '&orderBy="creatorId"&equalTo="$_userId"' : '';
      final response = http.get(
        '${enviroment['firebaseUrl']}/products.json?auth=$_token$filterText',
      );
      final favoritesResponse = http.get(
        '${enviroment['firebaseUrl']}/userFavorites/$_userId.json?auth=$_token',
      );

      final responseBody = (await response).body;
      final data = json.decode(responseBody) as Map<String, dynamic>;

      final favoriteBody = (await favoritesResponse).body;
      final favoritesData = json.decode(favoriteBody) as Map<String, dynamic>;

      final List<Product> newItems = List<Product>();

      data?.forEach((key, value) {
        newItems.add(
          Product(
            id: key,
            title: value['title'],
            description: value['description'],
            price: value['price'] is double
                ? value['price']
                : double.parse(value['price']),
            imageURL: value['imageURL'],
            favorite: (favoritesData ?? {})[key] ?? false,
          ),
        );
      });

      _items = newItems;

      notifyListeners();
    } catch (error) {
      print('[Products.fetchProducts] $error');
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final url = '${enviroment['firebaseUrl']}/products.json?auth=$_token';
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageURL': product.imageURL,
          'creatorId': _userId,
        }),
      );

      _items.add(product.copyWith(
        id: json.decode(response.body)['name'],
      ));

      notifyListeners();
    } catch (error) {
      print('[Products.addProduct] $error');
      throw error;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      final String url =
          '${enviroment['firebaseUrl']}/products/${product.id}.json?auth=$_token';
      await http.patch(url,
          body: json.encode(
            {
              'title': product.title,
              'description': product.description,
              'price': product.price,
              'imageURL': product.imageURL,
            },
          ));

      final productIndex =
          _items.indexWhere((element) => element.id == product.id);

      if (productIndex >= 0) {
        _items[productIndex] = product;
        notifyListeners();
      }
    } catch (error) {
      print('[Products.updateProduct] $error');
      throw error;
    }
  }

  Future<void> deleteProduct(String productId) async {
    final removedProductIndex =
        _items.indexWhere((product) => product.id == productId);
    var removedProduct = _items[removedProductIndex];
    _items.removeAt(removedProductIndex);

    notifyListeners();

    try {
      final String url =
          '${enviroment['firebaseUrl']}/products/$productId.json?auth=$_token';

      var response = await http.delete(url);
      if (response.statusCode >= 400) {
        throw HttpException(
          'Error ${response.statusCode}: ${response.reasonPhrase}',
          uri: Uri.dataFromString(url),
        );
      }

      removedProduct = null;
    } catch (error) {
      // If an error occur on the server, restores the removed product
      _items.insert(removedProductIndex, removedProduct);
      notifyListeners();

      print('[Products.deleteProduct] $error');
      throw error;
    }
  }
}
