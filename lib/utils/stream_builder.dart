import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class StreamUtil {
  static BehaviorSubject<int> dashboardBottomSubject = BehaviorSubject<int>.seeded(0);
}
