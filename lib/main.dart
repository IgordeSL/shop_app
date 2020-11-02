import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/helpers/custom_route.dart';
import 'package:shop_app/pages/auth_page.dart';
import 'package:shop_app/pages/cart_page.dart';
import 'package:shop_app/pages/edit_product_page.dart';
import 'package:shop_app/pages/products_overview_page.dart';
import 'package:shop_app/pages/user_products_page.dart';
import 'package:shop_app/pages/orders_page.dart';
import 'package:shop_app/pages/product_detail_page.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/providers/products.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appThemeData = ThemeData(
      primarySwatch: Colors.purple,
      accentColor: Colors.deepOrangeAccent,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      fontFamily: 'Lato',
      textTheme: const TextTheme(
        headline1: TextStyle(
          fontFamily: 'Raleway',
          fontWeight: FontWeight.bold,
        ),
        headline2: TextStyle(
          fontFamily: 'Raleway',
          fontWeight: FontWeight.bold,
        ),
        headline3: TextStyle(
          fontFamily: 'Raleway',
          fontWeight: FontWeight.bold,
        ),
        headline4: TextStyle(
          fontFamily: 'Raleway',
          fontWeight: FontWeight.bold,
        ),
        headline5: TextStyle(
          fontFamily: 'Raleway',
          fontWeight: FontWeight.bold,
        ),
        headline6: TextStyle(
          fontFamily: 'Raleway',
          fontWeight: FontWeight.bold,
        ),
        button: TextStyle(
          fontFamily: 'Raleway',
          fontWeight: FontWeight.bold,
        ),
      ),
      appBarTheme: const AppBarTheme(
        textTheme: TextTheme(
          headline6: TextStyle(
            fontFamily: 'Raleway',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        height: 40,
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 16,
        ),
      ),
      dividerTheme: DividerThemeData(
        thickness: 2,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CustomPageTransitionBuilder(),
        },
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: null,
          update: (context, auth, previous) => previous != null
              ? (previous
                ..token = auth.token
                ..userId = auth.userId)
              : Products(token: auth.token, userId: auth.userId),
        ),
        ChangeNotifierProvider(
          create: (context) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: null,
          update: (context, auth, previous) => previous != null
              ? (previous
                ..token = auth.token
                ..userId = auth.userId)
              : Orders(
                  token: auth.token,
                  userId: auth.userId,
                ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (context, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: appThemeData,
          home: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: auth.isAuthenticated
                ? ProductOverviewPage()
                : FutureBuilder(
                    future: auth.getLoginData(),
                    builder: (context, snapshot) {
                      return snapshot.connectionState == ConnectionState.waiting
                          ? Container(
                              color: appThemeData.scaffoldBackgroundColor,
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator())
                          : AuthPage();
                    },
                  ),
          ),
          routes: {
            //ProductOverviewPage.routeName: (ctx) => ProductOverviewPage(),
            UserProductsPage.routeName: (ctx) => UserProductsPage(),
            ProductDetailPage.routeName: (ctx) => ProductDetailPage(),
            CartPage.routeName: (ctx) => CartPage(),
            OrdersPage.routeName: (ctx) => OrdersPage(),
            EditProductPage.routeName: (ctx) => EditProductPage(),
          },
        ),
      ),
    );
  }
}
