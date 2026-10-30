import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_app/screens/splash_screen.dart';

import 'db/app_db.dart';
import 'screens/auth.dart';
import 'screens/subscription_expired.dart';
import 'screens/shell.dart';
import 'widgets/common.dart';


Future<void> loadPlans() async {
  final plans = await AppDb.i.plans();
  await AppDb.i.setPlans(plans);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const PowerCave());
}

class PowerCave extends StatelessWidget {
  const PowerCave({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Updated branding
      title: 'RTS Gym Manager',

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: orange,
          brightness: Brightness.light,
          primary: orange,
        ),
        scaffoldBackgroundColor: night,
        fontFamily: 'Roboto',
      ),

      // Phone-style layout on desktop/tablet
      builder: (context, child) {
        return ColoredBox(
          color: night,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 480,
              ),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },

      // IMPORTANT:
      // App starts from Splash, NOT Gate.
      home: const SplashScreen(),
    );
  }
}

///
/// Decides where user should go after Splash:
///
/// Session exists -> Dashboard
/// No session     -> Login
///
class Gate extends StatefulWidget {
  const Gate({super.key});

  @override
  State<Gate> createState() => _GateState();
}

class _GateState extends State<Gate> {
  bool? hasSession;
  bool subscriptionExpired = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    var session = false;
    try {
      session = await AppDb.i.hasSession();
      final admin = session ? await AppDb.i.currentAdmin() : null;
      final expired = session && admin?['subscription_active'] != true;

      if (!mounted) return;

      setState(() {
        hasSession = session && !expired;
        subscriptionExpired = expired;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        hasSession = session;
        subscriptionExpired = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (hasSession == null) {
      return const Scaffold(
        backgroundColor: night,
        body: Center(
          child: CircularProgressIndicator(
            color: orange,
          ),
        ),
      );
    }

    if (hasSession!) {
      return const Shell();
    }

    if (subscriptionExpired) {
      return const SubscriptionExpiredScreen();
    }

    return const AuthScreen();
  }
}