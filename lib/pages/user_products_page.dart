import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/pages/edit_product_page.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/user_product_item.dart';

class UserProductsPage extends StatelessWidget {
  static final routeName = '/user-products';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My products'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Add product',
            icon: Icon(Icons.add_rounded),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductPage.routeName);
            },
          ),
        ],
      ),
      drawer: AppDrawer(
        selectedRouteName: routeName,
      ),
      body: FutureBuilder(
        future: Provider.of<Products>(context, listen: false)
            .fetchProducts(filterByUser: true),
        builder: (context, snapshot) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: snapshot.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : Consumer<Products>(
                    builder: (context, products, _) {
                      return RefreshIndicator(
                        onRefresh: () async =>
                            products.fetchProducts(filterByUser: true),
                        child: Scrollbar(
                          child: SafeArea(
                            child: products.items.length <= 0
                                ? _buildEmptyProducsText(context)
                                : ListView.separated(
                                    itemBuilder: (context, index) {
                                      return UserProductItem(
                                        product: products.items[index],
                                        productBackgroundColor: Colors.accents[
                                            index % Colors.accents.length],
                                        key: ValueKey(products.items[index].id),
                                      );
                                    },
                                    itemCount: products.items.length,
                                    separatorBuilder: (context, index) {
                                      return const Divider(
                                        indent: 64,
                                        endIndent: 16,
                                      );
                                    },
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyProducsText(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 48,
          right: 48,
          bottom: 48,
        ),
        child: Opacity(
          opacity: 0.6,
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: Theme.of(context).textTheme.headline6,
              children: const [
                WidgetSpan(
                  child: Icon(
                    Icons.shopping_bag_rounded,
                    size: 48,
                  ),
                ),
                TextSpan(
                  text:
                      '\n\nYou haven\'t added your products to the ShopApp.\n',
                ),
                TextSpan(text: 'Press the '),
                WidgetSpan(
                  child: Icon(Icons.add_rounded),
                ),
                TextSpan(text: ' to add them.')
              ],
            ),
          ),
        ),
      ),
    );
  }
}
