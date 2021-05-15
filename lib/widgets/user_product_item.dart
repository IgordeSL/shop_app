import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/pages/edit_product_page.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products.dart';

enum UserProductActions { edit, delete }

class UserProductItem extends StatelessWidget {
  const UserProductItem({
    Key? key,
    required this.product,
    required this.productBackgroundColor,
  }) : super(key: key);

  final Product product;
  final Color productBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: productBackgroundColor,
        backgroundImage: NetworkImage(product.imageURL ?? ''),
        onBackgroundImageError: (exception, stackTrace) {},
      ),
      title: Text(product.title ?? ''),
      subtitle: Text(
        product.description ?? '',
        maxLines: 1,
      ),
      trailing: PopupMenuButton(
        offset: const Offset(0, 48),
        itemBuilder: (_) => <PopupMenuEntry<UserProductActions>>[
          PopupMenuItem(
            value: UserProductActions.edit,
            child: Row(
              children: <Widget>[
                Icon(Icons.edit_rounded),
                SizedBox(width: 8),
                Text('Edit'),
              ],
            ),
          ),
          PopupMenuItem(
            value: UserProductActions.delete,
            child: Row(
              children: <Widget>[
                Icon(Icons.delete_rounded),
                SizedBox(width: 8),
                Text('Delete'),
              ],
            ),
          ),
        ],
        onSelected: (UserProductActions value) async {
          switch (value) {
            case UserProductActions.edit:
              Navigator.of(context).pushNamed(
                EditProductPage.routeName,
                arguments: product.id,
              );
              break;
            case UserProductActions.delete:
              if (await _confirmProductDelete(context)) {
                try {
                  await Provider.of<Products>(
                    context,
                    listen: false,
                  ).deleteProduct(product.id);

                  scaffold.showSnackBar(
                    SnackBar(
                      content: Text('${product.title} was deleted'),
                    ),
                  );
                } catch (error) {
                  print('[UserProductItem Widget] onDelete error: $error');

                  scaffold.showSnackBar(
                    SnackBar(
                      content: Text(
                          '${product.title} couldn\'t be deleted and was restored'),
                    ),
                  );
                }
              }
              break;
          }
        },
      ),
    );
  }

  Future<bool> _confirmProductDelete(context) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete your product?'),
        content: Text('${product.title} will be deleted.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Delete'),
          )
        ],
      ),
    ).then((value) => value ?? false);
  }
}
