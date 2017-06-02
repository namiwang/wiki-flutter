import 'package:flutter/material.dart';

import './views/pages/home.dart';
import './views/entities/show.dart';

void main() {
  runApp(new WikiFlutter());
}

class WikiFlutter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: new PagesHome(),
      home: new EntitiesShow(title: 'Doraemon'),
    );
  }
}
