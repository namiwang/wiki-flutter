import 'package:flutter/material.dart';

import './config/application.dart';

import './views/pages/home.dart';

void main() {
  Application.initApp();

  runApp(new App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Banner(
      message: 'Alpha',
      location: BannerLocation.topEnd,
      textDirection: TextDirection.ltr,
      layoutDirection: TextDirection.ltr,
      child: new MaterialApp(
        title: 'WikiFlutter',
        theme: new ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        home: new PagesHome(),
        onGenerateRoute: Application.router.generator,
      )
    );
  }

}
