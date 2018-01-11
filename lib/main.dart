import 'package:flutter/material.dart';

import './views/pages/home.dart';
import './views/entries/show.dart';

void main() {
  runApp(new WikiFlutterApp());
}

class WikiFlutterApp extends StatelessWidget {
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
        routes: <String, WidgetBuilder>{
          '/': (BuildContext context) => new PagesHome(),
        },
        onGenerateRoute: _handleRoute,
      )
    );
  }

  Route<Null> _handleRoute(RouteSettings settings) {
    print('--- handling route: ' + settings.toString());

    final List<String> path = settings.name.split('/');

    // /entries/:title
    if ( path.length == 3 && path[0] == '' && path[1] == 'entries' ) {
      final String title = path[2];

      return new MaterialPageRoute<Null>(
        settings: settings,
        builder: (BuildContext context) => new EntriesShow(title: title)
      );
    }

    return null;
  }

}
