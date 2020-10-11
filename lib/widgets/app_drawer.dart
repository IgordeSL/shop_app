import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/pages/orders_page.dart';
import 'package:shop_app/pages/products_overview_page.dart';
import 'package:shop_app/pages/user_products_page.dart';
import 'package:shop_app/providers/auth.dart';

class AppDrawer extends StatelessWidget {
  final String selectedRouteName;

  const AppDrawer({@required this.selectedRouteName});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(height: 140),
            _buildListTile(
              context: context,
              title: 'Products',
              icon: Icons.shopping_basket,
              routeName: ProductOverviewPage.routeName,
            ),
            _buildListTile(
              context: context,
              title: 'Orders',
              icon: Icons.local_shipping,
              routeName: OrdersPage.routeName,
            ),
            Divider(
              indent: 64,
              endIndent: 16,
            ),
            _buildListTile(
              context: context,
              title: 'My products',
              icon: Icons.person,
              routeName: UserProductsPage.routeName,
            ),
            Expanded(child: Container()),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/');
                Provider.of<Auth>(context, listen: false).logout();
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'ShopApp',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    @required BuildContext context,
    @required IconData icon,
    @required String routeName,
    @required String title,
  }) {
    return AbsorbPointer(
      absorbing: routeName == selectedRouteName,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: routeName == selectedRouteName
              ? Theme.of(context).primaryColor.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          selected: routeName == selectedRouteName,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 8,
          ),
          onTap: () {
            Navigator.of(context).popAndPushNamed(routeName);
          },
        ),
      ),
    );
  }
}
