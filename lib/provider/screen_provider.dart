import 'package:flutter/material.dart';

class RouteArgument {
  final String? routeName;
  final String? id;

  RouteArgument({required this.routeName, required this.id});
}

class ScreenProvider with ChangeNotifier {
  RouteArgument? _routeArguemnt;

  RouteArgument? get routeArguemnt {
    final re = _routeArguemnt;
    _routeArguemnt = null;
    return re;
  }

  void setRouteArgument(RouteArgument arg) {
    _routeArguemnt = arg;
  }
}
