import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:visiting_card_app/Theme/theme.dart';

import '../utils/stream_builder.dart';

class DashboardBottomBar extends StatefulWidget {
  const DashboardBottomBar({Key? key}) : super(key: key);

  @override
  _DashboardBottomBarState createState() => _DashboardBottomBarState();
}

class _DashboardBottomBarState extends State<DashboardBottomBar> {
  Color color = Colors.red;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: StreamUtil.dashboardBottomSubject,
      builder: (context, snapshot) {
        return Container(
          height: 60.h,
          color: AppColors.cream,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ///Home
              Flexible(
                flex: 1,
                child: InkWell(
                  onTap: () {
                    StreamUtil.dashboardBottomSubject.add(0);
                    print(StreamUtil.dashboardBottomSubject.value.toString());
                  },
                  child: Container(
                    width: 60.w,
                    height: 60.h,

                    padding: EdgeInsets.all(4.r),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person, size: 22.h, color: snapshot.data == 0 ? AppColors.lightPurple : AppColors.black),
                        Text(
                          'Home',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: snapshot.data == 0 ? AppColors.lightPurple : AppColors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              ///Scan
              Flexible(
                flex: 1,
                child: InkWell(
                  onTap: () {
                    StreamUtil.dashboardBottomSubject.add(1);
                    print(StreamUtil.dashboardBottomSubject.value);
                  },
                  child: Container(
                    width: 60.w,
                    height: 60.h,

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_scanner, size: 22.h, color: snapshot.data == 1 ? AppColors.lightPurple : AppColors.black),
                        Text(
                          'Scan',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: snapshot.data == 1 ? AppColors.lightPurple : AppColors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              ///List
              Flexible(
                flex: 1,
                child: InkWell(
                  onTap: () {
                    StreamUtil.dashboardBottomSubject.add(2);
                    print(StreamUtil.dashboardBottomSubject.value);
                  },
                  child: Container(
                    width: 60.w,
                    height: 60.h,

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.list, size: 22.h, color: snapshot.data == 2 ? AppColors.lightPurple : AppColors.black),
                        Text(
                          'List',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: snapshot.data == 2 ? AppColors.lightPurple : AppColors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
