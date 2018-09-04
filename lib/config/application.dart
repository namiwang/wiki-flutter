import 'package:fluro/fluro.dart';

import './routes.dart';

class Application {
  static Router router;

  static initApp() {
    _initRouter();
  }

  static _initRouter() {
    router = new Router();
    Routes.configureRoutes(router);
  }
}
