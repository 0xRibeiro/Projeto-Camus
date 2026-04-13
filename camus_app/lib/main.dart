import 'package:flutter/material.dart';
import 'package:camus_app/config/dependencies.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:routefly/routefly.dart';

import 'main.route.dart';
part 'main.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  setupDependencies();
  runApp(const CamusApp());
}

@Main('lib/ui/')
class CamusApp extends StatelessWidget {
  const CamusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: Routefly.routerConfig(
        routes: routes,
        initialPath: '/auth/register'
        ),
    );
  }
}
