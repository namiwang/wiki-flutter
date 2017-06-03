import 'package:flutter/material.dart';

import './views/pages/home.dart';
import './views/entities/show.dart';

void main() {
  // TODO splash-screen
  runApp(new WikiFlutterApp());
}

class WikiFlutterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'WikiFlutter',
      theme: new ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => new PagesHome(),
      },
      onGenerateRoute: _handleRoute,
    );
  }

  Route<Null> _handleRoute(RouteSettings settings) {
    print('--- handling route');
    print(settings);

    // TODO not that elegant

    final List<String> path = settings.name.split('/');

    // /entities/:title
    if ( path.length == 3 && path[0] == '' && path[1] == 'entities' ) {
      final String title = path[2];

      return new MaterialPageRoute<Null>(
        settings: settings,
        builder: (BuildContext context) => new EntitiesShow(title: title)
      );
    }

    return null;
  }

}
