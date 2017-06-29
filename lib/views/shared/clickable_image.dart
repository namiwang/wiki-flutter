// import 'package:flutter/material.dart';

// import './image_with_loader.dart';

// class ClickableImage extends StatelessWidget {
//   const ClickableImage(this.imgSrc, { Key key }) : super(key: key);

//   final String imgSrc;

//   @override
//   Widget build(BuildContext context) {
//     assert(debugCheckHasMaterial(context));

//     final GlobalKey<ImageWithLoaderState> _imageStateKey = new GlobalKey<ImageWithLoaderState>();

//     return new InkWell(
//       child: new ImageWithLoader(imgSrc, key: _imageStateKey),
//       onTap: (){
//         Navigator.of(context).push(
//           new MaterialPageRoute<Null>(
//             builder: (BuildContext context) {
//               return new Scaffold(
//                 body: new Container(
//                   child: new ImageWithLoader(imgSrc, key: _imageStateKey),
//                   alignment: FractionalOffset.center,
//                 ),
//               );
//             }
//           )
//         );
//       },
//     );
//   }
// }
