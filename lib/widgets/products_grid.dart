import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
  final favoritesOnly;

  const ProductsGrid({
    Key? key,
    this.favoritesOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products =
        favoritesOnly ? productsData.favoriteItems : productsData.items;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (ctx, index) {
        return ChangeNotifierProvider.value(
          key: ValueKey(products[index].id),
          value: products[index],
          child: ProductItem(),
        );
      },
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 2 / 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
    );
  }
}
