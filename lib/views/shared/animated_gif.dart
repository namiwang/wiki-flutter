// TODO
// - make this a flutter plugin
// - use the platform
//   - android.graphics.Movie
// - BUG alpha composition
// - PERFORMANCE performance is soooo bad
// - speed/FPS
// - play/pause
// - reverse

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:image/image.dart' as image;

class AnimatedGif extends StatefulWidget {
  final Uint8List imgBytes;

  const AnimatedGif(this.imgBytes, { Key key }) : super(key: key);

  @override
  _AnimatedGifState createState() => new _AnimatedGifState();
}

class _AnimatedGifState extends State<AnimatedGif> {
  List<Uint8List> _frames;
  int currentFrameIndex = 0;

  @override
  void initState() {
    super.initState();

    _frames = image.decodeGifAnimation(widget.imgBytes).frames.map((image.Image frame){return image.encodeGif(frame);}).toList();

    if (_frames.length > 1) {
      new Timer.periodic(const Duration(milliseconds: 1000), (Timer timer){
        _updateFrame();
      });
    }
  }

  @override
  Image build(BuildContext context) {
    return new Image.memory(_frames[currentFrameIndex], gaplessPlayback: true);
  }

  void _updateFrame() {
    setState((){
      currentFrameIndex += 1;
      if ( currentFrameIndex >= _frames.length ) {
        currentFrameIndex = 0;
      }
    });
  }
}
