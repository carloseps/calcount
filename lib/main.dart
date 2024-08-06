import 'package:calcount/firebase/firebase_messaging.dart';
import 'package:calcount/firebase_options.dart';
import 'package:calcount/firebase/meal_food_firebase_data.dart';
import 'package:calcount/providers/user_provider.dart';
import 'package:calcount/screens/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseMessagingService().initNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MealFoodFirebaseData()),
        ChangeNotifierProvider(create: (context) => UserProvider())
      ],
      child: ToastificationWrapper(
        child: GetMaterialApp(
          title: 'CalCount',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: LoginPage(),
        ),
      ),
    );
  }
}
