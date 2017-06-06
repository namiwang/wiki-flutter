// TODO
// - BUG firstFrame not showing
// - FREEZING
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
  List<Image> _frames = [];
  int currentFrameIndex = 0;

  @override
  void initState() {
    super.initState();

    _frames = [ new Image.memory( widget.imgBytes ) ];

    // TODO BUGGY
    // Timer.run(_play);
  }

  @override
  Image build(BuildContext context) {
    return _frames[currentFrameIndex];
  }

  void _play() {
    _extractFrames().then((List frames){
      _frames = frames;

      new Timer.periodic(const Duration(seconds: 1), (Timer timer){_updateFrame();});
    });
  }

  Future<List<Image>> _extractFrames() async {
    return image.decodeGifAnimation(widget.imgBytes).frames.map((image.Image frame){
      return new Image.memory(image.encodeGif(frame), gaplessPlayback: true);
    }).toList();
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
