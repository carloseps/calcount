import 'package:calcount/firebase/meal_food_firebase_data.dart';
import 'package:calcount/model/meal.dart';
import 'package:calcount/providers/user_provider.dart';
import 'package:calcount/screens/account_options_page.dart';
import 'package:calcount/screens/daily_report.dart';
import 'package:calcount/screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavDrawer extends StatefulWidget {
  const NavDrawer({super.key});

  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  List<Meal> _meals = [];
  
  void _fetchData() async {
    MealFoodFirebaseData mealFoodFirebaseData = MealFoodFirebaseData();

    final user_id = Provider.of<UserProvider>(context, listen: false).currentUser!.id;
    await mealFoodFirebaseData.fetchData(user_id!);

    _meals = mealFoodFirebaseData.meals;
  }

  @override
  void initState() {
    super.initState();
     _fetchData();
  }

  _openDailyReportPage(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DailyReport(
          meals: _meals,
        ),
      ),
    );
  }

  _openAccountOptionsPage(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccountOptionsPage(),
      ),
    );
  }

  void _logoutUser(BuildContext context) async {
    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
        ModalRoute.withName('/login'));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.only(top: 96.0),
        children: [
          ListTile(
            leading: const Icon(Icons.insert_chart_outlined_rounded),
            title: const Text('Relatório Diário'),
            onTap: () => {_openDailyReportPage(context)},
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Conta'),
            onTap: () => {_openAccountOptionsPage(context)},
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Sair'),
            onTap: () => _logoutUser(context),
          )
        ],
      ),
    );
  }
}
