import 'package:flutter/material.dart';
import 'package:riddim_app/Screen/Home/home2.dart';
import 'package:riddim_app/Screen/SignUp/signup.dart';
import 'package:riddim_app/Screen/ReviewTrip/reviewTrip.dart';
import 'package:riddim_app/Screen/Trips/trips.dart';
import 'package:riddim_app/Screen/Upcoming/upcoming.dart';
import 'package:riddim_app/Screen/Walkthrough/walkthrough.dart';
import 'package:riddim_app/Screen/Login/login.dart';
import 'package:riddim_app/Screen/History/history.dart';
import 'package:riddim_app/Screen/Home/home.dart';

import 'Screen/MyProfile/myProfile.dart';
import 'Screen/MyProfile/profile.dart';
import 'Screen/PaymentMethod/paymentMethod.dart';
import 'Screen/Settings/settings.dart';

class MyCustomRoute<T> extends MaterialPageRoute<T> {
  MyCustomRoute({ WidgetBuilder builder, RouteSettings settings })
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (settings.isInitialRoute) return child;
    if (animation.status == AnimationStatus.reverse)
      return super.buildTransitions(context, animation, secondaryAnimation, child);
    return FadeTransition(opacity: animation, child: child);
  }
}

MaterialPageRoute getRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/login': return new MyCustomRoute(
      builder: (_) => LoginScreen(),
      settings: settings,
    );
    case '/signup': return new MyCustomRoute(
      builder: (_) => new SignupScreen(),
      settings: settings,
    );
    case '/home': return new MyCustomRoute(
      builder: (_) => new HomeScreen(),
      settings: settings,
    );
    case '/home2': return new MyCustomRoute(
      builder: (_) => new HomeScreen2(),
      settings: settings,
    );
    case '/forgot_password': return new MyCustomRoute(
      builder: (_) => new HomeScreen2(),
      settings: settings,
    );
    case '/review_trip': return new MyCustomRoute(
      builder: (_) => ReviewTripScreens(),
      settings: settings,
    );
    case '/walkthrough': return new MyCustomRoute(
      builder: (_) => WalkThroughScreen(),
      settings: settings,
    );
    case '/history': return new MyCustomRoute(
      builder: (_) => HistoryScreen(),
      settings: settings,
    );
    case '/upcoming': return new MyCustomRoute(
      builder: (_) => UpcomingScreen(),
      settings: settings,
    );
    case '/mytrips': return new MyCustomRoute(
      builder: (_) => TripScreen(),
      settings: settings,
    );
    case '/setting': return new MyCustomRoute(
      builder: (_) => new SettingsScreen(),
      settings: settings,
    );
    case '/profile': return new MyCustomRoute(
      builder: (_) => new Profile(),
      settings: settings,
    );
    case '/edit_prifile': return new MyCustomRoute(
      builder: (_) => new MyProfile(),
      settings: settings,
    );
    case '/paymentmethod': return new MyCustomRoute(
      builder: (_) => new PaymentMethod(),
      settings: settings,
    );
    default:
      return new MyCustomRoute(
        builder: (_) => new HomeScreen(),
        settings: settings,
      );
  }
}