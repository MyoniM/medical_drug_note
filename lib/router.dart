import 'package:flutter/material.dart';
import 'package:nest/models/drug_container.dart';

import './screens/home.dart';
import './screens/main_drugs.dart';
import './screens/tree.dart';
import './screens/details.dart';
import './screens/about.dart';

class AppRouter {
  Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Home.routeName:
        return MaterialPageRoute(builder: (ctx) => const Home());

      case MainDrugs.routeName:
        return MaterialPageRoute(builder: (ctx) => const MainDrugs());

      case Tree.routeName:
        return MaterialPageRoute(
            builder: (ctx) =>
                Tree(drugContainer: settings.arguments as DrugContainer));

      case Details.routeName:
        return MaterialPageRoute(
            builder: (ctx) => Details(drugId: settings.arguments as int));

      case About.routeName:
        return MaterialPageRoute(builder: (ctx) => const About());

      default:
        return MaterialPageRoute(builder: (ctx) => const Home());
    }
  }
}
