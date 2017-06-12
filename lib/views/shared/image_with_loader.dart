import 'dart:typed_data';
import 'dart:async';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import 'package:flutter_animated/animated_gif.dart';

// TODO checkout FutureBuilder
// https://docs.flutter.io/flutter/widgets/FutureBuilder-class.html

// TODO progress percentage

class ImageWithLoader extends StatefulWidget {
  final String imgSrc;

  ImageWithLoader(this.imgSrc, { Key key }) : super(key: key);

  @override
  _ImageWithLoaderState createState() => new _ImageWithLoaderState();
}

class _ImageWithLoaderState extends State<ImageWithLoader> {
  Uint8List imgBytes;

  @override
  void initState() {
    super.initState();

    _fetchImg();
  }

  @override
  Widget build(BuildContext context) {
    if ( imgBytes == null ) {
      return new Container(
        child: const CircularProgressIndicator(),
        alignment: FractionalOffset.center,
      );
    }

    if ( widget.imgSrc.endsWith('.gif') ) {
      return new AnimatedGif(imgBytes);
    } else {
      return new Image.memory(imgBytes);
    }
  }

  Future<Null> _fetchImg() async {
    final bytes = await http.readBytes(widget.imgSrc);
    setState((){ imgBytes = bytes; });
  }
}
