import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:intl/intl.dart';

import 'package:shop_app/providers/orders.dart' as models;
import 'package:shop_app/widgets/cart_item.dart';

class OrderItem extends StatefulWidget {
  final models.OrderItem order;

  OrderItem(this.order);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  AnimationController _animationController;
  Animation<double> _rotateAnimation;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: pi,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text('\$ ${widget.order.totalPrice.toStringAsFixed(2)}'),
          subtitle: Text(
            DateFormat.yMMMd().add_jm().format(widget.order.orderedAt),
          ),
          trailing: IconButton(
            icon: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotateAnimation.value,
                  child: child,
                );
              },
              child: const Icon(Icons.expand_more),
            ),
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;

                if (_isExpanded) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }
              });
            },
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 0,
            maxHeight: 180,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            reverseDuration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (child, animation) => SizeTransition(
              sizeFactor: animation,
              child: child,
              axis: Axis.vertical,
            ),
            child: _isExpanded
                ? Scrollbar(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                      itemBuilder: (_, index) => CartItem(
                        cartItem: widget.order.items[index],
                      ),
                      itemCount: widget.order.items.length,
                    ),
                  )
                : const SizedBox(height: 0),
          ),
        ),
      ],
    );
  }
}
