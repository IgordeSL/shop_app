import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/orders.dart' as models;
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/order_item.dart';

class OrdersPage extends StatelessWidget {
  static const routeName = '/orders';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your orders'),
      ),
      drawer: AppDrawer(
        selectedRouteName: OrdersPage.routeName,
      ),
      body: FutureBuilder(
        future: Provider.of<models.Orders>(
          context,
          listen: false,
        ).fetchOrders(),
        builder: (ctx, dataSnapshot) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: buildBodyContent(dataSnapshot, context),
          );
        },
      ),
    );
  }

  Widget buildBodyContent(AsyncSnapshot dataSnapshot, BuildContext context) {
    if (dataSnapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Consumer<models.Orders>(
        builder: (ctx, ordersProvider, _) {
          if (dataSnapshot.hasError) {
            return Center(
              child: Column(
                children: <Widget>[
                  Text(
                    'An error happend when loading your orders',
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center,
                  ),
                  FlatButton.icon(
                    onPressed: ordersProvider.fetchOrders,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text('TRY AGAIN'),
                  ),
                ],
              ),
            );
          } else {
            return RefreshIndicator(
              onRefresh: ordersProvider.fetchOrders,
              child: Scrollbar(
                child: SafeArea(
                  child: ListView.separated(
                    itemCount: ordersProvider.orders.length,
                    itemBuilder: (_, index) {
                      return OrderItem(ordersProvider.orders[index]);
                    },
                    separatorBuilder: (_, __) => const Divider(
                      indent: 16,
                      endIndent: 16,
                    ),
                  ),
                ),
              ),
            );
          }
        },
      );
    }
  }
}
