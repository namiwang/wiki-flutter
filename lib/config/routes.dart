import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import '../views/entries/show.dart';

class Routes {
  static void configureRoutes(Router router) {
    router.notFoundHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      // TODO handle error via sentry
      throw "ROUTE NOT FOUND";
    });

    router.define("/entries/:title", handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      final title = params['title'][0];
      return new EntriesShow(title: title);
    }));

  }
}
