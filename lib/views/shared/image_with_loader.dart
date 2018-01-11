import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ImageWithLoader extends StatelessWidget {
  final String imgSrc;

  ImageWithLoader(@required this.imgSrc, { Key key }) : super(key: key);

  Widget build(BuildContext context) {
    return new FadeInImage(
      placeholder: const AssetImage('assets/images/loader.gif'),
      image: new NetworkImage(imgSrc),
    );
  }
}
