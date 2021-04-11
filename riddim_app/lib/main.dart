import 'Router.dart';
import 'package:flutter/material.dart';
import 'Screen/SplashScreen/SplashScreen.dart';
import 'theme/style.dart';

void main() => runApp(RiddimApp());

class RiddimApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Riddim',
      theme: appTheme,
      onGenerateRoute: (RouteSettings settings) => getRoute(settings),
      home: SplashScreen(),
    );
  }
}