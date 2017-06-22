import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PagesFullImage extends StatelessWidget {
  const PagesFullImage({ Key key, @required this.image }) : super(key: key);

  final Widget image;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Hero(
        tag: image,
        child: new Container(
          child: image,
          alignment: FractionalOffset.center,
        ),
      ),
    );
  }
}
