import 'package:flutter/material.dart';
import 'package:visiting_card_app/Theme/theme.dart';

import '../../../utils/stream_builder.dart';
import '../../Model/user_profile.dart';
import '../../Widgets/dashboard_buttom_bar.dart';
import '../card_list.dart';
import '../homepage.dart';
import '../scan_method_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final VisitingCard _me = VisitingCard(
    type: CardType.user,
    id: null, // or provide an int if already stored
    fields: {
      'name': 'Kenil Patel',
      'email': 'kenil@example.com',
      'phone': '+91-9876543210',
      'company': 'Abcom Technologies',
      'address': '2ed Stage Halsuru - Bangalore',
    },
    extras: [], // or {} or any additional data if required
    qrData:
        '{"name":"Kenil Patel","email":"kenil@example.com","phone":"+91-9876543210","company":"Abcom Technologies","address":"2ed Stage Halsuru - Bangalore"}',
  );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (StreamUtil.dashboardBottomSubject.value == 1 ||
            StreamUtil.dashboardBottomSubject.value == 2 ||
            StreamUtil.dashboardBottomSubject.value == 3 ||
            StreamUtil.dashboardBottomSubject.value == 4) {
          StreamUtil.dashboardBottomSubject.add(0);
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        bottomNavigationBar: Material(elevation: 25, child: const DashboardBottomBar()),
        body: Container(
          color: AppColors.cream,
          child: StreamBuilder<int>(
            initialData: 0,
            stream: StreamUtil.dashboardBottomSubject,
            builder: (context, snapshot) {
              return snapshot.data == 0
                  ? HomeScreen()
                  : snapshot.data == 1
                  ? ScanMethodsScreen()
                  : CardListScreen();
            },
          ),
        ),
      ),
    );
  }
}
