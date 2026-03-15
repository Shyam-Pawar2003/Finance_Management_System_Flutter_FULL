import 'package:flutter/material.dart';

class NavItemData {
  const NavItemData({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class DashboardMetric {
  const DashboardMetric({
    required this.title,
    required this.value,
    required this.caption,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final String caption;
  final Color color;
  final IconData icon;
}

class UserTask {
  const UserTask({
    required this.title,
    required this.status,
    required this.dueDate,
    required this.priority,
  });

  final String title;
  final String status;
  final String dueDate;
  final String priority;
}

class QuickActionData {
  const QuickActionData({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

class UpcomingEvent {
  const UpcomingEvent({
    required this.title,
    required this.time,
    required this.tag,
  });

  final String title;
  final String time;
  final String tag;
}

class AttendanceDay {
  const AttendanceDay({required this.day, required this.value});

  final String day;
  final double value;
}
