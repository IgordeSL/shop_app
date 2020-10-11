import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products.dart';

import 'orders_page.dart';

class ProductDetailPage extends StatelessWidget {
  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    final productProvider = Provider.of<Products>(
      context,
      listen: false,
    );

    final cart = Provider.of<Cart>(
      context,
      listen: false,
    );

    final Product product = productProvider.findById(productId);

    return Scaffold(
      body: Scrollbar(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              primary: true,
              titleSpacing: 0,
              actions: <Widget>[
                PopupMenuButton(
                  offset: const Offset(0, 48),
                  icon: const Icon(
                    Icons.more_horiz,
                  ),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      child: Text('Orders'),
                      value: true,
                    ),
                  ],
                  onSelected: (_) {
                    Navigator.of(context).pushNamed(OrdersPage.routeName);
                  },
                ),
              ],
              pinned: true,
              expandedHeight: 360,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildProductImageHero(product),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          fit: FlexFit.tight,
                          child: Text(
                            product.title,
                            maxLines: 2,
                            style: Theme.of(context).textTheme.headline4,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '\$ ${product.price.toStringAsFixed(2)}',
                            style:
                                (Theme.of(context).primaryTextTheme.subtitle1)
                                    .copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 8,
                      bottom: 96,
                      left: 16,
                      right: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        SizedBox(height: 12),
                        Text(
                          product.description,
                          softWrap: true,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          cart.addCartItem(product);

          var scaffold = Scaffold.of(context);

          scaffold.removeCurrentSnackBar(
            reason: SnackBarClosedReason.hide,
          );
          scaffold.showSnackBar(
            SnackBar(
              content: Text('${product.title} added to cart'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  cart.removeSingleItem(product.id);
                },
              ),
            ),
          );
        },
        label: Text('Add to cart'),
        icon: Icon(Icons.add_shopping_cart),
      ),
    );
  }

  Widget _buildProductImageHero(Product product) {
    return Stack(
      children: [
        Hero(
          tag: 'image${product.id}',
          child: Image.network(
            product.imageURL,
            fit: BoxFit.cover,
            loadingBuilder: (ctx, child, progress) {
              return AnimatedSwitcher(
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                    alignment: Alignment.center,
                  );
                },
                duration: const Duration(
                  milliseconds: 200,
                ),
                child: progress == null &&
                        ((child as Semantics)?.child as RawImage)?.image != null
                    ? child
                    : Center(
                        child: CircularProgressIndicator(
                          value: progress?.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes
                              : null,
                        ),
                      ),
              );
            },
          ),
        ),
        Container(
          height: 160,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.black45, Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
          ),
        ),
      ],
    );
  }
}
