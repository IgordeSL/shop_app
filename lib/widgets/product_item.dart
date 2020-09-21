import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/helpers/custom_route.dart';
import 'package:shop_app/pages/product_detail_page.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/product.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Product product = Provider.of<Product>(
      context,
      listen: false,
    );

    Cart cart = Provider.of<Cart>(
      context,
      listen: false,
    );

    return Material(
      elevation: 2,
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.hardEdge,
      borderOnForeground: true,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            CustomRoute(
              builder: (context) => ProductDetailPage(),
              settings: RouteSettings(
                name: ProductDetailPage.routeName,
                arguments: product.id,
              ),
            ),
          );
        },
        child: GridTile(
          header: Material(
            color: Colors.transparent,
            clipBehavior: Clip.none,
            child: Align(
              heightFactor: 2,
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Consumer<Product>(
                  builder: (ctx, prod, _) => prod.favorite
                      ? Icon(
                          Icons.favorite,
                          color: Theme.of(ctx).accentColor,
                        )
                      : buildFavoriteTwoToneIcon(ctx),
                ),
                onPressed: () async {
                  try {
                    var auth = Provider.of<Auth>(context, listen: false);

                    await product.toggleFavorite(
                      !product.favorite,
                      token: auth.token,
                      userId: auth.userId,
                    );
                  } catch (error) {
                    print('[Widget ProductItem] $error');
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'An error happend when ${product.favorite ? 'un' : ''}favoriting product',
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          footer: Material(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            child: GridTileBar(
              title: Text(
                product.title,
                maxLines: 2,
              ),
              subtitle: Text('\$ ${product.price.toStringAsFixed(2)}'),
              trailing: IconButton(
                icon: Icon(Icons.add_shopping_cart),
                tooltip: 'Add to cart',
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
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 0,
            ),
            child: Hero(
              tag: 'image${product.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  product.imageURL,
                  fit: BoxFit.cover,
                  loadingBuilder: (ctx, child, progress) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
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
                      child: (progress == null &&
                              ((child as Semantics)?.child as RawImage)
                                      ?.image !=
                                  null
                          ? child
                          : Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Theme.of(ctx).dividerColor,
                                value: progress?.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded /
                                        progress.expectedTotalBytes
                                    : null,
                              ),
                            )),
                    );
                  },
                  errorBuilder: (ctx, error, stackTrace) {
                    print('[ProductItem Widget] Network Image error: $error');
                    return Center(
                      child: Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Theme.of(ctx).dividerColor,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFavoriteTwoToneIcon(BuildContext context) {
    return Stack(
      children: <Widget>[
        Icon(
          Icons.favorite,
          color: Theme.of(context).accentColor.withOpacity(0.2),
        ),
        Icon(
          Icons.favorite_border,
          color: Theme.of(context).accentColor.withOpacity(0.2),
        ),
      ],
    );
  }
}
