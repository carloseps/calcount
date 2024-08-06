import 'package:calcount/screens/account_options_page.dart';
import 'package:calcount/screens/daily_report.dart';
import 'package:calcount/components/mocked_data.dart';
import 'package:calcount/screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  _openDailyReportPage(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DailyReport(
          meals: meals,
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
