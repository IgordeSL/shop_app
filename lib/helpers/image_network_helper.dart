import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Widget imageNetworkLoadingBuilder(context, child, progress) {
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
    duration: const Duration(milliseconds: 200),
    child: progress == null &&
            ((child as Semantics).child as RawImage).image != null
        ? child
        : Container(
            height: 300,
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              value: progress?.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes
                  : null,
            ),
          ),
  );
}
