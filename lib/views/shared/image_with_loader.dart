import 'dart:typed_data';
import 'dart:async';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// TODO checkout FutureBuilder
// https://docs.flutter.io/flutter/widgets/FutureBuilder-class.html
// NOTE tried. not that elegant. got weird screen flicker

// TODO cache image
// TODO checkout globalcache pvovided by flutter

class ImageWithLoader extends StatefulWidget {
  final String imgSrc;

  ImageWithLoader(@required this.imgSrc, { Key key }) : super(key: key);

  @override
  ImageWithLoaderState createState() => new ImageWithLoaderState();
}

class ImageWithLoaderState extends State<ImageWithLoader> {
  Widget image;

  @override
  void initState() {
    super.initState();

    _fetchImg();
  }

  @override
  Widget build(BuildContext context) {
    print('************ REBUILDING ImageWithLoader');
    if ( image == null ) {
      return new Container(
        child: const CircularProgressIndicator(),
        alignment: FractionalOffset.center,
      );
    } else {
      return image;
    }
  }

  Future<Null> _fetchImg() async {
    final Uint8List bytes = await http.readBytes(widget.imgSrc);
    setState((){ image = new Image.memory(bytes);});
  }
}
