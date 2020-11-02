import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/pages/cart_page.dart';
import 'package:shop_app/pages/orders_page.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/badge.dart';
import 'package:shop_app/widgets/products_grid.dart';

enum SelectionOptions {
  orders,
  showFavorites,
  showAll,
}

class ProductOverviewPage extends StatefulWidget {
  static final routeName = '/';

  @override
  _ProductOverviewPageState createState() => _ProductOverviewPageState();
}

class _ProductOverviewPageState extends State<ProductOverviewPage> {
  bool _showOnlyFavorite = false;

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<Products>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('ShopApp'),
        actions: <Widget>[
          IconButton(
            icon: Consumer<Cart>(
              builder: (_, cart, child) {
                return Badge(
                  child: child,
                  value: '${cart.itemAmount}',
                );
              },
              child: Icon(Icons.shopping_cart_rounded),
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(CartPage.routeName);
            },
          ),
          PopupMenuButton(
            offset: const Offset(0, 48),
            icon: const Icon(Icons.more_horiz_rounded),
            itemBuilder: (_) => <PopupMenuEntry<SelectionOptions>>[
              PopupMenuItem(
                child: Text('Show only favorites'),
                value: SelectionOptions.showFavorites,
                enabled: !_showOnlyFavorite,
              ),
              PopupMenuItem(
                child: Text('Show all'),
                value: SelectionOptions.showAll,
                enabled: _showOnlyFavorite,
              ),
            ],
            onSelected: (SelectionOptions selectedValue) {
              if (selectedValue == SelectionOptions.showFavorites) {
                setState(() {
                  _showOnlyFavorite = true;
                });
              } else if (selectedValue == SelectionOptions.showAll) {
                setState(() {
                  _showOnlyFavorite = false;
                });
              } else {
                Navigator.of(context).pushNamed(OrdersPage.routeName);
              }
            },
          ),
        ],
      ),
      drawer: AppDrawer(
        selectedRouteName: ProductOverviewPage.routeName,
      ),
      body: FutureBuilder(
        future: productProvider.fetchProducts(),
        builder: (ctx, dataSnapshot) {
          return AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: buildBodyContent(dataSnapshot, context, productProvider));
        },
      ),
    );
  }

  Widget buildBodyContent(
    AsyncSnapshot dataSnapshot,
    BuildContext context,
    Products productProvider,
  ) {
    if (dataSnapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      if (dataSnapshot.hasError) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'An error happend when loading products',
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
            ),
            OutlineButton.icon(
              onPressed: productProvider.fetchProducts,
              icon: Icon(Icons.refresh_rounded),
              label: Text('TRY AGAIN'),
            ),
          ],
        );
      } else {
        return RefreshIndicator(
          onRefresh: productProvider.fetchProducts,
          child: Scrollbar(
            child: SafeArea(
              child: ProductsGrid(
                favoritesOnly: _showOnlyFavorite,
              ),
            ),
          ),
        );
      }
    }
  }
}
