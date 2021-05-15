import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart' show Cart;
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/widgets/cart_item.dart';

import 'orders_page.dart';

class CartPage extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your cart'),
        actions: <Widget>[
          PopupMenuButton(
            offset: const Offset(0, 48),
            icon: const Icon(Icons.more_horiz_rounded),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Orders'),
                value: true,
              ),
            ],
            onSelected: (_) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                OrdersPage.routeName,
                (route) => route.isFirst,
              );
            },
          ),
        ],
      ),
      body: Consumer<Cart>(
        builder: (ctx, cart, _) => Column(
          children: <Widget>[
            if (cart.itemCount <= 0)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Opacity(
                      opacity: 0.25,
                      child: Icon(Icons.shopping_cart_rounded),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your cart is empty',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Scrollbar(
                child: ListView.builder(
                  padding: const EdgeInsets.only(
                    top: 16,
                    bottom: 72,
                  ),
                  itemCount: cart.itemCount,
                  itemBuilder: (_, index) {
                    var cartItem = cart.items[index];

                    return CartItem(
                      cartItem: cartItem,
                      key: ValueKey(cartItem.id),
                    );
                  },
                ),
              ),
            ),
            Divider(
              indent: 16,
              endIndent: 16,
              height: 2,
              thickness: 2,
            ),
            ListTile(
              title: Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Text(
                '\$ ${cart.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: OrderButton(),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
  }) : super(key: key);

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    Cart cartProvider = Provider.of<Cart>(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 60),
      child: AnimatedSwitcher(
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: child,
        ),
        duration: const Duration(milliseconds: 120),
        child: cartProvider.itemCount <= 0
            ? null
            : FloatingActionButton.extended(
                onPressed: (cartProvider.itemCount <= 0 || _isLoading)
                    ? null
                    : () async {
                        setState(() {
                          _isLoading = true;
                        });

                        final Orders orders = Provider.of<Orders>(
                          context,
                          listen: false,
                        );

                        await orders.addOrder(
                          items: cartProvider.items,
                          totalAmount: cartProvider.totalAmount,
                        );

                        setState(() {
                          _isLoading = false;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Your order was successefully placed'),
                          ),
                        );

                        cartProvider.clearCart();
                      },
                label: AnimatedCrossFade(
                  firstChild: Text('Order now'),
                  secondChild: Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.all(4),
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    ),
                  ),
                  duration: const Duration(milliseconds: 200),
                  firstCurve: Curves.ease,
                  secondCurve: Curves.ease,
                  sizeCurve: Curves.ease,
                  crossFadeState: !_isLoading
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                ),
              ),
      ),
    );
  }
}
