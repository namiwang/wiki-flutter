import 'dart:typed_data';
import 'dart:async';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import 'package:flutter_animated/animated_gif.dart';

// TODO checkout FutureBuilder
// https://docs.flutter.io/flutter/widgets/FutureBuilder-class.html
// NOTE tried. not that elegant. got weird screen flicker

// TODO progress percentage

// TODO cache image
// TODO checkout globalcache pvovided by flutter

class ImageWithLoader extends StatefulWidget {
  final String imgSrc;

  ImageWithLoader(this.imgSrc, { Key key }) : super(key: key);

  @override
  _ImageWithLoaderState createState() => new _ImageWithLoaderState();
}

class _ImageWithLoaderState extends State<ImageWithLoader> {
  Widget image;

  @override
  void initState() {
    super.initState();

    _fetchImg();
  }

  @override
  Widget build(BuildContext context) {
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
    final bytes = await http.readBytes(widget.imgSrc);
    if ( widget.imgSrc.endsWith('.gif') ) {
      setState((){ image = new AnimatedGif.memory(bytes); });
    } else {
      setState((){ image = new Image.memory(bytes); });
    }
  }
}
