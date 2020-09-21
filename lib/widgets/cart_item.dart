import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart' as CartProvider;

class CartItem extends StatelessWidget {
  const CartItem({
    Key key,
    @required this.cartItem,
  }) : super(key: key);

  final CartProvider.CartItem cartItem;

  @override
  Widget build(BuildContext context) {
    final CartProvider.Cart cartProvider = Provider.of(
      context,
      listen: false,
    );

    return Dismissible(
      direction: DismissDirection.endToStart,
      background: buildRemoveContainer(context),
      key: ValueKey(cartItem.id),
      child: ListTile(
        title: Text(cartItem.title),
        subtitle: Text(
            '\$ ${cartItem.price.toStringAsFixed(2)} x ${cartItem.amount}'),
        trailing:
            Text('\$ ${(cartItem.price * cartItem.amount).toStringAsFixed(2)}'),
      ),
      confirmDismiss: (direction) => showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Remove item from cart?'),
          content: Text('${cartItem.title} will be removed from your cart.'),
          actions: <Widget>[
            FlatButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('Cancel'),
            ),
            FlatButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text('Remove'),
            )
          ],
        ),
      ),
      onDismissed: (_) {
        cartProvider.removeCartItem(cartItem.id);
      },
    );
  }

  Container buildRemoveContainer(BuildContext context) {
    return Container(
      color: Theme.of(context).errorColor,
      child: Icon(
        Icons.remove_shopping_cart,
        color: (Theme.of(context).errorColor.computeLuminance() > 0.5)
            ? Colors.black
            : Colors.white,
        size: 24,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerRight,
    );
  }
}
