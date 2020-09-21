import 'package:flutter/widgets.dart';
import 'package:shop_app/providers/product.dart';

class CartItem {
  final String id;

  final String productId;
  final String title;
  final double price;

  int amount;

  CartItem({
    @required this.id,
    @required this.productId,
    @required this.title,
    @required this.price,
    this.amount = 1,
  });
}

class Cart with ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items {
    return this._items.toList();
  }

  int get itemAmount {
    return _items.fold(
      0,
      (aggr, cartItem) {
        return aggr + cartItem.amount;
      },
    );
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    return _items.fold(
      0,
      (aggr, cartItem) => aggr + (cartItem.amount * cartItem.price),
    );
  }

  void addCartItem(Product product) {
    CartItem cartItem = _items.firstWhere(
      (item) => item.productId == product.id,
      orElse: () => null,
    );

    if (cartItem != null) {
      cartItem.amount++;
    } else {
      _items.add(
        CartItem(
          id: DateTime.now().toString(),
          productId: product.id,
          title: product.title,
          price: product.price,
          amount: 1,
        ),
      );
    }

    notifyListeners();
  }

  removeSingleItem(String productId) {
    CartItem cartItem = _items.firstWhere(
      (item) => item.productId == productId,
      orElse: () => null,
    );

    if (cartItem == null) return;

    if (cartItem.amount > 1) {
      cartItem.amount--;
    } else {
      _items.removeWhere((item) => item.id == cartItem.id);
    }

    notifyListeners();
  }

  void removeCartItem(String id) {
    _items.removeWhere((cartItem) => cartItem.id == id);
    notifyListeners();
  }

  void clearCart() {
    this._items.clear();
    notifyListeners();
  }
}
