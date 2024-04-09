import 'package:calcount/components/daily_report.dart';
import 'package:calcount/components/mocked_data.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.only(top: 96.0),
        children: [
          ListTile(
            leading: const Icon(Icons.insert_chart_outlined_rounded),
            title: Text('Relatório Diário'),
            onTap: () => {_openDailyReportPage(context)},
          )
        ],
      ),
    );
  }
}
