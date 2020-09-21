import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shop_app/env.dart';
import 'package:shop_app/providers/cart.dart';

import 'package:http/http.dart' as http;

class Orders with ChangeNotifier {
  List<OrderItem> _orders;
  List<OrderItem> get orders => _orders.toList();

  String _token;
  String _userId;

  set token(String value) {
    _token = value;
  }

  set userId(String value) {
    _userId = value;
  }

  Orders({
    @required String token,
    @required String userId,
    List<OrderItem> orders,
  })  : _token = token,
        _userId = userId,
        _orders = orders ?? <OrderItem>[];

  Future<void> addOrder(
      {@required List<CartItem> items, double totalAmount}) async {
    final String url =
        '${enviroment['firebaseUrl']}/orders/$_userId.json?auth=$_token';

    var order = OrderItem(
      id: null,
      orderedAt: DateTime.now(),
      items: items,
    );

    try {
      var response = await http.post(
        url,
        body: json.encode(
          {
            'orderedAt': order.orderedAt.toIso8601String(),
            'items': order.items
                .map(
                  (item) => {
                    'id': item.id,
                    'productId': item.productId,
                    'title': item.title,
                    'price': item.price,
                    'amount': item.amount,
                  },
                )
                .toList(),
          },
        ),
      );

      _orders.add(
        order.copyWith(
          id: json.decode(response.body)['name'],
        ),
      );
      notifyListeners();
    } catch (error) {}
  }

  Future<void> fetchOrders() async {
    try {
      final url =
          '${enviroment['firebaseUrl']}/orders/$_userId.json?auth=$_token';
      final response = await http.get(url);
      final data = json.decode(response.body) as Map<String, dynamic>;
      final newOrders = <OrderItem>[];

      data?.forEach((key, value) {
        newOrders.insert(
          0,
          OrderItem(
            id: key,
            orderedAt: DateTime.parse(value['orderedAt']),
            items: (value['items'] as List<dynamic>)
                .map<CartItem>(
                  (item) => CartItem(
                    id: item['id'],
                    productId: item['productId'],
                    title: item['title'],
                    price: item['price'] is double
                        ? item['price']
                        : double.parse(item['price']),
                    amount: item['amount'] is int
                        ? item['amount']
                        : int.parse(item['amount']),
                  ),
                )
                .toList(),
          ),
        );
      });

      _orders = newOrders;

      notifyListeners();
    } catch (error) {
      print('[Orders.fetchOrders] $error');
    }
  }
}

class OrderItem {
  final String id;
  final List<CartItem> items;
  final DateTime orderedAt;

  double get totalPrice => items.fold<double>(
        0,
        (aggr, item) => aggr + (item.price * item.amount),
      );

  OrderItem({
    @required this.id,
    @required this.items,
    @required this.orderedAt,
  });

  copyWith({
    String id,
    List<CartItem> items,
    DateTime orderedAt,
  }) {
    return OrderItem(
      id: id ?? this.id,
      items: items ?? this.items,
      orderedAt: orderedAt ?? this.orderedAt,
    );
  }
}
